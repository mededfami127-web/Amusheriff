-- ═══════════════════════════════════════════════════════════════════════════
-- 011 · products.subcategory_id, kept in step with the category tree
--
-- The app selects a product's subcategory through its `category_id`: the
-- admin's category dropdown lists every top-level category with its children
-- directly underneath, so picking "Mejlis → Corner units" writes
-- `category_id = <corner units id>`. That is enough for every screen the app
-- ships, and it is why nothing in Dart sends a `subcategory_id` column.
--
-- The column still exists here so the schema itself can answer "which products
-- belong to a subcategory" directly — for a report, a SQL filter, or a future
-- storefront query — without every reader having to join `categories` to learn
-- that a category has a parent. It is derived, never authored:
--
--   * a trigger recomputes it from `category_id` on insert and on every update
--     of `category_id`, so a client cannot write an inconsistent value (it is
--     overridden before the row reaches RLS);
--   * the backfill below fixes the rows that already exist;
--   * `on delete set null` keeps a category delete from being blocked by this
--     column — `products.category_id` already carries the `on delete restrict`
--     that stops a category with products from disappearing.
--
-- Idempotent: `add column if not exists`, `create or replace function`,
-- `drop trigger if exists`, `create index if not exists`, and the backfill only
-- touches rows whose value actually differs. Re-applying is a no-op.
-- ═══════════════════════════════════════════════════════════════════════════

alter table public.products
  add column if not exists subcategory_id uuid
    references public.categories (id) on delete set null;

comment on column public.products.subcategory_id is
  'Subcategory this product belongs to, derived from category_id (the parent '
  'of that category when it has one, otherwise NULL). Maintained by '
  'products_sync_subcategory; never written by clients.';

-- ── Derivation trigger ─────────────────────────────────────────────────────
-- Fires on insert and on `category_id` only: renaming a subcategory or
-- reordering categories does not rewrite every product row.
create or replace function public.sync_product_subcategory()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_parent uuid;
begin
  select c.parent_id
    into v_parent
    from public.categories c
   where c.id = new.category_id;

  new.subcategory_id := case
    when v_parent is null then null
    else new.category_id
  end;
  return new;
end;
$$;

comment on function public.sync_product_subcategory() is
  'Points products.subcategory_id at category_id whenever that category is itself a subcategory.';

drop trigger if exists products_sync_subcategory on public.products;
create trigger products_sync_subcategory
  before insert or update of category_id on public.products
  for each row execute function public.sync_product_subcategory();

-- ── Backfill ───────────────────────────────────────────────────────────────
-- Only rows whose derived value is wrong, so a re-run writes nothing.
update public.products p
   set subcategory_id = p.category_id
  from public.categories c
 where c.id = p.category_id
   and c.parent_id is not null
   and p.subcategory_id is distinct from p.category_id;

-- Products of a subcategory are read together on that subcategory's page.
create index if not exists products_subcategory_idx
  on public.products (subcategory_id, sort_order)
  where subcategory_id is not null;

-- A new column does not change any policy: RLS and grants are table-wide, and
-- the admin-only write policies in 20260101000300_rls_policies.sql already
-- cover this table. Nothing to add here on purpose.
