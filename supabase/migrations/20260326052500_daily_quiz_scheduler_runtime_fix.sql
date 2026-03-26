-- Fix nightly daily-quiz scheduler runtime failures caused by missing custom DB settings
-- (app.supabase_url / app.service_role_key) referenced by prior migrations.
--
-- This migration reschedules the job with explicit project URL and anon auth header.

do $$
declare
  v_job_id bigint;
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

    perform cron.schedule(
      'generate_daily_quiz_nightly',
      '20 18 * * *',  -- 18:20 UTC = 23:50 IST
      $inner$
        select net.http_post(
          url := 'https://pcfzekejubmcctwfkwxl.supabase.co/functions/v1/generate_daily_quiz',
          headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBjZnpla2VqdWJtY2N0d2Zrd3hsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyODc0NzYsImV4cCI6MjA4OTg2MzQ3Nn0.ydB6Uz6Hz0yP2mxDv3IlCcC-H9YHdbZ2FXZlEWt9wY0'
          ),
          body := '{}'::jsonb
        )
      $inner$
    );

    raise notice 'Scheduled generate_daily_quiz_nightly with explicit URL + auth header at 23:50 IST';
  else
    raise notice 'cron/net schema not available; nightly schedule not created';
  end if;
end
$$;
