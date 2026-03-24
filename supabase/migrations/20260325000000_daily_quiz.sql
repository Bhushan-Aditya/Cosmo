-- Daily Quiz system: tables, indexes, RLS, leaderboard views, and pg_cron schedule
-- Created: 2026-03-25

-- ─────────────────────────────────────────────
-- 1) Daily quiz manifest (one row per day)
-- ─────────────────────────────────────────────
create table if not exists public.daily_quizzes (
  id                   uuid primary key default gen_random_uuid(),
  quiz_date            date not null unique,
  status               text not null default 'draft'
                         check (status in ('draft', 'published', 'failed')),
  question_set_version integer not null default 1,
  created_at           timestamptz not null default timezone('utc', now()),
  published_at         timestamptz
);

-- ─────────────────────────────────────────────
-- 2) Questions belonging to a daily quiz
-- ─────────────────────────────────────────────
create table if not exists public.daily_quiz_questions (
  id             uuid primary key default gen_random_uuid(),
  daily_quiz_id  uuid not null references public.daily_quizzes(id) on delete cascade,
  position       integer not null check (position between 1 and 10),
  prompt         text not null,
  options        jsonb not null,   -- array of 4 strings
  correct_index  integer not null check (correct_index between 0 and 3),
  difficulty     text not null check (difficulty in ('easy', 'medium', 'hard')),
  explanation    text,
  sources        jsonb not null default '[]'::jsonb,
  question_hash  text not null unique,
  created_at     timestamptz not null default timezone('utc', now()),
  unique (daily_quiz_id, position)
);

-- ─────────────────────────────────────────────
-- 3) Per-user daily attempt records
-- ─────────────────────────────────────────────
create table if not exists public.daily_attempts (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  quiz_date    date not null,
  attempt_no   integer not null check (attempt_no >= 1),
  started_at   timestamptz not null default timezone('utc', now()),
  submitted_at timestamptz,
  status       text not null default 'in_progress'
                 check (status in ('in_progress', 'submitted', 'expired')),
  unique (user_id, quiz_date, attempt_no)
);

-- ─────────────────────────────────────────────
-- 4) Per-answer breakdown for each attempt
-- ─────────────────────────────────────────────
create table if not exists public.daily_attempt_answers (
  id               uuid primary key default gen_random_uuid(),
  attempt_id       uuid not null references public.daily_attempts(id) on delete cascade,
  question_id      uuid not null references public.daily_quiz_questions(id) on delete cascade,
  selected_index   integer check (selected_index between 0 and 3), -- null = unanswered/timed-out
  response_seconds numeric(5,2) not null check (response_seconds >= 0 and response_seconds <= 30),
  is_correct       boolean not null,
  awarded_points   integer not null check (awarded_points >= 0),
  unique (attempt_id, question_id)
);

-- ─────────────────────────────────────────────
-- 5) Best score per user per day (one row per attempt, best rank cached)
-- ─────────────────────────────────────────────
create table if not exists public.daily_quiz_scores (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references auth.users(id) on delete cascade,
  quiz_date           date not null,
  attempt_id          uuid not null unique references public.daily_attempts(id) on delete cascade,
  total_points        integer not null check (total_points >= 0),
  total_time_seconds  numeric(7,2) not null check (total_time_seconds >= 0),
  correct_count       integer not null check (correct_count >= 0),
  rank_cached         integer
);

-- ─────────────────────────────────────────────
-- 6) Aggregated all-time quiz leaderboard
-- ─────────────────────────────────────────────
create table if not exists public.quiz_leaderboard_all_time (
  user_id        uuid primary key references auth.users(id) on delete cascade,
  total_points   bigint not null default 0 check (total_points >= 0),
  total_attempts integer not null default 0 check (total_attempts >= 0),
  updated_at     timestamptz not null default timezone('utc', now())
);

-- ─────────────────────────────────────────────
-- Indexes
-- ─────────────────────────────────────────────
create index if not exists idx_daily_quizzes_date
  on public.daily_quizzes(quiz_date desc);

create index if not exists idx_daily_quiz_questions_quiz_id
  on public.daily_quiz_questions(daily_quiz_id, position);

create index if not exists idx_daily_quiz_questions_hash
  on public.daily_quiz_questions(question_hash);

create index if not exists idx_daily_attempts_user_date
  on public.daily_attempts(user_id, quiz_date desc);

create index if not exists idx_daily_attempt_answers_attempt
  on public.daily_attempt_answers(attempt_id);

create index if not exists idx_daily_quiz_scores_user_date
  on public.daily_quiz_scores(user_id, quiz_date desc);

create index if not exists idx_daily_quiz_scores_date_points
  on public.daily_quiz_scores(quiz_date, total_points desc, total_time_seconds asc);

create index if not exists idx_quiz_leaderboard_alltime_points
  on public.quiz_leaderboard_all_time(total_points desc);

-- ─────────────────────────────────────────────
-- updated_at trigger for all-time leaderboard
-- ─────────────────────────────────────────────
create trigger set_quiz_leaderboard_alltime_updated_at
before update on public.quiz_leaderboard_all_time
for each row execute function public.set_updated_at();

-- ─────────────────────────────────────────────
-- Row Level Security
-- ─────────────────────────────────────────────
alter table public.daily_quizzes            enable row level security;
alter table public.daily_quiz_questions     enable row level security;
alter table public.daily_attempts           enable row level security;
alter table public.daily_attempt_answers    enable row level security;
alter table public.daily_quiz_scores        enable row level security;
alter table public.quiz_leaderboard_all_time enable row level security;

-- daily_quizzes: authenticated users can read published quizzes
create policy "daily_quizzes_select_published"
on public.daily_quizzes
for select
to authenticated
using (status = 'published');

-- daily_quiz_questions: authenticated users can read questions for published quizzes
create policy "daily_quiz_questions_select_published"
on public.daily_quiz_questions
for select
to authenticated
using (
  exists (
    select 1 from public.daily_quizzes dq
    where dq.id = daily_quiz_id
      and dq.status = 'published'
  )
);

-- daily_attempts: users can read their own attempts
create policy "daily_attempts_select_own"
on public.daily_attempts
for select
using (auth.uid() = user_id);

-- daily_attempt_answers: users can read answers for their own attempts
create policy "daily_attempt_answers_select_own"
on public.daily_attempt_answers
for select
using (
  exists (
    select 1 from public.daily_attempts da
    where da.id = attempt_id
      and da.user_id = auth.uid()
  )
);

-- daily_quiz_scores: users can read their own scores
create policy "daily_quiz_scores_select_own"
on public.daily_quiz_scores
for select
using (auth.uid() = user_id);

-- quiz_leaderboard_all_time: any authenticated user can read (public leaderboard)
create policy "quiz_leaderboard_alltime_select_authenticated"
on public.quiz_leaderboard_all_time
for select
to authenticated
using (true);

-- Note: inserts/updates to daily_attempts, daily_attempt_answers, daily_quiz_scores,
-- and quiz_leaderboard_all_time are performed exclusively via edge functions using the
-- service_role key, so no client-facing insert/update policies are defined here.

-- ─────────────────────────────────────────────
-- Leaderboard Views
-- ─────────────────────────────────────────────

-- Daily leaderboard: best score per user per day, with rank
-- Client queries: GET /rest/v1/v_daily_leaderboard?quiz_date=eq.YYYY-MM-DD&order=rank.asc&limit=100
create or replace view public.v_daily_leaderboard as
select
  row_number() over (
    partition by s.quiz_date
    order by s.total_points desc, s.total_time_seconds asc, a.submitted_at asc
  )::integer                          as rank,
  s.quiz_date,
  s.user_id,
  coalesce(p.display_name, 'Anonymous') as display_name,
  s.total_points,
  s.total_time_seconds,
  s.correct_count,
  a.submitted_at
from (
  -- one row per user per day: their best-scoring attempt
  select distinct on (user_id, quiz_date)
    user_id,
    quiz_date,
    attempt_id,
    total_points,
    total_time_seconds,
    correct_count
  from public.daily_quiz_scores
  order by user_id, quiz_date, total_points desc, total_time_seconds asc
) s
join public.daily_attempts a on a.id = s.attempt_id
left join public.profiles p  on p.id = s.user_id;

-- All-time leaderboard: ranked by cumulative points
create or replace view public.v_alltime_quiz_leaderboard as
select
  row_number() over (
    order by l.total_points desc, l.total_attempts asc
  )::integer                          as rank,
  l.user_id,
  coalesce(p.display_name, 'Anonymous') as display_name,
  l.total_points,
  l.total_attempts,
  l.updated_at
from public.quiz_leaderboard_all_time l
left join public.profiles p on p.id = l.user_id;

-- ─────────────────────────────────────────────
-- pg_cron: schedule nightly quiz generation at 23:50 IST (18:20 UTC)
-- Optional: only schedules when the "cron" schema is available.
-- If pg_cron is unavailable, use an external scheduler to call:
--   POST /functions/v1/generate_daily_quiz
-- ─────────────────────────────────────────────
do $$
begin
  if exists (select 1 from pg_namespace where nspname = 'cron') then
    perform cron.schedule(
      'generate_daily_quiz_nightly',
      '20 18 * * *',  -- 18:20 UTC = 23:50 IST
      $inner$
        select net.http_post(
          url := current_setting('app.supabase_url') || '/functions/v1/generate_daily_quiz',
          headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer ' || current_setting('app.service_role_key')
          ),
          body := '{}'::jsonb
        )
      $inner$
    );
  else
    raise notice 'cron schema not available; skipped schedule generate_daily_quiz_nightly';
  end if;
end
$$;
