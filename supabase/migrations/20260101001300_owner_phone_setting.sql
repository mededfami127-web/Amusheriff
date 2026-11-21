-- ═══════════════════════════════════════════════════════════════════════════
-- 013 · One global owner phone, defaulted to the shop's published number
--
-- Every Call button in the customer app reads `admin_contact_settings.owner_phone`
-- (the same row the admin "Contact settings" panel already edits) and falls back
-- to `0917928950` in the app when the field is empty. This migration makes the
-- database agree with that fallback:
--
--   * the column gains a DEFAULT, so a row inserted without a phone is usable;
--   * the existing singleton row is filled only when it is NULL or blank — an
--     owner who already typed a number keeps it exactly as it is;
--   * the comment names the contract so a future reader does not add a second
--     "shop phone" column.
--
-- Additive only: no column is dropped, renamed, or made stricter, so every
-- version of the app that predates it keeps working.
-- ═══════════════════════════════════════════════════════════════════════════

alter table public.admin_contact_settings
  alter column owner_phone set default '0917928950';

comment on column public.admin_contact_settings.owner_phone is
  'Global owner phone. Every Call button in the app dials this number, '
  'normalised to +251… for the tel: intent. Blank means the app default '
  '(0917928950). Editable from the admin Contact settings panel.';

-- The singleton row is created by migration 009; recreate it defensively so
-- this migration is also safe on a project where 009 ran before the row insert.
insert into public.admin_contact_settings as s (id)
values (1)
on conflict (id) do nothing;

-- Fill the default only where the owner has not set anything. Never overwrite
-- a real number that the shop is already publishing.
update public.admin_contact_settings
   set owner_phone = '0917928950'
 where owner_phone is null
    or btrim(owner_phone) = '';

-- Keep the single-row table as the source of truth for this change, and make
-- sure the storefront's live subscription sees it.
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
