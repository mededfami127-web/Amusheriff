-- ═══════════════════════════════════════════════════════════════════════════
-- 012 · The shop's brand name
--
--   The app bar and the storefront hero render `site_settings.store_name_*`,
--   so renaming the shop in the app's ARBs alone would leave every existing
--   project showing the old wording: the row in the database wins over the
--   compiled default.
--
--   Two changes:
--     1. the column default, so a project created from this migration set
--        starts with the new name;
--     2. the row itself, but only while it still holds the shipped wording —
--        a name the owner typed in the gateway is never overwritten.
--
--   Idempotent: re-applying updates nothing on the second run.
-- ═══════════════════════════════════════════════════════════════════════════

alter table public.site_settings
  alter column store_name_en
  set default 'Amusheriff Arabiyan Mejlis and Furniture';

update public.site_settings
   set store_name_en = 'Amusheriff Arabiyan Mejlis and Furniture'
 where store_name_en = 'Amu Sharif Arabiyan Majlis';

update public.site_settings
   set store_name_am = 'አሙሸሪፍ አረቢያን መጅሊስ እና ፈርኒቸር'
 where store_name_am = 'አሙ ሸሪፍ አረቢያን መጅሊስ';

update public.site_settings
   set store_name_ar = 'أمشريف عربيان مجلس والأثاث'
 where store_name_ar = 'المجلس العربي عمو شريف';

update public.site_settings
   set store_name_om = 'Amusheriff Arabiyaan Majlis fi Meeshaa Manaa'
 where store_name_om = 'Aamu Sharif Arabiyaan Majlis';
