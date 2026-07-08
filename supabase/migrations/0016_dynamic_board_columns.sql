-- Make Kanban columns fully dynamic (creatable/deletable), not a fixed
-- 5-value enum. board_columns.status stays the stable key referenced by
-- tasks.status (slugified from the title at creation time); title is the
-- freely-editable display label.
alter table public.board_columns add column if not exists position integer not null default 0;
update public.board_columns set position = 0 where status = 'todo';
update public.board_columns set position = 1 where status = 'in_progress';
update public.board_columns set position = 2 where status = 'waiting_for_client';
update public.board_columns set position = 3 where status = 'review';
update public.board_columns set position = 4 where status = 'done';

alter table public.tasks drop constraint if exists tasks_status_check;

alter table public.tasks
  add constraint tasks_status_fkey foreign key (status)
  references public.board_columns(status)
  on update cascade on delete restrict;

create policy "board_columns_insert_authenticated" on public.board_columns
  for insert to authenticated with check (true);
create policy "board_columns_delete_authenticated" on public.board_columns
  for delete to authenticated using (true);
