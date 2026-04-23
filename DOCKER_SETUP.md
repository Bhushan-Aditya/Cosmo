# Docker setup for Cosmo (local Supabase)

This project is an iOS app, so Docker is used for the local backend stack in `supabase/`.

## 1) Prereqs

- Docker Desktop installed and running
- Supabase CLI installed

Install Supabase CLI (pick one):

```bash
brew install supabase/tap/supabase
# or
npm i -g supabase
```

## 2) Start local backend

From project root:

```bash
./scripts/setup-local-supabase.sh
```

Or manually:

```bash
make supabase-up
make supabase-status
```

## 3) Point iOS app to local Supabase (Debug)

In Xcode:

1. Product -> Scheme -> Edit Scheme...
2. Run -> Arguments -> Environment Variables
3. Add:

- `SUPABASE_LOCAL=1`
- `SUPABASE_LOCAL_URL=http://127.0.0.1:54321`
- `SUPABASE_LOCAL_ANON_KEY=<ANON_KEY from supabase status>`

Then run the app in simulator.

## 4) Stop backend

```bash
make supabase-down
```

## Notes

- `127.0.0.1` works for iOS Simulator. For a real device, use your Mac LAN IP.
- Migrations/functions in `supabase/` are loaded by local Supabase when started/reset.
