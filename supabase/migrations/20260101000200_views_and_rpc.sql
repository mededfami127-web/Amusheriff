-- ═══════════════════════════════════════════════════════════════════════════
-- 003 · Public views, RPCs and the inquiry rate limiter
-- ═══════════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────────
-- v_products_public — published products in visible categories, each joined
-- with its cover media and media counts.
--
-- `security_invoker = true` (PostgreSQL 15+) means the view is evaluated with
-- the CALLER's privileges, so RLS still applies. Without it, a view owned by
-- the migration role would leak unpublished rows to anonymous visitors.
-- ───────────────────────────────────────────────────────────────────────────
create or replace view public.v_products_public
with (security_invoker = true)
as
select
  p.id,
  p.category_id,
  p.title,
  p.title_am,
  p.title_ar,
  p.description,
  p.description_am,
  p.description_ar,
  p.price,
  p.compare_at_price,
  p.currency_code,
  p.is_available,
  p.is_featured,
  p.is_published,
  p.sort_order,
  p.created_at,
  p.updated_at,
  c.slug  as category_slug,
  c.name  as category_name,
  cm.storage_path as cover_path,
  cm.kind         as cover_kind,
  coalesce(mc.image_count, 0) as image_count,
  coalesce(mc.video_count, 0) as video_count
from public.products p
join public.categories c on c.id = p.category_id
left join lateral (
  select m.storage_path, m.kind
  from public.product_media m
  where m.product_id = p.id
  order by m.is_cover desc, m.sort_order asc
  limit 1
) cm on true
left join lateral (
  select
    count(*) filter (where m.kind = 'image') as image_count,
    count(*) filter (where m.kind = 'video') as video_count
  from public.product_media m
  where m.product_id = p.id
) mc on true
where p.is_published
  and c.is_visible;

comment on view public.v_products_public is
  'Storefront read model: published products in visible categories with cover media.';

-- ───────────────────────────────────────────────────────────────────────────
-- v_categories_with_counts — categories plus their published-product counts
-- ───────────────────────────────────────────────────────────────────────────
create or replace view public.v_categories_with_counts
with (security_invoker = true)
as
select
  c.id,
  c.name,
  c.name_am,
  c.name_ar,
  c.slug,
  c.cover_path,
  c.sort_order,
  c.is_visible,
  c.created_at,
  c.updated_at,
  (
    select count(*)
    from public.products p
    where p.category_id = c.id and p.is_published
  ) as product_count
from public.categories c;

comment on view public.v_categories_with_counts is
  'Categories with their published product counts.';

-- ───────────────────────────────────────────────────────────────────────────
-- search_products — trigram + substring search, RLS-safe
--
-- `security invoker` (the default) so RLS on public.products still applies:
-- an anonymous caller can only ever match published rows.
-- ───────────────────────────────────────────────────────────────────────────
create or replace function public.search_products(q text, p_limit int default 40)
returns setof public.products
language sql
stable
set search_path = public
as $$
  with needle as (
    select nullif(btrim(coalesce(q, '')), '') as term
  )
  select p.*
  from public.products p
  join public.categories c on c.id = p.category_id
  cross join needle n
  where n.term is not null
    and p.is_published
    and c.is_visible
    and (
      p.title % n.term
      or position(lower(n.term) in lower(p.title)) > 0
      or position(lower(n.term) in lower(coalesce(p.title_am, ''))) > 0
      or position(lower(n.term) in lower(coalesce(p.title_ar, ''))) > 0
      or position(lower(n.term) in lower(coalesce(p.description, ''))) > 0
    )
  order by
    greatest(
      similarity(p.title, n.term),
      similarity(coalesce(p.title_am, ''), n.term),
      similarity(coalesce(p.title_ar, ''), n.term)
    ) desc,
    p.sort_order asc,
    p.created_at desc
  limit least(greatest(coalesce(p_limit, 40), 1), 100);
$$;

comment on function public.search_products(text, int) is
  'Trigram + substring product search. Runs as the caller so RLS filters the rows.';

revoke all on function public.search_products(text, int) from public;
grant execute on function public.search_products(text, int) to anon, authenticated, service_role;

-- ───────────────────────────────────────────────────────────────────────────
-- reorder_rows — persist a whole manual ordering in one transaction
--
-- SECURITY DEFINER because it performs dynamic SQL; the explicit is_admin()
-- check is therefore mandatory (RLS is bypassed inside a definer function).
-- ───────────────────────────────────────────────────────────────────────────
create or replace function public.reorder_rows(p_table text, p_ids uuid[])
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  i     int;
  v_len int;
begin
  if not public.is_admin() then
    raise exception 'not authorised' using errcode = '42501';
  end if;

  if p_table not in ('categories', 'products', 'product_media', 'contact_links') then
    raise exception 'reorder_rows: unsupported table %', p_table
      using errcode = '22023';
  end if;

  v_len := coalesce(array_length(p_ids, 1), 0);
  if v_len = 0 then
    return;
  end if;

  for i in 1 .. v_len loop
    execute format('update public.%I set sort_order = $1 where id = $2', p_table)
      using (i - 1), p_ids[i];
  end loop;
end;
$$;

comment on function public.reorder_rows(text, uuid[]) is
  'Admin-only bulk sort_order update for catalogue tables.';

revoke all on function public.reorder_rows(text, uuid[]) from public;
grant execute on function public.reorder_rows(text, uuid[]) to authenticated, service_role;

-- ───────────────────────────────────────────────────────────────────────────
-- inquiries rate limiting
--
-- The storefront writes leads straight to public.inquiries (RLS allows anon
-- INSERT only). A BEFORE INSERT trigger caps how fast a single device can do
-- it, so the protection holds even before the Edge Function layer exists.
-- ───────────────────────────────────────────────────────────────────────────
create or replace function public.guard_inquiry_rate()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_recent int;
  c_window constant interval := interval '10 minutes';
  c_limit  constant int := 10;
begin
  new.device_id := left(nullif(btrim(coalesce(new.device_id, '')), ''), 128);

  if new.device_id is null then
    return new;
  end if;

  select count(*)
    into v_recent
    from public.inquiries
   where device_id = new.device_id
     and created_at > now() - c_window;

  if v_recent >= c_limit then
    raise exception 'Too many inquiries from this device, please try again later'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;

drop trigger if exists inquiries_rate_limit on public.inquiries;
create trigger inquiries_rate_limit
  before insert on public.inquiries
  for each row execute function public.guard_inquiry_rate();
