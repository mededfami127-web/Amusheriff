-- ═══════════════════════════════════════════════════════════════════════════
-- 002 · Core schema
--
-- Design notes
--   * Every table has a uuid primary key (gen_random_uuid()) and timestamptz
--     timestamps, so rows can be merged across devices without conflicts.
--   * `profiles.is_admin` is the ONLY source of authorisation. It lives in the
--     database, never in client-editable metadata.
--   * Media lives in Storage; `product_media.storage_path` is the object key.
-- ═══════════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────────
-- profiles — one row per auth user. The owner is the only admin.
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text,
  is_admin    boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

comment on table public.profiles is
  'Mirror of auth.users plus the is_admin flag. Never writable by clients.';

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- ── is_admin(): the single authorisation predicate ─────────────────────────
-- STABLE + SECURITY DEFINER with a pinned search_path so it can read
-- public.profiles inside a policy on public.profiles itself, and so a caller
-- cannot shadow `profiles` with their own schema.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select p.is_admin from public.profiles p where p.id = auth.uid()),
    false
  );
$$;

comment on function public.is_admin() is
  'True when the authenticated user is the shop owner. Used by every admin RLS policy.';

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated, service_role;

-- ── Provision a profile for every new auth user ────────────────────────────
-- Runs as the definer, so it is the only way a row is ever inserted into
-- public.profiles. New users are NEVER admins.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.email)
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── Privilege-escalation guard ─────────────────────────────────────────────
-- Even if a policy were mis-written, an anon/authenticated API call can never
-- flip is_admin. Only a direct SQL session (the project owner running the
-- documented snippet) or service_role can.
create or replace function public.guard_profiles_is_admin()
returns trigger
language plpgsql
as $$
begin
  if new.is_admin is distinct from old.is_admin
     and current_user in ('anon', 'authenticated') then
    raise exception
      'profiles.is_admin can only be changed by the project owner via SQL (current_user=%)',
      current_user
      using errcode = '42501';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_guard_is_admin on public.profiles;
create trigger profiles_guard_is_admin
  before update on public.profiles
  for each row execute function public.guard_profiles_is_admin();

-- ───────────────────────────────────────────────────────────────────────────
-- site_settings — a single row (id = 1) holding owner-editable branding.
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists public.site_settings (
  id                smallint primary key default 1 check (id = 1),
  store_name_en     text not null default 'Amusheriff Arabiyan Mejlis and Furniture',
  store_name_am     text default 'አሙሸሪፍ አረቢያን መጅሊስ እና ፈርኒቸር',
  store_name_ar     text default 'أمشريف عربيان مجلس والأثاث',
  tagline           text,
  about             text,
  logo_path         text,
  currency_code     text not null default 'ETB',
  default_language  text not null default 'en'
                    check (default_language in ('en', 'am', 'ar')),
  updated_at        timestamptz not null default now()
);

insert into public.site_settings (id)
values (1)
on conflict (id) do nothing;

drop trigger if exists site_settings_set_updated_at on public.site_settings;
create trigger site_settings_set_updated_at
  before update on public.site_settings
  for each row execute function public.set_updated_at();

-- ───────────────────────────────────────────────────────────────────────────
-- categories
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists public.categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(name) between 1 and 80),
  name_am     text,
  name_ar     text,
  slug        text not null unique,
  cover_path  text,
  sort_order  int not null default 0,
  is_visible  boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists categories_visible_order_idx
  on public.categories (is_visible, sort_order);

drop trigger if exists categories_set_updated_at on public.categories;
create trigger categories_set_updated_at
  before update on public.categories
  for each row execute function public.set_updated_at();

-- ───────────────────────────────────────────────────────────────────────────
-- products
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists public.products (
  id                uuid primary key default gen_random_uuid(),
  category_id       uuid not null references public.categories (id) on delete restrict,
  title             text not null check (char_length(title) between 1 and 140),
  title_am          text,
  title_ar          text,
  description       text,
  description_am    text,
  description_ar    text,
  price             numeric(12, 2) not null check (price >= 0),
  compare_at_price  numeric(12, 2)
                    check (compare_at_price is null or compare_at_price >= price),
  currency_code     text not null default 'ETB',
  is_available      boolean not null default true,
  is_featured       boolean not null default false,
  is_published      boolean not null default true,
  sort_order        int not null default 0,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index if not exists products_category_published_order_idx
  on public.products (category_id, is_published, sort_order);

create index if not exists products_featured_idx
  on public.products (is_featured, is_published);

-- Trigram indexes back the search_products RPC. One per searchable title
-- column so the planner can bitmap-OR them.
create index if not exists products_title_trgm
  on public.products using gin (title gin_trgm_ops);
create index if not exists products_title_am_trgm
  on public.products using gin (title_am gin_trgm_ops);
create index if not exists products_title_ar_trgm
  on public.products using gin (title_ar gin_trgm_ops);

drop trigger if exists products_set_updated_at on public.products;
create trigger products_set_updated_at
  before update on public.products
  for each row execute function public.set_updated_at();

-- ───────────────────────────────────────────────────────────────────────────
-- product_media — images and short videos
-- ───────────────────────────────────────────────────────────────────────────
do $$
begin
  if not exists (select 1 from pg_type where typname = 'media_kind') then
    create type public.media_kind as enum ('image', 'video');
  end if;
end;
$$;

create table if not exists public.product_media (
  id                uuid primary key default gen_random_uuid(),
  product_id        uuid not null references public.products (id) on delete cascade,
  kind              public.media_kind not null,
  storage_path      text not null,
  thumbnail_path    text,
  duration_seconds  int check (duration_seconds is null or duration_seconds between 1 and 60),
  is_cover          boolean not null default false,
  sort_order        int not null default 0,
  created_at        timestamptz not null default now()
);

create index if not exists product_media_product_order_idx
  on public.product_media (product_id, sort_order);

-- At most one cover per product.
create unique index if not exists one_cover_per_product
  on public.product_media (product_id)
  where is_cover;

-- ───────────────────────────────────────────────────────────────────────────
-- contact_links — how a customer reaches the owner
-- ───────────────────────────────────────────────────────────────────────────
do $$
begin
  if not exists (select 1 from pg_type where typname = 'contact_kind') then
    create type public.contact_kind as enum (
      'whatsapp', 'telegram', 'phone', 'email', 'instagram',
      'facebook', 'tiktok', 'youtube', 'website', 'location', 'other'
    );
  end if;
end;
$$;

create table if not exists public.contact_links (
  id          uuid primary key default gen_random_uuid(),
  kind        public.contact_kind not null,
  label       text not null,
  value       text not null,
  is_primary  boolean not null default false,
  is_visible  boolean not null default true,
  sort_order  int not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists contact_links_visible_order_idx
  on public.contact_links (is_visible, is_primary desc, sort_order);

drop trigger if exists contact_links_set_updated_at on public.contact_links;
create trigger contact_links_set_updated_at
  before update on public.contact_links
  for each row execute function public.set_updated_at();

-- ───────────────────────────────────────────────────────────────────────────
-- inquiries — anonymous lead log written when a customer taps Buy / contact
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists public.inquiries (
  id          uuid primary key default gen_random_uuid(),
  product_id  uuid references public.products (id) on delete set null,
  channel     public.contact_kind not null,
  device_id   text,
  -- SHA-256 of the caller IP, written only by the inquiry Edge Function.
  -- Stored hashed so the lead log never holds a raw address.
  ip_hash     text,
  created_at  timestamptz not null default now()
);

create index if not exists inquiries_created_idx
  on public.inquiries (created_at desc);
create index if not exists inquiries_device_idx
  on public.inquiries (device_id, created_at desc);
create index if not exists inquiries_ip_idx
  on public.inquiries (ip_hash, created_at desc);

-- ───────────────────────────────────────────────────────────────────────────
-- audit_log — append-only trail for every admin write
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists public.audit_log (
  id          bigint generated always as identity primary key,
  actor       uuid references auth.users (id),
  action      text not null,
  table_name  text not null,
  row_id      text,
  diff        jsonb,
  created_at  timestamptz not null default now()
);

create index if not exists audit_log_created_idx
  on public.audit_log (created_at desc);
create index if not exists audit_log_table_idx
  on public.audit_log (table_name, created_at desc);

create or replace function public.audit_row()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor  uuid := auth.uid();
  v_row_id text;
  v_diff   jsonb;
begin
  if tg_op = 'DELETE' then
    v_row_id := old.id::text;
    v_diff := jsonb_build_object('old', to_jsonb(old));
  elsif tg_op = 'UPDATE' then
    v_row_id := new.id::text;
    v_diff := jsonb_build_object('old', to_jsonb(old), 'new', to_jsonb(new));
  else
    v_row_id := new.id::text;
    v_diff := jsonb_build_object('new', to_jsonb(new));
  end if;

  insert into public.audit_log (actor, action, table_name, row_id, diff)
  values (v_actor, lower(tg_op), tg_table_name, v_row_id, v_diff);

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

comment on function public.audit_row() is
  'SECURITY DEFINER audit trigger writer. Never fails an admin write on its own.';

do $$
declare
  t text;
begin
  foreach t in array array['categories', 'products', 'product_media',
                            'contact_links', 'site_settings']
  loop
    execute format('drop trigger if exists %I on public.%I', t || '_audit', t);
    execute format(
      'create trigger %I after insert or update or delete on public.%I '
      'for each row execute function public.audit_row()',
      t || '_audit', t
    );
  end loop;
end;
$$;
