create index idx_tasks_client_id on public.tasks(client_id);
create index idx_tasks_status on public.tasks(status);
create index idx_tasks_due_date on public.tasks(due_date);
create index idx_tasks_created_by on public.tasks(created_by);

create index idx_task_assignees_profile_id on public.task_assignees(profile_id);
create index idx_task_comments_task_id on public.task_comments(task_id);
create index idx_task_checklist_items_task_id on public.task_checklist_items(task_id);
create index idx_task_attachments_task_id on public.task_attachments(task_id);
create index idx_task_labels_task_id on public.task_labels(task_id);

create index idx_content_items_client_id on public.content_items(client_id);
create index idx_content_items_publish_at on public.content_items(publish_at);
create index idx_content_items_approval_status on public.content_items(approval_status);
create index idx_content_items_task_id on public.content_items(task_id);

create index idx_activity_logs_task_id on public.activity_logs(task_id);
create index idx_activity_logs_content_item_id on public.activity_logs(content_item_id);
create index idx_activity_logs_created_at on public.activity_logs(created_at);
