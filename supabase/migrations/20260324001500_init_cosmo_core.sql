-- Cosmo core auth-linked data model
-- Created: 2026-03-24

create extension if not exists pgcrypto;

-- Keep updated_at fresh automatically.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

-- 1) Profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  timezone text not null default 'Asia/Kolkata',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- 2) Quiz runs
create table if not exists public.quiz_runs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id text not null,
  question_ids jsonb not null default '[]'::jsonb,
  answers_by_id jsonb not null default '{}'::jsonb,
  correct_count integer not null check (correct_count >= 0),
  total_count integer not null check (total_count > 0),
  accuracy integer not null check (accuracy >= 0 and accuracy <= 100),
  played_at timestamptz not null default timezone('utc', now())
);

-- 3) Quiz streaks
create table if not exists public.quiz_streaks (
  user_id uuid primary key references auth.users(id) on delete cascade,
  current_streak integer not null default 0 check (current_streak >= 0),
  best_streak integer not null default 0 check (best_streak >= 0),
  last_quiz_date date,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- 4) Game sessions
create table if not exists public.game_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  score integer not null default 0 check (score >= 0),
  wave_reached integer not null default 1 check (wave_reached >= 1),
  lives_left integer not null default 0 check (lives_left >= 0),
  duration_seconds integer not null default 0 check (duration_seconds >= 0),
  played_at timestamptz not null default timezone('utc', now())
);

-- 5) Game streaks
create table if not exists public.game_streaks (
  user_id uuid primary key references auth.users(id) on delete cascade,
  current_streak integer not null default 0 check (current_streak >= 0),
  best_streak integer not null default 0 check (best_streak >= 0),
  last_game_date date,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- 6) User settings
create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- 7) Entitlements (monetization snapshot, ready for StoreKit integration)
create table if not exists public.user_entitlements (
  user_id uuid primary key references auth.users(id) on delete cascade,
  is_pro boolean not null default false,
  has_lifetime boolean not null default false,
  source text not null default 'storekit',
  expires_at timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

-- 8) Optional content manifest for remote JSON quiz packs
create table if not exists public.question_packs (
  id text primary key,
  title text not null,
  version integer not null default 1 check (version >= 1),
  url text not null,
  checksum text,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_quiz_runs_user_played_at
  on public.quiz_runs(user_id, played_at desc);

create index if not exists idx_quiz_runs_user_category
  on public.quiz_runs(user_id, category_id);

create index if not exists idx_game_sessions_user_played_at
  on public.game_sessions(user_id, played_at desc);

create index if not exists idx_question_packs_active
  on public.question_packs(is_active, updated_at desc);

-- updated_at triggers
create trigger set_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger set_quiz_streaks_updated_at
before update on public.quiz_streaks
for each row execute function public.set_updated_at();

create trigger set_game_streaks_updated_at
before update on public.game_streaks
for each row execute function public.set_updated_at();

create trigger set_user_settings_updated_at
before update on public.user_settings
for each row execute function public.set_updated_at();

create trigger set_user_entitlements_updated_at
before update on public.user_entitlements
for each row execute function public.set_updated_at();

create trigger set_question_packs_updated_at
before update on public.question_packs
for each row execute function public.set_updated_at();

-- Row Level Security
alter table public.profiles enable row level security;
alter table public.quiz_runs enable row level security;
alter table public.quiz_streaks enable row level security;
alter table public.game_sessions enable row level security;
alter table public.game_streaks enable row level security;
alter table public.user_settings enable row level security;
alter table public.user_entitlements enable row level security;
alter table public.question_packs enable row level security;

-- profiles
create policy "profiles_select_own"
on public.profiles
for select
using (auth.uid() = id);

create policy "profiles_insert_own"
on public.profiles
for insert
with check (auth.uid() = id);

create policy "profiles_update_own"
on public.profiles
for update
using (auth.uid() = id)
with check (auth.uid() = id);

-- quiz_runs
create policy "quiz_runs_select_own"
on public.quiz_runs
for select
using (auth.uid() = user_id);

create policy "quiz_runs_insert_own"
on public.quiz_runs
for insert
with check (auth.uid() = user_id);

create policy "quiz_runs_update_own"
on public.quiz_runs
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "quiz_runs_delete_own"
on public.quiz_runs
for delete
using (auth.uid() = user_id);

-- quiz_streaks
create policy "quiz_streaks_select_own"
on public.quiz_streaks
for select
using (auth.uid() = user_id);

create policy "quiz_streaks_insert_own"
on public.quiz_streaks
for insert
with check (auth.uid() = user_id);

create policy "quiz_streaks_update_own"
on public.quiz_streaks
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- game_sessions
create policy "game_sessions_select_own"
on public.game_sessions
for select
using (auth.uid() = user_id);

create policy "game_sessions_insert_own"
on public.game_sessions
for insert
with check (auth.uid() = user_id);

create policy "game_sessions_update_own"
on public.game_sessions
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "game_sessions_delete_own"
on public.game_sessions
for delete
using (auth.uid() = user_id);

-- game_streaks
create policy "game_streaks_select_own"
on public.game_streaks
for select
using (auth.uid() = user_id);

create policy "game_streaks_insert_own"
on public.game_streaks
for insert
with check (auth.uid() = user_id);

create policy "game_streaks_update_own"
on public.game_streaks
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- user_settings
create policy "user_settings_select_own"
on public.user_settings
for select
using (auth.uid() = user_id);

create policy "user_settings_insert_own"
on public.user_settings
for insert
with check (auth.uid() = user_id);

create policy "user_settings_update_own"
on public.user_settings
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- user_entitlements
create policy "user_entitlements_select_own"
on public.user_entitlements
for select
using (auth.uid() = user_id);

create policy "user_entitlements_insert_own"
on public.user_entitlements
for insert
with check (auth.uid() = user_id);

create policy "user_entitlements_update_own"
on public.user_entitlements
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- question_packs: readable to authenticated users, writable only by service role (no write policy here)
create policy "question_packs_select_authenticated"
on public.question_packs
for select
to authenticated
using (is_active = true);
