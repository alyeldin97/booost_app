create table public.clients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  logo_url text,
  color text,
  is_active boolean not null default true,
  -- Nullable, unconstrained for now: reserved so a future org/workspace
  -- feature can scope clients without a schema migration.
  org_id uuid,
  created_at timestamptz not null default now(),
  created_by uuid references public.profiles(id) on delete set null
);
