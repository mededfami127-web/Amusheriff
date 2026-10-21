-- ═══════════════════════════════════════════════════════════════════════════
-- 010 · Per-language catalogue text: Afaan Oromo
--
-- The catalogue already carried English + Amharic + Arabic columns, but no
-- Oromo ones, so `Product.titleFor('om')` / `Category.nameFor('om')` could only
-- ever answer with English. These columns close that gap for the fourth shipped
-- language, keeping the same shape as `title_am` / `name_ar`:
--
--   * nullable, because English stays the only required field;
--   * no default, so an untouched row is "no Oromo text" and the app falls back
--     selected language → English → any non-empty value.
--
-- Nothing here touches RLS: the new columns ride on the existing table grants
-- and policies, which already restrict writes to `is_admin()`.
--
-- Idempotent: every statement is `if not exists` / `create or replace`, so the
-- file can be re-applied against an up-to-date database without a change.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Columns ────────────────────────────────────────────────────────────────

alter table public.categories
  add column if not exists name_om text;

alter table public.products
  add column if not exists title_om text;

alter table public.products
  add column if not exists description_om text;

comment on column public.categories.name_om is
  'Optional Afaan Oromo category name. NULL or blank falls back to English.';

comment on column public.products.title_om is
  'Optional Afaan Oromo product title. NULL or blank falls back to English.';

comment on column public.products.description_om is
  'Optional Afaan Oromo product description. NULL or blank falls back to English.';

-- Same trigram treatment as `title_am` / `title_ar`, so `search_products` can
-- match an Oromo query against an Oromo title through an index instead of a
-- sequential scan.
create index if not exists products_title_om_trgm
  on public.products using gin (title_om gin_trgm_ops);

-- ── Read models ────────────────────────────────────────────────────────────
-- `create or replace view` may only append columns, never rename or reorder
-- existing ones, so the new columns go at the end of each select list.

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
  coalesce(mc.video_count, 0) as video_count,
  p.title_om,
  p.description_om
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
  ) as product_count,
  c.name_om
from public.categories c;

comment on view public.v_categories_with_counts is
  'Categories with their published product counts.';

-- ── Search ─────────────────────────────────────────────────────────────────
-- The Oromo title joins the match and the ranking, so a shopper typing Oromo
-- text finds the row and the best Oromo match sorts first.

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
      or position(lower(n.term) in lower(coalesce(p.title_om, ''))) > 0
      or position(lower(n.term) in lower(coalesce(p.description, ''))) > 0
      or position(lower(n.term) in lower(coalesce(p.description_om, ''))) > 0
    )
  order by
    greatest(
      similarity(p.title, n.term),
      similarity(coalesce(p.title_am, ''), n.term),
      similarity(coalesce(p.title_ar, ''), n.term),
      similarity(coalesce(p.title_om, ''), n.term)
    ) desc,
    p.sort_order asc,
    p.created_at desc
  limit least(greatest(coalesce(p_limit, 40), 1), 100);
$$;

comment on function public.search_products(text, int) is
  'Trigram + substring product search across every shipped language. Runs as the caller so RLS filters the rows.';

revoke all on function public.search_products(text, int) from public;
grant execute on function public.search_products(text, int) to anon, authenticated, service_role;
