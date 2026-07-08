-- Client profile fields
alter table public.clients add column if not exists notes text;
alter table public.clients add column if not exists persona text; -- "shakhbata"
alter table public.clients add column if not exists feedback text;

-- Weekly per-client analytics
create table public.client_analytics (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete cascade,
  week_start date not null,
  total_sales numeric,
  net_sales numeric,
  retention_rate numeric,
  roas numeric,
  cpc numeric,
  ctr numeric,
  ad_spend numeric,
  created_at timestamptz not null default now(),
  unique (client_id, week_start)
);
create index idx_client_analytics_client_id on public.client_analytics(client_id);

alter table public.client_analytics enable row level security;
create policy "client_analytics_select_authenticated" on public.client_analytics
  for select to authenticated using (true);
create policy "client_analytics_insert_authenticated" on public.client_analytics
  for insert to authenticated with check (true);
create policy "client_analytics_update_authenticated" on public.client_analytics
  for update to authenticated using (true) with check (true);
create policy "client_analytics_delete_authenticated" on public.client_analytics
  for delete to authenticated using (true);

-- Editable Kanban column titles (display-only relabeling of the fixed
-- task_status values, since the status enum itself drives filtering/DB
-- semantics and shouldn't change).
create table public.board_columns (
  status text primary key,
  title text not null
);
insert into public.board_columns (status, title) values
  ('todo', 'To Do'),
  ('in_progress', 'In Progress'),
  ('waiting_for_client', 'Waiting for Client'),
  ('review', 'Review'),
  ('done', 'Done');

alter table public.board_columns enable row level security;
create policy "board_columns_select_authenticated" on public.board_columns
  for select to authenticated using (true);
create policy "board_columns_update_authenticated" on public.board_columns
  for update to authenticated using (true) with check (true);

-- "Shakhabeet" — freeform notes/ideas board, separate from tasks
create table public.notes (
  id uuid primary key default gen_random_uuid(),
  title text not null default 'Untitled',
  content text,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger notes_set_updated_at
  before update on public.notes
  for each row execute function public.set_updated_at();

alter table public.notes enable row level security;
create policy "notes_select_authenticated" on public.notes
  for select to authenticated using (true);
create policy "notes_insert_authenticated" on public.notes
  for insert to authenticated with check (true);
create policy "notes_update_authenticated" on public.notes
  for update to authenticated using (true) with check (true);
create policy "notes_delete_authenticated" on public.notes
  for delete to authenticated using (true);
