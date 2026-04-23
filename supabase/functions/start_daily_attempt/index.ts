import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const FREE_ATTEMPT_CAP = 1;
const PRO_ATTEMPT_CAP = 3;

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

  // Create a user-scoped client so auth.getUser() validates against the incoming JWT.
  const userClient = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: { user }, error: authErr } = await userClient.auth.getUser();
  if (authErr || !user) {
    console.error("[start_daily_attempt] Auth failed:", authErr?.message ?? "no user");
    return errorResponse(401, "Invalid or expired session");
  }

  const userId = user.id;
  // Admin client for privileged DB operations
  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  // ── Parse body ────────────────────────────────────────────────────────────
  let body: { quiz_date?: string } = {};
  try {
    body = await req.json();
  } catch { /* empty body is fine */ }

  // Default to today in IST
  const quizDate = body.quiz_date ?? todayIST();

  // ── Check attempt cap ────────────────────────────────────────────────────
  const { data: entitlement } = await admin
    .from("user_entitlements")
    .select("is_pro")
    .eq("user_id", userId)
    .maybeSingle();

  // `is_pro` is the DB column for Premium (paid tier).
  const hasPremium = entitlement?.is_pro === true;
  const cap = hasPremium ? PRO_ATTEMPT_CAP : FREE_ATTEMPT_CAP;

  const { count: usedCount } = await admin
    .from("daily_attempts")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
    .eq("quiz_date", quizDate);

  const used = usedCount ?? 0;
  if (used >= cap) {
    return errorResponse(403, `Attempt limit reached (${used}/${cap} today)`);
  }

  // ── Fetch today's published quiz ──────────────────────────────────────────
  const { data: quiz, error: quizErr } = await admin
    .from("daily_quizzes")
    .select("id")
    .eq("quiz_date", quizDate)
    .eq("status", "published")
    .maybeSingle();

  if (quizErr || !quiz) {
    return errorResponse(404, `No published daily quiz found for ${quizDate}`);
  }

  // ── Fetch questions (without correct_index) ───────────────────────────────
  const { data: questions, error: qErr } = await admin
    .from("daily_quiz_questions")
    .select("id, position, prompt, options, difficulty")
    .eq("daily_quiz_id", quiz.id)
    .order("position", { ascending: true });

  if (qErr || !questions || questions.length === 0) {
    return errorResponse(500, "Failed to load quiz questions");
  }

  // ── Create attempt row ────────────────────────────────────────────────────
  const attemptNo = used + 1;
  const { data: attempt, error: attErr } = await admin
    .from("daily_attempts")
    .insert({
      user_id: userId,
      quiz_date: quizDate,
      attempt_no: attemptNo,
      status: "in_progress",
    })
    .select("id")
    .single();

  if (attErr || !attempt) {
    return errorResponse(500, `Failed to create attempt: ${attErr?.message}`);
  }

  return jsonResponse(200, {
    attempt_id: attempt.id,
    attempt_no: attemptNo,
    remaining_attempts: cap - attemptNo,
    quiz_date: quizDate,
    questions: questions.map((q) => ({
      id: q.id,
      position: q.position,
      prompt: q.prompt,
      options: q.options,
      difficulty: q.difficulty,
      // correct_index intentionally omitted
    })),
  });
});

// ─── Helpers ─────────────────────────────────────────────────────────────────

function todayIST(): string {
  const nowIST = new Date(Date.now() + 5.5 * 60 * 60 * 1000);
  return nowIST.toISOString().slice(0, 10);
}

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
