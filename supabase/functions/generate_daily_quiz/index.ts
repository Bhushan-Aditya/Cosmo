import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { createHash } from "node:crypto";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!;
const GEMINI_MODEL = "gemini-2.5-flash";
const GEMINI_ENDPOINT = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`;

const MAX_RETRIES = 3;
const CANDIDATE_COUNT = 14; // ask for 14, pick best 10 after validation
const TARGET_COUNT = 10;

// ─── Types ───────────────────────────────────────────────────────────────────

interface RawQuestion {
  prompt: string;
  options: string[];
  correct_index: number;
  difficulty: "easy" | "medium" | "hard";
  explanation: string;
  sources: string[];
}

interface ValidatedQuestion extends RawQuestion {
  question_hash: string;
}

// ─── Gemini generation ───────────────────────────────────────────────────────

async function generateCandidates(existingHashes: Set<string>): Promise<ValidatedQuestion[]> {
  const prompt = `You are a space and astronomy quiz master. Generate ${CANDIDATE_COUNT} unique multiple-choice questions about astronomy, cosmology, space exploration, or astrophysics.

Requirements for EACH question:
- Exactly 4 answer options (options array)
- Exactly one correct answer (correct_index: 0-3)
- A difficulty tag: "easy", "medium", or "hard"
- A clear explanation (2-3 sentences)
- At least one source URL (NASA, ESA, arXiv, Wikipedia astronomy pages, etc.)
- The question must be factual, not opinion-based
- No trick questions; the correct answer must be unambiguous

Return a JSON array (no markdown fences, raw JSON only) with this exact schema:
[
  {
    "prompt": "string",
    "options": ["string", "string", "string", "string"],
    "correct_index": 0,
    "difficulty": "easy",
    "explanation": "string",
    "sources": ["https://example.com"]
  }
]`;

  const res = await fetch(GEMINI_ENDPOINT, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { temperature: 0.7, maxOutputTokens: 8192 },
    }),
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Gemini API error ${res.status}: ${err}`);
  }

  const data = await res.json();
  const text: string = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

  // Strip markdown fences if present
  const jsonText = text.replace(/^```(?:json)?\s*/i, "").replace(/\s*```$/, "").trim();
  let raw: unknown[];
  try {
    raw = JSON.parse(jsonText);
  } catch {
    throw new Error(`Failed to parse Gemini response as JSON: ${text.slice(0, 200)}`);
  }

  const validated: ValidatedQuestion[] = [];
  for (const item of raw) {
    const q = item as Record<string, unknown>;
    if (!validateRaw(q)) continue;

    const hash = hashQuestion(q.prompt as string, q.options as string[]);
    if (existingHashes.has(hash)) continue; // skip duplicate

    validated.push({
      prompt: q.prompt as string,
      options: q.options as string[],
      correct_index: q.correct_index as number,
      difficulty: q.difficulty as "easy" | "medium" | "hard",
      explanation: q.explanation as string,
      sources: q.sources as string[],
      question_hash: hash,
    });
  }

  return validated;
}

function validateRaw(q: Record<string, unknown>): boolean {
  if (typeof q.prompt !== "string" || q.prompt.trim().length < 10) return false;
  if (!Array.isArray(q.options) || q.options.length !== 4) return false;
  if (q.options.some((o) => typeof o !== "string" || o.trim().length === 0)) return false;
  if (typeof q.correct_index !== "number" || q.correct_index < 0 || q.correct_index > 3) return false;
  if (!["easy", "medium", "hard"].includes(q.difficulty as string)) return false;
  if (typeof q.explanation !== "string" || q.explanation.trim().length < 10) return false;
  if (!Array.isArray(q.sources) || q.sources.length === 0) return false;
  return true;
}

function hashQuestion(prompt: string, options: string[]): string {
  const canonical = [prompt.toLowerCase().trim(), ...options.map((o) => o.toLowerCase().trim())].join("|");
  return createHash("sha256").update(canonical).digest("hex");
}

// ─── Handler ─────────────────────────────────────────────────────────────────

Deno.serve(async (req) => {
  // Allow health-check GET
  if (req.method === "GET") {
    return new Response(JSON.stringify({ ok: true }), { status: 200 });
  }

  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  // Optional override for manual backfill/testing. Otherwise default to tomorrow in IST.
  let requestedQuizDate: string | undefined;
  try {
    const body = await req.json();
    if (body && typeof body.quiz_date === "string") {
      requestedQuizDate = body.quiz_date;
    }
  } catch {
    // empty/non-JSON body is fine
  }

  let quizDate: string;
  if (requestedQuizDate) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(requestedQuizDate)) {
      return new Response(
        JSON.stringify({ ok: false, error: "quiz_date must be in YYYY-MM-DD format" }),
        { status: 400 },
      );
    }
    quizDate = requestedQuizDate;
  } else {
    const nowIST = new Date(Date.now() + 5.5 * 60 * 60 * 1000);
    const tomorrow = new Date(nowIST);
    tomorrow.setUTCDate(tomorrow.getUTCDate() + 1);
    quizDate = tomorrow.toISOString().slice(0, 10);
  }

  // Idempotency: skip if already published for this date
  const { data: existing } = await supabase
    .from("daily_quizzes")
    .select("id, status")
    .eq("quiz_date", quizDate)
    .maybeSingle();

  if (existing?.status === "published") {
    return new Response(
      JSON.stringify({ ok: true, message: `Quiz for ${quizDate} already published` }),
      { status: 200 },
    );
  }

  // Fetch all existing question hashes for dedup
  const { data: hashes } = await supabase
    .from("daily_quiz_questions")
    .select("question_hash");
  const existingHashes = new Set<string>((hashes ?? []).map((r: { question_hash: string }) => r.question_hash));

  let questions: ValidatedQuestion[] = [];
  let lastError = "";

  for (let attempt = 0; attempt < MAX_RETRIES; attempt++) {
    try {
      const candidates = await generateCandidates(existingHashes);
      if (candidates.length >= TARGET_COUNT) {
        questions = candidates.slice(0, TARGET_COUNT);
        break;
      }
      lastError = `Only ${candidates.length} valid unique candidates generated (need ${TARGET_COUNT})`;
    } catch (err) {
      lastError = String(err);
    }
  }

  // Insert quiz row (draft → published on success, failed on error)
  const status = questions.length >= TARGET_COUNT ? "published" : "failed";

  const { data: quiz, error: quizErr } = await supabase
    .from("daily_quizzes")
    .upsert({
      quiz_date: quizDate,
      status,
      question_set_version: (existing?.status ? 2 : 1),
      published_at: status === "published" ? new Date().toISOString() : null,
    }, { onConflict: "quiz_date" })
    .select("id")
    .single();

  if (quizErr || !quiz) {
    return new Response(
      JSON.stringify({ ok: false, error: quizErr?.message ?? "Failed to upsert daily_quizzes" }),
      { status: 500 },
    );
  }

  if (status === "failed") {
    console.error(`[generate_daily_quiz] Failed for ${quizDate}: ${lastError}`);
    return new Response(
      JSON.stringify({ ok: false, error: lastError }),
      { status: 500 },
    );
  }

  // Idempotency hardening: replace prior question set for this quiz_date before insert.
  // This allows safe re-runs for the same date without hitting (daily_quiz_id, position) conflicts.
  const { error: deleteErr } = await supabase
    .from("daily_quiz_questions")
    .delete()
    .eq("daily_quiz_id", quiz.id);
  if (deleteErr) {
    await supabase.from("daily_quizzes").update({ status: "failed" }).eq("id", quiz.id);
    return new Response(
      JSON.stringify({ ok: false, error: `Failed to clear prior question set: ${deleteErr.message}` }),
      { status: 500 },
    );
  }

  // Insert replacement questions
  const rows = questions.map((q, i) => ({
    daily_quiz_id: quiz.id,
    position: i + 1,
    prompt: q.prompt,
    options: q.options,
    correct_index: q.correct_index,
    difficulty: q.difficulty,
    explanation: q.explanation,
    sources: q.sources,
    question_hash: q.question_hash,
  }));

  const { error: qErr } = await supabase.from("daily_quiz_questions").insert(rows);

  if (qErr) {
    // Roll back quiz to failed
    await supabase.from("daily_quizzes").update({ status: "failed" }).eq("id", quiz.id);
    return new Response(
      JSON.stringify({ ok: false, error: qErr.message }),
      { status: 500 },
    );
  }

  console.log(`[generate_daily_quiz] Published ${TARGET_COUNT} questions for ${quizDate}`);
  return new Response(
    JSON.stringify({ ok: true, quiz_date: quizDate, question_count: TARGET_COUNT }),
    { status: 200 },
  );
});
