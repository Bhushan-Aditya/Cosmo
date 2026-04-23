-- IAP security hardening
-- 1) Prevent client-side entitlement escalation by removing write policies.
-- 2) Reschedule daily quiz cron job without hardcoded bearer tokens.

-- Lock entitlement mutations to trusted server-side actors (service_role).
drop policy if exists "user_entitlements_insert_own" on public.user_entitlements;
drop policy if exists "user_entitlements_update_own" on public.user_entitlements;

-- Keep read access for users to their own entitlement snapshot.
-- (No-op if already exists from prior migration.)
do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'user_entitlements'
      and policyname = 'user_entitlements_select_own'
  ) then
    create policy "user_entitlements_select_own"
    on public.user_entitlements
    for select
    using (auth.uid() = user_id);
  end if;
end
$$;

-- Secure scheduler configuration:
-- Requires DB settings:
--   app.supabase_url
--   app.service_role_key
-- If missing, we intentionally skip scheduling to avoid insecure fallback.
do $$
declare
  v_job_id bigint;
  v_supabase_url text;
  v_service_role_key text;
begin
  begin
    execute 'create extension if not exists pg_cron';
  exception when others then
    raise notice 'Could not enable pg_cron automatically: %', sqlerrm;
  end;

  begin
    execute 'create extension if not exists pg_net';
  exception when others then
    raise notice 'Could not enable pg_net automatically: %', sqlerrm;
  end;

  if exists (select 1 from pg_namespace where nspname = 'cron')
     and exists (select 1 from pg_namespace where nspname = 'net') then
    for v_job_id in
      select jobid from cron.job where jobname = 'generate_daily_quiz_nightly'
    loop
      perform cron.unschedule(v_job_id);
    end loop;

    v_supabase_url := nullif(current_setting('app.supabase_url', true), '');
    v_service_role_key := nullif(current_setting('app.service_role_key', true), '');

    if v_supabase_url is null then
      v_supabase_url := 'https://pcfzekejubmcctwfkwxl.supabase.co';
    end if;

    if v_service_role_key is null then
      raise notice 'app.service_role_key is not configured; skipped generate_daily_quiz_nightly scheduling';
    else
      perform cron.schedule(
        'generate_daily_quiz_nightly',
        '20 18 * * *',  -- 18:20 UTC = 23:50 IST
        format(
          $fmt$
            select net.http_post(
              url := %L,
              headers := jsonb_build_object(
                'Content-Type', 'application/json',
                'Authorization', 'Bearer ' || %L
              ),
              body := '{}'::jsonb
            )
          $fmt$,
          v_supabase_url || '/functions/v1/generate_daily_quiz',
          v_service_role_key
        )
      );

      raise notice 'Scheduled generate_daily_quiz_nightly with service role auth at 23:50 IST (18:20 UTC)';
    end if;
  else
    raise notice 'cron/net schema not available; nightly schedule not created';
  end if;
end
$$;
