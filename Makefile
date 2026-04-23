.PHONY: supabase-up supabase-down supabase-reset supabase-status

supabase-up:
	supabase start

supabase-down:
	supabase stop

supabase-reset:
	supabase db reset

supabase-status:
	supabase status
