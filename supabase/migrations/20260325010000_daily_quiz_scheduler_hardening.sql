-- Ensure nightly daily-quiz generation schedule exists and is idempotent.
-- Runs at 23:50 IST daily (18:20 UTC) and calls generate_daily_quiz,
-- which creates the NEXT day's quiz by default and stores it in daily_quizzes + daily_quiz_questions.

do $$
declare
  v_job_id bigint;
begin
  if exists (select 1 from pg_namespace where nspname = 'cron') then
    -- Remove any prior jobs with the same name so re-running migrations is safe.
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
          url := current_setting('app.supabase_url') || '/functions/v1/generate_daily_quiz',
          headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer ' || current_setting('app.service_role_key')
          ),
          body := '{}'::jsonb
        )
      $inner$
    );

    raise notice 'Scheduled generate_daily_quiz_nightly at 23:50 IST (18:20 UTC)';
  else
    raise notice 'cron schema not available; nightly schedule not created';
  end if;
end
$$;
