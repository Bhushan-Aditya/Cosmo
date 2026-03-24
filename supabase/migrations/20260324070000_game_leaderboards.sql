-- Game leaderboard aggregates + ranked views
-- Created: 2026-03-24

-- Aggregate table: per-user per-day game performance
create table if not exists public.game_leaderboard_daily (
  user_id               uuid not null references auth.users(id) on delete cascade,
  session_date          date not null,
  total_score           bigint not null default 0 check (total_score >= 0),
  total_sessions        integer not null default 0 check (total_sessions >= 0),
  best_score            integer not null default 0 check (best_score >= 0),
  total_duration_seconds bigint not null default 0 check (total_duration_seconds >= 0),
  latest_played_at      timestamptz,
  updated_at            timestamptz not null default timezone('utc', now()),
  primary key (user_id, session_date)
);

-- Aggregate table: per-user all-time game performance
create table if not exists public.game_leaderboard_all_time (
  user_id                uuid primary key references auth.users(id) on delete cascade,
  total_score            bigint not null default 0 check (total_score >= 0),
  total_sessions         integer not null default 0 check (total_sessions >= 0),
  best_score             integer not null default 0 check (best_score >= 0),
  total_duration_seconds bigint not null default 0 check (total_duration_seconds >= 0),
  latest_played_at       timestamptz,
  updated_at             timestamptz not null default timezone('utc', now())
);

create index if not exists idx_game_leaderboard_daily_date_score
  on public.game_leaderboard_daily(session_date, total_score desc, total_duration_seconds asc);

create index if not exists idx_game_leaderboard_all_time_score
  on public.game_leaderboard_all_time(total_score desc, total_duration_seconds asc);

create trigger set_game_leaderboard_daily_updated_at
before update on public.game_leaderboard_daily
for each row execute function public.set_updated_at();

create trigger set_game_leaderboard_all_time_updated_at
before update on public.game_leaderboard_all_time
for each row execute function public.set_updated_at();

-- Maintain leaderboard aggregates whenever a game session is inserted
create or replace function public.update_game_leaderboards_on_session_insert()
returns trigger
language plpgsql
as $$
declare
  session_day date;
begin
  session_day := (new.played_at at time zone 'UTC')::date;

  insert into public.game_leaderboard_daily (
    user_id,
    session_date,
    total_score,
    total_sessions,
    best_score,
    total_duration_seconds,
    latest_played_at
  )
  values (
    new.user_id,
    session_day,
    new.score,
    1,
    new.score,
    new.duration_seconds,
    new.played_at
  )
  on conflict (user_id, session_date)
  do update set
    total_score = public.game_leaderboard_daily.total_score + excluded.total_score,
    total_sessions = public.game_leaderboard_daily.total_sessions + 1,
    best_score = greatest(public.game_leaderboard_daily.best_score, excluded.best_score),
    total_duration_seconds = public.game_leaderboard_daily.total_duration_seconds + excluded.total_duration_seconds,
    latest_played_at = greatest(public.game_leaderboard_daily.latest_played_at, excluded.latest_played_at),
    updated_at = timezone('utc', now());

  insert into public.game_leaderboard_all_time (
    user_id,
    total_score,
    total_sessions,
    best_score,
    total_duration_seconds,
    latest_played_at
  )
  values (
    new.user_id,
    new.score,
    1,
    new.score,
    new.duration_seconds,
    new.played_at
  )
  on conflict (user_id)
  do update set
    total_score = public.game_leaderboard_all_time.total_score + excluded.total_score,
    total_sessions = public.game_leaderboard_all_time.total_sessions + 1,
    best_score = greatest(public.game_leaderboard_all_time.best_score, excluded.best_score),
    total_duration_seconds = public.game_leaderboard_all_time.total_duration_seconds + excluded.total_duration_seconds,
    latest_played_at = greatest(public.game_leaderboard_all_time.latest_played_at, excluded.latest_played_at),
    updated_at = timezone('utc', now());

  return new;
end;
$$;

drop trigger if exists game_sessions_update_leaderboards on public.game_sessions;
create trigger game_sessions_update_leaderboards
after insert on public.game_sessions
for each row execute function public.update_game_leaderboards_on_session_insert();

-- Enable RLS
alter table public.game_leaderboard_daily enable row level security;
alter table public.game_leaderboard_all_time enable row level security;

-- Public read for authenticated users
create policy "game_leaderboard_daily_select_authenticated"
on public.game_leaderboard_daily
for select
to authenticated
using (true);

create policy "game_leaderboard_all_time_select_authenticated"
on public.game_leaderboard_all_time
for select
to authenticated
using (true);

-- Ranked views
create or replace view public.v_game_leaderboard_daily as
select
  row_number() over (
    partition by d.session_date
    order by d.total_score desc, d.total_duration_seconds asc, d.latest_played_at asc
  )::integer as rank,
  d.session_date,
  d.user_id,
  coalesce(p.display_name, 'Anonymous') as display_name,
  d.total_score,
  d.total_sessions,
  d.best_score,
  d.total_duration_seconds,
  d.latest_played_at
from public.game_leaderboard_daily d
left join public.profiles p on p.id = d.user_id;

create or replace view public.v_game_leaderboard_all_time as
select
  row_number() over (
    order by a.total_score desc, a.total_duration_seconds asc, a.latest_played_at asc
  )::integer as rank,
  a.user_id,
  coalesce(p.display_name, 'Anonymous') as display_name,
  a.total_score,
  a.total_sessions,
  a.best_score,
  a.total_duration_seconds,
  a.latest_played_at,
  a.updated_at
from public.game_leaderboard_all_time a
left join public.profiles p on p.id = a.user_id;
