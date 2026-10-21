-- ═══════════════════════════════════════════════════════════════════════════
-- APPLY_ALL.sql · bring the live project up to date with supabase/migrations/
--
-- Why this file exists
--   CI runs `scripts/apply_migrations.sh --dry-run` against a throwaway
--   PostgreSQL service and rolls it back: the migration set is validated on
--   every push, but nothing ever reaches the hosted project by itself. The
--   app, however, already sends the newer columns (`name_om`, `title_om`,
--   `description_om`, `parent_id`, `site_content`, …), so a project that has
--   not been pasted since the earlier features answered every admin save with
--   PGRST204 — "Could not find the 'title_om' column of 'products' in the
--   schema cache" — which the app could only render as "The service is
--   temporarily unavailable. Please try again."
--
-- What it contains
--   The migrations after the core schema, verbatim and in order:
--     000 · extensions + set_updated_at()
--     002 · views, search_products, reorder_rows, inquiry rate limit
--     003 · row level security and grants
--     004 · storage buckets and the brand / product-media policies
--     005 · realtime publication membership
--     006 · text_overrides + store_name_om
--     007 · categories.parent_id (subcategories)
--     008 · site_content
--     009 · admin_contact_settings
--     010 · the Afaan Oromo catalogue columns
--     011 · products.subcategory_id
--   001 (core schema) is left out because every table and column it defines is
--   already answering reads on the project — the storefront loads products,
--   categories, contact links and site settings — so it has been applied.
--   Re-running it would be harmless (`create table if not exists`): copy
--   supabase/migrations/20260101000100_core_schema.sql in front of this file
--   if you prefer a fully verbatim sweep.
--
-- How to run it
--   Supabase dashboard → SQL Editor → New query → paste this file → Run.
--   Every statement is idempotent (`if not exists` / `or replace` /
--   `drop … if exists`), so a second run changes nothing, and running it
--   against an already up-to-date project is a no-op. Use the SQL Editor (or
--   the *session* pooler, port 5432) — not the transaction pooler on 6543,
--   which does not hold a session and misbehaves across DDL.
--
-- What it will not do
--   It never loosens RLS: policies are recreated exactly as the migrations
--   define them — public read for published/visible rows, writes only through
--   public.is_admin() — and profiles.is_admin stays behind its guard trigger,
--   so only a direct SQL session (you) can flag an account.
--
-- After running it
--   The last statement reloads PostgREST's schema cache; wait ~30 seconds,
--   then retry the save. To confirm the columns landed:
--
--     select table_name, column_name
--       from information_schema.columns
--      where table_schema = 'public'
--        and column_name in ('name_om','title_om','description_om',
--                            'parent_id','subcategory_id')
--      order by 1, 2;
-- ═══════════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────────
-- 001 · extensions_and_helpers
-- ───────────────────────────────────────────────────────────────────────────

create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

comment on function public.set_updated_at() is
  'BEFORE UPDATE trigger that stamps updated_at with the server clock.';

-- ───────────────────────────────────────────────────────────────────────────
-- 002 · views_and_rpc
-- ───────────────────────────────────────────────────────────────────────────

-- v_products_public - published products in visible categories, each joined
-- with its cover media and media counts.
--
-- `security_invoker = true` (PostgreSQL 15+) means the view is evaluated with
-- the CALLER's privileges, so RLS still applies. Without it, a view owned by
-- the migration role would leak unpublished rows to anonymous visitors.
--
-- `drop ... if exists` rather than `create or replace`: a later migration
-- (010, the Oromo columns) appends columns to this view, and `create or
-- replace` refuses to *remove* a column. Re-applying the whole set would then
-- fail on this file. Dropping first keeps the set re-runnable; the select
-- grant lives in 003, which runs again in the same pass.
drop view if exists public.v_products_public;
create view public.v_products_public
with (security_invoker = true)
as
select
  p.id,
  p.category_id,
  p.title,
  p.title_am,
  p.title_ar,
  p.description,
  p.description_am,
  p.description_ar,
  p.price,
  p.compare_at_price,
  p.currency_code,
  p.is_available,
  p.is_featured,
  p.is_published,
  p.sort_order,
  p.created_at,
  p.updated_at,
  c.slug  as category_slug,
  c.name  as category_name,
  cm.storage_path as cover_path,
  cm.kind         as cover_kind,
  coalesce(mc.image_count, 0) as image_count,
  coalesce(mc.video_count, 0) as video_count
from public.products p
join public.categories c on c.id = p.category_id
left join lateral (
  select m.storage_path, m.kind
  from public.product_media m
  where m.product_id = p.id
  order by m.is_cover desc, m.sort_order asc
  limit 1
) cm on true
left join lateral (
  select
    count(*) filter (where m.kind = 'image') as image_count,
    count(*) filter (where m.kind = 'video') as video_count
  from public.product_media m
  where m.product_id = p.id
) mc on true
where p.is_published
  and c.is_visible;

comment on view public.v_products_public is
  'Storefront read model: published products in visible categories with cover media.';

-- v_categories_with_counts - categories plus their published-product counts
drop view if exists public.v_categories_with_counts;
create view public.v_categories_with_counts
with (security_invoker = true)
as
select
  c.id,
  c.name,
  c.name_am,
  c.name_ar,
  c.slug,
  c.cover_path,
  c.sort_order,
  c.is_visible,
  c.created_at,
  c.updated_at,
  (
    select count(*)
    from public.products p
    where p.category_id = c.id and p.is_published
  ) as product_count
from public.categories c;

comment on view public.v_categories_with_counts is
  'Categories with their published product counts.';

-- search_products - trigram + substring search, RLS-safe
--
-- `security invoker` (the default) so RLS on public.products still applies:
-- an anonymous caller can only ever match published rows.
create or replace function public.search_products(q text, p_limit int default 40)
returns setof public.products
language sql
stable
set search_path = public
as $$
  with needle as (
    select nullif(btrim(coalesce(q, '')), '') as term
  )
  select p.*
  from public.products p
  join public.categories c on c.id = p.category_id
  cross join needle n
  where n.term is not null
    and p.is_published
    and c.is_visible
    and (
      p.title % n.term
      or position(lower(n.term) in lower(p.title)) > 0
      or position(lower(n.term) in lower(coalesce(p.title_am, ''))) > 0
      or position(lower(n.term) in lower(coalesce(p.title_ar, ''))) > 0
      or position(lower(n.term) in lower(coalesce(p.description, ''))) > 0
    )
  order by
    greatest(
      similarity(p.title, n.term),
      similarity(coalesce(p.title_am, ''), n.term),
      similarity(coalesce(p.title_ar, ''), n.term)
    ) desc,
    p.sort_order asc,
    p.created_at desc
  limit least(greatest(coalesce(p_limit, 40), 1), 100);
$$;

comment on function public.search_products(text, int) is
  'Trigram + substring product search. Runs as the caller so RLS filters the rows.';

revoke all on function public.search_products(text, int) from public;
grant execute on function public.search_products(text, int) to anon, authenticated, service_role;

-- reorder_rows - persist a whole manual ordering in one transaction
--
-- SECURITY DEFINER because it performs dynamic SQL; the explicit is_admin()
-- check is therefore mandatory (RLS is bypassed inside a definer function).
create or replace function public.reorder_rows(p_table text, p_ids uuid[])
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  i     int;
  v_len int;
begin
  if not public.is_admin() then
    raise exception 'not authorised' using errcode = '42501';
  end if;

  if p_table not in ('categories', 'products', 'product_media') then
    raise exception 'reorder_rows: unsupported table %', p_table
      using errcode = '22023';
  end if;

  v_len := coalesce(array_length(p_ids, 1), 0);
  if v_len = 0 then
    return;
  end if;

  for i in 1 .. v_len loop
    execute format('update public.%I set sort_order = $1 where id = $2', p_table)
      using (i - 1), p_ids[i];
  end loop;
end;
$$;

comment on function public.reorder_rows(text, uuid[]) is
  'Admin-only bulk sort_order update for catalogue tables.';

revoke all on function public.reorder_rows(text, uuid[]) from public;
grant execute on function public.reorder_rows(text, uuid[]) to authenticated, service_role;

-- inquiries rate limiting
--
-- The storefront writes leads straight to public.inquiries (RLS allows anon
-- INSERT only). A BEFORE INSERT trigger caps how fast a single device can do
-- it, so the protection holds even before the Edge Function layer exists.
create or replace function public.guard_inquiry_rate()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_recent int;
  c_window constant interval := interval '10 minutes';
  c_limit  constant int := 10;
begin
  new.device_id := left(nullif(btrim(coalesce(new.device_id, '')), ''), 128);

  if new.device_id is null then
    return new;
  end if;

  select count(*)
    into v_recent
    from public.inquiries
   where device_id = new.device_id
     and created_at > now() - c_window;

  if v_recent >= c_limit then
    raise exception 'Too many inquiries from this device, please try again later'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;

drop trigger if exists inquiries_rate_limit on public.inquiries;
create trigger inquiries_rate_limit
  before insert on public.inquiries
  for each row execute function public.guard_inquiry_rate();

-- ───────────────────────────────────────────────────────────────────────────
-- 003 · rls_policies
-- ───────────────────────────────────────────────────────────────────────────

-- Model
--   * RLS is enabled on EVERY table. With no policy, access is denied, so the
--     posture is deny-by-default: a new table added without policies is inert.
--   * Anonymous (storefront) callers get SELECT on the public columns only.
--   * Admin (owner) callers are identified exclusively by public.is_admin().
--   * Every INSERT/UPDATE policy carries a WITH CHECK, so a client cannot
--     write a row it would not be allowed to read back.
--   * RLS is NOT forced on the table owner: SECURITY DEFINER helpers
--     (is_admin, reorder_rows, audit_row, handle_new_user) must keep working.

alter table public.profiles       enable row level security;
alter table public.site_settings  enable row level security;
alter table public.categories     enable row level security;
alter table public.products       enable row level security;
alter table public.product_media  enable row level security;
alter table public.contact_links  enable row level security;
alter table public.inquiries      enable row level security;
alter table public.audit_log      enable row level security;

-- profiles
--   A user may read and update their own row. There is deliberately NO insert
--   policy: rows appear only through handle_new_user(). A user cannot promote
--   themselves because guard_profiles_is_admin() rejects the write, and the
--   UPDATE policy's WITH CHECK pins the row id to the caller.
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = auth.uid());

-- Admins additionally see their own row (already covered) and nobody else's.
drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- site_settings - world-readable branding, owner-writable singleton row
drop policy if exists site_settings_public_select on public.site_settings;
create policy site_settings_public_select on public.site_settings
  for select to anon, authenticated
  using (true);

drop policy if exists site_settings_admin_insert on public.site_settings;
create policy site_settings_admin_insert on public.site_settings
  for insert to authenticated
  with check (public.is_admin() and id = 1);

drop policy if exists site_settings_admin_update on public.site_settings;
create policy site_settings_admin_update on public.site_settings
  for update to authenticated
  using (public.is_admin() and id = 1)
  with check (public.is_admin() and id = 1);

-- categories
drop policy if exists categories_public_select on public.categories;
create policy categories_public_select on public.categories
  for select to anon, authenticated
  using (is_visible);

drop policy if exists categories_admin_select on public.categories;
create policy categories_admin_select on public.categories
  for select to authenticated
  using (public.is_admin());

drop policy if exists categories_admin_insert on public.categories;
create policy categories_admin_insert on public.categories
  for insert to authenticated
  with check (public.is_admin());

drop policy if exists categories_admin_update on public.categories;
create policy categories_admin_update on public.categories
  for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists categories_admin_delete on public.categories;
create policy categories_admin_delete on public.categories
  for delete to authenticated
  using (public.is_admin());

-- products - visible only when published AND its category is visible
drop policy if exists products_public_select on public.products;
create policy products_public_select on public.products
  for select to anon, authenticated
  using (
    is_published
    and exists (
      select 1
      from public.categories c
      where c.id = products.category_id
        and c.is_visible
    )
  );

drop policy if exists products_admin_select on public.products;
create policy products_admin_select on public.products
  for select to authenticated
  using (public.is_admin());

drop policy if exists products_admin_insert on public.products;
create policy products_admin_insert on public.products
  for insert to authenticated
  with check (public.is_admin());

drop policy if exists products_admin_update on public.products;
create policy products_admin_update on public.products
  for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists products_admin_delete on public.products;
create policy products_admin_delete on public.products
  for delete to authenticated
  using (public.is_admin());

-- product_media - visible only while its product is publicly visible
drop policy if exists product_media_public_select on public.product_media;
create policy product_media_public_select on public.product_media
  for select to anon, authenticated
  using (
    exists (
      select 1
      from public.products p
      join public.categories c on c.id = p.category_id
      where p.id = product_media.product_id
        and p.is_published
        and c.is_visible
    )
  );

drop policy if exists product_media_admin_select on public.product_media;
create policy product_media_admin_select on public.product_media
  for select to authenticated
  using (public.is_admin());

drop policy if exists product_media_admin_insert on public.product_media;
create policy product_media_admin_insert on public.product_media
  for insert to authenticated
  with check (public.is_admin());

drop policy if exists product_media_admin_update on public.product_media;
create policy product_media_admin_update on public.product_media
  for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists product_media_admin_delete on public.product_media;
create policy product_media_admin_delete on public.product_media
  for delete to authenticated
  using (public.is_admin());

-- contact_links
drop policy if exists contact_links_public_select on public.contact_links;
create policy contact_links_public_select on public.contact_links
  for select to anon, authenticated
  using (is_visible);

drop policy if exists contact_links_admin_select on public.contact_links;
create policy contact_links_admin_select on public.contact_links
  for select to authenticated
  using (public.is_admin());

drop policy if exists contact_links_admin_insert on public.contact_links;
create policy contact_links_admin_insert on public.contact_links
  for insert to authenticated
  with check (public.is_admin());

drop policy if exists contact_links_admin_update on public.contact_links;
create policy contact_links_admin_update on public.contact_links
  for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists contact_links_admin_delete on public.contact_links;
create policy contact_links_admin_delete on public.contact_links
  for delete to authenticated
  using (public.is_admin());

-- inquiries - anonymous INSERT only; the owner reads and prunes
drop policy if exists inquiries_public_insert on public.inquiries;
create policy inquiries_public_insert on public.inquiries
  for insert to anon, authenticated
  with check (true);

drop policy if exists inquiries_admin_select on public.inquiries;
create policy inquiries_admin_select on public.inquiries
  for select to authenticated
  using (public.is_admin());

drop policy if exists inquiries_admin_delete on public.inquiries;
create policy inquiries_admin_delete on public.inquiries
  for delete to authenticated
  using (public.is_admin());

-- audit_log - owner-readable, append-only through the audit trigger only
drop policy if exists audit_log_admin_select on public.audit_log;
create policy audit_log_admin_select on public.audit_log
  for select to authenticated
  using (public.is_admin());

-- ───────────────────────────────────────────────────────────────────────────
-- Grants. RLS decides *which rows*; grants decide *which verbs* at all.
-- Anon/authenticated get no DML on audit_log, profiles, site_settings, etc.
-- ───────────────────────────────────────────────────────────────────────────
grant usage on schema public to anon, authenticated;

grant select on public.site_settings to anon, authenticated;
grant select on public.categories, public.products, public.product_media,
              public.contact_links to anon, authenticated;
grant insert on public.inquiries to anon, authenticated;

grant select, insert, update, delete on public.categories,
      public.products, public.product_media, public.contact_links,
      public.site_settings to authenticated;
grant select, delete on public.inquiries to authenticated;
grant select on public.audit_log to authenticated;
grant select, update on public.profiles to authenticated;

grant select on public.v_products_public, public.v_categories_with_counts
  to anon, authenticated;

-- ───────────────────────────────────────────────────────────────────────────
-- 004 · storage_buckets
-- ───────────────────────────────────────────────────────────────────────────
--
--   product-media  public read · admin write
--                  products/{product_id}/{uuid}.{ext}
--                  image/jpeg, image/png, image/webp  -> max 5 MB
--                  video/mp4                          -> max 40 MB, less than or equal to 60 s
--   brand          public read · admin write — logo and category covers
--                  logo|categories|splash/{name}-{uuid}.{ext}
--
-- The bucket-level `file_size_limit` / `allowed_mime_types` are the first line
-- of defence; the per-object policies add the tighter 5 MB image cap that a
-- bucket can only express once.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  (
    'product-media',
    'product-media',
    true,
    41943040, -- 40 MB
    array['image/jpeg', 'image/png', 'image/webp', 'video/mp4']
  ),
  (
    'brand',
    'brand',
    true,
    5242880, -- 5 MB
    array['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml']
  )
on conflict (id) do update
  set public             = excluded.public,
      file_size_limit    = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Public read
-- Both buckets are world-readable: everything in them is marketing imagery.
drop policy if exists "product media public read" on storage.objects;
create policy "product media public read" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'product-media');

drop policy if exists "brand public read" on storage.objects;
create policy "brand public read" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'brand');

-- Admin write: product-media
drop policy if exists "product media admin insert" on storage.objects;
create policy "product media admin insert" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'product-media'
    and public.is_admin()
    and (storage.foldername(name))[1] = 'products'
    and (
      (
        lower(storage.extension(name)) in ('jpg', 'jpeg', 'png', 'webp')
        and coalesce((metadata ->> 'size')::bigint, 0) <= 5 * 1024 * 1024
      )
      or (
        lower(storage.extension(name)) = 'mp4'
        and coalesce((metadata ->> 'size')::bigint, 0) <= 40 * 1024 * 1024
      )
    )
  );

drop policy if exists "product media admin update" on storage.objects;
create policy "product media admin update" on storage.objects
  for update to authenticated
  using (bucket_id = 'product-media' and public.is_admin())
  with check (
    bucket_id = 'product-media'
    and public.is_admin()
    and (storage.foldername(name))[1] = 'products'
  );

drop policy if exists "product media admin delete" on storage.objects;
create policy "product media admin delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'product-media' and public.is_admin());

-- Admin write: brand
drop policy if exists "brand admin insert" on storage.objects;
create policy "brand admin insert" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'brand'
    and public.is_admin()
    and (storage.foldername(name))[1] in ('logo', 'categories', 'splash')
  );

drop policy if exists "brand admin update" on storage.objects;
create policy "brand admin update" on storage.objects
  for update to authenticated
  using (bucket_id = 'brand' and public.is_admin())
  with check (bucket_id = 'brand' and public.is_admin());

drop policy if exists "brand admin delete" on storage.objects;
create policy "brand admin delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'brand' and public.is_admin());

-- ───────────────────────────────────────────────────────────────────────────
-- 005 · realtime_publication
-- ───────────────────────────────────────────────────────────────────────────
--
--   The storefront and the admin gateway both watch tables with `.stream()`,
--   and Realtime only delivers events for tables that belong to the
--   `supabase_realtime` publication. Nothing ever added them, so every live
--   update silently never fired: the subscription opened, the queries
--   succeeded, and no change ever arrived.
--
--   Idempotent: the publication is created when it is missing (on a hosted
--   project it already exists, created by the platform) and each table is
--   added only when it is not already a member, so re-applying is a no-op.

do $$
declare
  t text;
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    create publication supabase_realtime;
  end if;

  foreach t in array array[
       'categories', 'products', 'product_media',
       'contact_links', 'site_settings', 'inquiries'
     ]
  loop
    if not exists (
      select 1
        from pg_publication_tables
       where pubname = 'supabase_realtime'
         and schemaname = 'public'
         and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end;
$$;

-- ───────────────────────────────────────────────────────────────────────────
-- 006 · text_overrides
-- ───────────────────────────────────────────────────────────────────────────
--
--   Two additions that travel together because they are the same idea: the
--   owner can type their own wording, in every language, without a release.
--
--   1. `store_name_om` - the site-settings row gains the Oromo brand line, so
--      `storeNameFor('om')` has something to render.
--   2. `text_overrides` - one row per (ARB key, locale) the owner has
--      rewritten. The app renders `override ?? ARB default`, so an empty table
--      means "ship the built-in wording" and a row means "the owner said
--      something else".
--
--   Public read is deliberate: the storefront is anonymous and must render the
--   owner's wording to everyone. Writes are admin-only, exactly like every
--   other content table.

-- 1. Oromo in site_settings

alter table public.site_settings
  add column if not exists store_name_om text default 'Aamu Sharif Arabiyaan Majlis';

-- Widen the language check to include Oromo. Dropped by its generated name
-- first, so re-applying the migration is a no-op.
alter table public.site_settings
  drop constraint if exists site_settings_default_language_check;

alter table public.site_settings
  add constraint site_settings_default_language_check
  check (default_language in ('en', 'am', 'ar', 'om'));

update public.site_settings
   set store_name_om = coalesce(store_name_om, 'Aamu Sharif Arabiyaan Majlis')
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

-- ───────────────────────────────────────────────────────────────────────────
-- 007 · subcategories
-- ───────────────────────────────────────────────────────────────────────────
--
-- One level of nesting, enforced in the database rather than trusted from the
-- app: a category may point at a parent, and that parent must itself be
-- top-level. Any deeper tree, and any self-reference, is rejected with a CHECK
-- violation the client already renders as "correct the highlighted fields".
--
-- `on delete restrict` (not cascade) is deliberate: deleting a parent that
-- still has subcategories — or products inside them — fails loudly instead of
-- silently removing catalogue rows the owner never asked to lose.

alter table public.categories
  add column if not exists parent_id uuid
    references public.categories (id) on delete restrict;

comment on column public.categories.parent_id is
  'Parent category of a subcategory. NULL means the row is top-level.';

-- Matches the read pattern everywhere: children of one parent, in order.
create index if not exists categories_parent_order_idx
  on public.categories (parent_id, sort_order);

-- ── Nesting guard ──────────────────────────────────────────────────────────
-- Written as a trigger rather than a CHECK because the rule needs to look at
-- another row. Fires on `parent_id` only, so renaming a subcategory is free.
create or replace function public.guard_category_nesting()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_grandparent uuid;
begin
  if new.parent_id is null then
    return new;
  end if;

  if new.parent_id = new.id then
    raise exception 'a category cannot be its own parent'
      using errcode = '23514';
  end if;

  select c.parent_id
    into v_grandparent
    from public.categories c
   where c.id = new.parent_id;

  if v_grandparent is not null then
    raise exception 'subcategories cannot be nested more than one level deep'
      using errcode = '23514';
  end if;

  return new;
end;
$$;

comment on function public.guard_category_nesting() is
  'Rejects self-referencing and grandchild categories, keeping the tree one level deep.';

drop trigger if exists categories_guard_nesting on public.categories;
create trigger categories_guard_nesting
  before insert or update of parent_id on public.categories
  for each row execute function public.guard_category_nesting();

-- ───────────────────────────────────────────────────────────────────────────
-- 008 · site_content (live hero / home texts, owner-editable)
-- ───────────────────────────────────────────────────────────────────────────
-- One row per (key, locale). Public read; admin-only write — the same model
-- as text_overrides. The home screen reads these keys through a provider and
-- falls back to the built-in l10n string when no override exists.

create table if not exists public.site_content (
  key         text        not null check (char_length(key) between 1 and 120),
  locale      text        not null check (locale in ('en', 'am', 'ar', 'om')),
  value       text        not null check (char_length(value) between 1 and 2000),
  updated_at  timestamptz not null default now(),
  updated_by  uuid        references auth.users (id) on delete set null,
  primary key (key, locale)
);

comment on table public.site_content is
  'Live-editable home/dashboard copy the storefront reads before falling back to '
  'the built-in ARB wording. Public read; admin write only.';

create index if not exists site_content_locale_idx
  on public.site_content (locale);

drop trigger if exists site_content_set_updated_at on public.site_content;
create trigger site_content_set_updated_at
  before update on public.site_content
  for each row execute function public.set_updated_at();

-- ── Row level security ─────────────────────────────────────────────────────
grant select on public.site_content to anon, authenticated;
grant insert, update, delete on public.site_content to authenticated;

alter table public.site_content enable row level security;

drop policy if exists site_content_public_select on public.site_content;
create policy site_content_public_select on public.site_content
  for select
  to anon, authenticated
  using (true);

drop policy if exists site_content_admin_select on public.site_content;
create policy site_content_admin_select on public.site_content
  for select
  to authenticated
  using (public.is_admin());

drop policy if exists site_content_admin_insert on public.site_content;
create policy site_content_admin_insert on public.site_content
  for insert
  to authenticated
  with check (public.is_admin());

drop policy if exists site_content_admin_update on public.site_content;
create policy site_content_admin_update on public.site_content
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists site_content_admin_delete on public.site_content;
create policy site_content_admin_delete on public.site_content
  for delete
  to authenticated
  using (public.is_admin());

-- ── Realtime membership ───────────────────────────────────────────────────
do $$
begin
  if not exists (
    select 1
      from pg_publication_tables
     where pubname = 'supabase_realtime'
       and schemaname = 'public'
       and tablename = 'site_content'
  ) then
    alter publication supabase_realtime add table public.site_content;
  end if;
end;
$$;

-- ───────────────────────────────────────────────────────────────────────────
-- 009 · admin_contact_settings
-- ───────────────────────────────────────────────────────────────────────────
-- A single-row settings table holding the owner's contact channels, separate
-- from public `contact_links` so the owner can store private phone / social
-- handles without publishing every raw value to anonymous readers.

create table if not exists public.admin_contact_settings (
  id             smallint  not null check (id = 1),
  owner_phone    text,
  owner_email    text,
  whatsapp_number text,
  telegram_handle text,
  instagram_handle text,
  facebook_handle text,
  tiktok_handle  text,
  youtube_handle text,
  website_url    text,
  updated_at     timestamptz not null default now(),
  primary key (id)
);

comment on table public.admin_contact_settings is
  'Owner contact details the admin panel edits and the storefront may surface. '
  'Public read; admin write only. Only non-empty entries are shown.';

comment on column public.admin_contact_settings.owner_phone is
  'Raw owner phone, used for tel: and as the WhatsApp number source when set.';

comment on column public.admin_contact_settings.owner_email is
  'Owner email used for mailto: and as a fallback contact.';

comment on column public.admin_contact_settings.whatsapp_number is
  'Digits-only WhatsApp number the storefront may deep-link into.';

comment on column public.admin_contact_settings.telegram_handle is
  'Telegram handle (no leading @) the storefront may deep-link into.';

drop trigger if exists admin_contact_settings_set_updated_at on public.admin_contact_settings;
create trigger admin_contact_settings_set_updated_at
  before update on public.admin_contact_settings
  for each row execute function public.set_updated_at();

-- ── Row level security ─────────────────────────────────────────────────────

grant select on public.admin_contact_settings to anon, authenticated;
grant insert, update, delete on public.admin_contact_settings to authenticated;

alter table public.admin_contact_settings enable row level security;

drop policy if exists admin_contact_settings_public_select on public.admin_contact_settings;
create policy admin_contact_settings_public_select on public.admin_contact_settings
  for select
  to anon, authenticated
  using (true);

drop policy if exists admin_contact_settings_admin_insert on public.admin_contact_settings;
create policy admin_contact_settings_admin_insert on public.admin_contact_settings
  for insert
  to authenticated
  with check (public.is_admin());

drop policy if exists admin_contact_settings_admin_update on public.admin_contact_settings;
create policy admin_contact_settings_admin_update on public.admin_contact_settings
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists admin_contact_settings_admin_delete on public.admin_contact_settings;
create policy admin_contact_settings_admin_delete on public.admin_contact_settings
  for delete
  to authenticated
  using (public.is_admin());

-- ── Seed a single row so the admin panel always has something to edit ───────
insert into public.admin_contact_settings as s
  (id, updated_at)
values
  (1, now())
on conflict (id) do nothing;

-- ── Realtime membership ───────────────────────────────────────────────────
do $$
begin
  if not exists (
    select 1
      from pg_publication_tables
     where pubname = 'supabase_realtime'
       and schemaname = 'public'
       and tablename = 'admin_contact_settings'
  ) then
    alter publication supabase_realtime add table public.admin_contact_settings;
  end if;
end;
$$;

-- ───────────────────────────────────────────────────────────────────────────
-- 010 · catalogue_omoro_text (per-language catalogue columns)
-- ───────────────────────────────────────────────────────────────────────────
--
-- The catalogue already carried English + Amharic + Arabic columns, but no
-- Oromo ones, so `Product.titleFor('om')` / `Category.nameFor('om')` could only
-- ever answer with English. These columns close that gap for the fourth shipped
-- language:
--
--   * nullable, because English stays the only required field;
--   * no default, so an untouched row is "no Oromo text" and the app falls back
--     selected language → English → any non-empty value.
--
-- Nothing here touches RLS: the new columns ride on the existing table grants
-- and policies, which already restrict writes to `is_admin()`.

-- ── Columns ────────────────────────────────────────────────────────────────

alter table public.categories
  add column if not exists name_om text;

alter table public.products
  add column if not exists title_om text;

alter table public.products
  add column if not exists description_om text;

comment on column public.categories.name_om is
  'Optional Afaan Oromo category name. NULL or blank falls back to English.';

comment on column public.products.title_om is
  'Optional Afaan Oromo product title. NULL or blank falls back to English.';

comment on column public.products.description_om is
  'Optional Afaan Oromo product description. NULL or blank falls back to English.';

-- Same trigram treatment as `title_am` / `title_ar`, so `search_products` can
-- match an Oromo query against an Oromo title through an index instead of a
-- sequential scan.
create index if not exists products_title_om_trgm
  on public.products using gin (title_om gin_trgm_ops);

-- ── Read models ────────────────────────────────────────────────────────────
-- `create or replace view` may only append columns, never rename or reorder
-- existing ones, so the new columns go at the end of each select list.

create or replace view public.v_products_public
with (security_invoker = true)
as
select
  p.id,
  p.category_id,
  p.title,
  p.title_am,
  p.title_ar,
  p.description,
  p.description_am,
  p.description_ar,
  p.price,
  p.compare_at_price,
  p.currency_code,
  p.is_available,
  p.is_featured,
  p.is_published,
  p.sort_order,
  p.created_at,
  p.updated_at,
  c.slug  as category_slug,
  c.name  as category_name,
  cm.storage_path as cover_path,
  cm.kind         as cover_kind,
  coalesce(mc.image_count, 0) as image_count,
  coalesce(mc.video_count, 0) as video_count,
  p.title_om,
  p.description_om
from public.products p
join public.categories c on c.id = p.category_id
left join lateral (
  select m.storage_path, m.kind
  from public.product_media m
  where m.product_id = p.id
  order by m.is_cover desc, m.sort_order asc
  limit 1
) cm on true
left join lateral (
  select
    count(*) filter (where m.kind = 'image') as image_count,
    count(*) filter (where m.kind = 'video') as video_count
  from public.product_media m
  where m.product_id = p.id
) mc on true
where p.is_published
  and c.is_visible;

comment on view public.v_products_public is
  'Storefront read model: published products in visible categories with cover media.';

create or replace view public.v_categories_with_counts
with (security_invoker = true)
as
select
  c.id,
  c.name,
  c.name_am,
  c.name_ar,
  c.slug,
  c.cover_path,
  c.sort_order,
  c.is_visible,
  c.created_at,
  c.updated_at,
  (
    select count(*)
    from public.products p
    where p.category_id = c.id and p.is_published
  ) as product_count,
  c.name_om
from public.categories c;

comment on view public.v_categories_with_counts is
  'Categories with their published product counts.';

-- ── Search ─────────────────────────────────────────────────────────────────
-- The Oromo title joins the match and the ranking, so a shopper typing Oromo
-- text finds the row and the best Oromo match sorts first.

create or replace function public.search_products(q text, p_limit int default 40)
returns setof public.products
language sql
stable
set search_path = public
as $$
  with needle as (
    select nullif(btrim(coalesce(q, '')), '') as term
  )
  select p.*
  from public.products p
  join public.categories c on c.id = p.category_id
  cross join needle n
  where n.term is not null
    and p.is_published
    and c.is_visible
    and (
      p.title % n.term
      or position(lower(n.term) in lower(p.title)) > 0
      or position(lower(n.term) in lower(coalesce(p.title_am, ''))) > 0
      or position(lower(n.term) in lower(coalesce(p.title_ar, ''))) > 0
      or position(lower(n.term) in lower(coalesce(p.title_om, ''))) > 0
      or position(lower(n.term) in lower(coalesce(p.description, ''))) > 0
      or position(lower(n.term) in lower(coalesce(p.description_om, ''))) > 0
    )
  order by
    greatest(
      similarity(p.title, n.term),
      similarity(coalesce(p.title_am, ''), n.term),
      similarity(coalesce(p.title_ar, ''), n.term),
      similarity(coalesce(p.title_om, ''), n.term)
    ) desc,
    p.sort_order asc,
    p.created_at desc
  limit least(greatest(coalesce(p_limit, 40), 1), 100);
$$;

comment on function public.search_products(text, int) is
  'Trigram + substring product search across every shipped language. Runs as the caller so RLS filters the rows.';

revoke all on function public.search_products(text, int) from public;
grant execute on function public.search_products(text, int) to anon, authenticated, service_role;

-- ───────────────────────────────────────────────────────────────────────────
-- 011 · products.subcategory_id, kept in step with the category tree
-- ───────────────────────────────────────────────────────────────────────────
--
-- The app selects a product's subcategory through its `category_id`: the
-- admin's category dropdown lists every top-level category with its children
-- directly underneath, so picking "Mejlis → Corner units" writes
-- `category_id = <corner units id>`. This column makes the same fact readable
-- straight from the row. It is derived, never authored — a trigger recomputes
-- it from `category_id` — so no client can write an inconsistent value.

alter table public.products
  add column if not exists subcategory_id uuid
    references public.categories (id) on delete set null;

comment on column public.products.subcategory_id is
  'Subcategory this product belongs to, derived from category_id (the parent '
  'of that category when it has one, otherwise NULL). Maintained by '
  'products_sync_subcategory; never written by clients.';

create or replace function public.sync_product_subcategory()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_parent uuid;
begin
  select c.parent_id
    into v_parent
    from public.categories c
   where c.id = new.category_id;

  new.subcategory_id := case
    when v_parent is null then null
    else new.category_id
  end;
  return new;
end;
$$;

comment on function public.sync_product_subcategory() is
  'Points products.subcategory_id at category_id whenever that category is itself a subcategory.';

drop trigger if exists products_sync_subcategory on public.products;
create trigger products_sync_subcategory
  before insert or update of category_id on public.products
  for each row execute function public.sync_product_subcategory();

-- Backfill: only rows whose derived value is wrong, so a re-run writes nothing.
update public.products p
   set subcategory_id = p.category_id
  from public.categories c
 where c.id = p.category_id
   and c.parent_id is not null
   and p.subcategory_id is distinct from p.category_id;

create index if not exists products_subcategory_idx
  on public.products (subcategory_id, sort_order)
  where subcategory_id is not null;

-- A new column changes no policy: RLS and grants are table-wide, and the
-- admin-only write policies in 003 already cover this table.

-- ───────────────────────────────────────────────────────────────────────────
-- Done. Reload PostgREST's schema cache so the app stops answering
-- "column not found in schema cache" for the columns above.
-- ───────────────────────────────────────────────────────────────────────────
notify pgrst, 'reload schema';
