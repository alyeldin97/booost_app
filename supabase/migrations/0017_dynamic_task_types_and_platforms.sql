-- Task types: same dynamic-lookup pattern as board_columns.
create table public.task_types (
  task_type text primary key,
  title text not null,
  position integer not null default 0
);
insert into public.task_types (task_type, title, position) values
  ('design', 'Design', 0),
  ('copywriting', 'Copywriting', 1),
  ('strategy', 'Strategy', 2),
  ('development', 'Development', 3),
  ('ad_setup', 'Ad Setup', 4),
  ('reporting', 'Reporting', 5),
  ('client_request', 'Client Request', 6),
  ('internal', 'Internal', 7);

alter table public.tasks alter column task_type set default 'internal';
alter table public.tasks
  add constraint tasks_task_type_fkey foreign key (task_type)
  references public.task_types(task_type)
  on update cascade on delete restrict;

alter table public.task_types enable row level security;
create policy "task_types_select_authenticated" on public.task_types
  for select to authenticated using (true);
create policy "task_types_insert_authenticated" on public.task_types
  for insert to authenticated with check (true);
create policy "task_types_update_authenticated" on public.task_types
  for update to authenticated using (true) with check (true);
create policy "task_types_delete_authenticated" on public.task_types
  for delete to authenticated using (true);

-- Platforms: same pattern, replaces the fixed CHECK constraints on
-- task_platforms.platform and content_items.platform.
create table public.platforms (
  platform text primary key,
  title text not null,
  position integer not null default 0
);
insert into public.platforms (platform, title, position) values
  ('instagram', 'Instagram', 0),
  ('facebook', 'Facebook', 1),
  ('tiktok', 'TikTok', 2),
  ('linkedin', 'LinkedIn', 3),
  ('x', 'X', 4),
  ('youtube', 'YouTube', 5),
  ('google_ads', 'Google Ads', 6),
  ('meta_ads', 'Meta Ads', 7),
  ('email', 'Email', 8),
  ('website', 'Website', 9),
  ('blog', 'Blog', 10);

alter table public.task_platforms drop constraint if exists task_platforms_platform_check;
alter table public.content_items drop constraint if exists content_items_platform_check;

alter table public.task_platforms
  add constraint task_platforms_platform_fkey foreign key (platform)
  references public.platforms(platform)
  on update cascade on delete restrict;
alter table public.content_items
  add constraint content_items_platform_fkey foreign key (platform)
  references public.platforms(platform)
  on update cascade on delete restrict;

alter table public.platforms enable row level security;
create policy "platforms_select_authenticated" on public.platforms
  for select to authenticated using (true);
create policy "platforms_insert_authenticated" on public.platforms
  for insert to authenticated with check (true);
create policy "platforms_update_authenticated" on public.platforms
  for update to authenticated using (true) with check (true);
create policy "platforms_delete_authenticated" on public.platforms
  for delete to authenticated using (true);

alter publication supabase_realtime add table public.task_types, public.platforms;
