-- Store Sign in with Apple refresh tokens for later revocation on account deletion.
-- Required for Apple account deletion guidance when SIWA is supported.

create table if not exists public.apple_auth_tokens (
  user_id uuid primary key references auth.users(id) on delete cascade,
  refresh_token text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create trigger set_apple_auth_tokens_updated_at
before update on public.apple_auth_tokens
for each row execute function public.set_updated_at();

alter table public.apple_auth_tokens enable row level security;

-- No read/write policies for authenticated users; table is service-role only.
