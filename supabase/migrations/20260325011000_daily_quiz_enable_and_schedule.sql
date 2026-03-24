-- Try enabling pg_cron, then create an idempotent nightly schedule for daily quiz generation.

do $$
declare
  v_job_id bigint;
begin
  begin
    execute 'create extension if not exists pg_cron';
  exception when others then
    raise notice 'Could not enable pg_cron automatically: %', sqlerrm;
  end;

  if exists (select 1 from pg_namespace where nspname = 'cron') then
    for v_job_id in
      select jobid from cron.job where jobname = 'generate_daily_quiz_nightly'
    loop
      perform cron.unschedule(v_job_id);
    end loop;

    perform cron.schedule(
      'generate_daily_quiz_nightly',
      '20 18 * * *',
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
    raise notice 'pg_cron still unavailable. Enable extension in Supabase Dashboard -> Database -> Extensions.';
  end if;
end
$$;
