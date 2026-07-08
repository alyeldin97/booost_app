-- v1 policy shape: every table gets one policy per operation (not a combined
-- `for all`), scoped to `authenticated` with a blanket `using (true)`.
-- This makes a future org-scoped rewrite a per-policy `using` clause edit
-- (e.g. `using (org_id = ...)`) rather than a structural rewrite.

alter table public.profiles enable row level security;
alter table public.clients enable row level security;
alter table public.tasks enable row level security;
alter table public.task_assignees enable row level security;
alter table public.task_platforms enable row level security;
alter table public.task_labels enable row level security;
alter table public.task_checklist_items enable row level security;
alter table public.task_attachments enable row level security;
alter table public.task_comments enable row level security;
alter table public.content_items enable row level security;
alter table public.activity_logs enable row level security;

-- profiles: readable by any authenticated user (needed for assignee
-- pickers/avatars), but only self-editable.
create policy "profiles_select_authenticated" on public.profiles
  for select to authenticated using (true);
create policy "profiles_update_own" on public.profiles
  for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

-- clients
create policy "clients_select_authenticated" on public.clients
  for select to authenticated using (true);
create policy "clients_insert_authenticated" on public.clients
  for insert to authenticated with check (true);
create policy "clients_update_authenticated" on public.clients
  for update to authenticated using (true) with check (true);
create policy "clients_delete_authenticated" on public.clients
  for delete to authenticated using (true);

-- tasks
create policy "tasks_select_authenticated" on public.tasks
  for select to authenticated using (true);
create policy "tasks_insert_authenticated" on public.tasks
  for insert to authenticated with check (true);
create policy "tasks_update_authenticated" on public.tasks
  for update to authenticated using (true) with check (true);
create policy "tasks_delete_authenticated" on public.tasks
  for delete to authenticated using (true);

-- task_assignees
create policy "task_assignees_select_authenticated" on public.task_assignees
  for select to authenticated using (true);
create policy "task_assignees_insert_authenticated" on public.task_assignees
  for insert to authenticated with check (true);
create policy "task_assignees_delete_authenticated" on public.task_assignees
  for delete to authenticated using (true);

-- task_platforms
create policy "task_platforms_select_authenticated" on public.task_platforms
  for select to authenticated using (true);
create policy "task_platforms_insert_authenticated" on public.task_platforms
  for insert to authenticated with check (true);
create policy "task_platforms_delete_authenticated" on public.task_platforms
  for delete to authenticated using (true);

-- task_labels
create policy "task_labels_select_authenticated" on public.task_labels
  for select to authenticated using (true);
create policy "task_labels_insert_authenticated" on public.task_labels
  for insert to authenticated with check (true);
create policy "task_labels_delete_authenticated" on public.task_labels
  for delete to authenticated using (true);

-- task_checklist_items
create policy "task_checklist_items_select_authenticated" on public.task_checklist_items
  for select to authenticated using (true);
create policy "task_checklist_items_insert_authenticated" on public.task_checklist_items
  for insert to authenticated with check (true);
create policy "task_checklist_items_update_authenticated" on public.task_checklist_items
  for update to authenticated using (true) with check (true);
create policy "task_checklist_items_delete_authenticated" on public.task_checklist_items
  for delete to authenticated using (true);

-- task_attachments
create policy "task_attachments_select_authenticated" on public.task_attachments
  for select to authenticated using (true);
create policy "task_attachments_insert_authenticated" on public.task_attachments
  for insert to authenticated with check (true);
create policy "task_attachments_delete_authenticated" on public.task_attachments
  for delete to authenticated using (true);

-- task_comments
create policy "task_comments_select_authenticated" on public.task_comments
  for select to authenticated using (true);
create policy "task_comments_insert_authenticated" on public.task_comments
  for insert to authenticated with check (true);
create policy "task_comments_delete_authenticated" on public.task_comments
  for delete to authenticated using (true);

-- content_items
create policy "content_items_select_authenticated" on public.content_items
  for select to authenticated using (true);
create policy "content_items_insert_authenticated" on public.content_items
  for insert to authenticated with check (true);
create policy "content_items_update_authenticated" on public.content_items
  for update to authenticated using (true) with check (true);
create policy "content_items_delete_authenticated" on public.content_items
  for delete to authenticated using (true);

-- activity_logs: append-only from the app's perspective (no update/delete policy)
create policy "activity_logs_select_authenticated" on public.activity_logs
  for select to authenticated using (true);
create policy "activity_logs_insert_authenticated" on public.activity_logs
  for insert to authenticated with check (true);
