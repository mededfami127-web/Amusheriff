// GENERATED FILE — DO NOT EDIT BY HAND.
//
// Run `dart run tool/gen_text_overlay.dart` after changing any
// lib/l10n/app_*.arb file. It restates the ARBs as Dart so the
// owner-facing text editor can list and resolve every string by key.
// ignore_for_file: type=lint

/// One editable string: its key, its shipped wording in every
/// locale, and the screen group it belongs to.
class AppTextEntry {
  const AppTextEntry({
    required this.key,
    required this.sectionKey,
    required this.defaults,
    this.placeholders = const <String>[],
    this.isPlural = false,
  });

  final String key;

  /// ARB key of the screen this text belongs to.
  final String sectionKey;

  /// Locale code → shipped wording.
  final Map<String, String> defaults;

  /// `{name}`-style variables the text must keep.
  final List<String> placeholders;

  /// ICU plurals cannot be replaced by plain text, so the editor
  /// shows these read-only.
  final bool isPlural;

  bool get hasPlaceholders => placeholders.isNotEmpty;

  bool get isEditable => !isPlural;

  /// The shipped wording for [locale], falling back to English.
  String defaultFor(String locale) => defaults[locale] ?? defaults['en'] ?? key;

  /// Same, for the first locale that has any wording at all.
  String get anyDefault =>
      defaults.values.isEmpty ? key : defaults.values.first;
}

/// Locales the owner can edit, in picker order.
const List<String> kAppTextLocales = <String>['en', 'am', 'ar', 'om'];

/// Locale code → the name shown in the language picker.
const Map<String, String> kAppTextLocaleNames = <String, String>{
  'en': 'English',
  'am': 'አማርኛ',
  'ar': 'العربي',
  'om': 'Oromoo',
};

/// Screen groups, in the order the editor shows them.
const List<String> kAppTextSections = <String>[
  'groupStorefront',
  'settingsTitle',
  'adminDashboard',
  'adminProducts',
  'adminCategories',
  'adminContacts',
  'adminInquiries',
  'adminSiteSettings',
  'adminTextEditor',
  'adminAccount',
  'gateTitle',
  'groupErrors',
  'groupValidation',
  'groupCommon',
];

/// Every string in the app.
const List<AppTextEntry> kAppTextEntries = <AppTextEntry>[
  AppTextEntry(
    key: 'a11yOpenCategory',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Open the {name} category',
      'am': 'የ{name} ምድብ ክፈት',
      'ar': 'افتح فئة {name}',
      'om': 'Ramaddii {name} bani',
    },
    placeholders: <String>['name'],
  ),
  AppTextEntry(
    key: 'a11yProductImage',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Photo of {title}',
      'am': 'የ{title} ፎቶ',
      'ar': 'صورة {title}',
      'om': 'Suuraa {title}',
    },
    placeholders: <String>['title'],
  ),
  AppTextEntry(
    key: 'a11yVideoThumbnail',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Play the video for {title}',
      'am': 'የ{title} ቪዲዮ አጫውት',
      'ar': 'تشغيل فيديو {title}',
      'om': 'Viidiyoo {title} taphachiisi',
    },
    placeholders: <String>['title'],
  ),
  AppTextEntry(
    key: 'aboutFallback',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Amu Sharif Arabiyan Majlis crafts premium majlis seating, floor cushions and furnishings in the Arabian tradition.',
      'am': 'አሙ ሸሪፍ አረቢያን መጅሊስ በአረብ ወግ መሰረት ጥራት ያላቸው የመጅሊስ ወንበሮች፣ የመሬት ትራሶች እና የቤት እቃዎችን ያመርታል።',
      'ar': 'المجلس العربي عمو شريف يصنع مجالس وكنب وأثاثًا فاخرًا وفق التقاليد العربية.',
      'om': 'Aamu Sharif Arabiyaan Majlis teessoo majlisii, boraatiiwwanii fi meeshaalee mana keessaa sadarkaa olaanaa haala Arabiyaan harkaan hojjeta.',
    },
  ),
  AppTextEntry(
    key: 'actionAdd',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Add',
      'am': 'ጨምር',
      'ar': 'إضافة',
      'om': 'Ida\'i',
    },
  ),
  AppTextEntry(
    key: 'actionCallNow',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Call now',
      'am': 'አሁን ይደውሉ',
      'ar': 'اتصل الآن',
      'om': 'Amma bilbilii',
    },
  ),
  AppTextEntry(
    key: 'actionCancel',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Cancel',
      'am': 'ሰርዝ',
      'ar': 'إلغاء',
      'om': 'Dhiisi',
    },
  ),
  AppTextEntry(
    key: 'actionClear',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Clear',
      'am': 'አጽዳ',
      'ar': 'مسح',
      'om': 'Haqi',
    },
  ),
  AppTextEntry(
    key: 'actionClose',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Close',
      'am': 'ዝጋ',
      'ar': 'إغلاق',
      'om': 'Cufi',
    },
  ),
  AppTextEntry(
    key: 'actionConfirm',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Confirm',
      'am': 'አረጋግጥ',
      'ar': 'تأكيد',
      'om': 'Mirkaneessi',
    },
  ),
  AppTextEntry(
    key: 'actionContactOwner',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Contact the owner',
      'am': 'ባለቤቱን ያግኙ',
      'ar': 'تواصل مع المالك',
      'om': 'Abbaa qabeenyaa quunnami',
    },
  ),
  AppTextEntry(
    key: 'actionContinue',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Continue',
      'am': 'ቀጥል',
      'ar': 'متابعة',
      'om': 'Itti fufi',
    },
  ),
  AppTextEntry(
    key: 'actionCopyLink',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Copy link',
      'am': 'አገናኝ ቅዳ',
      'ar': 'انسخ الرابط',
      'om': 'Geessituu waraabi',
    },
  ),
  AppTextEntry(
    key: 'actionCopySuccess',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Link copied',
      'am': 'አገናኙ ተቀድቷል',
      'ar': 'تم نسخ الرابط',
      'om': 'Geessituun waraabame',
    },
  ),
  AppTextEntry(
    key: 'actionCreate',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Create',
      'am': 'ይፍጠሩ',
      'ar': 'إنشاء',
      'om': 'Uumi',
    },
  ),
  AppTextEntry(
    key: 'actionDelete',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Delete',
      'am': 'አጥፋ',
      'ar': 'حذف',
      'om': 'Balleessi',
    },
  ),
  AppTextEntry(
    key: 'actionDiscardAll',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Discard',
      'am': 'አስተውል',
      'ar': 'تجاهل',
      'om': 'Jijjiirama haqi',
    },
  ),
  AppTextEntry(
    key: 'actionEdit',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Edit',
      'am': 'አስተካክል',
      'ar': 'تعديل',
      'om': 'Gulaali',
    },
  ),
  AppTextEntry(
    key: 'actionFavourite',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Save to favourites',
      'am': 'ወደ ተወዳጆች አስቀምጥ',
      'ar': 'أضف إلى المفضلة',
      'om': 'Filannoo keetti galchi',
    },
  ),
  AppTextEntry(
    key: 'actionMove',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Move',
      'am': 'አስቀይጥ',
      'ar': 'نقل',
      'om': 'Sochoosi',
    },
  ),
  AppTextEntry(
    key: 'actionOrderNow',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Order now',
      'am': 'አሁን ያዙ',
      'ar': 'اطلب الآن',
      'om': 'Amma ajaji',
    },
  ),
  AppTextEntry(
    key: 'actionRetry',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Try again',
      'am': 'እንደገና ሞክር',
      'ar': 'أعد المحاولة',
      'om': 'Irra deebi\'ii yaali',
    },
  ),
  AppTextEntry(
    key: 'actionSave',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Save',
      'am': 'አስቀምጥ',
      'ar': 'حفظ',
      'om': 'Olkaa\'i',
    },
  ),
  AppTextEntry(
    key: 'actionSearch',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Search',
      'am': 'ፈልግ',
      'ar': 'بحث',
      'om': 'Barbaadi',
    },
  ),
  AppTextEntry(
    key: 'actionSelectImage',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Select image',
      'am': 'ምስል ይምረጡ',
      'ar': 'اختر صورة',
      'om': 'Suuraa filadhu',
    },
  ),
  AppTextEntry(
    key: 'actionShare',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Share',
      'am': 'አጋራ',
      'ar': 'مشاركة',
      'om': 'Qoodi',
    },
  ),
  AppTextEntry(
    key: 'actionUnfavourite',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Remove from favourites',
      'am': 'ከተወዳጆች አስወግድ',
      'ar': 'أزل من المفضلة',
      'om': 'Filannoo keessaa haqi',
    },
  ),
  AppTextEntry(
    key: 'actionViewDetails',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'View details',
      'am': 'ዝርዝር ይመልከቱ',
      'ar': 'عرض التفاصيل',
      'om': 'Bal\'ina ilaali',
    },
  ),
  AppTextEntry(
    key: 'adminAbout',
    sectionKey: 'adminSiteSettings',
    defaults: <String, String>{
      'en': 'About the store',
      'am': 'ስለ ሚስጥሩ',
      'ar': 'عن المتجر',
      'om': 'Waa\'ee suuqii',
    },
  ),
  AppTextEntry(
    key: 'adminAccount',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Owner account',
      'am': 'የባለቤት መለያ',
      'ar': 'حساب المالك',
      'om': 'Herrega abbaa qabeenyaa',
    },
  ),
  AppTextEntry(
    key: 'adminAddContact',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Add link',
      'am': 'አገናኝ ይጨምሩ',
      'ar': 'إضافة رابط',
      'om': 'Geessituu dabali',
    },
  ),
  AppTextEntry(
    key: 'adminAddImages',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Add images',
      'am': 'ምስሎችን ይጨምሩ',
      'ar': 'إضافة صور',
      'om': 'Suuraa dabali',
    },
  ),
  AppTextEntry(
    key: 'adminAddProduct',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Add product',
      'am': 'ምርት ይጨምሩ',
      'ar': 'إضافة منتج',
      'om': 'Oomisha dabali',
    },
  ),
  AppTextEntry(
    key: 'adminAddVideo',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Add video',
      'am': 'ቪዲዮ ይጨምሩ',
      'ar': 'إضافة فيديو',
      'om': 'Viidiyoo dabali',
    },
  ),
  AppTextEntry(
    key: 'adminAnonymous',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Anonymous',
      'am': 'አስመስግን',
      'ar': 'مجهول',
      'om': 'Maqaa hin beekamne',
    },
  ),
  AppTextEntry(
    key: 'adminBackToGateway',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Back to gateway',
      'am': 'ወደ በሩ ይመለሱ',
      'ar': 'العودة إلى البوابة',
      'om': 'Gara seensaatti deebi\'i',
    },
  ),
  AppTextEntry(
    key: 'adminCategories',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'Categories',
      'am': 'ምድቦች',
      'ar': 'الفئات',
      'om': 'Ramaddiiwwan',
    },
  ),
  AppTextEntry(
    key: 'adminCategoryCreated',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'Category created',
      'am': 'ምድብ ተፈጥሯል',
      'ar': 'تم إنشاء القسم',
      'om': 'Ramaddiin uumame',
    },
  ),
  AppTextEntry(
    key: 'adminCategoryDeleted',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'Category deleted',
      'am': 'ምድብ ተሰርዟል',
      'ar': 'تم حذف القسم',
      'om': 'Ramaddiin haqame',
    },
  ),
  AppTextEntry(
    key: 'adminCategoryHasProducts',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'This category still has {count} products. Move them to another category first, or delete the products.',
      'am': 'ይህ ምድብ እስካሁን {count} ምርቶች አሉት። በመጀመሪያ ወደ ሌላ ምድብ ያስተካክሉ ወይም ምርቶቹን ይሰርዙ።',
      'ar': 'لا يزال هذا القسم يحتوي على {count} منتج. انقلها إلى قسم آخر أولاً، أو احذف المنتجات.',
      'om': 'Ramaddii kana keessatti oomishni {count} hafa. Dura isaan ramaddii biraatti sochoosi, yookaan oomishaalee sana balleessi.',
    },
    placeholders: <String>['count'],
  ),
  AppTextEntry(
    key: 'adminCategoryHidden',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'Category hidden',
      'am': 'ምድብ ተደብቋል',
      'ar': 'تم إخفاء القسم',
      'om': 'Ramaddiin dhokate',
    },
  ),
  AppTextEntry(
    key: 'adminCategoryName',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'Name (English)',
      'am': 'ስም (እንግሊዝኛ)',
      'ar': 'الاسم (إنجليزي)',
      'om': 'Maqaa (Ingiliffa)',
    },
  ),
  AppTextEntry(
    key: 'adminCategoryNameAm',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'Name (Amharic)',
      'am': 'ስም (አማርኛ)',
      'ar': 'الاسم (أمهرية)',
      'om': 'Maqaa (Amaariffa)',
    },
  ),
  AppTextEntry(
    key: 'adminCategoryNameAr',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'Name (Arabic)',
      'am': 'ስም (በአረብኛ)',
      'ar': 'الاسم (عربي)',
      'om': 'Maqaa (Arabiffa)',
    },
  ),
  AppTextEntry(
    key: 'adminCategoryUpdated',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'Category updated',
      'am': 'ምድብ ተዘምኗል',
      'ar': 'تم تحديث القسم',
      'om': 'Ramaddiin haaromfame',
    },
  ),
  AppTextEntry(
    key: 'adminChangePassword',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Change password',
      'am': 'የይለፍ ቃል ቀይር',
      'ar': 'تغيير كلمة المرور',
      'om': 'Jecha darbii jijjiiri',
    },
  ),
  AppTextEntry(
    key: 'adminChannel',
    sectionKey: 'adminContacts',
    defaults: <String, String>{
      'en': 'Channel',
      'am': 'መስመር',
      'ar': 'القناة',
      'om': 'Karaa',
    },
  ),
  AppTextEntry(
    key: 'adminClearInquiries',
    sectionKey: 'adminInquiries',
    defaults: <String, String>{
      'en': 'Clear all',
      'am': 'ሁሉንም አጽዳ',
      'ar': 'مسح الكل',
      'om': 'Hunda haqi',
    },
  ),
  AppTextEntry(
    key: 'adminCompareAtPrice',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Compare-at price (optional)',
      'am': 'የገና ዋጋ (አማራጭ)',
      'ar': 'السعر قبل الخصم (اختياري)',
      'om': 'Gatii madaallii (filannoo)',
    },
  ),
  AppTextEntry(
    key: 'adminConfirmDeleteCategory',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Delete this category?',
      'am': 'ይህን ምድብ ሊሰርዙ ነው؟',
      'ar': 'هل تريد حذف هذا القسم؟',
      'om': 'Ramaddii kana balleessinaa?',
    },
  ),
  AppTextEntry(
    key: 'adminConfirmDeleteContact',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Remove this link?',
      'am': 'ይህን አገናኝ ሊሰርዙ ነው؟',
      'ar': 'هل تريد إزالة هذا الرابط؟',
      'om': 'Geessituu kana haqnaa?',
    },
  ),
  AppTextEntry(
    key: 'adminConfirmDeleteMessage',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'This cannot be undone.',
      'am': 'ይህን መቀስቀስ አይቻልም.',
      'ar': 'لا يمكن التراجع عن هذا.',
      'om': 'Kun deebi\'ee hin dhufu.',
    },
  ),
  AppTextEntry(
    key: 'adminConfirmDeleteProduct',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Delete this product?',
      'am': 'ይህን ምርት ሊሰርዙ ነው؟',
      'ar': 'هل تريد حذف هذا المنتج؟',
      'om': 'Oomisha kana balleessinaa?',
    },
  ),
  AppTextEntry(
    key: 'adminConfirmPassword',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Confirm new password',
      'am': 'አዲሱን የይለፍ ቃል ያረጋግጡ',
      'ar': 'تأكيد كلمة المرور الجديدة',
      'om': 'Jecha darbii haaraa mirkaneessi',
    },
  ),
  AppTextEntry(
    key: 'adminContactDeleted',
    sectionKey: 'adminContacts',
    defaults: <String, String>{
      'en': 'Link removed',
      'am': 'አገናኝ ተወግዷል',
      'ar': 'تمت إزالة الرابط',
      'om': 'Geessituun haqame',
    },
  ),
  AppTextEntry(
    key: 'adminContactLabel',
    sectionKey: 'adminContacts',
    defaults: <String, String>{
      'en': 'Label',
      'am': 'መጠሪያ',
      'ar': 'التسمية',
      'om': 'Mallattoo',
    },
  ),
  AppTextEntry(
    key: 'adminContactSaved',
    sectionKey: 'adminContacts',
    defaults: <String, String>{
      'en': 'Link saved',
      'am': 'አገናኝ ተቀምጧል',
      'ar': 'تم حفظ الرابط',
      'om': 'Geessituun olkaa\'ame',
    },
  ),
  AppTextEntry(
    key: 'adminContactValue',
    sectionKey: 'adminContacts',
    defaults: <String, String>{
      'en': 'Value',
      'am': 'ዋጋ',
      'ar': 'القيمة',
      'om': 'Qabiyyee',
    },
  ),
  AppTextEntry(
    key: 'adminContacts',
    sectionKey: 'adminContacts',
    defaults: <String, String>{
      'en': 'Contact links',
      'am': 'የመገኛ አገናኞች',
      'ar': 'روابط التواصل',
      'om': 'Geessituuwwan quunnamtii',
    },
  ),
  AppTextEntry(
    key: 'adminCover',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Cover',
      'am': 'መሸፈኛ',
      'ar': 'الغلاف',
      'om': 'Uwwisa',
    },
  ),
  AppTextEntry(
    key: 'adminCoverImage',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Cover image',
      'am': 'የመሸፈኛ ምስል',
      'ar': 'صورة الغلاف',
      'om': 'Suuraa uwwisaa',
    },
  ),
  AppTextEntry(
    key: 'adminCreateCategory',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'Create category',
      'am': 'ምድብ ይፍጠሩ',
      'ar': 'إنشاء قسم',
      'om': 'Ramaddii uumi',
    },
  ),
  AppTextEntry(
    key: 'adminCurrency',
    sectionKey: 'adminSiteSettings',
    defaults: <String, String>{
      'en': 'Currency',
      'am': 'ምንዛሪ',
      'ar': 'العملة',
      'om': 'Maallaqa',
    },
  ),
  AppTextEntry(
    key: 'adminCurrentPassword',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Current password',
      'am': 'የአሁኑ የይለፍ ቃል',
      'ar': 'كلمة المرور الحالية',
      'om': 'Jecha darbii ammaa',
    },
  ),
  AppTextEntry(
    key: 'adminDashboard',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'Dashboard',
      'am': 'ዳሽቦርድ',
      'ar': 'لوحة التحكم',
      'om': 'Daashboordii',
    },
  ),
  AppTextEntry(
    key: 'adminDefaultLanguage',
    sectionKey: 'adminSiteSettings',
    defaults: <String, String>{
      'en': 'Default language',
      'am': 'የመነሻ ቋንቋ',
      'ar': 'اللغة الافتراضية',
      'om': 'Afaan durtii',
    },
  ),
  AppTextEntry(
    key: 'adminDiscard',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Discard',
      'am': 'አስተውል',
      'ar': 'تجاهل',
      'om': 'Jijjiirama haqi',
    },
  ),
  AppTextEntry(
    key: 'adminDragToReorder',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Drag to reorder',
      'am': 'ለመደራደር ጎትት',
      'ar': 'اسحب لإعادة الترتيب',
      'om': 'Tartiiba jijjiiruuf harkisi',
    },
  ),
  AppTextEntry(
    key: 'adminDuplicate',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Duplicate',
      'am': 'ቀጥል',
      'ar': 'نسخ',
      'om': 'Koppii',
    },
  ),
  AppTextEntry(
    key: 'adminDuplicateCreated',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Copy created',
      'am': 'ቅጂ ተፈጥሯል',
      'ar': 'تم إنشاء النسخة',
      'om': 'Koppiin uumame',
    },
  ),
  AppTextEntry(
    key: 'adminEditCategory',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Edit category',
      'am': 'ምድብ ያስተካክሉ',
      'ar': 'تعديل القسم',
      'om': 'Ramaddii gulaali',
    },
  ),
  AppTextEntry(
    key: 'adminEditContact',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Edit link',
      'am': 'አገናኝ ያስተካክሉ',
      'ar': 'تعديل الرابط',
      'om': 'Geessituu gulaali',
    },
  ),
  AppTextEntry(
    key: 'adminEditProduct',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Edit product',
      'am': 'ምርት ያስተካክሉ',
      'ar': 'تعديل المنتج',
      'om': 'Oomisha gulaali',
    },
  ),
  AppTextEntry(
    key: 'adminEmailLabel',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Email',
      'am': 'ኢሜይል',
      'ar': 'البريد الإلكتروني',
      'om': 'Imeelii',
    },
  ),
  AppTextEntry(
    key: 'adminExitPreview',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'Exit preview',
      'am': 'ምልዓቱን ይውጣ',
      'ar': 'إنهاء المعاينة',
      'om': 'Ilaalcha irraa bahi',
    },
  ),
  AppTextEntry(
    key: 'adminFeatured',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Featured',
      'am': 'ተመራጭ',
      'ar': 'مميز',
      'om': 'Filatamaa',
    },
  ),
  AppTextEntry(
    key: 'adminFilterAllCategories',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'All categories',
      'am': 'ሁሉም ምድቦች',
      'ar': 'كل الأقسام',
      'om': 'Ramaddiiwwan hunda',
    },
  ),
  AppTextEntry(
    key: 'adminFilterAllStatus',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'All',
      'am': 'ሁሉም',
      'ar': 'الكل',
      'om': 'Hunda',
    },
  ),
  AppTextEntry(
    key: 'adminFilterDraft',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Draft',
      'am': 'ድራፍት',
      'ar': 'مسودة',
      'om': 'Wixinee',
    },
  ),
  AppTextEntry(
    key: 'adminFilterPublished',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Published',
      'am': 'ታወቀ',
      'ar': 'منشور',
      'om': 'Maxxanfame',
    },
  ),
  AppTextEntry(
    key: 'adminForgotPassword',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Forgot password?',
      'am': 'የይለፍ ቃል ረሱ?',
      'ar': 'هل نسيت كلمة المرور؟',
      'om': 'Jecha darbii dagatteettaa?',
    },
  ),
  AppTextEntry(
    key: 'adminGatewayTitle',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Admin gateway',
      'am': 'የአስተዳደር በር',
      'ar': 'بوابة الإدارة',
      'om': 'Seensa bulchaa',
    },
  ),
  AppTextEntry(
    key: 'adminHide',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Hide',
      'am': 'የደብቅ',
      'ar': 'إخفاء',
      'om': 'Dhoki',
    },
  ),
  AppTextEntry(
    key: 'adminInquiries',
    sectionKey: 'adminInquiries',
    defaults: <String, String>{
      'en': 'Inquiries',
      'am': 'ጥያቄዎች',
      'ar': 'الاستفسارات',
      'om': 'Gaaffiiwwan',
    },
  ),
  AppTextEntry(
    key: 'adminInquiriesWeek',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'Inquiries this week',
      'am': 'የዚህ ሳምንት ጥያቄዎች',
      'ar': 'استفسارات هذا الأسبوع',
      'om': 'Torban kana gaaffiiwwan',
    },
  ),
  AppTextEntry(
    key: 'adminInquiryDeleted',
    sectionKey: 'adminInquiries',
    defaults: <String, String>{
      'en': 'Inquiry cleared',
      'am': 'ጥያቄው ተጸድቋል',
      'ar': 'تم حذف الاستفسار',
      'om': 'Gaaffiin haqame',
    },
  ),
  AppTextEntry(
    key: 'adminJustNow',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'just now',
      'am': 'አሁን',
      'ar': 'الآن',
      'om': 'amma',
    },
  ),
  AppTextEntry(
    key: 'adminKeepEditing',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Keep editing',
      'am': 'ቀጥል',
      'ar': 'متابعة التحرير',
      'om': 'Gulaaluu itti fufi',
    },
  ),
  AppTextEntry(
    key: 'adminLiveEdit',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'Live edit',
      'am': 'ቀጥታ አርትዖት',
      'ar': 'التحرير المباشر',
      'om': 'Gulaala kallattii',
    },
  ),
  AppTextEntry(
    key: 'adminLiveEditOff',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'Live editing off',
      'am': 'ቀጥታ አርትዖት ጠፍቷል',
      'ar': 'التحرير المباشر مُطفأ',
      'om': 'Gulaalli kallattii cufameera',
    },
  ),
  AppTextEntry(
    key: 'adminLiveEditOn',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'Live editing on — tap a pencil to rewrite that text',
      'am': 'ቀጥታ አርትዖት በርቷል — ጽሑፉን ለመቀየር እርሳሱን ነካ',
      'ar': 'التحرير المباشر مُشغَّل — انقر القلم لتغيير ذلك النص',
      'om': 'Gulaalli kallattii banameera — barruu sana jijjiiruuf qalama tuqi',
    },
  ),
  AppTextEntry(
    key: 'adminLivePreview',
    sectionKey: 'adminSiteSettings',
    defaults: <String, String>{
      'en': 'Customer preview',
      'am': 'የደንበኛ ምልዓት',
      'ar': 'معاينة الزبون',
      'om': 'Ilaalcha maamila',
    },
  ),
  AppTextEntry(
    key: 'adminLoginSubtitle',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'This area is restricted to the shop owner.',
      'am': 'ይህ ክፍል ለሱቁ ባለቤት ብቻ ነው።',
      'ar': 'هذه المنطقة مخصصة لمالك المتجر فقط.',
      'om': 'Naannoon kun abbaa qabeenyaa suuqii qofaaf.',
    },
  ),
  AppTextEntry(
    key: 'adminLoginTitle',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Owner sign in',
      'am': 'የባለቤት መግቢያ',
      'ar': 'دخول المالك',
      'om': 'Seensa abbaa qabeenyaa',
    },
  ),
  AppTextEntry(
    key: 'adminLogoPreview',
    sectionKey: 'adminSiteSettings',
    defaults: <String, String>{
      'en': 'Logo preview',
      'am': 'የሎጎ ምልዓት',
      'ar': 'معاينة الشعار',
      'om': 'Ilaalcha mallattoo',
    },
  ),
  AppTextEntry(
    key: 'adminMarkPrimary',
    sectionKey: 'adminContacts',
    defaults: <String, String>{
      'en': 'Primary link',
      'am': 'ዋና አገናኝ',
      'ar': 'الرابط الأساسي',
      'om': 'Geessituu jalqabaa',
    },
  ),
  AppTextEntry(
    key: 'adminMedia',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Media',
      'am': 'ሚዲያ',
      'ar': 'الوسائط',
      'om': 'Miidiyaa',
    },
  ),
  AppTextEntry(
    key: 'adminMostContacted',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'Most contacted',
      'am': 'በጣም የተገናኙ',
      'ar': 'الأكثر تواصلًا',
      'om': 'Baay\'ee quunnamame',
    },
  ),
  AppTextEntry(
    key: 'adminMoveProductsTo',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'Move products to',
      'am': 'ምርቶችን ወደ',
      'ar': 'نقل المنتجات إلى',
      'om': 'Oomishaalee garasitti sochoosi',
    },
  ),
  AppTextEntry(
    key: 'adminNewPassword',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'New password',
      'am': 'አዲስ የይለፍ ቃል',
      'ar': 'كلمة المرور الجديدة',
      'om': 'Jecha darbii haaraa',
    },
  ),
  AppTextEntry(
    key: 'adminNoCategories',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'No categories yet. Create the first one to group your products.',
      'am': 'እስካሁን ምድቦች የሉም። ምርቶችዎን ለማድረስ መጀመሪያውን ይፍጠሩ።',
      'ar': 'لا توجد أقسام بعد. أنشئ أول قسم لتجميع منتجاتك.',
      'om': 'Ramaddiin hin jiru. Oomishaalee kee gareessuuf kan jalqabaa uumi.',
    },
  ),
  AppTextEntry(
    key: 'adminNoContacts',
    sectionKey: 'adminContacts',
    defaults: <String, String>{
      'en': 'No contact links yet. Customers reach you through these.',
      'am': 'እስካሁን የመገናኛ አገናኝ የለም። ደንበኞች ይህን በኩል ያገናኛሉ።',
      'ar': 'لا توجد روابط تواصل بعد. يبلغك الزوار من خلالها.',
      'om': 'Geessituun quunnamtii hin jiru. Maamiltoonni kanaan si quunnamu.',
    },
  ),
  AppTextEntry(
    key: 'adminNoInquiries',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'No inquiries yet. Customer taps on a contact button will show up here.',
      'am': 'እስካሁን ጥያቄዎች የለም። የደንበኛ ጠቅላላዎች እዚህ ይታያሉ።',
      'ar': 'لا توجد استفسارات بعد. ستظهر هنا نقرات الزوار على أزرار التواصل.',
      'om': 'Gaaffiin hin jiru. Yeroo maamilli geessituu quunnamtii tuqu asitti mul\'ata.',
    },
  ),
  AppTextEntry(
    key: 'adminNoInquiriesYet',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'No customer taps recorded yet. They will appear here as soon as someone taps a contact button.',
      'am': 'እስካሁን የደንበኛ ጠቅላላ የለም። ማንኛውም ተጠቃሚ የመገናኛ ቁልፍ ሲጠቅም እዚህ ይታያል።',
      'ar': 'لا توجد نقرات مسجلة بعد. ستظهر هنا فور نقر أحد الزوار على زر التواصل.',
      'om': 'Tuqaan maamilaa hin galmoofne. Namni geessituu quunnamtii tuqe asitti mul\'ata.',
    },
  ),
  AppTextEntry(
    key: 'adminNoMedia',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'No images or videos yet.',
      'am': 'እስካሁን ምስሎች ወይም ቪዲዮዎች የሉም።',
      'ar': 'لا توجد صور أو مقاطع فيديو بعد.',
      'om': 'Suuraa yookaan viidiyoo hin jiru.',
    },
  ),
  AppTextEntry(
    key: 'adminNoProducts',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'No products yet. Add your first piece to the catalogue.',
      'am': 'እስካሁን ምርቶች የለም። የመጀመሪያውን ምርት ይጨምሩ።',
      'ar': 'لا توجد منتجات بعد. أضف أول قطعة إلى الكتالوج.',
      'om': 'Oomishni hin jiru. Meeshaa jalqabaa galmee keetti dabali.',
    },
  ),
  AppTextEntry(
    key: 'adminNoProductsMatch',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'No products match your filters.',
      'am': 'ከማጣሪያዎዎ ጋር የሚገናኙ ምርቶች የሉም።',
      'ar': 'لا توجد منتجات مطابقة لعوامل التصفية.',
      'om': 'Oomishni filtarii kee wajjin walsimu hin jiru.',
    },
  ),
  AppTextEntry(
    key: 'adminNotAuthorised',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'This account is not an administrator.',
      'am': 'ይህ አካውንት አስተዳዳሪ አይደለም።',
      'ar': 'هذا الحساب ليس مسؤولًا.',
      'om': 'Herregni kun bulchaa hin ta\'e.',
    },
  ),
  AppTextEntry(
    key: 'adminOtherSessionsSignedOut',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Other sessions were signed out.',
      'am': 'ሌሎች ክፍለ ጊዜዎች ተውሰደዋል።',
      'ar': 'تم تسجيل خروج الجلسات الأخرى.',
      'om': 'Seensaaleen biroo baafaman.',
    },
  ),
  AppTextEntry(
    key: 'adminPasswordChanged',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Your password has been updated.',
      'am': 'የይለፍ ቃልዎ ተቀይሯል።',
      'ar': 'تم تحديث كلمة المرور.',
      'om': 'Jechi darbii kee haaromfame.',
    },
  ),
  AppTextEntry(
    key: 'adminPasswordLabel',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Password',
      'am': 'የይለፍ ቃል',
      'ar': 'كلمة المرور',
      'om': 'Jecha darbii',
    },
  ),
  AppTextEntry(
    key: 'adminPreviewAsCustomer',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'Preview as customer',
      'am': 'እንደ ደንበኛ ይመልከቱ',
      'ar': 'معاينة كزبون',
      'om': 'Akka maamilaatti ilaali',
    },
  ),
  AppTextEntry(
    key: 'adminPreviewBadge',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'Previewing as customer',
      'am': 'እንደ ደንበኛ ትመልከታለች',
      'ar': 'معاينة كزبون',
      'om': 'Akka maamilaatti ilaalama',
    },
  ),
  AppTextEntry(
    key: 'adminPrice',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Price',
      'am': 'ዋጋ',
      'ar': 'السعر',
      'om': 'Gatii',
    },
  ),
  AppTextEntry(
    key: 'adminPrimaryBadge',
    sectionKey: 'adminContacts',
    defaults: <String, String>{
      'en': 'Primary',
      'am': 'ዋና',
      'ar': 'أساسي',
      'om': 'Jalqabaa',
    },
  ),
  AppTextEntry(
    key: 'adminProductColumn',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'Product',
      'am': 'ምርت',
      'ar': 'المنتج',
      'om': 'Oomisha',
    },
  ),
  AppTextEntry(
    key: 'adminProductDeleted',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Product deleted',
      'am': 'ምርት ተሰርዟል',
      'ar': 'تم حذف المنتج',
      'om': 'Oomishni haqame',
    },
  ),
  AppTextEntry(
    key: 'adminProductDescription',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Description (English)',
      'am': 'መግለጫ (እንግሊዝኛ)',
      'ar': 'الوصف (الإنجليزية)',
      'om': 'Ibsa (Ingiliffa)',
    },
  ),
  AppTextEntry(
    key: 'adminProductDescriptionAm',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Description (Amharic)',
      'am': 'መግለጫ (አማርኛ)',
      'ar': 'الوصف (الأمهرية)',
      'om': 'Ibsa (Amaariffa)',
    },
  ),
  AppTextEntry(
    key: 'adminProductDescriptionAr',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Description (Arabic)',
      'am': 'መግለጫ (አረብኛ)',
      'ar': 'الوصف (العربية)',
      'om': 'Ibsa (Arabiffa)',
    },
  ),
  AppTextEntry(
    key: 'adminProductSaved',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Product saved',
      'am': 'ምርት ተቀምጧል',
      'ar': 'تم حفظ المنتج',
      'om': 'Oomishni olkaa\'ame',
    },
  ),
  AppTextEntry(
    key: 'adminProductTitle',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Title (English)',
      'am': 'ርዕስ (እንግሊዝኛ)',
      'ar': 'العنوان (الإنجليزية)',
      'om': 'Mata-duree (Ingiliffa)',
    },
  ),
  AppTextEntry(
    key: 'adminProductTitleAm',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Title (Amharic)',
      'am': 'ርዕስ (አማርኛ)',
      'ar': 'العنوان (الأمهرية)',
      'om': 'Mata-duree (Amaariffa)',
    },
  ),
  AppTextEntry(
    key: 'adminProductTitleAr',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Title (Arabic)',
      'am': 'ርዕስ (አረብኛ)',
      'ar': 'العنوان (العربية)',
      'om': 'Mata-duree (Arabiffa)',
    },
  ),
  AppTextEntry(
    key: 'adminProducts',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Products',
      'am': 'ምርቶች',
      'ar': 'المنتجات',
      'om': 'Oomishaalee',
    },
  ),
  AppTextEntry(
    key: 'adminPublish',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Publish',
      'am': 'አሳትር',
      'ar': 'نشر',
      'om': 'Maxxansi',
    },
  ),
  AppTextEntry(
    key: 'adminQuickActions',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'Quick actions',
      'am': 'ፈጣን ተግባራት',
      'ar': 'إجراءات سريعة',
      'om': 'Gochaawwan saffisaa',
    },
  ),
  AppTextEntry(
    key: 'adminReauthPrompt',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Enter your current password to confirm this change.',
      'am': 'ይህን ለውጥ ለማረጋገጥ የአሁኑን የይለፍ ቃል ያስገቡ።',
      'ar': 'أدخل كلمة المرور الحالية لتأكيد هذا التغيير.',
      'om': 'Jijjiirama kana mirkaneessuuf jecha darbii ammaa kee galchi.',
    },
  ),
  AppTextEntry(
    key: 'adminRemoveMedia',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Remove media',
      'am': 'ሚዲያውን አስወግድ',
      'ar': 'إزالة الوسائط',
      'om': 'Miidiyaa haqi',
    },
  ),
  AppTextEntry(
    key: 'adminResetSent',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Check your inbox for a reset link.',
      'am': 'የመቀየሪያ አገናኝ ኢሜይልዎን ይመልከቱ።',
      'ar': 'تحقق من بريدك الإلكتروني للحصول على رابط إعادة التعيين.',
      'om': 'Geessituu haaraa argachuuf imeelii kee ilaali.',
    },
  ),
  AppTextEntry(
    key: 'adminSaveAndPublish',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Save and publish',
      'am': 'አስቀምጥ እና አሳትር',
      'ar': 'حفظ ونشر',
      'om': 'Olkaa\'ii maxxansi',
    },
  ),
  AppTextEntry(
    key: 'adminSaveDraft',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Save draft',
      'am': 'ድራፍት አስቀምጥ',
      'ar': 'حفظ كمسودة',
      'om': 'Wixinee olkaa\'i',
    },
  ),
  AppTextEntry(
    key: 'adminSearchProducts',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Search products',
      'am': 'ምርቶችን ይፈልጉ',
      'ar': 'بحث في المنتجات',
      'om': 'Oomishaalee barbaadi',
    },
  ),
  AppTextEntry(
    key: 'adminSectionSoon',
    sectionKey: 'adminCategories',
    defaults: <String, String>{
      'en': 'Coming in the next screen',
      'am': 'በቀጣዩ ገጽ ይመጣል',
      'ar': 'قادم في الشاشة التالية',
      'om': 'Fuula itti aanu irratti dhufa',
    },
  ),
  AppTextEntry(
    key: 'adminSetCover',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Set as cover',
      'am': 'እንደ መሸፈኛ አድርግ',
      'ar': 'تعيين كغلاف',
      'om': 'Uwwisa godhi',
    },
  ),
  AppTextEntry(
    key: 'adminShow',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Show',
      'am': 'አሳይ',
      'ar': 'إظهار',
      'om': 'Agarsiisi',
    },
  ),
  AppTextEntry(
    key: 'adminSignIn',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Sign in',
      'am': 'ግባ',
      'ar': 'تسجيل الدخول',
      'om': 'Seeni',
    },
  ),
  AppTextEntry(
    key: 'adminSignOut',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Sign out',
      'am': 'ውጣ',
      'ar': 'تسجيل الخروج',
      'om': 'Ba\'i',
    },
  ),
  AppTextEntry(
    key: 'adminSignOutOthers',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Sign out other sessions',
      'am': 'ሌሎች ክፍለ ጊዜዎችን ይውጣ',
      'ar': 'تسجيل الخروج من الجلسات الأخرى',
      'om': 'Seensaalee biroo baasi',
    },
  ),
  AppTextEntry(
    key: 'adminSiteSettings',
    sectionKey: 'adminSiteSettings',
    defaults: <String, String>{
      'en': 'Site settings',
      'am': 'የጣቢያ ቅንብሮች',
      'ar': 'إعدادات الموقع',
      'om': 'Qindaa\'ina marsariitii',
    },
  ),
  AppTextEntry(
    key: 'adminSiteSettingsSaved',
    sectionKey: 'adminSiteSettings',
    defaults: <String, String>{
      'en': 'Settings saved',
      'am': 'ቅንብሮች ተቀምጠዋል',
      'ar': 'تم حفظ الإعدادات',
      'om': 'Qindaa\'inni olkaa\'ame',
    },
  ),
  AppTextEntry(
    key: 'adminSlug',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'URL slug',
      'am': 'የአድራሻ ቅርንጫፍ',
      'ar': 'معرّف الرابط',
      'om': 'Geessituu URL',
    },
  ),
  AppTextEntry(
    key: 'adminSlugAuto',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Generated from the English name if left empty.',
      'am': 'ከተተወ ከእንግሊዝኛው ስም ይዘጋጃል.',
      'ar': 'يُولَّد من الاسم الإنجليزي إذا تُرك فارغًا.',
      'om': 'Yoo duwwaa ta\'e maqaa Ingiliffaa irraa uumama.',
    },
  ),
  AppTextEntry(
    key: 'adminSortOrderHint',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'Shown in the order below.',
      'am': 'ከዚህ በታች በወቅቱ ይታያል.',
      'ar': 'يظهر بالترتيب أدناه.',
      'om': 'Tartiiba gadii keessatti agarsiifama.',
    },
  ),
  AppTextEntry(
    key: 'adminStatsCategories',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'Categories',
      'am': 'ምድቦች',
      'ar': 'الأقسام',
      'om': 'Ramaddiiwwan',
    },
  ),
  AppTextEntry(
    key: 'adminStatsProducts',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'Products',
      'am': 'ምርቶች',
      'ar': 'المنتجات',
      'om': 'Oomishaalee',
    },
  ),
  AppTextEntry(
    key: 'adminStoreName',
    sectionKey: 'adminSiteSettings',
    defaults: <String, String>{
      'en': 'Store name',
      'am': 'የሚስጥር ስም',
      'ar': 'اسم المتجر',
      'om': 'Maqaa suuqii',
    },
  ),
  AppTextEntry(
    key: 'adminStoreNameAm',
    sectionKey: 'adminSiteSettings',
    defaults: <String, String>{
      'en': 'Store name (Amharic)',
      'am': 'የሚስጥር ስም (አማርኛ)',
      'ar': 'اسم المتجر (أمهرية)',
      'om': 'Maqaa suuqii (Amaariffa)',
    },
  ),
  AppTextEntry(
    key: 'adminStoreNameAr',
    sectionKey: 'adminSiteSettings',
    defaults: <String, String>{
      'en': 'Store name (Arabic)',
      'am': 'የሚስጥር ስም (عربي)',
      'ar': 'اسم المتجر (عربي)',
      'om': 'Maqaa suuqii (Arabiffa)',
    },
  ),
  AppTextEntry(
    key: 'adminStoreNameOm',
    sectionKey: 'adminSiteSettings',
    defaults: <String, String>{
      'en': 'Store name (Oromo)',
      'am': 'የመሸጫ ስም (ኦሮምኛ)',
      'ar': 'اسم المتجر (الأورومو)',
      'om': 'Maqaa suuqii (Afaan Oromoo)',
    },
  ),
  AppTextEntry(
    key: 'adminStrength',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Strength',
      'am': 'አጥንት',
      'ar': 'القوة',
      'om': 'Cimina',
    },
  ),
  AppTextEntry(
    key: 'adminStrengthFair',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Fair',
      'am': 'መካከለኛ',
      'ar': 'متوسطة',
      'om': 'Giddu-galeessa',
    },
  ),
  AppTextEntry(
    key: 'adminStrengthStrong',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Strong',
      'am': 'አቅም',
      'ar': 'قوية',
      'om': 'Cimaa',
    },
  ),
  AppTextEntry(
    key: 'adminStrengthWeak',
    sectionKey: 'adminAccount',
    defaults: <String, String>{
      'en': 'Weak',
      'am': 'አትካለ',
      'ar': 'ضعيفة',
      'om': 'Laafaa',
    },
  ),
  AppTextEntry(
    key: 'adminTagline',
    sectionKey: 'adminSiteSettings',
    defaults: <String, String>{
      'en': 'Tagline',
      'am': 'አፈጻጸም',
      'ar': 'الشعار',
      'om': 'Jecha beeksisaa',
    },
  ),
  AppTextEntry(
    key: 'adminTextEditor',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'Text & language',
      'am': 'ጽሑፍና ቋንቋ',
      'ar': 'النصوص واللغة',
      'om': 'Barruu fi afaan',
    },
  ),
  AppTextEntry(
    key: 'adminTextEditorAllScreens',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'All screens',
      'am': 'ሁሉም ገጾች',
      'ar': 'كل الشاشات',
      'om': 'Fuula hunda',
    },
  ),
  AppTextEntry(
    key: 'adminTextEditorHasVariables',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'Has variables',
      'am': 'ተለዋዋጮች አሉት',
      'ar': 'يحتوي على متغيرات',
      'om': 'Jijjiiramaa qaba',
    },
  ),
  AppTextEntry(
    key: 'adminTextEditorHint',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'Every word of the app, in every language. Edit one and it changes everywhere.',
      'am': 'የመተግበሪያው ሁሉም ቃላት፣ በሁሉም ቋንቋ። አንዱን ሲቀይሩ በሁሉም ቦታ ይቀየራል።',
      'ar': 'كل كلمات التطبيق، بجميع اللغات. عدّل كلمة فتتغير في كل مكان.',
      'om': 'Jecha hunda appii kanaa, afaan hunda keessatti. Tokko yoo jijjiirte bakka hundatti jijjiirama.',
    },
  ),
  AppTextEntry(
    key: 'adminTextEditorNoResults',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'No text matches your search',
      'am': 'ከፍለጋዎ ጋር የሚመሳሰል ጽሑፍ የለም',
      'ar': 'لا يوجد نص يطابق بحثك',
      'om': 'Barruun barbaadii kee wajjin walsimu hin jiru',
    },
  ),
  AppTextEntry(
    key: 'adminTextEditorPlaceholderHint',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'Keep the variables in brackets exactly as written.',
      'am': 'በቅንፍ ውስጥ ያሉትን ተለዋዋጮች እንዳሉ ይተዉ።',
      'ar': 'اترك المتغيرات بين الأقواس كما هي بالضبط.',
      'om': 'Jijjiiramoota ulee keessa jiran akkuma jiranitti dhiisi.',
    },
  ),
  AppTextEntry(
    key: 'adminTextEditorReset',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'Restore default',
      'am': 'ነባሪውን መልስ',
      'ar': 'استعادة الافتراضي',
      'om': 'Durtii deebisi',
    },
  ),
  AppTextEntry(
    key: 'adminTextEditorResetDone',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'Default wording restored',
      'am': 'ነባሪው ጽሑፍ ተመልሷል',
      'ar': 'تمت استعادة النص الافتراضي',
      'om': 'Barruun durtii deebi\'e',
    },
  ),
  AppTextEntry(
    key: 'adminTextEditorSaved',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'Text saved',
      'am': 'ጽሑፉ ተቀምጧል',
      'ar': 'تم حفظ النص',
      'om': 'Barruun olkaa\'ame',
    },
  ),
  AppTextEntry(
    key: 'adminTextEditorSearch',
    sectionKey: 'adminTextEditor',
    defaults: <String, String>{
      'en': 'Search a word',
      'am': 'ቃል ፈልግ',
      'ar': 'ابحث عن كلمة',
      'om': 'Jecha barbaadi',
    },
  ),
  AppTextEntry(
    key: 'adminUnpublish',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Unpublish',
      'am': 'አቁም',
      'ar': 'إلغاء النشر',
      'om': 'Maxxansuu dhaabi',
    },
  ),
  AppTextEntry(
    key: 'adminUnpublished',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Unpublished',
      'am': 'ያልታወቀ',
      'ar': 'غير منشور',
      'om': 'Hin maxxanfamne',
    },
  ),
  AppTextEntry(
    key: 'adminUnsavedMessage',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'You have unsaved changes. Leaving now will lose them.',
      'am': 'ያልተቀመጡ ለውጦች አሉዎ። ከአሁን ቢተዉ ይጠፋሉ።',
      'ar': 'لديك تغييرات غير محفوظة. ستفقدها إذا غادرت الآن.',
      'om': 'Jijjiirama hin olkaa\'amne qabda. Amma yoo ba\'u isaan badu.',
    },
  ),
  AppTextEntry(
    key: 'adminUnsavedTitle',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Discard changes?',
      'am': 'ለውጦችን ይተውል?',
      'ar': 'هل تريد تجاهل التغييرات؟',
      'om': 'Jijjiirama haqnaa?',
    },
  ),
  AppTextEntry(
    key: 'adminUploadLogo',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Upload logo',
      'am': 'ሎጎ ይጫኑ',
      'ar': 'رفع الشعار',
      'om': 'Mallattoo fe\'i',
    },
  ),
  AppTextEntry(
    key: 'adminUploadQueue',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Upload queue',
      'am': 'የመጫን ቅርብ ጽሑፍ',
      'ar': 'قائمة الرفع',
      'om': 'Tarree fe\'umsaa',
    },
  ),
  AppTextEntry(
    key: 'adminUploadRetrying',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Retrying…',
      'am': 'እንደገና ብትሞክሩ…',
      'ar': 'جارٍ إعادة المحاولة…',
      'om': 'Irra deebi\'aa jira…',
    },
  ),
  AppTextEntry(
    key: 'adminUploadingCount',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': '{done} of {total} uploaded',
      'am': '{total} ከ {done} ተጫኗል',
      'ar': '{done} من {total} تم رفعها',
      'om': '{done} / {total} fe\'ame',
    },
    placeholders: <String>['done', 'total'],
  ),
  AppTextEntry(
    key: 'adminViewAll',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'View all',
      'am': 'ሁሉንም ይመልከቱ',
      'ar': 'عرض الكل',
      'om': 'Hunda ilaali',
    },
  ),
  AppTextEntry(
    key: 'adminViewStore',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'View store',
      'am': 'ሚስጥሩን ይመልከቱ',
      'ar': 'عرض المتجر',
      'om': 'Suuqii ilaali',
    },
  ),
  AppTextEntry(
    key: 'adminVisibleInStore',
    sectionKey: 'adminProducts',
    defaults: <String, String>{
      'en': 'Visible in store',
      'am': 'በሚስጥሩ ይታይ',
      'ar': 'ظاهر في المتجر',
      'om': 'Suuqii keessatti mul\'ata',
    },
  ),
  AppTextEntry(
    key: 'adminWhen',
    sectionKey: 'adminDashboard',
    defaults: <String, String>{
      'en': 'When',
      'am': 'መቼ',
      'ar': 'متى',
      'om': 'Yeroo',
    },
  ),
  AppTextEntry(
    key: 'appTitle',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Amu Sharif Arabiyan Majlis',
      'am': 'አሙ ሸሪፍ አረቢያን መጅሊስ',
      'ar': 'المجلس العربي عمو شريف',
      'om': 'Aamu Sharif Arabiyaan Majlis',
    },
  ),
  AppTextEntry(
    key: 'brandMonogram',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'ASM',
      'am': 'ASM',
      'ar': 'ASM',
      'om': 'ASM',
    },
  ),
  AppTextEntry(
    key: 'brandNameAm',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'አሙ ሸሪፍ አረቢያን መጅሊስ',
      'am': 'አሙ ሸሪፍ አረቢያን መጅሊስ',
      'ar': 'አሙ ሸሪፍ አረቢያን መጅሊስ',
      'om': 'አሙ ሸሪፍ አረቢያን መጅሊስ',
    },
  ),
  AppTextEntry(
    key: 'brandNameAr',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'المجلس العربي عمو شريف',
      'am': 'المجلس العربي عمو شريف',
      'ar': 'المجلس العربي عمو شريف',
      'om': 'المجلس العربي عمو شريف',
    },
  ),
  AppTextEntry(
    key: 'brandNameEn',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Amu Sharif Arabiyan Majlis',
      'am': 'Amu Sharif Arabiyan Majlis',
      'ar': 'Amu Sharif Arabiyan Majlis',
      'om': 'Amu Sharif Arabiyan Majlis',
    },
  ),
  AppTextEntry(
    key: 'contactEmail',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Email',
      'am': 'ኢሜይል',
      'ar': 'البريد الإلكتروني',
      'om': 'Imeelii',
    },
  ),
  AppTextEntry(
    key: 'contactFacebook',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Facebook',
      'am': 'ፌስቡክ',
      'ar': 'فيسبوك',
      'om': 'Facebook',
    },
  ),
  AppTextEntry(
    key: 'contactInstagram',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Instagram',
      'am': 'ኢንስታግራም',
      'ar': 'إنستغرام',
      'om': 'Instagram',
    },
  ),
  AppTextEntry(
    key: 'contactLaunchFailed',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Could not open that link on this device.',
      'am': 'ይህን አገናኝ በዚህ መሳሪያ ላይ መክፈት አልተቻለም።',
      'ar': 'تعذّر فتح هذا الرابط على هذا الجهاز.',
      'om': 'Geessituun sun meeshaa kana irratti hin banamne.',
    },
  ),
  AppTextEntry(
    key: 'contactLocation',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Location',
      'am': 'አድራሻ',
      'ar': 'الموقع',
      'om': 'Bakka',
    },
  ),
  AppTextEntry(
    key: 'contactOther',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Other',
      'am': 'ሌላ',
      'ar': 'أخرى',
      'om': 'Kan biraa',
    },
  ),
  AppTextEntry(
    key: 'contactPhone',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Phone',
      'am': 'ስልክ',
      'ar': 'هاتف',
      'om': 'Bilbila',
    },
  ),
  AppTextEntry(
    key: 'contactTelegram',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Telegram',
      'am': 'ቴሌግራም',
      'ar': 'تيليجرام',
      'om': 'Telegram',
    },
  ),
  AppTextEntry(
    key: 'contactTikTok',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'TikTok',
      'am': 'ቲክቶክ',
      'ar': 'تيك توك',
      'om': 'TikTok',
    },
  ),
  AppTextEntry(
    key: 'contactWebsite',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Website',
      'am': 'ድህረ ገጽ',
      'ar': 'الموقع الإلكتروني',
      'om': 'Marsariitii',
    },
  ),
  AppTextEntry(
    key: 'contactWhatsApp',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'WhatsApp',
      'am': 'ዋትስአፕ',
      'ar': 'واتساب',
      'om': 'WhatsApp',
    },
  ),
  AppTextEntry(
    key: 'contactYouTube',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'YouTube',
      'am': 'ዩቲዩብ',
      'ar': 'يوتيوب',
      'om': 'YouTube',
    },
  ),
  AppTextEntry(
    key: 'errorAuth',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'We could not sign you in.',
      'am': 'መግቢያ አልተሳካም።',
      'ar': 'تعذّر تسجيل دخولك.',
      'om': 'Si seenessuu hin dandeenye.',
    },
  ),
  AppTextEntry(
    key: 'errorCheckViolation',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'A value is outside the allowed range.',
      'am': 'አንድ እሴት ከተፈቀደው ክልል ውጭ ነው።',
      'ar': 'إحدى القيم خارج النطاق المسموح.',
      'om': 'Gatiin sun daangaa hayyamamee ala jira.',
    },
  ),
  AppTextEntry(
    key: 'errorConstraintViolation',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Some values are not allowed.',
      'am': 'አንዳንድ እሴቶች አይፈቀዱም።',
      'ar': 'بعض القيم غير مسموح بها.',
      'om': 'Gatiiwwan tokko tokko hin hayyamamu.',
    },
  ),
  AppTextEntry(
    key: 'errorDuplicate',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'That value is already in use.',
      'am': 'ያ እሴት አስቀድሞ ጥቅም ላይ ውሏል።',
      'ar': 'هذه القيمة مستخدمة بالفعل.',
      'om': 'Gatiin sun duraan tajaajila keessa jira.',
    },
  ),
  AppTextEntry(
    key: 'errorEmailNotConfirmed',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Confirm your email address before signing in.',
      'am': 'ከመግባትዎ በፊት ኢሜይልዎን ያረጋግጡ።',
      'ar': 'أكّد بريدك الإلكتروني قبل تسجيل الدخول.',
      'om': 'Seenuu dura teessoo imeelii kee mirkaneessi.',
    },
  ),
  AppTextEntry(
    key: 'errorForeignKey',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Related data is missing.',
      'am': 'ተዛማጅ መረጃ ጎድሏል።',
      'ar': 'البيانات المرتبطة مفقودة.',
      'om': 'Ragaan walitti hidhame hin jiru.',
    },
  ),
  AppTextEntry(
    key: 'errorGateLocked',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Incorrect username or password.',
      'am': 'የመግቢያ ስም ወይም የይለፍ ቃል ትክክል አይደለም።',
      'ar': 'اسم المستخدم أو كلمة المرور غير صحيحة.',
      'om':
          'Lakkoofsi iccitii jalqabaa dogoggora. Maaloo irra deebi\'ii yaali.',
    },
  ),
  AppTextEntry(
    key: 'errorInvalidCredentials',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Incorrect email or password.',
      'am': 'የተሳሳተ ኢሜይል ወይም የይለፍ ቃል።',
      'ar': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      'om': 'Imeelii yookaan jecha darbii sirrii miti.',
    },
  ),
  AppTextEntry(
    key: 'errorInvalidFormat',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'That value is not in the expected format.',
      'am': 'ያ እሴት በሚጠበቀው ቅርጸት አይደለም።',
      'ar': 'هذه القيمة ليست بالتنسيق المتوقع.',
      'om': 'Gatiin sun bifa barbaadameen hin jiru.',
    },
  ),
  AppTextEntry(
    key: 'errorMedia',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'That file could not be processed.',
      'am': 'ያ ፋይል ሊሰራ አልቻለም።',
      'ar': 'تعذّرت معالجة ذلك الملف.',
      'om': 'Faayilii sun hin hojjetamne.',
    },
  ),
  AppTextEntry(
    key: 'errorMediaImageTooLarge',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Images must be 5 MB or smaller after compression.',
      'am': 'ምስሎች ከመጨመሩ በኋላ 5 MB ወይም ከዚያ በታች መሆን አለባቸው።',
      'ar': 'يجب ألا تتجاوز الصور 5 ميغابايت بعد الضغط.',
      'om': 'Suuraan erga cuunfame booda 5 MB gadi ta\'uu qaba.',
    },
  ),
  AppTextEntry(
    key: 'errorMediaUnsupportedImage',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Use a JPG, PNG or WebP image.',
      'am': 'JPG, PNG ወይም WebP ምስል ይጠቀሙ።',
      'ar': 'استخدم صورة JPG أو PNG أو WebP.',
      'om': 'Suuraa JPG, PNG yookaan WebP fayyadami.',
    },
  ),
  AppTextEntry(
    key: 'errorMediaUnsupportedVideo',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Use an MP4 video.',
      'am': 'MP4 ቪዲዮ ይጠቀሙ።',
      'ar': 'استخدم فيديو MP4.',
      'om': 'Viidiyoo MP4 fayyadami.',
    },
  ),
  AppTextEntry(
    key: 'errorMediaVideoTooLarge',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Videos must be 40 MB or smaller.',
      'am': 'ቪዲዮዎች 40 MB ወይም ከዚያ በታች መሆን አለባቸው።',
      'ar': 'يجب ألا تتجاوز مقاطع الفيديو 40 ميغابايت.',
      'om': 'Viidiyoon 40 MB gadi ta\'uu qaba.',
    },
  ),
  AppTextEntry(
    key: 'errorNetwork',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'We could not reach the store. Check your connection.',
      'am': 'ሱቁን ማግኘት አልቻልንም። ግንኙነትዎን ያረጋግጡ።',
      'ar': 'لم نتمكن من الوصول إلى المتجر. تحقق من اتصالك.',
      'om': 'Suuqii bira ga\'uu hin dandeenye. Interneetii kee ilaali.',
    },
  ),
  AppTextEntry(
    key: 'errorNotFound',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'We could not find what you were looking for.',
      'am': 'የፈለጉትን ማግኘት አልቻልንም።',
      'ar': 'لم نتمكن من العثور على ما تبحث عنه.',
      'om': 'Wanta barbaadde argachuu hin dandeenye.',
    },
  ),
  AppTextEntry(
    key: 'errorPermission',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'You do not have permission to do that.',
      'am': 'ይህን ለማድረግ ፈቃድ የለዎትም።',
      'ar': 'ليس لديك إذن للقيام بذلك.',
      'om': 'Kana gochuuf hayyama hin qabdu.',
    },
  ),
  AppTextEntry(
    key: 'errorServer',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'The service is temporarily unavailable. Please try again.',
      'am': 'አገልግሎቱ ለጊዜው አይገኝም። እንደገና ይሞክሩ።',
      'ar': 'الخدمة غير متاحة مؤقتًا. حاول مرة أخرى.',
      'om': 'Tajaajilli yeroof hin jiru. Maaloo irra deebi\'ii yaali.',
    },
  ),
  AppTextEntry(
    key: 'errorSessionExpired',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Your session expired. Please sign in again.',
      'am': 'ክፍለ ጊዜዎ አልቋል። እንደገና ይግቡ።',
      'ar': 'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.',
      'om': 'Yeroon seensa kee dhumate. Maaloo irra deebi\'ii seeni.',
    },
  ),
  AppTextEntry(
    key: 'errorStorage',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'The file could not be uploaded.',
      'am': 'ፋይሉ ሊጫን አልቻለም።',
      'ar': 'تعذّر رفع الملف.',
      'om': 'Faayiliin sun fe\'amuu hin dandeenye.',
    },
  ),
  AppTextEntry(
    key: 'errorTimeout',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'The request took too long. Please try again.',
      'am': 'ጥያቄው በጣም ረጅም ወሰደ። እንደገና ይሞክሩ።',
      'ar': 'استغرق الطلب وقتًا طويلًا. حاول مرة أخرى.',
      'om': 'Gaaffiin yeroo dheeraa fudhate. Maaloo irra deebi\'ii yaali.',
    },
  ),
  AppTextEntry(
    key: 'errorTooManyAttempts',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Too many attempts. Please wait a moment and try again.',
      'am': 'ብዙ ሙከራዎች። ትንሽ ቆይተው እንደገና ይሞክሩ።',
      'ar': 'محاولات كثيرة جدًا. انتظر قليلًا ثم حاول مرة أخرى.',
      'om': 'Yaaliin baay\'ee ta\'e. Maaloo xiqqoo eegiitii irra deebi\'i.',
    },
  ),
  AppTextEntry(
    key: 'errorUnknown',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Something unexpected happened. Please try again.',
      'am': 'ያልተጠበቀ ነገር ተፈጥሯል። እንደገና ይሞክሩ።',
      'ar': 'حدث أمر غير متوقع. حاول مرة أخرى.',
      'om': 'Wanti hin eegamne ta\'e. Maaloo irra deebi\'ii yaali.',
    },
  ),
  AppTextEntry(
    key: 'errorValidation',
    sectionKey: 'groupErrors',
    defaults: <String, String>{
      'en': 'Please correct the highlighted fields.',
      'am': 'እባክዎ የተመለከቱትን መስኮች ያስተካክሉ።',
      'ar': 'يرجى تصحيح الحقول المحددة.',
      'om': 'Maaloo dirreewwan mallattoo qaban sirreessi.',
    },
  ),
  AppTextEntry(
    key: 'favouritesEmptyMessage',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Tap the heart on a piece to keep it here.',
      'am': 'የሚወዱትን እዚህ ለማስቀመጥ በልብ ምልክቱ ላይ ነካ።',
      'ar': 'انقر على القلب لحفظ القطعة هنا.',
      'om': 'Meeshaa asitti kuusuuf onnee tuqi.',
    },
  ),
  AppTextEntry(
    key: 'favouritesEmptyTitle',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'No favourites yet',
      'am': 'እስካሁን ተወዳጅ የለም',
      'ar': 'لا مفضلات بعد',
      'om': 'Amma filannoon hin jiru',
    },
  ),
  AppTextEntry(
    key: 'gateChangeIntro',
    sectionKey: 'gateTitle',
    defaults: <String, String>{
      'en': 'This password opens the owner panel on this device. Change it whenever you like.',
      'am': 'ይህ ይለፍ ቃል በዚህ መሣሪያ ላይ የባለቤት ክፍልን ይከፍታል። በፈለጉት ጊዜ ይቀይሩት።',
      'ar': 'تفتح كلمة المرور هذه لوحة المالك على هذا الجهاز. غيّرها متى شئت.',
      'om': 'Jechi darbii kun meeshaa kana irratti paneela abbaa qabeenyaa bana. Yeroo barbaaddetti jijjiiri.',
    },
  ),
  AppTextEntry(
    key: 'gateChangeTitle',
    sectionKey: 'gateTitle',
    defaults: <String, String>{
      'en': 'Gateway password',
      'am': 'የመግቢያ ይለፍ ቃል',
      'ar': 'كلمة مرور الدخول',
      'om': 'Jecha darbii seensaa',
    },
  ),
  AppTextEntry(
    key: 'gateChanged',
    sectionKey: 'gateTitle',
    defaults: <String, String>{
      'en': 'Gateway password updated.',
      'am': 'የመግቢያ ይለፍ ቃል ተቀይሯል።',
      'ar': 'تم تحديث كلمة مرور الدخول.',
      'om': 'Jechi darbii seensaa haaromfame.',
    },
  ),
  AppTextEntry(
    key: 'gateHint',
    sectionKey: 'gateTitle',
    defaults: <String, String>{
      'en': 'Tip: tap the logo five times to reopen this panel.',
      'am': 'ማጠቃለያ፦ ይህን ክፍል ለመክፈት አርማውን አምስት ጊዜ ነካ።',
      'ar': 'تلميح: انقر الشعار خمس مرات لإعادة فتح هذه اللوحة.',
      'om': 'Gorsa: paneela kana deebi\'ee banuuf mallattoo yeroo shan tuqi.',
    },
  ),
  AppTextEntry(
    key: 'gateLocked',
    sectionKey: 'gateTitle',
    defaults: <String, String>{
      'en': 'Incorrect username or password.',
      'am': 'የመግቢያ ስም ወይም የይለፍ ቃል ትክክል አይደለም።',
      'ar': 'اسم المستخدم أو كلمة المرور غير صحيحة.',
      'om': 'Maqaa fayyadamaa yookaan jecha darbii sirrii miti.',
    },
  ),
  AppTextEntry(
    key: 'gateTitle',
    sectionKey: 'gateTitle',
    defaults: <String, String>{
      'en': 'Owner access',
      'am': 'የባለቤት መግቢያ',
      'ar': 'دخول المالك',
      'om': 'Seensa abbaa qabeenyaa',
    },
  ),
  AppTextEntry(
    key: 'gateUnlock',
    sectionKey: 'gateTitle',
    defaults: <String, String>{
      'en': 'Unlock',
      'am': 'ክፈት',
      'ar': 'فتح',
      'om': 'Bani',
    },
  ),
  AppTextEntry(
    key: 'gateUnlocked',
    sectionKey: 'gateTitle',
    defaults: <String, String>{
      'en': 'Owner access unlocked.',
      'am': 'የባለቤት መግቢያ ተከፍቷል።',
      'ar': 'تم فتح دخول المالك.',
      'om': 'Seensi abbaa qabeenyaa baname.',
    },
  ),
  AppTextEntry(
    key: 'gateUsername',
    sectionKey: 'gateTitle',
    defaults: <String, String>{
      'en': 'Username',
      'am': 'የመግቢያ ስም',
      'ar': 'اسم المستخدم',
      'om': 'Maqaa fayyadamaa',
    },
  ),
  AppTextEntry(
    key: 'groupCommon',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Shared words',
      'am': 'የጋራ ቃላት',
      'ar': 'كلمات مشتركة',
      'om': 'Jecha waliigalaa',
    },
  ),
  AppTextEntry(
    key: 'groupErrors',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Errors & states',
      'am': 'ስህተቶችና ሁኔታዎች',
      'ar': 'الأخطاء والحالات',
      'om': 'Dogoggora fi haala',
    },
  ),
  AppTextEntry(
    key: 'groupStorefront',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Storefront screens',
      'am': 'የመሸጫ ገጾች',
      'ar': 'شاشات المتجر',
      'om': 'Fuulawwan suuqii',
    },
  ),
  AppTextEntry(
    key: 'groupValidation',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Validation messages',
      'am': 'የማረጋገጫ መልዕክቶች',
      'ar': 'رسائل التحقق',
      'om': 'Ergaawwan mirkaneessaa',
    },
  ),
  AppTextEntry(
    key: 'inquiryMessageTemplate',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Hello! I am interested in “{product}” ({price}).',
      'am': 'ሰላም! በ“{product}” ({price}) ፍላጎት አለኝ።',
      'ar': 'مرحبًا! أنا مهتم بـ «{product}» ({price}).',
      'om': 'Akkam! “{product}” ({price}) xiyyeeffannaa qaba.',
    },
    placeholders: <String>['price', 'product'],
  ),
  AppTextEntry(
    key: 'labelAvailable',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Available',
      'am': 'ይገኛል',
      'ar': 'متوفر',
      'om': 'Jira',
    },
  ),
  AppTextEntry(
    key: 'labelDiscount',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Save {percent}%',
      'am': '{percent}% ይቆጥቡ',
      'ar': 'وفّر {percent}%',
      'om': '{percent}% qusadhu',
    },
    placeholders: <String>['percent'],
  ),
  AppTextEntry(
    key: 'labelDuration',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': '{minutes}m {seconds}s',
      'am': '{minutes}ደ {seconds}ሰ',
      'ar': '{minutes}د {seconds}ث',
      'om': '{minutes}m {seconds}s',
    },
    placeholders: <String>['minutes', 'seconds'],
  ),
  AppTextEntry(
    key: 'labelFrom',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'From {price}',
      'am': 'ከ{price} ጀምሮ',
      'ar': 'تبدأ من {price}',
      'om': '{price} irraa',
    },
    placeholders: <String>['price'],
  ),
  AppTextEntry(
    key: 'labelPrice',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Price',
      'am': 'ዋጋ',
      'ar': 'السعر',
      'om': 'Gatii',
    },
  ),
  AppTextEntry(
    key: 'labelUnavailable',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Out of stock',
      'am': 'ከመጋዘን አልቋል',
      'ar': 'غير متوفر',
      'om': 'Kuusaa keessaa ba\'e',
    },
  ),
  AppTextEntry(
    key: 'navAbout',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'About',
      'am': 'ስለ እኛ',
      'ar': 'من نحن',
      'om': 'Waa\'ee',
    },
  ),
  AppTextEntry(
    key: 'navAdmin',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Admin',
      'am': 'አስተዳዳሪ',
      'ar': 'الإدارة',
      'om': 'Bulchaa',
    },
  ),
  AppTextEntry(
    key: 'navCategories',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Categories',
      'am': 'ምድቦች',
      'ar': 'الفئات',
      'om': 'Ramaddiiwwan',
    },
  ),
  AppTextEntry(
    key: 'navContact',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Contact',
      'am': 'አግኙን',
      'ar': 'اتصل بنا',
      'om': 'Quunnamtii',
    },
  ),
  AppTextEntry(
    key: 'navFavourites',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Favourites',
      'am': 'ተወዳጆች',
      'ar': 'المفضلة',
      'om': 'Filannoo',
    },
  ),
  AppTextEntry(
    key: 'navHome',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Home',
      'am': 'መነሻ',
      'ar': 'الرئيسية',
      'om': 'Mana',
    },
  ),
  AppTextEntry(
    key: 'navSettings',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Settings',
      'am': 'ቅንብሮች',
      'ar': 'الإعدادات',
      'om': 'Qindaa\'ina',
    },
  ),
  AppTextEntry(
    key: 'searchHint',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Search majlis, sofas, cushions…',
      'am': 'መጅሊስ፣ ሶፋ፣ ትራስ ይፈልጉ…',
      'ar': 'ابحث عن مجالس أو كنب أو وسائد…',
      'om': 'Majlisii, soofaa, boraatii barbaadi…',
    },
  ),
  AppTextEntry(
    key: 'searchNoResults',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'No products match “{query}”',
      'am': 'ከ“{query}” ጋር የሚዛመድ ምርት አልተገኘም',
      'ar': 'لا توجد منتجات تطابق «{query}»',
      'om': '“{query}” wajjin walsimu hin jiru',
    },
    placeholders: <String>['query'],
  ),
  AppTextEntry(
    key: 'searchResultsCount',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en':
          '{count, plural, =0{No results} =1{1 result} other{{count} results}}',
      'am': '{count, plural, =0{ውጤት የለም} =1{1 ውጤት} other{{count} ውጤቶች}}',
      'ar': '{count, plural, =0{لا توجد نتائج} =1{نتيجة واحدة} =2{نتيجتان} few{{count} نتائج} many{{count} نتيجة} other{{count} نتيجة}}',
      'om': '{count, plural, =0{Bu\'aan hin jiru} =1{Bu\'aa 1} other{Bu\'aawwan {count}}}',
    },
    placeholders: <String>['count'],
    isPlural: true,
  ),
  AppTextEntry(
    key: 'sectionAllProducts',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'All products',
      'am': 'ሁሉም ምርቶች',
      'ar': 'جميع المنتجات',
      'om': 'Oomishaalee hunda',
    },
  ),
  AppTextEntry(
    key: 'sectionBrowseCategories',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Browse by category',
      'am': 'በምድብ ያስሱ',
      'ar': 'تصفح حسب الفئة',
      'om': 'Ramaddiin barbaadi',
    },
  ),
  AppTextEntry(
    key: 'sectionFeatured',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'Featured',
      'am': 'የተመረጡ',
      'ar': 'مميزة',
      'om': 'Filatamaa',
    },
  ),
  AppTextEntry(
    key: 'sectionNewArrivals',
    sectionKey: 'groupStorefront',
    defaults: <String, String>{
      'en': 'New arrivals',
      'am': 'አዲስ የገቡ',
      'ar': 'وصل حديثًا',
      'om': 'Kan haaraa dhufe',
    },
  ),
  AppTextEntry(
    key: 'settingsAbout',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'About',
      'am': 'ስለ መተግበሪያው',
      'ar': 'حول التطبيق',
      'om': 'Waa\'ee',
    },
  ),
  AppTextEntry(
    key: 'settingsAdminEntry',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Admin',
      'am': 'አስተዳዳሪ',
      'ar': 'الإدارة',
      'om': 'Bulchaa',
    },
  ),
  AppTextEntry(
    key: 'settingsAdminHint',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Owner sign in',
      'am': 'የባለቤት መግቢያ',
      'ar': 'دخول المالك',
      'om': 'Seensa abbaa qabeenyaa',
    },
  ),
  AppTextEntry(
    key: 'settingsLanguage',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Language',
      'am': 'ቋንቋ',
      'ar': 'اللغة',
      'om': 'Afaan',
    },
  ),
  AppTextEntry(
    key: 'settingsTheme',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Appearance',
      'am': 'አቀራረብ',
      'ar': 'المظهر',
      'om': 'Mul\'ata',
    },
  ),
  AppTextEntry(
    key: 'settingsThemeDark',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Dark',
      'am': 'ጨለማ',
      'ar': 'داكن',
      'om': 'Dukkana',
    },
  ),
  AppTextEntry(
    key: 'settingsThemeLight',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Light',
      'am': 'ብሩህ',
      'ar': 'فاتح',
      'om': 'Ifaa',
    },
  ),
  AppTextEntry(
    key: 'settingsThemeSystem',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'System',
      'am': 'የስርዓቱ',
      'ar': 'النظام',
      'om': 'Sirna',
    },
  ),
  AppTextEntry(
    key: 'settingsTitle',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Settings',
      'am': 'ቅንብሮች',
      'ar': 'الإعدادات',
      'om': 'Qindaa\'ina',
    },
  ),
  AppTextEntry(
    key: 'settingsVersion',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Version',
      'am': 'ስሪት',
      'ar': 'الإصدار',
      'om': 'Maxxansa',
    },
  ),
  AppTextEntry(
    key: 'stateEmptyMessage',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'New pieces will appear here as soon as the owner publishes them.',
      'am': 'ባለቤቱ ሲያትም አዲስ ዕቃዎች እዚህ ይታያሉ።',
      'ar': 'ستظهر القطع الجديدة هنا بمجرد أن ينشرها المالك.',
      'om': 'Yeroo abbaan qabeenyaa maxxansu meeshaan haaraan asitti mul\'ata.',
    },
  ),
  AppTextEntry(
    key: 'stateEmptyTitle',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Nothing here yet',
      'am': 'እስካሁን ምንም የለም',
      'ar': 'لا يوجد شيء بعد',
      'om': 'Amma asitti homaa hin jiru',
    },
  ),
  AppTextEntry(
    key: 'stateErrorTitle',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Something went wrong',
      'am': 'የሆነ ችግር ተፈጥሯል',
      'ar': 'حدث خطأ ما',
      'om': 'Wanti tokko dogoggore',
    },
  ),
  AppTextEntry(
    key: 'stateLoading',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Loading…',
      'am': 'በመጫን ላይ…',
      'ar': 'جارٍ التحميل…',
      'om': 'Fe\'aa jira…',
    },
  ),
  AppTextEntry(
    key: 'stateNoResults',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'No results',
      'am': 'ምንም ውጤት የለም',
      'ar': 'لا نتائج',
      'om': 'Bu\'aan hin jiru',
    },
  ),
  AppTextEntry(
    key: 'stateNotFoundMessage',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'That link does not exist any more.',
      'am': 'ያ አገናኝ ከእንግዲህ የለም።',
      'ar': 'هذا الرابط لم يعد موجودًا.',
      'om': 'Geessituun sun amma hin jiru.',
    },
  ),
  AppTextEntry(
    key: 'stateNotFoundTitle',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Page not found',
      'am': 'ገጹ አልተገኘም',
      'ar': 'الصفحة غير موجودة',
      'om': 'Fuulli hin argamne',
    },
  ),
  AppTextEntry(
    key: 'stateOffline',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'You are offline. Check your connection and try again.',
      'am': 'ከመስመር ውጭ ነዎት። ግንኙነትዎን አረጋግጠው እንደገና ይሞክሩ።',
      'ar': 'أنت غير متصل بالإنترنت. تحقق من اتصالك وأعد المحاولة.',
      'om': 'Interneetii hin qabdu. Interneetii kee ilaaliitii irra deebi\'i.',
    },
  ),
  AppTextEntry(
    key: 'stateSaved',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Saved',
      'am': 'ተቀምጧል',
      'ar': 'تم الحفظ',
      'om': 'Olkaa\'ame',
    },
  ),
  AppTextEntry(
    key: 'stateSaving',
    sectionKey: 'groupCommon',
    defaults: <String, String>{
      'en': 'Saving…',
      'am': 'በመቀመጥ ላይ…',
      'ar': 'جارٍ الحفظ…',
      'om': 'Olkaa\'aa jira…',
    },
  ),
  AppTextEntry(
    key: 'tagline',
    sectionKey: 'settingsTitle',
    defaults: <String, String>{
      'en': 'Luxury Arabic majlis & sofas, handcrafted for your home',
      'am': 'የቅንጦት የአረብ መጅሊስ እና ሶፋዎች፣ ለቤትዎ በእጅ የተሰሩ',
      'ar': 'مجالس وكنب عربية فاخرة، مصنوعة يدويًا لمنزلك',
      'om': 'Majlisii fi soofaa Arabiyaan sadarkaa olaanaa, mana keetiif harkaan hojjetame',
    },
  ),
  AppTextEntry(
    key: 'validateCompareAtPrice',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Original price must be at least the selling price',
      'am': 'የመጀመሪያው ዋጋ ከሽያጭ ዋጋ መብለጥ አለበት',
      'ar': 'يجب أن يكون السعر الأصلي مساويًا لسعر البيع على الأقل',
      'om': 'Gatiin jalqabaa gatiin gurgurtaa gadi hin ta\'uu qabu',
    },
  ),
  AppTextEntry(
    key: 'validateEmail',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Enter a valid email address',
      'am': 'ትክክለኛ ኢሜይል ያስገቡ',
      'ar': 'أدخل بريدًا إلكترونيًا صالحًا',
      'om': 'Teessoo imeelii sirrii galchi',
    },
  ),
  AppTextEntry(
    key: 'validateNegative',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Value cannot be negative',
      'am': 'እሴቱ አሉታዊ መሆን አይችልም',
      'ar': 'لا يمكن أن تكون القيمة سالبة',
      'om': 'Gatiin negatiivi ta\'uu hin danda\'u',
    },
  ),
  AppTextEntry(
    key: 'validateNumber',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Enter a valid number',
      'am': 'ትክክለኛ ቁጥር ያስገቡ',
      'ar': 'أدخل رقمًا صالحًا',
      'om': 'Lakkoofsa sirrii galchi',
    },
  ),
  AppTextEntry(
    key: 'validatePasswordLength',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Use at least 10 characters',
      'am': 'ቢያንስ 10 ቁምፊዎችን ይጠቀሙ',
      'ar': 'استخدم 10 أحرف على الأقل',
      'om': 'Yoo xiqqaate arfii 10 fayyadami',
    },
  ),
  AppTextEntry(
    key: 'validatePasswordMismatch',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Passwords do not match',
      'am': 'የይለፍ ቃላቱ አይመሳሰሉም',
      'ar': 'كلمتا المرور غير متطابقتين',
      'om': 'Jechi darbii wal hin simu',
    },
  ),
  AppTextEntry(
    key: 'validatePasswordStrength',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Include an uppercase letter, a lowercase letter and a number',
      'am': 'አንድ አቢይ ፊደል፣ አንድ ትንሽ ፊደል እና አንድ ቁጥር ያካትቱ',
      'ar': 'أدخل حرفًا كبيرًا وحرفًا صغيرًا ورقمًا',
      'om': 'Qubeellaa guddaa, qubeellaa xiqqaa fi lakkoofsa dabalii',
    },
  ),
  AppTextEntry(
    key: 'validatePhone',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Enter a valid phone number',
      'am': 'ትክክለኛ ስልክ ቁጥር ያስገቡ',
      'ar': 'أدخل رقم هاتف صالحًا',
      'om': 'Lakkoofsa bilbilaa sirrii galchi',
    },
  ),
  AppTextEntry(
    key: 'validatePositive',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Value must be greater than zero',
      'am': 'እሴቱ ከዜሮ በላይ መሆን አለበት',
      'ar': 'يجب أن تكون القيمة أكبر من صفر',
      'om': 'Gatiin zeeroo caalaa ta\'uu qaba',
    },
  ),
  AppTextEntry(
    key: 'validateRequired',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'This field is required',
      'am': 'ይህ መስክ ያስፈልጋል',
      'ar': 'هذا الحقل مطلوب',
      'om': 'Dirreen kun barbaachisa',
    },
  ),
  AppTextEntry(
    key: 'validateSlug',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Use lowercase letters, numbers and hyphens only',
      'am': 'ትንንሽ ፊደላት፣ ቁጥሮች እና ሰረዞችን ብቻ ይጠቀሙ',
      'ar': 'استخدم الحروف الصغيرة والأرقام والشرطات فقط',
      'om': 'Qubeellaa xiqqaa, lakkoofsa fi \'-\' qofa fayyadami',
    },
  ),
  AppTextEntry(
    key: 'validateTelegramHandle',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Enter a Telegram handle like @username or a t.me link',
      'am': 'የቴሌግራም አያያዝ እንደ @username ወይም t.me አገናኝ ያስገቡ',
      'ar': 'أدخل معرّف تيليجرام مثل ‎@username‎ أو رابط t.me',
      'om': 'Akka @username yookaan geessituu t.me tiin Telegram galchi',
    },
  ),
  AppTextEntry(
    key: 'validateTooLong',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'This value is too long',
      'am': 'ይህ እሴት በጣም ረጅም ነው',
      'ar': 'هذه القيمة طويلة جدًا',
      'om': 'Gatiin sun baay\'ee dheeraa',
    },
  ),
  AppTextEntry(
    key: 'validateTooShort',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'This value is too short',
      'am': 'ይህ እሴት በጣም አጭር ነው',
      'ar': 'هذه القيمة قصيرة جدًا',
      'om': 'Gatiin sun baay\'ee gabaabaa',
    },
  ),
  AppTextEntry(
    key: 'validateUrl',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Enter a valid link starting with https://',
      'am': 'በ https:// የሚጀምር ትክክለኛ አገናኝ ያስገቡ',
      'ar': 'أدخل رابطًا صالحًا يبدأ بـ https://',
      'om': 'Geessituu https:// tiin jalqabu galchi',
    },
  ),
  AppTextEntry(
    key: 'validateVideoTooLong',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'Videos must be 60 seconds or shorter',
      'am': 'ቪዲዮዎች 60 ሰከንድ ወይም ከዚያ በታች መሆን አለባቸው',
      'ar': 'يجب ألا تتجاوز مدة الفيديو 60 ثانية',
      'om': 'Viidiyoon sekondii 60 gadi ta\'uu qaba',
    },
  ),
  AppTextEntry(
    key: 'validateVideoUnreadable',
    sectionKey: 'groupValidation',
    defaults: <String, String>{
      'en': 'That video could not be read',
      'am': 'ያ ቪዲዮ ሊነበብ አልቻለም',
      'ar': 'تعذّر قراءة ذلك الفيديو',
      'om': 'Viidiyoon sun dubbifamuu hin dandeenye',
    },
  ),
];

/// Lookup by key, for the in-place pencils and the editor.
final Map<String, AppTextEntry> kAppTextByKey = <String, AppTextEntry>{
  for (final AppTextEntry entry in kAppTextEntries) entry.key: entry,
};
