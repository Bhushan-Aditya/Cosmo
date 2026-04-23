# Supabase Edge Function Secrets and DB Settings

The production backend requires these runtime values.

## Edge function secrets

Set via Supabase CLI (`supabase secrets set ...`) or Dashboard:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `GEMINI_API_KEY`
- `APPLE_CLIENT_ID`
- `APPLE_TEAM_ID`
- `APPLE_KEY_ID`
- `APPLE_PRIVATE_KEY`
- `APPSTORE_ISSUER_ID`
- `APPSTORE_KEY_ID`
- `APPSTORE_PRIVATE_KEY`
- `APPSTORE_BUNDLE_ID`
- `PREMIUM_PRODUCT_IDS` (optional, defaults to `premium_lifetime`)
- `REQUIRE_APP_ACCOUNT_TOKEN` (optional, defaults to `1`)

## Database settings for secure cron auth

The migration `20260422173000_iap_security_hardening.sql` expects:

- `app.supabase_url`
- `app.service_role_key`

Set them in SQL (replace placeholders):

```sql
alter database postgres set app.supabase_url = 'https://<project-ref>.supabase.co';
alter database postgres set app.service_role_key = '<service-role-key>';
```

Then restart DB sessions and re-run migrations if needed.
