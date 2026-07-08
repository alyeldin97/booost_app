-- Authoritative sync: whenever a content item's publish_at changes (or it's
-- inserted already linked to a task), the linked task's due_date follows it.
-- This is the source of truth; any app-level optimistic patch during drag
-- reschedule is purely for perceived responsiveness.
create or replace function public.sync_task_due_date_from_content()
returns trigger
language plpgsql
as $$
begin
  if new.task_id is not null
     and (tg_op = 'INSERT' or old.publish_at is distinct from new.publish_at) then
    update public.tasks
    set due_date = new.publish_at
    where id = new.task_id
      and due_date is distinct from new.publish_at;
  end if;
  return new;
end;
$$;

create trigger content_items_sync_task_due_date
  after insert or update on public.content_items
  for each row execute function public.sync_task_due_date_from_content();
