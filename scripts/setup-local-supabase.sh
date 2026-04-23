#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not on PATH."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker Desktop is installed but not running. Start it, then rerun this script."
  exit 1
fi

if ! command -v supabase >/dev/null 2>&1; then
  cat <<'MSG'
Supabase CLI is not installed.
Install it with one of these:
  brew install supabase/tap/supabase
  npm i -g supabase
MSG
  exit 1
fi

echo "Starting local Supabase stack (Docker containers)..."
supabase start

echo
echo "Current local credentials (from supabase status):"
supabase status

echo
echo "Use this in Xcode Run Scheme -> Environment Variables:"
if supabase status -o env >/dev/null 2>&1; then
  env_dump="$(supabase status -o env)"
  api_url="$(echo "$env_dump" | sed -nE 's/^API_URL=\"?([^\"]*)\"?$/\1/p')"
  anon_key="$(echo "$env_dump" | sed -nE 's/^ANON_KEY=\"?([^\"]*)\"?$/\1/p')"
  [ -n "$api_url" ] && echo "SUPABASE_LOCAL_URL=$api_url"
  [ -n "$anon_key" ] && echo "SUPABASE_LOCAL_ANON_KEY=$anon_key"
  echo "SUPABASE_LOCAL=1"
else
  cat <<'MSG'
SUPABASE_LOCAL=1
SUPABASE_LOCAL_URL=http://127.0.0.1:54321
SUPABASE_LOCAL_ANON_KEY=<copy ANON_KEY from 'supabase status'>
MSG
fi

echo
echo "Done. Your app can now talk to local Supabase in Debug when env vars are set."
