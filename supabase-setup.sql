-- =====================================================================
-- ATCHÉ — Complete Supabase Setup
-- Run this entire script once in your Supabase SQL Editor.
-- Dashboard → SQL Editor → New Query → paste → Run
-- =====================================================================


-- ── 1. ROSTER DATA (shared talent, notes, events) ──────────────────
--
-- One row per user. Xavier's row is the source of truth.
-- Monet reads and writes to Xavier's row via the shared-row pattern.

create table if not exists roster_data (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  models     jsonb        not null default '[]'::jsonb,
  notes      text         not null default '',
  events     jsonb        not null default '[]'::jsonb,
  updated_at timestamptz  not null default now()
);

-- Keep updated_at current automatically
create or replace function touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists roster_data_touch on roster_data;
create trigger roster_data_touch
  before update on roster_data
  for each row execute procedure touch_updated_at();


-- ── 2. RLS FOR ROSTER_DATA ──────────────────────────────────────────
--
-- SELECT / UPDATE: any authenticated user (Monet can read Xavier's row)
-- INSERT: only your own row (each person seeds their own row once)

alter table roster_data enable row level security;

-- Drop old policies first so re-running the script is safe
drop policy if exists "roster_select"       on roster_data;
drop policy if exists "roster_update"       on roster_data;
drop policy if exists "roster_insert"       on roster_data;
drop policy if exists "authenticated_select" on roster_data;
drop policy if exists "authenticated_update" on roster_data;
drop policy if exists "own_insert"           on roster_data;

create policy "roster_select" on roster_data
  for select using (auth.uid() is not null);

create policy "roster_update" on roster_data
  for update using (auth.uid() is not null);

create policy "roster_insert" on roster_data
  for insert with check (auth.uid() = user_id);


-- ── 3. VENUE PIPELINE ───────────────────────────────────────────────
--
-- Individual venue rows — both users can see and edit all venues.

create table if not exists atche_venues (
  id             uuid         primary key default gen_random_uuid(),
  user_id        uuid         references auth.users(id) on delete set null,
  name           text         not null default '',
  contact        text,
  ig             text,
  pipeline_stage text         not null default 'Prospecting',
  notes          text,
  next_follow_up date,
  last_contact   date,
  created_at     timestamptz  not null default now(),
  updated_at     timestamptz  not null default now()
);

drop trigger if exists atche_venues_touch on atche_venues;
create trigger atche_venues_touch
  before update on atche_venues
  for each row execute procedure touch_updated_at();

alter table atche_venues enable row level security;

drop policy if exists "venues_select" on atche_venues;
drop policy if exists "venues_all"    on atche_venues;

create policy "venues_select" on atche_venues
  for select using (auth.uid() is not null);

-- Any authenticated user can insert, update, delete any venue row
create policy "venues_write" on atche_venues
  for all using (auth.uid() is not null)
  with check (auth.uid() is not null);


-- ── 4. SUPABASE STORAGE — profile photos ────────────────────────────
--
-- Bucket: atche-media (public)
-- Photos are uploaded here instead of stored as base64 in the JSONB.
-- Public URL means Monet and anyone with the link can see the image.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'atche-media',
  'atche-media',
  true,
  5242880,          -- 5 MB max per file
  array['image/jpeg','image/png','image/webp','image/gif']
)
on conflict (id) do update set
  public             = true,
  file_size_limit    = 5242880,
  allowed_mime_types = array['image/jpeg','image/png','image/webp','image/gif'];


-- Storage RLS
drop policy if exists "media_public_read"  on storage.objects;
drop policy if exists "media_auth_upload"  on storage.objects;
drop policy if exists "media_auth_update"  on storage.objects;
drop policy if exists "media_auth_delete"  on storage.objects;

-- Anyone (including unauthenticated) can view images
create policy "media_public_read" on storage.objects
  for select using (bucket_id = 'atche-media');

-- Any authenticated user can upload
create policy "media_auth_upload" on storage.objects
  for insert with check (
    bucket_id = 'atche-media'
    and auth.role() = 'authenticated'
  );

-- Any authenticated user can update (replace) a photo
create policy "media_auth_update" on storage.objects
  for update using (
    bucket_id = 'atche-media'
    and auth.role() = 'authenticated'
  );

-- Any authenticated user can delete a photo
create policy "media_auth_delete" on storage.objects
  for delete using (
    bucket_id = 'atche-media'
    and auth.role() = 'authenticated'
  );


-- ── DONE ─────────────────────────────────────────────────────────────
-- After running this script:
--   1. Go to Storage → atche-media → confirm bucket exists and is public
--   2. Open model-tracker.html — photo uploads now go to storage
--   3. Both Xavier and Monet will see the same photos from the public URL
