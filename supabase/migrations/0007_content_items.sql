create table public.content_items (
  id uuid primary key default gen_random_uuid(),
  task_id uuid references public.tasks(id) on delete set null,
  client_id uuid not null references public.clients(id) on delete cascade,
  title text not null,
  platform text not null check (platform in (
    'instagram','facebook','tiktok','linkedin','x','youtube',
    'google_ads','meta_ads','email','website','blog'
  )),
  content_type text not null check (content_type in (
    'reel','post','story','carousel','ad','email','blog','landing_page'
  )),
  publish_at timestamptz not null,
  caption text,
  brief text,
  approval_status text not null default 'draft'
    check (approval_status in ('draft','internal_review','client_review','approved','published')),
  -- Spec's schema section doesn't define a dedicated content_attachments
  -- table (only task_attachments), so file metadata for content items
  -- without a linked task is kept here as jsonb, matching the jsonb idiom
  -- already used by activity_logs.metadata.
  attachments jsonb not null default '[]'::jsonb,
  copywriter_id uuid references public.profiles(id) on delete set null,
  designer_id uuid references public.profiles(id) on delete set null,
  account_manager_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger content_items_set_updated_at
  before update on public.content_items
  for each row execute function public.set_updated_at();
