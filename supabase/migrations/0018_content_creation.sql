-- Content Creation: a separate production-pipeline Kanban (Idea -> Script
-- -> Shooting -> Editing -> Copywriting -> Waiting for publishing ->
-- Published), distinct from the marketing content_items schedule. The
-- Content Calendar tab becomes a read-only calendar view of these cards
-- by their `should_be_published_on` date.
create table public.content_creation_columns (
  status text primary key,
  title text not null,
  position integer not null default 0
);
insert into public.content_creation_columns (status, title, position) values
  ('idea', 'Idea', 0),
  ('script', 'Script', 1),
  ('shooting', 'Shooting', 2),
  ('editing', 'Editing', 3),
  ('copywriting', 'Copywriting', 4),
  ('waiting_for_publishing', 'Waiting for Publishing', 5),
  ('published', 'Published', 6);

alter table public.content_creation_columns enable row level security;
create policy "content_creation_columns_select_authenticated" on public.content_creation_columns
  for select to authenticated using (true);
create policy "content_creation_columns_insert_authenticated" on public.content_creation_columns
  for insert to authenticated with check (true);
create policy "content_creation_columns_update_authenticated" on public.content_creation_columns
  for update to authenticated using (true) with check (true);
create policy "content_creation_columns_delete_authenticated" on public.content_creation_columns
  for delete to authenticated using (true);

create table public.content_creation_items (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  status text not null default 'idea' references public.content_creation_columns(status)
    on update cascade on delete restrict,
  script text,
  deadline timestamptz,
  copy text,
  drive_url text,
  client_id uuid references public.clients(id) on delete set null,
  should_be_published_on timestamptz,
  assignee_id uuid references public.profiles(id) on delete set null,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger content_creation_items_set_updated_at
  before update on public.content_creation_items
  for each row execute function public.set_updated_at();

create index idx_content_creation_items_status on public.content_creation_items(status);
create index idx_content_creation_items_client_id on public.content_creation_items(client_id);
create index idx_content_creation_items_assignee_id on public.content_creation_items(assignee_id);
create index idx_content_creation_items_should_be_published_on on public.content_creation_items(should_be_published_on);

alter table public.content_creation_items enable row level security;
create policy "content_creation_items_select_authenticated" on public.content_creation_items
  for select to authenticated using (true);
create policy "content_creation_items_insert_authenticated" on public.content_creation_items
  for insert to authenticated with check (true);
create policy "content_creation_items_update_authenticated" on public.content_creation_items
  for update to authenticated using (true) with check (true);
create policy "content_creation_items_delete_authenticated" on public.content_creation_items
  for delete to authenticated using (true);

alter publication supabase_realtime add table
  public.content_creation_columns,
  public.content_creation_items;
