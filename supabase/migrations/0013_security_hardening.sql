-- Pin search_path on SECURITY DEFINER / trigger functions to close the
-- "mutable search_path" advisory, and ensure the auth-bootstrap trigger
-- function can't be invoked directly as a public RPC (it only makes sense
-- running inside the auth.users trigger context).

alter function public.set_updated_at() set search_path = public, pg_temp;
alter function public.sync_task_due_date_from_content() set search_path = public, pg_temp;
alter function public.handle_new_user() set search_path = public, pg_temp;

revoke execute on function public.handle_new_user() from public, anon, authenticated;
