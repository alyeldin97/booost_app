-- Seed data for local/demo use. Not applied as a schema migration (kept
-- separate so it can be re-run/adjusted without polluting migration
-- history). Team member accounts are real auth.users rows (required since
-- profiles.id FKs to auth.users) with password: Booost2026!
do $$
declare
  u_sarah uuid := gen_random_uuid();
  u_marcus uuid := gen_random_uuid();
  u_priya uuid := gen_random_uuid();
  u_jordan uuid := gen_random_uuid();
  u_alex uuid := gen_random_uuid();
  u_taylor uuid := gen_random_uuid();

  c_nova uuid := gen_random_uuid();
  c_summit uuid := gen_random_uuid();
  c_brightleaf uuid := gen_random_uuid();
  c_pulse uuid := gen_random_uuid();
  c_harbor uuid := gen_random_uuid();

  t_id uuid;
  today date := current_date;
begin
  -- 1. Team member auth accounts (trigger auto-creates matching profiles rows)
  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change,
    raw_app_meta_data, raw_user_meta_data, is_super_admin
  ) values
    ('00000000-0000-0000-0000-000000000000', u_sarah, 'authenticated', 'authenticated',
     'sarah@booost.agency', crypt('Booost2026!', gen_salt('bf')), now(), now(), now(),
     '', '', '', '', '{"provider":"email","providers":["email"]}', '{"full_name":"Sarah Chen"}', false),
    ('00000000-0000-0000-0000-000000000000', u_marcus, 'authenticated', 'authenticated',
     'marcus@booost.agency', crypt('Booost2026!', gen_salt('bf')), now(), now(), now(),
     '', '', '', '', '{"provider":"email","providers":["email"]}', '{"full_name":"Marcus Rodriguez"}', false),
    ('00000000-0000-0000-0000-000000000000', u_priya, 'authenticated', 'authenticated',
     'priya@booost.agency', crypt('Booost2026!', gen_salt('bf')), now(), now(), now(),
     '', '', '', '', '{"provider":"email","providers":["email"]}', '{"full_name":"Priya Patel"}', false),
    ('00000000-0000-0000-0000-000000000000', u_jordan, 'authenticated', 'authenticated',
     'jordan@booost.agency', crypt('Booost2026!', gen_salt('bf')), now(), now(), now(),
     '', '', '', '', '{"provider":"email","providers":["email"]}', '{"full_name":"Jordan Lee"}', false),
    ('00000000-0000-0000-0000-000000000000', u_alex, 'authenticated', 'authenticated',
     'alex@booost.agency', crypt('Booost2026!', gen_salt('bf')), now(), now(), now(),
     '', '', '', '', '{"provider":"email","providers":["email"]}', '{"full_name":"Alex Kim"}', false),
    ('00000000-0000-0000-0000-000000000000', u_taylor, 'authenticated', 'authenticated',
     'taylor@booost.agency', crypt('Booost2026!', gen_salt('bf')), now(), now(), now(),
     '', '', '', '', '{"provider":"email","providers":["email"]}', '{"full_name":"Taylor Brooks"}', false);

  update public.profiles set role = 'admin' where id = u_sarah;
  update public.profiles set role = 'account_manager' where id = u_marcus;
  update public.profiles set role = 'copywriter' where id = u_priya;
  update public.profiles set role = 'copywriter' where id = u_jordan;
  update public.profiles set role = 'designer' where id = u_alex;
  update public.profiles set role = 'designer' where id = u_taylor;

  -- 2. Clients
  insert into public.clients (id, name, color, is_active, created_by) values
    (c_nova, 'Nova Fitness', '#4F46E5', true, u_sarah),
    (c_summit, 'Summit Realty Group', '#0EA5E9', true, u_sarah),
    (c_brightleaf, 'Brightleaf Skincare', '#16A34A', true, u_sarah),
    (c_pulse, 'Pulse Analytics', '#D97706', true, u_sarah),
    (c_harbor, 'Harbor & Co. Coffee', '#DB2777', true, u_sarah);

  -- 3. Tasks — 6 per status across the 5 clients, varied type/priority/due dates
  -- To Do
  insert into public.tasks (client_id, title, description, status, priority, task_type, due_date, created_by) values
    (c_nova, 'Draft Q3 Instagram content calendar', 'Plan 12 posts for July-Sept', 'todo', 'medium', 'Strategy', today + 5, u_sarah),
    (c_summit, 'Design new listing flyer template', null, 'todo', 'high', 'Design', today + 2, u_sarah),
    (c_brightleaf, 'Research skincare TikTok trends', null, 'todo', 'low', 'Strategy', today + 10, u_marcus),
    (c_pulse, 'Write landing page copy for new dashboard', null, 'todo', 'urgent', 'Copywriting', today + 1, u_sarah),
    (c_harbor, 'Shoot product photos for fall menu', null, 'todo', 'medium', 'Design', today + 7, u_marcus),
    (c_nova, 'Set up Meta Ads pixel', null, 'todo', 'high', 'Ad Setup', today + 3, u_sarah);

  -- In Progress
  insert into public.tasks (client_id, title, description, status, priority, task_type, due_date, created_by) values
    (c_summit, 'Write blog: "5 tips for first-time buyers"', null, 'in_progress', 'medium', 'Copywriting', today + 4, u_sarah),
    (c_brightleaf, 'Design Instagram carousel — new serum launch', null, 'in_progress', 'high', 'Design', today + 2, u_marcus),
    (c_pulse, 'Google Ads campaign setup', null, 'in_progress', 'urgent', 'Ad Setup', today + 1, u_sarah),
    (c_harbor, 'Edit reel: behind the roast', null, 'in_progress', 'medium', 'Design', today + 3, u_marcus),
    (c_nova, 'Client monthly performance report', null, 'in_progress', 'high', 'Reporting', today + 2, u_sarah),
    (c_summit, 'Update email nurture sequence', null, 'in_progress', 'low', 'Copywriting', today + 6, u_sarah);

  -- Waiting for Client
  insert into public.tasks (client_id, title, description, status, priority, task_type, due_date, created_by) values
    (c_brightleaf, 'Awaiting product samples for photoshoot', null, 'waiting_for_client', 'medium', 'Design', today + 8, u_sarah),
    (c_pulse, 'Awaiting brand guideline approval', null, 'waiting_for_client', 'high', 'Client Request', today + 3, u_sarah),
    (c_harbor, 'Confirm holiday menu items', null, 'waiting_for_client', 'medium', 'Client Request', today + 5, u_marcus),
    (c_nova, 'Awaiting testimonial video release', null, 'waiting_for_client', 'low', 'Client Request', today + 12, u_sarah),
    (c_summit, 'Confirm listing addresses for Q3 campaign', null, 'waiting_for_client', 'medium', 'Client Request', today + 4, u_sarah),
    (c_brightleaf, 'Awaiting influencer contract signature', null, 'waiting_for_client', 'high', 'Client Request', today + 2, u_marcus);

  -- Review
  insert into public.tasks (client_id, title, description, status, priority, task_type, due_date, created_by) values
    (c_pulse, 'Review: new dashboard demo video', null, 'review', 'high', 'Design', today + 1, u_sarah),
    (c_nova, 'Review: August content calendar', null, 'review', 'medium', 'Strategy', today + 2, u_sarah),
    (c_harbor, 'Review: fall menu announcement copy', null, 'review', 'medium', 'Copywriting', today + 1, u_marcus),
    (c_summit, 'Review: listing flyer designs', null, 'review', 'high', 'Design', today, u_sarah),
    (c_brightleaf, 'Review: serum launch ad creative', null, 'review', 'urgent', 'Design', today, u_marcus),
    (c_nova, 'Review: Meta Ads copy variations', null, 'review', 'medium', 'Copywriting', today + 3, u_sarah);

  -- Done
  insert into public.tasks (client_id, title, description, status, priority, task_type, due_date, created_by) values
    (c_summit, 'Publish June newsletter', null, 'done', 'medium', 'Copywriting', today - 5, u_sarah),
    (c_brightleaf, 'Launch spring skincare campaign', null, 'done', 'high', 'Ad Setup', today - 10, u_marcus),
    (c_pulse, 'Complete Q2 analytics report', null, 'done', 'medium', 'Reporting', today - 3, u_sarah),
    (c_harbor, 'Publish summer menu post', null, 'done', 'low', 'Design', today - 7, u_marcus),
    (c_nova, 'Finish onboarding creative brief', null, 'done', 'medium', 'Internal', today - 14, u_sarah),
    (c_summit, 'Set up Google Business profile', null, 'done', 'low', 'Internal', today - 20, u_sarah);

  -- Assignees + platforms for a representative subset of tasks
  for t_id in select id from public.tasks loop
    insert into public.task_assignees (task_id, profile_id)
    values (t_id, (array[u_priya, u_jordan, u_alex, u_taylor])[1 + floor(random() * 4)::int])
    on conflict do nothing;
  end loop;

  for t_id in select id from public.tasks loop
    insert into public.task_platforms (task_id, platform)
    values (t_id, (array['instagram','facebook','tiktok','linkedin','email','website'])[1 + floor(random() * 6)::int])
    on conflict do nothing;
  end loop;

  -- 4. Content items — 4 per client across varied platforms/types/approval statuses
  insert into public.content_items (client_id, title, platform, content_type, publish_at, caption, brief, approval_status, copywriter_id, designer_id, account_manager_id) values
    (c_nova, 'New member spotlight reel', 'instagram', 'reel', now() + interval '1 day', 'Meet Jess, down 20lbs since joining!', 'Highlight a real member success story', 'draft', u_priya, u_alex, u_marcus),
    (c_nova, 'Summer bootcamp announcement', 'facebook', 'post', now() + interval '3 day', 'Summer bootcamp starts July 1 — spots limited!', null, 'internal_review', u_jordan, u_taylor, u_marcus),
    (c_nova, 'Trainer tips carousel', 'instagram', 'carousel', now() + interval '5 day', '5 form tips from our head trainer', null, 'client_review', u_priya, u_alex, u_marcus),
    (c_nova, 'Google Ads — new member promo', 'google_ads', 'ad', now() + interval '2 day', null, 'Promote $0 enrollment fee offer', 'approved', u_jordan, null, u_marcus),

    (c_summit, 'Open house this weekend', 'facebook', 'post', now() + interval '2 day', 'Join us Saturday 12-3pm at 44 Elm St', null, 'approved', u_priya, u_taylor, u_marcus),
    (c_summit, 'First-time buyer blog', 'blog', 'blog', now() + interval '6 day', null, 'SEO blog on first-time homebuyer tips', 'draft', u_jordan, null, u_marcus),
    (c_summit, 'New listing teaser', 'instagram', 'story', now() + interval '1 day', 'Coming soon 👀', null, 'published', u_priya, u_alex, u_marcus),
    (c_summit, 'Market update email', 'email', 'email', now() + interval '4 day', null, 'Monthly market trends newsletter', 'internal_review', u_jordan, null, u_marcus),

    (c_brightleaf, 'Serum launch hero post', 'instagram', 'post', now() + interval '1 day', 'Introducing GlowSerum ✨', 'Launch announcement, link in bio', 'client_review', u_priya, u_alex, u_marcus),
    (c_brightleaf, 'Ingredient spotlight reel', 'tiktok', 'reel', now() + interval '3 day', 'Why niacinamide works', null, 'draft', u_jordan, u_taylor, u_marcus),
    (c_brightleaf, 'Before/after carousel', 'instagram', 'carousel', now() + interval '7 day', '30-day glow up results', null, 'approved', u_priya, u_alex, u_marcus),
    (c_brightleaf, 'Meta Ads — serum launch', 'meta_ads', 'ad', now() + interval '2 day', null, 'Conversion campaign for launch week', 'draft', u_jordan, u_taylor, u_marcus),

    (c_pulse, 'Dashboard demo landing page', 'website', 'landing_page', now() + interval '5 day', null, 'New self-serve demo landing page copy', 'internal_review', u_priya, null, u_marcus),
    (c_pulse, 'LinkedIn thought leadership post', 'linkedin', 'post', now() + interval '2 day', 'Why data literacy matters in 2026', null, 'approved', u_jordan, null, u_marcus),
    (c_pulse, 'Product explainer video script', 'youtube', 'reel', now() + interval '8 day', null, '60-second product explainer script', 'draft', u_priya, u_alex, u_marcus),
    (c_pulse, 'Google Ads — free trial push', 'google_ads', 'ad', now() + interval '1 day', null, 'Drive free trial signups', 'client_review', u_jordan, null, u_marcus),

    (c_harbor, 'Fall menu reveal', 'instagram', 'post', now() + interval '4 day', 'Pumpkin spice is back 🎃☕', null, 'draft', u_priya, u_taylor, u_marcus),
    (c_harbor, 'Behind the roast reel', 'tiktok', 'reel', now() + interval '2 day', 'How we roast our single-origin beans', null, 'approved', u_jordan, u_alex, u_marcus),
    (c_harbor, 'Loyalty program email blast', 'email', 'email', now() + interval '6 day', null, 'Announce new loyalty rewards tiers', 'internal_review', u_priya, null, u_marcus),
    (c_harbor, 'Weekly specials story', 'instagram', 'story', now() + interval '1 day', 'This week: honey lavender latte', null, 'published', u_jordan, u_taylor, u_marcus);

end $$;
