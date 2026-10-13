-- ═══════════════════════════════════════════════════════════════════════════
-- Local Supabase shim — TEST ONLY, never applied to a real project.
--
-- Reproduces just enough of the managed platform for `supabase/migrations` to
-- apply unchanged on a plain PostgreSQL 15+ instance:
--   * the anon / authenticated / service_role roles
--   * the auth schema with auth.users and auth.uid() / auth.role()
--   * the storage schema with buckets, objects, extension() and foldername()
--
-- This is what lets the RLS suite below exercise the *real* policies instead of
-- a hand-written approximation.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Roles ──────────────────────────────────────────────────────────────────
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin noinherit;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin noinherit;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    create role service_role nologin noinherit bypassrls;
  end if;
end;
$$;

-- ── auth schema ────────────────────────────────────────────────────────────
create schema if not exists auth;

create table if not exists auth.users (
  id                  uuid primary key default gen_random_uuid(),
  email               text unique,
  encrypted_password  text,
  raw_user_meta_data  jsonb not null default '{}'::jsonb,
  created_at          timestamptz not null default now()
);

-- Mirrors the deployed definition: read the subject from either the singular
-- claim GUC (set by PostgREST per-request) or the full claims JSON.
create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub'
  )::uuid;
$$;

create or replace function auth.role()
returns text
language sql
stable
as $$
  select coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role'
  );
$$;

create or replace function auth.email()
returns text
language sql
stable
as $$
  select nullif(current_setting('request.jwt.claim.email', true), '');
$$;

grant usage on schema auth to anon, authenticated, service_role;

-- ── storage schema ─────────────────────────────────────────────────────────
create schema if not exists storage;

create table if not exists storage.buckets (
  id                 text primary key,
  name               text not null,
  owner              uuid,
  public             boolean not null default false,
  avif_autodetection boolean not null default false,
  file_size_limit    bigint,
  allowed_mime_types text[],
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create table if not exists storage.objects (
  id          uuid primary key default gen_random_uuid(),
  bucket_id   text references storage.buckets (id),
  name        text,
  owner       uuid,
  metadata    jsonb,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

alter table storage.objects enable row level security;
alter table storage.buckets enable row level security;

create or replace function storage.foldername(name text)
returns text[]
language plpgsql
immutable
as $$
declare
  _parts text[];
begin
  select string_to_array(name, '/') into _parts;
  return _parts[1 : array_length(_parts, 1) - 1];
end;
$$;

create or replace function storage.extension(name text)
returns text
language plpgsql
immutable
as $$
declare
  _parts text[];
  _filename text;
begin
  select string_to_array(name, '/') into _parts;
  select _parts[array_length(_parts, 1)] into _filename;
  return reverse(split_part(reverse(_filename), '.', 1));
end;
$$;

grant usage on schema storage to anon, authenticated, service_role;
grant select on storage.buckets to anon, authenticated, service_role;
grant select, insert, update, delete on storage.objects to anon, authenticated;
grant all on storage.objects to service_role;

-- ── test helper schema ─────────────────────────────────────────────────────
create schema if not exists test;

-- Raises (and therefore aborts the script) when the condition is not true.
create or replace function test.assert(p_condition boolean, p_message text)
returns void
language plpgsql
as $$
begin
  if p_condition is distinct from true then
    raise exception 'ASSERTION FAILED: %', p_message using errcode = 'P0001';
  end if;
end;
$$;

-- `anycompatible` (not `anyelement`) so `count(*)` (bigint) can be compared
-- against an integer literal without an explicit cast at every call site.
create or replace function test.assert_eq(
  p_actual anycompatible,
  p_expected anycompatible,
  p_message text
)
returns void
language plpgsql
as $$
begin
  if p_actual is distinct from p_expected then
    raise exception 'ASSERTION FAILED: % (expected %, got %)',
      p_message, p_expected, p_actual using errcode = 'P0001';
  end if;
end;
$$;

grant usage on schema test to anon, authenticated, service_role;
grant execute on all functions in schema test to anon, authenticated, service_role;
