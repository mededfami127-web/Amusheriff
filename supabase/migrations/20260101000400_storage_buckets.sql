-- ═══════════════════════════════════════════════════════════════════════════
-- 005 · Storage buckets and object policies
--
--   product-media  public read · admin write
--                  products/{product_id}/{uuid}.{ext}
--                  image/jpeg, image/png, image/webp  → max 5 MB
--                  video/mp4                          → max 40 MB, ≤ 60 s
--   brand          public read · admin write — logo and category covers
--
-- The bucket-level `file_size_limit` / `allowed_mime_types` are the first line
-- of defence; the per-object policies add the tighter 5 MB image cap that a
-- bucket can only express once.
-- ═══════════════════════════════════════════════════════════════════════════

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

-- ── Public read ────────────────────────────────────────────────────────────
-- Both buckets are world-readable: everything in them is marketing imagery.
drop policy if exists "product media public read" on storage.objects;
create policy "product media public read" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'product-media');

drop policy if exists "brand public read" on storage.objects;
create policy "brand public read" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'brand');

-- ── Admin write: product-media ─────────────────────────────────────────────
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

-- ── Admin write: brand ─────────────────────────────────────────────────────
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
