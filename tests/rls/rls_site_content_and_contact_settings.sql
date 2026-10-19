-- ═══════════════════════════════════════════════════════════════════════════
-- site_content + admin_contact_settings — anon blocked, admin allowed
--
-- Included from tests/rls/rls_tests.sql, so the fixtures (admin and customer
-- profiles) already exist when this runs. Every write uses the same role and
-- JWT-claim setup as the rest of the suite, so the policies are exercised the
-- way PostgREST exercises them.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── anon cannot write site_content ─────────────────────────────────────────
set role anon;
do $$
declare
  v_state text;
begin
  begin
    insert into public.site_content (key, locale, value)
      values ('heroTitle', 'en', 'Anon rewrite');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon INSERT site_content denied');
end;
$$;

-- ── a non-admin customer cannot write site_content ─────────────────────────
set role authenticated;
select set_config('request.jwt.claim.sub', 'bbbbbbbb-0000-4000-8000-000000000001', false);
select set_config('request.jwt.claim.role', 'authenticated', false);
do $$
declare
  v_state text;
begin
  begin
    insert into public.site_content (key, locale, value)
      values ('heroTitle', 'en', 'Customer rewrite');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'non-admin INSERT site_content denied');
end;
$$;

-- ── the admin can write every locale, update and delete ────────────────────
set role authenticated;
select set_config('request.jwt.claim.sub', 'aaaaaaaa-0000-4000-8000-000000000001', false);
select set_config('request.jwt.claim.role', 'authenticated', false);
do $$
begin
  insert into public.site_content (key, locale, value) values
    ('heroTitle', 'en', 'Admin hero title'),
    ('heroTitle', 'am', 'የአዲስ መሪያ ርዕስ'),
    ('heroTitle', 'ar', 'عنوان البطاقة الجديد'),
    ('heroTitle', 'om', 'Baay''ina Haaraa');

  update public.site_content
     set value = 'Admin hero title — updated'
   where key = 'heroTitle' and locale = 'en';

  delete from public.site_content
   where key = 'heroTitle' and locale = 'om';

  perform test.assert_eq(
    (select count(*) from public.site_content where key = 'heroTitle'),
    3,
    'admin writes, updates and deletes site_content rows'
  );
end;
$$;

-- ── reads stay public, for anon and customers alike ────────────────────────
set role anon;
do $$
begin
  perform test.assert_eq(
    (select count(*) from public.site_content where key = 'heroTitle'),
    3,
    'anon can still read site_content (public select)'
  );
end;
$$;

set role authenticated;
select set_config('request.jwt.claim.sub', 'bbbbbbbb-0000-4000-8000-000000000001', false);
select set_config('request.jwt.claim.role', 'authenticated', false);
do $$
begin
  perform test.assert_eq(
    (select count(*) from public.site_content where key = 'heroTitle'),
    3,
    'a customer can still read site_content (public select)'
  );
end;
$$;

-- ═══════════════════════════════════════════════════════════════════════════
-- admin_contact_settings
-- ═══════════════════════════════════════════════════════════════════════════

-- ── anon cannot insert or update the singleton row ─────────────────────────
set role anon;
do $$
declare
  v_state text;
begin
  begin
    insert into public.admin_contact_settings (id, owner_phone)
      values (2, '+251999000000');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon INSERT admin_contact_settings denied');

  begin
    update public.admin_contact_settings
       set owner_phone = '+251999000001'
     where id = 1;
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon UPDATE admin_contact_settings denied');
end;
$$;

-- ── a non-admin customer cannot update it either ───────────────────────────
-- The table is granted to `authenticated`, so RLS filters the row rather than
-- raising: the update must touch zero rows and leave the value untouched.
set role authenticated;
select set_config('request.jwt.claim.sub', 'bbbbbbbb-0000-4000-8000-000000000001', false);
select set_config('request.jwt.claim.role', 'authenticated', false);
do $$
declare
  v_count integer;
begin
  update public.admin_contact_settings
     set owner_phone = '+251999000002'
   where id = 1;
  get diagnostics v_count = row_count;
  perform test.assert_eq(
    v_count,
    0,
    'non-admin UPDATE admin_contact_settings touches no row'
  );
end;
$$;

-- ── the admin can save every channel ───────────────────────────────────────
set role authenticated;
select set_config('request.jwt.claim.sub', 'aaaaaaaa-0000-4000-8000-000000000001', false);
select set_config('request.jwt.claim.role', 'authenticated', false);
update public.admin_contact_settings
   set
     owner_phone      = '+251911223344',
     whatsapp_number  = '251911223344',
     telegram_handle  = 'amumejlisamusharif',
     instagram_handle = 'amusheriff',
     facebook_handle  = 'amusheriff',
     tiktok_handle    = 'amusheriff',
     owner_email      = 'owner@asm.et',
     website_url      = 'https://asm.et'
 where id = 1;

do $$
begin
  perform test.assert_eq(
    (select owner_phone from public.admin_contact_settings where id = 1),
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
end;
$$;

-- ── reads stay public ──────────────────────────────────────────────────────
set role anon;
do $$
begin
  perform test.assert_eq(
    (select owner_phone from public.admin_contact_settings where id = 1),
    '+251911223344',
    'anon can read admin_contact_settings (public select)'
  );
end;
$$;
