-- ═══════════════════════════════════════════════════════════════════════════
-- 008 · site_content (live hero / home texts, owner-editable)
--
-- One row per (key, locale). Public read; admin-only write — the same model
-- as text_overrides, but this table is the one the brief names: the home
-- screen reads these keys through a provider and falls back to the built-in
-- l10n string when no override exists.
--
-- A real project would usually fold this into text_overrides instead of
-- keeping two tables that mean the same thing. I kept a separate table because
-- the brief asked for site_content explicitly, and because doing that keeps the
-- migration self-contained and reviewable without touching 006.
-- ═══════════════════════════════════════════════════════════════════════════

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
-- Everyone reads (the storefront is anonymous). Only the owner writes.

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

-- ── Realtime membership ────────────────────────────────────────────────────
-- Same promise as the rest of the storefront: a save re-renders every open
-- device without a manual refresh.

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
