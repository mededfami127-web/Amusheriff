-- ═══════════════════════════════════════════════════════════════════════════
-- site_content + admin_contact_settings: anon blocked, admin allowed
-- ═══════════════════════════════════════════════════════════════════════════

-- ── site_content ───────────────────────────────────────────────────────────
set role anon;
begin
  insert into public.site_content (key, locale, value)
    values ('heroTitle', 'en', 'Anon rewrite');
  perform test.assert(false, 'anon should not have inserted site_content');
exception when others then
  perform test.assert_eq(sqlstate, '42501', 'anon INSERT site_content denied');
end;

set role authenticated; -- non-admin customer
begin
  insert into public.site_content (key, locale, value)
    values ('heroTitle', 'en', 'Customer rewrite');
  perform test.assert(false, 'non-admin should not have inserted site_content');
exception when others then
  perform test.assert_eq(sqlstate, '42501', 'non-admin INSERT site_content denied');
end;

set role service_role;
insert into public.site_content (key, locale, value, updated_by)
  values ('heroTitle', 'en', 'Admin hero title', 'aaaaaaaa-0000-4000-8000-000000000001');
insert into public.site_content (key, locale, value, updated_by)
  values ('heroTitle', 'am', 'የአዲስ መሪያ ርዕስ', updated_by => 'aaaaaaaa-0000-4000-8000-000000000001');
insert into public.site_content (key, locale, value, updated_by)
  values ('heroTitle', 'ar', 'عنوان البطاقة الجديد', updated_by => 'aaaaaaaa-0000-4000-8000-000000000001');
insert into public.site_content (key, locale, value, updated_by)
  values ('heroTitle', 'om', 'Baay\'ina Haaraa', updated_by => 'aaaaaaaa-0000-4000-8000-000000000001');

-- admin update
update public.site_content
   set value = 'Admin hero title — updated', updated_by = 'aaaaaaaa-0000-4000-8000-000000000001'
 where key = 'heroTitle' and locale = 'en';

-- admin delete
delete from public.site_content
 where key = 'heroTitle' and locale = 'om';

-- admin can still read every row
perform test.assert_eq(
  (select count(*) from public.site_content where key = 'heroTitle'),
  3,
  'admin sees all site_content rows after writes'
);

-- anon/non-admin read is still allowed (public select)
set role anon;
perform test.assert_eq(
  (select count(*) from public.site_content where key = 'heroTitle'),
  3,
  'anon can still read site_content (public select)'
);

-- ── admin_contact_settings ─────────────────────────────────────────────────
set role anon;
begin
  insert into public.admin_contact_settings (id, owner_phone)
    values (1, '+251999000000');
  perform test.assert(false, 'anon should not have inserted admin_contact_settings');
exception when others then
  perform test.assert_eq(sqlstate, '42501', 'anon INSERT admin_contact_settings denied');
end;

set role authenticated;
begin
  update public.admin_contact_settings
     set owner_phone = '+251999000001'
   where id = 1;
  perform test.assert(false, 'non-admin should not have updated admin_contact_settings');
exception when others then
  perform test.assert_eq(sqlstate, '42501', 'non-admin UPDATE admin_contact_settings denied');
end;

set role service_role;
update public.admin_contact_settings
   set
     owner_phone    = '+251911223344',
     whatsapp_number = '251911223344',
     telegram_handle = 'amumejlisamusharif',
     instagram_handle = 'amusheriff',
     facebook_handle  = 'amusheriff',
     tiktok_handle    = 'amusheriff',
     owner_email      = 'owner@asm.et',
     website_url      = 'https://asm.et',
     updated_by       = 'aaaaaaaa-0000-4000-8000-000000000001'
 where id = 1;

perform test.assert_eq(
  (select owner_phone    from public.admin_contact_settings where id = 1),
  '+251911223344',
  'admin UPDATE persisted owner_phone'
);
perform test.assert_eq(
  (select whatsapp_number from public.admin_contact_settings where id = 1),
  '251911223344',
  'admin UPDATE persisted whatsapp_number'
);
perform test.assert_eq(
  (select telegram_handle from public.admin_contact_settings where id = 1),
  'amumejlisamusharif',
  'admin UPDATE persisted telegram_handle'
);

-- admin delete of the only row is permitted by policy, but the PK prevents an
-- empty-table state in practice; still, the policy itself must not reject it.
-- (We do not actually delete the seeded singleton here so the fixture stays valid
-- for later tests that read contact settings.)
 펼치는;

set role anon;
perform test.assert_eq(
  (select owner_phone from public.admin_contact_settings where id = 1),
  '+251911223344',
  'anon can read admin_contact_settings (public select)'
);
