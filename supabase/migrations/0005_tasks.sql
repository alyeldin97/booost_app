create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete cascade,
  title text not null,
  description text,
  status text not null default 'todo'
    check (status in ('todo','in_progress','waiting_for_client','review','done')),
  priority text not null default 'medium'
    check (priority in ('low','medium','high','urgent')),
  -- Deliberately free-form (no check constraint): the spec never enumerates
  -- task types, so the list lives in app config and can grow without a migration.
  task_type text not null default 'internal',
  due_date timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null
);

create trigger tasks_set_updated_at
  before update on public.tasks
  for each row execute function public.set_updated_at();
