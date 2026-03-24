import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Scoring constants (from PRD §5.5)
const BASE_POINTS: Record<string, number> = { easy: 100, medium: 150, hard: 220 };
const TIME_BONUS_PER_SECOND = 5;
const MAX_RESPONSE_SECONDS = 30;

interface AnswerInput {
  question_id: string;
  selected_index: number | null;
  response_seconds: number;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  // ── Auth: validate caller JWT using the canonical Supabase edge-function pattern ──
  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) {
    return errorResponse(401, "Missing or invalid Authorization header");
  }

  const userClient = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: { user }, error: authErr } = await userClient.auth.getUser();
  if (authErr || !user) {
    console.error("[submit_daily_attempt] Auth failed:", authErr?.message ?? "no user");
    return errorResponse(401, "Invalid or expired session");
  }
  const userId = user.id;
  // Admin client for privileged DB operations
  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  // ── Parse body ────────────────────────────────────────────────────────────
  let body: { attempt_id?: string; answers?: AnswerInput[] };
  try {
    body = await req.json();
  } catch {
    return errorResponse(400, "Invalid JSON body");
  }

  const { attempt_id: attemptId, answers } = body;
  if (!attemptId || !Array.isArray(answers) || answers.length === 0) {
    return errorResponse(400, "attempt_id and answers[] are required");
  }

  // ── Validate attempt ownership and state ──────────────────────────────────
  const { data: attempt, error: attErr } = await admin
    .from("daily_attempts")
    .select("id, user_id, quiz_date, status")
    .eq("id", attemptId)
    .maybeSingle();

  if (attErr || !attempt) {
    return errorResponse(404, "Attempt not found");
  }
  if (attempt.user_id !== userId) {
    return errorResponse(403, "Forbidden");
  }
  if (attempt.status !== "in_progress") {
    return errorResponse(409, `Attempt already ${attempt.status}`);
  }

  // ── Fetch correct answers for the quiz ────────────────────────────────────
  const { data: quiz } = await admin
    .from("daily_quizzes")
    .select("id")
    .eq("quiz_date", attempt.quiz_date)
    .eq("status", "published")
    .maybeSingle();

  if (!quiz) {
    return errorResponse(404, "Published quiz not found for this attempt");
  }

  const { data: questions, error: qErr } = await admin
    .from("daily_quiz_questions")
    .select("id, correct_index, difficulty")
    .eq("daily_quiz_id", quiz.id);

  if (qErr || !questions) {
    return errorResponse(500, "Failed to fetch quiz questions");
  }

  const questionMap = new Map(questions.map((q) => [q.id, q]));
  const expectedQuestionIds = new Set(questions.map((q) => q.id));

  // Strict contract: exactly one answer for every quiz question (10 total), no duplicates.
  if (answers.length !== questions.length) {
    return errorResponse(400, `answers must contain exactly ${questions.length} items`);
  }
  const providedIds = answers.map((a) => a.question_id);
  const uniqueProvidedIds = new Set(providedIds);
  if (uniqueProvidedIds.size !== providedIds.length) {
    return errorResponse(400, "Duplicate question_id values are not allowed");
  }
  for (const qid of providedIds) {
    if (!expectedQuestionIds.has(qid)) {
      return errorResponse(400, "answers contain question_id not present in this quiz");
    }
  }

  // ── Score each answer ─────────────────────────────────────────────────────
  let totalPoints = 0;
  let totalTime = 0;
  let correctCount = 0;

  const answerRows = answers.map((a: AnswerInput) => {
    const q = questionMap.get(a.question_id)!;

    // Clamp response_seconds to [0, MAX_RESPONSE_SECONDS]
    const secs = Math.max(0, Math.min(MAX_RESPONSE_SECONDS, Number(a.response_seconds) || 0));
    const isCorrect = a.selected_index !== null && a.selected_index === q.correct_index;

    const base = BASE_POINTS[q.difficulty] ?? BASE_POINTS.medium;
    const timeBonus = isCorrect ? Math.max(0, MAX_RESPONSE_SECONDS - secs) * TIME_BONUS_PER_SECOND : 0;
    const points = isCorrect ? base + timeBonus : 0;

    totalPoints += points;
    totalTime += secs;
    if (isCorrect) correctCount++;

    return {
      attempt_id: attemptId,
      question_id: a.question_id,
      selected_index: a.selected_index ?? null,
      response_seconds: secs,
      is_correct: isCorrect,
      awarded_points: Math.round(points),
    };
  });

  // ── Persist answers ───────────────────────────────────────────────────────
  const { error: ansErr } = await admin.from("daily_attempt_answers").insert(answerRows);
  if (ansErr) {
    return errorResponse(500, `Failed to save answers: ${ansErr.message}`);
  }

  // ── Update attempt status ─────────────────────────────────────────────────
  await admin
    .from("daily_attempts")
    .update({ status: "submitted", submitted_at: new Date().toISOString() })
    .eq("id", attemptId);

  // ── Upsert score row ──────────────────────────────────────────────────────
  const { error: scoreErr } = await admin.from("daily_quiz_scores").insert({
    user_id: userId,
    quiz_date: attempt.quiz_date,
    attempt_id: attemptId,
    total_points: Math.round(totalPoints),
    total_time_seconds: parseFloat(totalTime.toFixed(2)),
    correct_count: correctCount,
  });

  if (scoreErr) {
    console.error("[submit_daily_attempt] Score insert error:", scoreErr.message);
  }

  // ── Upsert all-time leaderboard ───────────────────────────────────────────
  const { data: existing } = await admin
    .from("quiz_leaderboard_all_time")
    .select("total_points, total_attempts")
    .eq("user_id", userId)
    .maybeSingle();

  await admin.from("quiz_leaderboard_all_time").upsert(
    {
      user_id: userId,
      total_points: (existing?.total_points ?? 0) + Math.round(totalPoints),
      total_attempts: (existing?.total_attempts ?? 0) + 1,
      updated_at: new Date().toISOString(),
    },
    { onConflict: "user_id" },
  );

  // ── Compute daily rank for caller ─────────────────────────────────────────
  // Count scores that are strictly better (higher points, or equal points + lower time)
  const { count: betterCount } = await admin
    .from("daily_quiz_scores")
    .select("id", { count: "exact", head: true })
    .eq("quiz_date", attempt.quiz_date)
    .or(
      `total_points.gt.${Math.round(totalPoints)},` +
      `and(total_points.eq.${Math.round(totalPoints)},total_time_seconds.lt.${parseFloat(totalTime.toFixed(2))})`,
    );

  const dailyRank = (betterCount ?? 0) + 1;

  // Cache rank on score row
  await admin
    .from("daily_quiz_scores")
    .update({ rank_cached: dailyRank })
    .eq("attempt_id", attemptId);

  return jsonResponse(200, {
    total_points: Math.round(totalPoints),
    correct_count: correctCount,
    total_time_seconds: parseFloat(totalTime.toFixed(2)),
    daily_rank: dailyRank,
    quiz_date: attempt.quiz_date,
  });
});

// ─── Helpers ─────────────────────────────────────────────────────────────────

function jsonResponse(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}

function errorResponse(status: number, message: string): Response {
  return jsonResponse(status, { error: message });
}
