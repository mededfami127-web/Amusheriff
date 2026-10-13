-- ═══════════════════════════════════════════════════════════════════════════
-- seed.sql — Amu Sharif Arabiyan Majlis
--
-- Idempotent: every insert has a deterministic id and `on conflict do nothing`,
-- so running it twice is safe, and re-running after a `supabase db reset`
-- reproduces the same catalogue.
--
-- The demo products below are marked with a "Demo — " title prefix and use
-- reserved UUIDs (11111111-…). Remove them with:
--     delete from public.products where title like 'Demo — %';
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Branding ───────────────────────────────────────────────────────────────
update public.site_settings
   set store_name_en = 'Amu Sharif Arabiyan Majlis',
       store_name_am = 'አሙ ሸሪፍ አረቢያን መጅሊስ',
       store_name_ar = 'المجلس العربي عمو شريف',
       tagline       = 'Luxury Arabic majlis & sofas, handcrafted for your home',
       about         = 'Amu Sharif Arabiyan Majlis builds premium majlis seating, '
                       'floor cushions and furnishings in the Arabian tradition — '
                       'made in Ethiopia, shipped nationwide.',
       currency_code = 'ETB',
       default_language = 'en'
 where id = 1;

-- ── Categories ─────────────────────────────────────────────────────────────
insert into public.categories (id, name, name_am, name_ar, slug, sort_order, is_visible)
values
  ('c0000000-0000-4000-8000-000000000001', 'Majlis Sofas', 'የመጅሊስ ሶፋዎች', 'كنب المجلس',
   'majlis-sofas', 0, true),
  ('c0000000-0000-4000-8000-000000000002', 'Floor Seating', 'የመሬት መቀመጫ', 'جلسات أرضية',
   'floor-seating', 1, true),
  ('c0000000-0000-4000-8000-000000000003', 'Cushions and Pillows', 'ትራሶች እና ወረታ', 'وسائد ومساند',
   'cushions-and-pillows', 2, true),
  ('c0000000-0000-4000-8000-000000000004', 'Carpets', 'ምንጣፎች', 'سجاد',
   'carpets', 3, true),
  ('c0000000-0000-4000-8000-000000000005', 'Curtains', 'መጋረጃዎች', 'ستائر',
   'curtains', 4, true),
  ('c0000000-0000-4000-8000-000000000006', 'Accessories', 'ተጨማሪ ዕቃዎች', 'إكسسوارات',
   'accessories', 5, true)
on conflict (id) do nothing;

-- ── Demo products ──────────────────────────────────────────────────────────
insert into public.products (
  id, category_id, title, title_am, title_ar,
  description, description_am, description_ar,
  price, compare_at_price, currency_code,
  is_available, is_featured, is_published, sort_order
)
values
  (
    '11111111-1111-4111-8111-000000000001',
    'c0000000-0000-4000-8000-000000000001',
    'Demo — Royal Amber Majlis Sofa', 'ዴሞ — ሮያል አምበር መጅሊስ ሶፋ', 'تجريبي — كنب المجلس العنبري الملكي',
    'Three-seat majlis sofa with hand-carved beech frame, gold-thread trim and '
    'high-density cushions. Demonstrated in the royal violet and metallic gold palette.',
    'ባለሶስት መቀመጫ የመጅሊስ ሶፋ፣ በእጅ የተቀረጸ የቢች እንጨት፣ የወርቅ ጥልፍ እና ጥቅጥቅ ያለ ትራስ።',
    'كنب مجلس بثلاثة مقاعد بإطار خشبي محفور يدويًا وحواف ذهبية ووسائد عالية الكثافة.',
    28500.00, 34000.00, 'ETB', true, true, true, 0
  ),
  (
    '11111111-1111-4111-8111-000000000002',
    'c0000000-0000-4000-8000-000000000001',
    'Demo — Crescent Two-Seat Majlis', 'ዴሞ — ክሬሰንት ባለሁለት መቀመጫ', 'تجريبي — مجلس الهلال بمقعدين',
    'Compact two-seat majlis for apartments, with a crescent back and piped '
    'gold seams. Available in ivory and deep plum upholstery.',
    'ለአፓርታማ ተስማሚ የሆነ ባለሁለት መቀመጫ መጅሊስ፣ የግማሽ ጨረቃ ጀርባ እና የወርቅ ስፌት።',
    'مجلس مدمج بمقعدين بظهر هلالي وحواف ذهبية، متوفر بالإيفوري والبرقوقي.',
    18900.00, null, 'ETB', true, true, true, 1
  ),
  (
    '11111111-1111-4111-8111-000000000003',
    'c0000000-0000-4000-8000-000000000002',
    'Demo — Low Floor Majlis Set', 'ዴሞ — ዝቅተኛ የመሬት መጅሊስ ስብስብ', 'تجريبي — طقم جلسة أرضية منخفضة',
    'Six-piece low floor seating set with a wooden base table. Ideal for a '
    'traditional Arabic sitting room.',
    'ባለስድስት ክፍል ዝቅተኛ የመሬት መቀመጫ ስብስብ ከእንጨት ጠረጴዛ ጋር።',
    'طقم جلسة أرضية منخفضة من ست قطع مع طاولة خشبية.',
    22400.00, null, 'ETB', true, false, true, 2
  ),
  (
    '11111111-1111-4111-8111-000000000004',
    'c0000000-0000-4000-8000-000000000003',
    'Demo — Velvet Cushion Set (6)', 'ዴሞ — የቬልቬት ትራስ ስብስብ (6)', 'تجريبي — طقم وسائد مخملية (٦)',
    'Six velvet cushions with gold piping in ivory, plum and ochre. Covers are '
    'removable and machine washable.',
    'ስድስት የቬልቬት ትራሶች ከወርቅ ጠርዝ ጋር። ሽፋኖቹ ሊወለቁ ይችላሉ።',
    'ست وسائد مخملية بحواف ذهبية، الأغطية قابلة للإزالة والغسل.',
    3400.00, 4200.00, 'ETB', true, true, true, 3
  ),
  (
    '11111111-1111-4111-8111-000000000005',
    'c0000000-0000-4000-8000-000000000004',
    'Demo — Handknotted Wool Carpet', 'ዴሞ — በእጅ የተሰራ የሱፍ ምንጣፍ', 'تجريبي — سجادة صوف معقودة يدويًا',
    'Handknotted wool carpet, 200 × 300 cm, in a traditional geometric motif.',
    'በእጅ የተሰራ የሱፍ ምንጣፍ 200 × 300 ሴ.ሜ በባህላዊ ንድፍ።',
    'سجادة صوف معقودة يدويًا ٢٠٠ × ٣٠٠ سم بنقش هندسي تقليدي.',
    15200.00, null, 'ETB', true, false, true, 4
  ),
  (
    '11111111-1111-4111-8111-000000000006',
    'c0000000-0000-4000-8000-000000000005',
    'Demo — Gold-Tassel Curtain Pair', 'ዴሞ — የወርቅ ጋርዳ መጋረጃ ጥንድ', 'تجريبي — زوج ستائر بشرابة ذهبية',
    'Floor-length blackout curtain pair with gold tassel tiebacks.',
    'እስከ ወለል የሚዘልቅ መጋረጃ ጥንድ ከወርቅ ጋርዳ ጋር።',
    'زوج ستائر بطول الأرض مع شراشيب ذهبية.',
    6800.00, 7900.00, 'ETB', true, false, true, 5
  )
on conflict (id) do nothing;

-- ── Contact links (from the logo artwork) ──────────────────────────────────
-- The logo prints "https;t.me/amumejlisamusharif" — a typographic slip. The
-- value below is the normalised URL.
insert into public.contact_links (id, kind, label, value, is_primary, is_visible, sort_order)
values
  ('d0000000-0000-4000-8000-000000000001', 'whatsapp', 'WhatsApp',
   '+251917928950', true, true, 0),
  ('d0000000-0000-4000-8000-000000000002', 'telegram', 'Telegram',
   'https://t.me/amumejlisamusharif', false, true, 1),
  ('d0000000-0000-4000-8000-000000000003', 'phone', 'Second line',
   '+251918959071', false, true, 2),
  ('d0000000-0000-4000-8000-000000000004', 'location', 'Showroom',
   'Jimma, Ethiopia', false, true, 3),
  -- Kept hidden so the owner can see the shape of an "other" link without it
  -- appearing on the storefront.
  ('d0000000-0000-4000-8000-000000000005', 'other', 'Price list (PDF)',
   'https://example.com/asm-price-list.pdf', false, false, 9)
on conflict (id) do nothing;
