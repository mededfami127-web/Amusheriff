-- ═══════════════════════════════════════════════════════════════════════════
-- 009 · admin_contact_settings (owner phone / WhatsApp / Telegram / social / email)
--
-- A single-row settings table holding the owner's contact channels, separate from
-- public `contact_links` so the owner can store private phone / social handles
-- without publishing every raw value to anonymous readers. The storefront only
-- ever renders the channels the owner has marked visible through public
-- `contact_links`; this table is what backs the admin "Contact settings" panel
-- and the product page "Contact the owner" section when the owner prefers a
-- settings-first model.
--
-- Public read, admin-only write, same shape as every other settings table here.
-- ═══════════════════════════════════════════════════════════════════════════

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

comment on column public.admin_contact_settings.instagram_handle is
  'Instagram handle the storefront may link to.';

comment on column public.admin_contact_settings.facebook_handle is
  'Facebook page or profile handle the storefront may link to.';

comment on column public.admin_contact_settings.tiktok_handle is
  'TikTok handle the storefront may link to.';

comment on column public.admin_contact_settings.youtube_handle is
  'YouTube channel handle or URL the storefront may link to.';

comment on column public.admin_contact_settings.website_url is
  'Owner website the storefront may link to.';

drop trigger if exists admin_contact_settings_set_updated_at on public.admin_contact_settings;
create trigger admin_contact_settings_set_updated_at
  before update on public.admin_contact_settings
  for each row execute function public.set_updated_at();

-- ── Row level security ─────────────────────────────────────────────────────
-- Everyone may read the row (so an admin session is not required to render the
-- storefront), but only the owner may write it.

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

-- ── Realtime membership ────────────────────────────────────────────────────
-- A save here should refresh the admin panel and any storefront contact section
-- that streams this row.

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
