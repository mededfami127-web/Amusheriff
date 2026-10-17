-- 004 - Row Level Security
--
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
