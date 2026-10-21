-- 006 - Live text overrides + Oromo store name
--
--   Two additions that travel together because they are the same idea: the
--   owner can type their own wording, in every language, without a release.
--
--   1. `store_name_om` - the site-settings row gains the Oromo brand line, so
--      `storeNameFor('om')` has something to render (see
--      `SiteSettings.storeNameFor`).
--
--   2. `text_overrides` - one row per (ARB key, locale) the owner has
--      rewritten. The app renders `override ?? ARB default`, so an empty table
--      means "ship the built-in wording" and a row means "the owner said
--      something else".
--
--   Keyed on the ARB key rather than on a screen, so the same row feeds both
--   the in-place pencils and the full editor, and a future key rename is the
--   only thing that can orphan a row.
--
--   Public read is deliberate: the storefront is anonymous and must render the
--   owner's wording to everyone. Writes are admin-only, exactly like every
--   other content table.
--
--   Idempotent: safe to re-apply. Realtime membership is added here (not in
--   005) because group 11 of the RLS suite asserts the publication against the
--   tables the Dart layer streams.

-- 1. Oromo in site_settings

alter table public.site_settings
  add column if not exists store_name_om text default 'Amusheriff Arabiyaan Majlis fi Meeshaa Manaa';

-- Widen the language check to include Oromo. Dropped by its generated name
-- first, so re-applying the migration is a no-op.
alter table public.site_settings
  drop constraint if exists site_settings_default_language_check;

alter table public.site_settings
  add constraint site_settings_default_language_check
  check (default_language in ('en', 'am', 'ar', 'om'));

update public.site_settings
   set store_name_om = coalesce(store_name_om, 'Amusheriff Arabiyaan Majlis fi Meeshaa Manaa')
 where id = 1;

-- 2. text_overrides

create table if not exists public.text_overrides (
  text_key    text        not null check (char_length(text_key) between 1 and 120),
  locale      text        not null check (locale in ('en', 'am', 'ar', 'om')),
  value       text        not null check (char_length(value) between 1 and 2000),
  updated_at  timestamptz not null default now(),
  updated_by  uuid        references auth.users (id) on delete set null,
  primary key (text_key, locale)
);

comment on table public.text_overrides is
  'Owner-authored replacements for built-in UI strings, one row per ARB key and '
  'locale. The app renders override ?? ARB default, so deleting a row restores '
  'the shipped wording.';

create index if not exists text_overrides_locale_idx
  on public.text_overrides (locale);

drop trigger if exists text_overrides_set_updated_at on public.text_overrides;
create trigger text_overrides_set_updated_at
  before update on public.text_overrides
  for each row execute function public.set_updated_at();

-- 3. Row level security
-- Everyone reads (the storefront is anonymous); only the owner writes.
-- Table privileges first, then policies: a policy on a table the caller has no
-- grant for is never even consulted.

grant select on public.text_overrides to anon, authenticated;
grant insert, update, delete on public.text_overrides to authenticated;

alter table public.text_overrides enable row level security;

drop policy if exists text_overrides_public_select on public.text_overrides;
create policy text_overrides_public_select on public.text_overrides
  for select
  to anon, authenticated
  using (true);

drop policy if exists text_overrides_admin_select on public.text_overrides;
create policy text_overrides_admin_select on public.text_overrides
  for select
  to authenticated
  using (public.is_admin());

drop policy if exists text_overrides_admin_insert on public.text_overrides;
create policy text_overrides_admin_insert on public.text_overrides
  for insert
  to authenticated
  with check (public.is_admin());

drop policy if exists text_overrides_admin_update on public.text_overrides;
create policy text_overrides_admin_update on public.text_overrides
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists text_overrides_admin_delete on public.text_overrides;
create policy text_overrides_admin_delete on public.text_overrides
  for delete
  to authenticated
  using (public.is_admin());

-- 4. Realtime
-- The editor writes, every open device re-renders: the same promise the rest
-- of the storefront makes.

do $$
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    create publication supabase_realtime;
  end if;

  if not exists (
    select 1
      from pg_publication_tables
     where pubname = 'supabase_realtime'
       and schemaname = 'public'
       and tablename = 'text_overrides'
  ) then
    alter publication supabase_realtime add table public.text_overrides;
  end if;
end;
$$;
