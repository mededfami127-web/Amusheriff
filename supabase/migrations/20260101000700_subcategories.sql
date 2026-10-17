-- ═══════════════════════════════════════════════════════════════════════════
-- 007 · Subcategories
--
-- One level of nesting, enforced in the database rather than trusted from the
-- app: a category may point at a parent, and that parent must itself be
-- top-level. Any deeper tree, and any self-reference, is rejected with a CHECK
-- violation the client already renders as "correct the highlighted fields".
--
-- `on delete restrict` (not cascade) is deliberate: deleting a parent that
-- still has subcategories — or products inside them — fails loudly instead of
-- silently removing catalogue rows the owner never asked to lose. The gateway
-- deletes subcategories first, exactly as it does for products.
-- ═══════════════════════════════════════════════════════════════════════════

begin;

alter table public.categories
  add column if not exists parent_id uuid
    references public.categories (id) on delete restrict;

comment on column public.categories.parent_id is
  'Parent category of a subcategory. NULL means the row is top-level.';

-- Matches the read pattern everywhere: children of one parent, in order.
create index if not exists categories_parent_order_idx
  on public.categories (parent_id, sort_order);

-- ── Nesting guard ──────────────────────────────────────────────────────────
-- Written as a trigger rather than a CHECK because the rule needs to look at
-- another row. Fires on `parent_id` only, so renaming a subcategory is free.
create or replace function public.guard_category_nesting()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_grandparent uuid;
begin
  if new.parent_id is null then
    return new;
  end if;

  if new.parent_id = new.id then
    raise exception 'a category cannot be its own parent'
      using errcode = '23514';
  end if;

  select c.parent_id
    into v_grandparent
    from public.categories c
   where c.id = new.parent_id;

  if v_grandparent is not null then
    raise exception 'subcategories cannot be nested more than one level deep'
      using errcode = '23514';
  end if;

  return new;
end;
$$;

comment on function public.guard_category_nesting() is
  'Rejects self-referencing and grandchild categories, keeping the tree one level deep.';

drop trigger if exists categories_guard_nesting on public.categories;
create trigger categories_guard_nesting
  before insert or update of parent_id on public.categories
  for each row execute function public.guard_category_nesting();

commit;
