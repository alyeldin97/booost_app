insert into storage.buckets (id, name, public)
values ('task-attachments', 'task-attachments', false)
on conflict (id) do nothing;

create policy "task_attachments_bucket_insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'task-attachments');

create policy "task_attachments_bucket_select" on storage.objects
  for select to authenticated
  using (bucket_id = 'task-attachments');

create policy "task_attachments_bucket_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'task-attachments')
  with check (bucket_id = 'task-attachments');

create policy "task_attachments_bucket_delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'task-attachments');
