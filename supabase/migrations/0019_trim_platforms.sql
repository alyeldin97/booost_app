-- Platforms are now limited to Facebook, Instagram, TikTok per product
-- decision — trim the rest of the seeded list. No task_platforms/
-- content_items rows referenced the removed platforms at the time of this
-- migration, so this is a plain delete (the FK would otherwise restrict it).
delete from public.platforms
where platform not in ('facebook', 'instagram', 'tiktok');

update public.platforms set position = 0 where platform = 'instagram';
update public.platforms set position = 1 where platform = 'facebook';
update public.platforms set position = 2 where platform = 'tiktok';
