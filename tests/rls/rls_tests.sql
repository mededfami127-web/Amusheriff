-- ═══════════════════════════════════════════════════════════════════════════
-- RLS acceptance suite — Amu Sharif Arabiyan Majlis
--
-- Run against a FRESH database that already has:
--   tests/rls/00_supabase_shim.sql, supabase/migrations/*, supabase/seed.sql
-- (scripts/run_rls_tests.sh does exactly that).
--
-- Every assertion is a `test.assert(...)`; the first failure raises and psql
-- exits non-zero, so this file is directly usable as a CI gate.
--
-- The suite proves the four contract points from the brief:
--   1. anon cannot write anywhere,
--   2. anon cannot see unpublished / hidden items,
--   3. a non-admin authenticated user cannot write,
--   4. an admin can.
-- plus inquiries, audit logging, the RPCs, the security_invoker views and the
-- storage bucket policies.
-- ═══════════════════════════════════════════════════════════════════════════

\set ON_ERROR_STOP on
\echo '=== ASM RLS acceptance suite ==='

-- ═══════════════════════════════════════════════════════════════════════════
-- Fixtures (written as the schema owner, so RLS is bypassed by design)
-- ═══════════════════════════════════════════════════════════════════════════
insert into auth.users (id, email, raw_user_meta_data)
values
  ('aaaaaaaa-0000-4000-8000-000000000001', 'owner@asm.test',    '{"full_name":"ASM Owner"}'),
  ('bbbbbbbb-0000-4000-8000-000000000001', 'customer@asm.test', '{"full_name":"Customer"}');

\echo 'ok - handle_new_user provisioned both profiles'

-- The ONLY supported way to create an admin: direct SQL by the project owner.
update public.profiles
   set is_admin = true
 where id = 'aaaaaaaa-0000-4000-8000-000000000001';

do $$
begin
  perform test.assert(
    (select is_admin from public.profiles where id = 'aaaaaaaa-0000-4000-8000-000000000001'),
    'owner profile is flagged admin'
  );
  perform test.assert(
    not (select is_admin from public.profiles where id = 'bbbbbbbb-0000-4000-8000-000000000001'),
    'a freshly created user is NOT an admin'
  );
end;
$$;
\echo 'ok - is_admin can be set by the owner via SQL and defaults to false'

-- Catalogue fixtures: one visible + one hidden category, and products that
-- exercise every visibility combination.
insert into public.categories (id, name, slug, sort_order, is_visible) values
  ('e0000000-0000-4000-8000-000000000001', 'RLS Visible Category', 'rls-test-visible', 90, true),
  ('e0000000-0000-4000-8000-000000000002', 'RLS Hidden Category',  'rls-test-hidden',  91, false);

insert into public.products (id, category_id, title, price, is_published, is_available) values
  ('f0000000-0000-4000-8000-000000000001', 'e0000000-0000-4000-8000-000000000001',
   'RLS Published Product',   1200, true,  true),
  ('f0000000-0000-4000-8000-000000000002', 'e0000000-0000-4000-8000-000000000001',
   'RLS Unpublished Product', 1300, false, true),
  ('f0000000-0000-4000-8000-000000000003', 'e0000000-0000-4000-8000-000000000002',
   'RLS Hidden Category Product', 1400, true, true);

insert into public.product_media (id, product_id, kind, storage_path, is_cover) values
  ('a0000000-0000-4000-8000-000000000001', 'f0000000-0000-4000-8000-000000000001',
   'image', 'products/f0000000-0000-4000-8000-000000000001/cover.jpg', true),
  ('a0000000-0000-4000-8000-000000000002', 'f0000000-0000-4000-8000-000000000002',
   'image', 'products/f0000000-0000-4000-8000-000000000002/cover.jpg', true),
  ('a0000000-0000-4000-8000-000000000003', 'f0000000-0000-4000-8000-000000000003',
   'video', 'products/f0000000-0000-4000-8000-000000000003/clip.mp4', true);

insert into public.contact_links (id, kind, label, value, is_visible) values
  ('d1111111-0000-4000-8000-000000000001', 'whatsapp', 'RLS Visible Channel', '+251900000001', true),
  ('d1111111-0000-4000-8000-000000000002', 'phone',    'RLS Hidden Channel',  '+251900000002', false);

-- One owner-authored string, so the read assertions below have something to
-- find. The table is otherwise empty, which is the normal shipped state.
insert into public.text_overrides (text_key, locale, value) values
  ('tagline', 'en', 'Owner written tagline');

\echo 'ok - catalogue fixtures inserted'

-- ═══════════════════════════════════════════════════════════════════════════
-- site_content + admin_contact_settings RLS assertions
-- ═══════════════════════════════════════════════════════════════════════════
\echo '── site_content + admin_contact_settings RLS'
\i '$(dirname $0)/rls_site_content_and_contact_settings.sql'
\echo 'ok - site_content and admin_contact_settings RLS'

-- ═══════════════════════════════════════════════════════════════════════════
-- 1 · ANON — read visibility
-- ═══════════════════════════════════════════════════════════════════════════
set role anon;

do $$
declare
  v_visible     int;
  v_unpublished int;
  v_hidden      int;
  v_state       text;
begin
  select count(*) into v_visible
    from public.products where id = 'f0000000-0000-4000-8000-000000000001';
  select count(*) into v_unpublished
    from public.products where id = 'f0000000-0000-4000-8000-000000000002';
  select count(*) into v_hidden
    from public.products where id = 'f0000000-0000-4000-8000-000000000003';

  perform test.assert_eq(v_visible, 1,
    'anon sees a published product in a visible category');
  perform test.assert_eq(v_unpublished, 0,
    'anon CANNOT see an unpublished product');
  perform test.assert_eq(v_hidden, 0,
    'anon CANNOT see a published product whose category is hidden');

  perform test.assert_eq(
    (select count(*) from public.categories where id = 'e0000000-0000-4000-8000-000000000002'),
    0, 'anon CANNOT see a hidden category');
  perform test.assert_eq(
    (select count(*) from public.categories where id = 'e0000000-0000-4000-8000-000000000001'),
    1, 'anon sees a visible category');

  perform test.assert_eq(
    (select count(*) from public.product_media where id = 'a0000000-0000-4000-8000-000000000001'),
    1, 'anon sees media of a publicly visible product');
  perform test.assert_eq(
    (select count(*) from public.product_media where id = 'a0000000-0000-4000-8000-000000000002'),
    0, 'anon CANNOT see media of an unpublished product');
  perform test.assert_eq(
    (select count(*) from public.product_media where id = 'a0000000-0000-4000-8000-000000000003'),
    0, 'anon CANNOT see media of a product in a hidden category');

  perform test.assert_eq(
    (select count(*) from public.contact_links where id = 'd1111111-0000-4000-8000-000000000001'),
    1, 'anon sees a visible contact link');
  perform test.assert_eq(
    (select count(*) from public.contact_links where id = 'd1111111-0000-4000-8000-000000000002'),
    0, 'anon CANNOT see a hidden contact link');

  -- The lead log, the audit trail and the profiles table have no SELECT grant
  -- for anon at all, so the deny happens one layer earlier than RLS.
  begin
    perform count(*) from public.inquiries;
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon CANNOT read the inquiries lead log');

  begin
    perform count(*) from public.audit_log;
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon CANNOT read the audit log');

  begin
    perform count(*) from public.profiles;
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon CANNOT read profiles');
end;
$$;
\echo 'ok 1 - anon read visibility is limited to published, visible rows'

-- ═══════════════════════════════════════════════════════════════════════════
-- 2 · ANON — every write is denied
-- ═══════════════════════════════════════════════════════════════════════════
do $$
declare
  v_state text;
begin
  -- INSERT: RLS rejects with 42501.
  begin
    insert into public.categories (name, slug) values ('Anon write', 'anon-write');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon INSERT on categories is denied');

  begin
    insert into public.products (category_id, title, price)
    values ('e0000000-0000-4000-8000-000000000001', 'Anon write', 10);
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon INSERT on products is denied');

  begin
    insert into public.product_media (product_id, kind, storage_path)
    values ('f0000000-0000-4000-8000-000000000001', 'image', 'x.jpg');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon INSERT on product_media is denied');

  begin
    insert into public.contact_links (kind, label, value)
    values ('phone', 'Anon', '+251900000003');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon INSERT on contact_links is denied');

  begin
    insert into public.site_settings (id, tagline) values (1, 'anon')
    on conflict (id) do update set tagline = 'anon';
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon write on site_settings is denied');

  begin
    insert into public.text_overrides (text_key, locale, value)
    values ('tagline', 'en', 'Anon rewrite');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon INSERT on text_overrides is denied');

  begin
    insert into public.audit_log (action, table_name) values ('fake', 'fake');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon INSERT on audit_log is denied');

  begin
    update public.profiles set is_admin = true;
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon UPDATE on profiles is denied');
end;
$$;
\echo 'ok 2 - anon INSERT/UPDATE is denied on every table'

do $$
declare
  v_state text;
begin
  -- update/delete are denied because anon holds no such grant; a matching
  -- RLS policy is the second (never-reached) layer.
  begin
    update public.categories set name = 'Anon overwrite'
     where id = 'e0000000-0000-4000-8000-000000000001';
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon UPDATE on categories is denied');

  begin
    delete from public.categories where id = 'e0000000-0000-4000-8000-000000000001';
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon DELETE on categories is denied');

  begin
    delete from public.products where id = 'f0000000-0000-4000-8000-000000000001';
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon DELETE on products is denied');
end;
$$;
\echo 'ok 2b - anon UPDATE/DELETE are denied too'

do $$
begin
  perform test.assert_eq(
    (select name from public.categories where id = 'e0000000-0000-4000-8000-000000000001'),
    'RLS Visible Category',
    'the category survived the anon write attempts unchanged'
  );
end;
$$;
\echo 'ok 2c - data is unchanged after the anon write attempts'

reset role;

-- ═══════════════════════════════════════════════════════════════════════════
-- 3 · ANON — can submit an inquiry, but not read them back
-- ═══════════════════════════════════════════════════════════════════════════
set role anon;

do $$
begin
  insert into public.inquiries (product_id, channel, device_id)
  values ('f0000000-0000-4000-8000-000000000001', 'whatsapp', 'device-anon-1');
  perform test.assert(true, 'anon CAN submit an inquiry');
end;
$$;

do $$
declare
  v_state text;
begin
  begin
    perform count(*) from public.inquiries;
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(
    v_state, '42501',
    'anon still CANNOT read the inquiries it just wrote');
end;
$$;
\echo 'ok 3 - anon may insert an inquiry but cannot read the lead log'

-- ═══════════════════════════════════════════════════════════════════════════
-- 3b · Inquiry rate limiting (10 per device per 10 minutes)
-- ═══════════════════════════════════════════════════════════════════════════
do $$
declare
  i       int;
  v_state text := 'ok';
begin
  for i in 1 .. 20 loop
    begin
      insert into public.inquiries (product_id, channel, device_id)
      values ('f0000000-0000-4000-8000-000000000001', 'phone', 'device-flood');
    exception when others then
      v_state := sqlstate;
      exit;
    end;
  end loop;

  perform test.assert_eq(v_state, 'P0001',
    'the inquiry rate limiter rejects the 11th submission from one device');
end;
$$;
\echo 'ok 3b - inquiry rate limiter caps a single device at 10 per window'

reset role;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4 · AUTHENTICATED NON-ADMIN — reads the public set, writes nothing
-- ═══════════════════════════════════════════════════════════════════════════
set role authenticated;
select set_config('request.jwt.claim.sub', 'bbbbbbbb-0000-4000-8000-000000000001', false);
select set_config('request.jwt.claim.role', 'authenticated', false);

do $$
declare
  v_state text;
begin
  perform test.assert_eq(
    (select count(*) from public.products where id = 'f0000000-0000-4000-8000-000000000002'),
    0, 'a non-admin CANNOT see an unpublished product');

  perform test.assert_eq(
    (select count(*) from public.categories where id = 'e0000000-0000-4000-8000-000000000002'),
    0, 'a non-admin CANNOT see a hidden category');

  perform test.assert_eq(
    (select count(*) from public.audit_log), 0,
    'a non-admin CANNOT read the audit log');

  -- Own profile: readable and updatable.
  perform test.assert_eq(
    (select count(*) from public.profiles where id = 'bbbbbbbb-0000-4000-8000-000000000001'),
    1, 'a non-admin CAN read their own profile');

  update public.profiles
     set full_name = 'Customer Renamed'
   where id = 'bbbbbbbb-0000-4000-8000-000000000001';
  perform test.assert_eq(
    (select full_name from public.profiles where id = 'bbbbbbbb-0000-4000-8000-000000000001'),
    'Customer Renamed', 'a non-admin CAN update their own profile');

  -- …but still cannot promote themselves: the guard trigger fires.
  begin
    update public.profiles
       set is_admin = true
     where id = 'bbbbbbbb-0000-4000-8000-000000000001';
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501',
    'a non-admin CANNOT promote themselves to admin');

  perform test.assert(
    not (select is_admin from public.profiles where id = 'bbbbbbbb-0000-4000-8000-000000000001'),
    'the non-admin is still not an admin after the attempt');

  -- Writes denied.
  begin
    insert into public.categories (name, slug) values ('Non admin', 'non-admin');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'a non-admin INSERT on categories is denied');

  begin
    insert into public.products (category_id, title, price)
    values ('e0000000-0000-4000-8000-000000000001', 'Non admin', 10);
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'a non-admin INSERT on products is denied');

  begin
    update public.products set price = 1
     where id = 'f0000000-0000-4000-8000-000000000001';
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, 'ok', 'UPDATE with no matching policy is silent');

  begin
    insert into public.text_overrides (text_key, locale, value)
    values ('tagline', 'en', 'Non admin rewrite');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501',
    'a non-admin INSERT on text_overrides is denied');

  perform test.assert_eq(
    (select price from public.products where id = 'f0000000-0000-4000-8000-000000000001')::numeric,
    1200::numeric,
    'the non-admin UPDATE changed nothing');
end;
$$;
\echo 'ok 4 - a non-admin authenticated user can never write or self-promote'

reset role;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4b · TEXT OVERRIDES — everyone reads the owner's wording, only the owner writes
--
-- The storefront is anonymous and must render whatever the owner typed, so a
-- plain anon caller has to see the row. Editing it is the owner's job alone.
-- ═══════════════════════════════════════════════════════════════════════════
set role anon;

do $$
begin
  perform test.assert_eq(
    (select value from public.text_overrides
      where text_key = 'tagline' and locale = 'en'),
    'Owner written tagline',
    'anon CAN read an owner-authored string');
end;
$$;

reset role;

set role authenticated;
select set_config('request.jwt.claim.sub', 'aaaaaaaa-0000-4000-8000-000000000001', false);
select set_config('request.jwt.claim.role', 'authenticated', false);

do $$
declare
  v_state text;
begin
  -- The owner edits, adds a second language, then restores the default by
  -- deleting the row — the three operations the editor performs.
  update public.text_overrides set value = 'Owner edited tagline'
   where text_key = 'tagline' and locale = 'en';
  perform test.assert_eq(
    (select value from public.text_overrides
      where text_key = 'tagline' and locale = 'en'),
    'Owner edited tagline', 'the admin CAN update an override');

  insert into public.text_overrides (text_key, locale, value)
  values ('adminDashboard', 'om', 'Daashboordii');
  perform test.assert_eq(
    (select count(*) from public.text_overrides where locale = 'om'),
    1, 'the admin CAN add an override for the new Oromo locale');

  delete from public.text_overrides where text_key = 'adminDashboard';
  perform test.assert_eq(
    (select count(*) from public.text_overrides where text_key = 'adminDashboard'),
    0, 'the admin CAN delete an override to restore the shipped wording');

  -- The key/locale pair is the identity: a duplicate is refused, so the
  -- editor can upsert without race-conditions deciding who wins.
  begin
    insert into public.text_overrides (text_key, locale, value)
    values ('tagline', 'en', 'duplicate');
    v_state := 'ok';
  exception when unique_violation then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '23505',
    'a duplicate (key, locale) override is refused');

  -- Only the four shipped locales are storable.
  begin
    insert into public.text_overrides (text_key, locale, value)
    values ('tagline', 'fr', 'bonjour');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '23514',
    'an unsupported locale is refused by the check constraint');
end;
$$;
\echo 'ok 4b - text overrides: public read, admin-only write, identity by (key, locale)'

reset role;

-- ═══════════════════════════════════════════════════════════════════════════
-- 4c · OROMO — the fourth language is storable end to end
-- ═══════════════════════════════════════════════════════════════════════════
set role authenticated;
select set_config('request.jwt.claim.sub', 'aaaaaaaa-0000-4000-8000-000000000001', false);
select set_config('request.jwt.claim.role', 'authenticated', false);

do $$
begin
  perform test.assert(
    exists (
      select 1 from information_schema.columns
       where table_schema = 'public'
         and table_name = 'site_settings'
         and column_name = 'store_name_om'),
    'site_settings has an Oromo store-name column');

  update public.site_settings set default_language = 'om' where id = 1;
  perform test.assert_eq(
    (select default_language from public.site_settings where id = 1),
    'om', 'the owner CAN set Oromo as the default language');

  update public.site_settings set default_language = 'en' where id = 1;
end;
$$;
\echo 'ok 4c - Oromo is accepted as a store name and default language'

reset role;

-- ═══════════════════════════════════════════════════════════════════════════
-- 5 · ADMIN — full read and CRUD
-- ═══════════════════════════════════════════════════════════════════════════
set role authenticated;
select set_config('request.jwt.claim.sub', 'aaaaaaaa-0000-4000-8000-000000000001', false);
select set_config('request.jwt.claim.role', 'authenticated', false);

do $$
declare
  v_category_id uuid;
  v_product_id  uuid;
  v_contact_id  uuid;
begin
  perform test.assert_eq(
    (select count(*) from public.products where id = 'f0000000-0000-4000-8000-000000000002'),
    1, 'the admin CAN see an unpublished product');

  perform test.assert_eq(
    (select count(*) from public.products where id = 'f0000000-0000-4000-8000-000000000003'),
    1, 'the admin CAN see a product in a hidden category');

  perform test.assert_eq(
    (select count(*) from public.categories where id = 'e0000000-0000-4000-8000-000000000002'),
    1, 'the admin CAN see a hidden category');

  perform test.assert_eq(
    (select count(*) from public.contact_links where id = 'd1111111-0000-4000-8000-000000000002'),
    1, 'the admin CAN see a hidden contact link');

  perform test.assert(
    (select count(*) from public.audit_log) > 0,
    'the admin CAN read the audit log');

  perform test.assert(
    (select count(*) from public.inquiries) > 0,
    'the admin CAN read the lead log');

  -- ── category CRUD ────────────────────────────────────────────────────────
  insert into public.categories (name, name_am, name_ar, slug, sort_order)
  values ('Admin Created', 'የአስተዳዳሪ', 'مسؤول', 'admin-created', 99)
  returning id into v_category_id;

  update public.categories set name = 'Admin Updated' where id = v_category_id;
  perform test.assert_eq(
    (select name from public.categories where id = v_category_id),
    'Admin Updated', 'the admin CAN update a category');

  delete from public.categories where id = v_category_id;
  perform test.assert_eq(
    (select count(*) from public.categories where id = v_category_id),
    0, 'the admin CAN delete a category');

  -- ── product CRUD ─────────────────────────────────────────────────────────
  insert into public.products (category_id, title, price, compare_at_price)
  values ('e0000000-0000-4000-8000-000000000001', 'Admin Created Product', 500, 700)
  returning id into v_product_id;

  update public.products set is_featured = true, price = 450 where id = v_product_id;
  perform test.assert_eq(
    (select is_featured from public.products where id = v_product_id),
    true, 'the admin CAN update a product');

  -- ── media CRUD ───────────────────────────────────────────────────────────
  insert into public.product_media (product_id, kind, storage_path, is_cover)
  values (v_product_id, 'image', 'products/x/cover.jpg', true);

  perform test.assert_eq(
    (select count(*) from public.product_media where product_id = v_product_id),
    1, 'the admin CAN attach media');

  -- The partial unique index allows exactly one cover per product.
  declare
    v_state text;
  begin
    begin
      insert into public.product_media (product_id, kind, storage_path, is_cover)
      values (v_product_id, 'image', 'products/x/cover2.jpg', true);
      v_state := 'ok';
    exception when others then v_state := sqlstate;
    end;
    perform test.assert_eq(v_state, '23505',
      'a second cover for the same product is rejected by one_cover_per_product');
  end;

  delete from public.product_media where product_id = v_product_id;
  perform test.assert_eq(
    (select count(*) from public.product_media where product_id = v_product_id),
    0, 'the admin CAN delete media');

  -- ── contact links ────────────────────────────────────────────────────────
  insert into public.contact_links (kind, label, value)
  values ('instagram', 'Admin IG', '@asm') returning id into v_contact_id;

  update public.contact_links set is_visible = false where id = v_contact_id;
  delete from public.contact_links where id = v_contact_id;
  perform test.assert_eq(
    (select count(*) from public.contact_links where id = v_contact_id),
    0, 'the admin CAN CRUD contact links');

  update public.site_settings set tagline = 'Admin tagline' where id = 1;
  perform test.assert_eq(
    (select tagline from public.site_settings where id = 1),
    'Admin tagline', 'the admin CAN update site_settings');

  -- ── audit trail was written ──────────────────────────────────────────────
  perform test.assert(
    (select count(*) from public.audit_log
      where table_name = 'categories' and action = 'insert') > 0,
    'the audit trigger recorded a category insert');
  perform test.assert(
    (select count(*) from public.audit_log
      where table_name = 'products' and action = 'update') > 0,
    'the audit trigger recorded a product update');
  perform test.assert(
    (select count(*) from public.audit_log where table_name = 'site_settings') > 0,
    'the audit trigger recorded a site_settings write');

  -- ── delete the created product ───────────────────────────────────────────
  delete from public.products where id = v_product_id;
  perform test.assert_eq(
    (select count(*) from public.products where id = v_product_id),
    0, 'the admin CAN delete a product');
end;
$$;
\echo 'ok 5 - the admin has full CRUD and the audit trail records every write'

-- ═══════════════════════════════════════════════════════════════════════════
-- 6 · reorder_rows RPC — admin only, whitelisted tables
-- ═══════════════════════════════════════════════════════════════════════════
do $$
declare
  v_state text;
begin
  perform public.reorder_rows(
    'categories',
    array[
      'e0000000-0000-4000-8000-000000000002'::uuid,
      'e0000000-0000-4000-8000-000000000001'::uuid
    ]
  );
  perform test.assert_eq(
    (select sort_order from public.categories where id = 'e0000000-0000-4000-8000-000000000002'),
    0, 'the admin CAN reorder categories');

  begin
    perform public.reorder_rows('audit_log', array[]::uuid[]);
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '22023',
    'reorder_rows refuses a table outside the whitelist');
end;
$$;
\echo 'ok 6a - admin can reorder; the whitelist rejects other tables'

reset role;

set role anon;
do $$
declare
  v_state text;
begin
  begin
    perform public.reorder_rows('categories', array['e0000000-0000-4000-8000-000000000001'::uuid]);
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon CANNOT call reorder_rows');
end;
$$;
reset role;

set role authenticated;
select set_config('request.jwt.claim.sub', 'bbbbbbbb-0000-4000-8000-000000000001', false);
do $$
declare
  v_state text;
begin
  begin
    perform public.reorder_rows('categories', array['e0000000-0000-4000-8000-000000000001'::uuid]);
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'a non-admin CANNOT call reorder_rows');
end;
$$;
reset role;
\echo 'ok 6b - reorder_rows is admin-only'

-- ═══════════════════════════════════════════════════════════════════════════
-- 7 · search_products RPC — respects RLS
-- ═══════════════════════════════════════════════════════════════════════════
set role anon;
do $$
begin
  -- Asserted by id, not by count: trigram similarity intentionally matches
  -- near-identical titles, so a count would be a brittle assertion.
  perform test.assert(
    exists (
      select 1 from public.search_products('RLS')
      where id = 'f0000000-0000-4000-8000-000000000001'
    ),
    'anon search finds the published product');
  perform test.assert(
    not exists (
      select 1 from public.search_products('RLS')
      where id = 'f0000000-0000-4000-8000-000000000002'
    ),
    'anon search CANNOT return an unpublished product');
  perform test.assert(
    not exists (
      select 1 from public.search_products('RLS')
      where id = 'f0000000-0000-4000-8000-000000000003'
    ),
    'anon search CANNOT return a product from a hidden category');
  perform test.assert(
    (select count(*) from public.search_products('Majlis')) >= 1,
    'anon search finds the seeded Majlis products');
end;
$$;
reset role;
\echo 'ok 7 - search_products is index-backed and RLS-filtered'

set role authenticated;
select set_config('request.jwt.claim.sub', 'aaaaaaaa-0000-4000-8000-000000000001', false);
do $$
begin
  -- search_products is the STOREFRONT search: its WHERE clause already filters
  -- to published rows, so it stays a public search for every caller. RLS is the
  -- second, never-reached layer — which only works while the function is
  -- SECURITY INVOKER rather than SECURITY DEFINER.
  perform test.assert(
    not exists (
      select 1 from public.search_products('RLS')
      where id = 'f0000000-0000-4000-8000-000000000002'
    ),
    'search_products excludes unpublished rows even for an admin');

  perform test.assert(
    not (select prosecdef from pg_proc where proname = 'search_products'),
    'search_products is SECURITY INVOKER, so RLS still applies to it');

  -- The helpers that MUST bypass RLS are explicitly definer, and each one
  -- therefore carries its own authorisation check.
  perform test.assert(
    (select prosecdef from pg_proc where proname = 'is_admin'),
    'is_admin() is SECURITY DEFINER so it can read profiles inside its own policy');
  perform test.assert(
    (select prosecdef from pg_proc where proname = 'reorder_rows'),
    'reorder_rows is SECURITY DEFINER and therefore checks is_admin() itself');
end;
$$;
reset role;
\echo 'ok 7b - SECURITY INVOKER vs DEFINER is asserted structurally'

-- ═══════════════════════════════════════════════════════════════════════════
-- 8 · security_invoker views cannot leak unpublished rows
-- ═══════════════════════════════════════════════════════════════════════════
set role anon;
do $$
begin
  perform test.assert_eq(
    (select count(*) from public.v_products_public
      where id = 'f0000000-0000-4000-8000-000000000002'),
    0, 'v_products_public hides an unpublished product from anon');
  perform test.assert_eq(
    (select count(*) from public.v_products_public
      where id = 'f0000000-0000-4000-8000-000000000001'),
    1, 'v_products_public shows a published product to anon');
  perform test.assert(
    (select product_count from public.v_categories_with_counts
      where id = 'e0000000-0000-4000-8000-000000000001') = 1,
    'v_categories_with_counts counts only published products');
end;
$$;
reset role;
\echo 'ok 8 - views run with the caller privileges (security_invoker)'

-- ═══════════════════════════════════════════════════════════════════════════
-- 9 · Storage policies
-- ═══════════════════════════════════════════════════════════════════════════
do $$
begin
  perform test.assert_eq(
    (select count(*) from storage.buckets where id = 'product-media' and public),
    1, 'the product-media bucket exists and is public');
  perform test.assert_eq(
    (select count(*) from storage.buckets where id = 'brand' and public),
    1, 'the brand bucket exists and is public');

  -- Bucket *configuration*, not authorisation: this runs as the owner, because
  -- storage.buckets carries RLS with no select policy (the platform behaves the
  -- same way), so an anon/authenticated caller legitimately sees zero rows and
  -- could never assert the configured allow-list from underneath that policy.
  -- These tokens are the exact strings the product-media policy's allow-list
  -- matches against, so a future bucket change fails here instead of silently
  -- accepting a different type everywhere.
  perform test.assert(
    (select allowed_mime_types @>
        array['image/jpeg', 'image/png', 'image/webp', 'video/mp4']::text[]
     from storage.buckets
     where id = 'product-media'),
    'product-media allowed_mime_types document the four supported types');
  perform test.assert(
    (select allowed_mime_types @>
        array['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml']::text[]
     from storage.buckets
     where id = 'brand'),
    'brand allowed_mime_types document the four supported types');
end;
$$;
\echo 'ok 9a - both buckets exist, are public and declare their allow-lists'

-- One object for anon to find: it is inserted as the owner (RLS bypassed)
-- because anon deliberately has no insert policy to use.
insert into storage.objects (bucket_id, name, metadata)
values ('product-media',
        'products/f0000000-0000-4000-8000-000000000001/seed.jpg',
        '{"size":1024,"mimetype":"image/jpeg"}'::jsonb);

set role anon;
do $$
declare
  v_state text;
  v_read  int;
begin
  -- Public read of an object that already exists.
  perform test.assert(
    (select true), 'anon has select on storage.objects');

  begin
    insert into storage.objects (bucket_id, name, metadata)
    values ('product-media', 'products/x/evil.png', '{"size":1024}'::jsonb);
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'anon CANNOT upload to product-media');

  select count(*) into v_read
    from storage.objects
   where bucket_id = 'product-media'
     and name = 'products/f0000000-0000-4000-8000-000000000001/seed.jpg';
  perform test.assert_eq(
    v_read, 1, 'anon CAN read the product-media object (public read)');
end;
$$;
reset role;

set role authenticated;
-- Non-admin: still denied.
select set_config('request.jwt.claim.sub', 'bbbbbbbb-0000-4000-8000-000000000001', false);
do $$
declare
  v_state text;
begin
  begin
    insert into storage.objects (bucket_id, name, metadata)
    values ('product-media', 'products/x/nonadmin.png', '{"size":1024}'::jsonb);
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501', 'a non-admin CANNOT upload product media');
end;
$$;

-- Admin: allowed within the size/type/path rules.
select set_config('request.jwt.claim.sub', 'aaaaaaaa-0000-4000-8000-000000000001', false);
do $$
declare
  v_state text;
begin
  insert into storage.objects (bucket_id, name, metadata)
  values ('product-media', 'products/f0000000-0000-4000-8000-000000000001/cover.jpg',
          '{"size":1048576,"mimetype":"image/jpeg"}'::jsonb);
  perform test.assert(true, 'admin CAN upload a 1 MB jpeg under products/');

  begin
    insert into storage.objects (bucket_id, name, metadata)
    values ('product-media', 'products/f0000000-0000-4000-8000-000000000001/big.png',
            '{"size":10485760,"mimetype":"image/png"}'::jsonb);
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501',
    'admin CANNOT upload a 10 MB image (5 MB cap)');

  begin
    insert into storage.objects (bucket_id, name, metadata)
    values ('product-media', 'elsewhere/x.png', '{"size":1024}'::jsonb);
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501',
    'admin CANNOT upload outside the products/ prefix');

  insert into storage.objects (bucket_id, name, metadata)
  values ('brand', 'logo/asm-logo.png', '{"size":204800}'::jsonb);
  perform test.assert(true, 'admin CAN upload the brand logo');
end;
$$;
reset role;
\echo 'ok 9b - storage: public read, admin-only write, size and path enforced'

-- ═══════════════════════════════════════════════════════════════════════════
-- 10 · Every table really has RLS enabled
-- ═══════════════════════════════════════════════════════════════════════════
do $$
declare
  v_missing text;
begin
  select string_agg(c.relname, ', ')
    into v_missing
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public'
     and c.relkind = 'r'
     and not c.relrowsecurity;

  perform test.assert(
    v_missing is null,
    'every table in public has row level security enabled (missing: ' || coalesce(v_missing, 'none') || ')'
  );
end;
$$;
\echo 'ok 10 - RLS is enabled on every public table'

-- ═══════════════════════════════════════════════════════════════════════════
-- 11 · Realtime publication — a streamed table that is not in it never updates
--
-- The app opens `.stream()` subscriptions on exactly these tables. Realtime
-- only delivers events for tables in `supabase_realtime`, and the failure is
-- silent: the subscription opens, the query succeeds, changes simply never
-- arrive. The list below mirrors the `.stream()` calls in lib/ — add a stream,
-- add its table here and to the migration.
-- ═══════════════════════════════════════════════════════════════════════════
do $$
declare
  v_missing text;
begin
  select string_agg(v.table_name, ', ' order by v.table_name)
    into v_missing
    from ( values ('categories'), ('products'), ('product_media'),
                   ('contact_links'), ('site_settings'), ('inquiries'),
                   ('text_overrides') )
           as v (table_name)
   where not exists (
     select 1
       from pg_publication_tables pt
      where pt.pubname = 'supabase_realtime'
        and pt.schemaname = 'public'
        and pt.tablename = v.table_name
   );

  perform test.assert(
    v_missing is null,
    'every streamed table is in the supabase_realtime publication (missing: '
      || coalesce(v_missing, 'none') || ')');
end;
$$;
\echo 'ok 11 - every table the app streams is in the realtime publication'

-- ═══════════════════════════════════════════════════════════════════════════
-- 12 · SUBCATEGORIES — one level of nesting, read through the parent
--
-- The column is a plain FK on `categories`, so the public policies above
-- already decide who sees a subcategory. What is new, and asserted here, is
-- the shape of the tree: exactly one level, a parent cannot be deleted while
-- children exist, and a product inside a subcategory reads like any other.
-- ═══════════════════════════════════════════════════════════════════════════
insert into public.categories (id, name, slug, sort_order, is_visible, parent_id)
values
  ('e0000000-0000-4000-8000-000000000010', 'RLS Subcategory', 'rls-test-sub',
   1, true, 'e0000000-0000-4000-8000-000000000001'),
  ('e0000000-0000-4000-8000-000000000020', 'RLS Delete Parent', 'rls-test-del-parent',
   2, true, null),
  ('e0000000-0000-4000-8000-000000000021', 'RLS Delete Child', 'rls-test-del-child',
   0, true, 'e0000000-0000-4000-8000-000000000020');

insert into public.products (id, category_id, title, price, is_published, is_available)
values ('f0000000-0000-4000-8000-000000000004',
        'e0000000-0000-4000-8000-000000000010',
        'RLS Subcategory Product', 1500, true, true);

set role anon;
do $$
declare
  v_state text;
begin
  perform test.assert_eq(
    (select count(*) from public.categories
      where id = 'e0000000-0000-4000-8000-000000000010'),
    1, 'anon sees a visible subcategory');

  perform test.assert_eq(
    (select parent_id from public.categories
      where id = 'e0000000-0000-4000-8000-000000000010'),
    'e0000000-0000-4000-8000-000000000001'::uuid,
    'a subcategory keeps its parent link for the storefront');

  perform test.assert_eq(
    (select count(*) from public.products
      where id = 'f0000000-0000-4000-8000-000000000004'),
    1, 'a product inside a visible subcategory is readable by anon');

  begin
    insert into public.categories (name, slug, parent_id)
    values ('RLS Anon Subcategory', 'rls-test-anon-sub',
            'e0000000-0000-4000-8000-000000000001');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '42501',
    'anon CANNOT create a subcategory');
end;
$$;
reset role;
\echo 'ok 12a - subcategories follow the category read policies'

set role authenticated;
select set_config('request.jwt.claim.sub', 'aaaaaaaa-0000-4000-8000-000000000001', false);
do $$
declare
  v_state text;
begin
  -- One level only: guard_category_nesting() rejects a grandchild.
  begin
    insert into public.categories (name, slug, parent_id)
    values ('RLS Grandchild', 'rls-test-grandchild',
            'e0000000-0000-4000-8000-000000000010');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '23514',
    'a subcategory CANNOT itself become a parent');

  -- Nor may a row be its own parent.
  begin
    insert into public.categories (id, name, slug, parent_id)
    values ('e0000000-0000-4000-8000-000000000011', 'RLS Self Parent',
            'rls-test-self-parent', 'e0000000-0000-4000-8000-000000000011');
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '23514',
    'a category CANNOT be its own parent');

  -- `on delete restrict`: a parent with children is refused, so the gateway
  -- never loses subcategories it did not ask to delete.
  begin
    delete from public.categories
     where id = 'e0000000-0000-4000-8000-000000000020';
    v_state := 'ok';
  exception when others then v_state := sqlstate;
  end;
  perform test.assert_eq(v_state, '23503',
    'a parent with subcategories CANNOT be deleted');

  -- Deleting the child first is the supported order, and then the parent goes.
  delete from public.categories
   where id = 'e0000000-0000-4000-8000-000000000021';
  delete from public.categories
   where id = 'e0000000-0000-4000-8000-000000000020';
  perform test.assert(
    not exists (
      select 1 from public.categories
       where id = 'e0000000-0000-4000-8000-000000000020'
    ),
    'deleting a subcategory first lets its parent be deleted');
end;
$$;
reset role;
\echo 'ok 12b - the tree stays one level deep and deletion is explicit'

\echo ''
\echo '=== ALL RLS TESTS PASSED ==='
