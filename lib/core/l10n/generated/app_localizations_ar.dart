// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String a11yOpenCategory(String name) {
    return 'افتح فئة $name';
  }

  @override
  String a11yProductImage(String title) {
    return 'صورة $title';
  }

  @override
  String a11yVideoThumbnail(String title) {
    return 'تشغيل فيديو $title';
  }

  @override
  String get aboutFallback =>
      'المجلس العربي عمو شريف يصنع مجالس وكنب وأثاثًا فاخرًا وفق التقاليد العربية.';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionCallNow => 'اتصل الآن';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionClear => 'مسح';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionContactOwner => 'تواصل مع المالك';

  @override
  String get actionContinue => 'متابعة';

  @override
  String get actionCopyLink => 'انسخ الرابط';

  @override
  String get actionCopySuccess => 'تم نسخ الرابط';

  @override
  String get actionCreate => 'إنشاء';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionDiscardAll => 'تجاهل';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionFavourite => 'أضف إلى المفضلة';

  @override
  String get actionLoadMore => 'عرض المزيد';

  @override
  String get actionMove => 'نقل';

  @override
  String get actionOrderNow => 'اطلب الآن';

  @override
  String get actionRetry => 'أعد المحاولة';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionSelectImage => 'اختر صورة';

  @override
  String get actionShare => 'مشاركة';

  @override
  String get actionUnfavourite => 'أزل من المفضلة';

  @override
  String get actionViewDetails => 'عرض التفاصيل';

  @override
  String get adminAbout => 'عن المتجر';

  @override
  String get adminAccount => 'حساب المالك';

  @override
  String get adminAddContact => 'إضافة رابط';

  @override
  String get adminAddImages => 'إضافة صور';

  @override
  String get adminAddProduct => 'إضافة منتج';

  @override
  String get adminAddVideo => 'إضافة فيديو';

  @override
  String get adminAnonymous => 'مجهول';

  @override
  String get adminBackToGateway => 'العودة إلى البوابة';

  @override
  String get adminCategories => 'الفئات';

  @override
  String get adminCategoryAddSubcategory => 'إضافة قسم فرعي';

  @override
  String get adminCategoryCreated => 'تم إنشاء القسم';

  @override
  String get adminCategoryDeleted => 'تم حذف القسم';

  @override
  String adminCategoryHasProducts(int count) {
    return 'لا يزال هذا القسم يحتوي على $count منتج. انقلها إلى قسم آخر أولاً، أو احذف المنتجات.';
  }

  @override
  String get adminCategoryHasSubcategories =>
      'لا يزال هذا القسم يحتوي على أقسام فرعية. احذفها أولاً.';

  @override
  String get adminCategoryHidden => 'تم إخفاء القسم';

  @override
  String get adminCategoryName => 'الاسم (إنجليزي)';

  @override
  String get adminCategoryNameAm => 'الاسم (أمهرية)';

  @override
  String get adminCategoryNameAr => 'الاسم (عربي)';

  @override
  String get adminCategoryNameOm => 'الاسم (أورومو)';

  @override
  String get adminCategoryUpdated => 'تم تحديث القسم';

  @override
  String get adminChangePassword => 'تغيير كلمة المرور';

  @override
  String get adminChannel => 'القناة';

  @override
  String get adminClearInquiries => 'مسح الكل';

  @override
  String get adminCompareAtPrice => 'السعر قبل الخصم (اختياري)';

  @override
  String get adminConfirmDeleteCategory => 'هل تريد حذف هذا القسم؟';

  @override
  String get adminConfirmDeleteContact => 'هل تريد إزالة هذا الرابط؟';

  @override
  String get adminConfirmDeleteMessage => 'لا يمكن التراجع عن هذا.';

  @override
  String get adminConfirmDeleteProduct => 'هل تريد حذف هذا المنتج؟';

  @override
  String get adminConfirmPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get adminContactDeleted => 'تمت إزالة الرابط';

  @override
  String get adminContactLabel => 'التسمية';

  @override
  String get adminContactSaved => 'تم حفظ الرابط';

  @override
  String get adminContactValue => 'القيمة';

  @override
  String get adminContacts => 'روابط التواصل';

  @override
  String get adminCover => 'الغلاف';

  @override
  String get adminCoverImage => 'صورة الغلاف';

  @override
  String get adminCreateCategory => 'إنشاء قسم';

  @override
  String get adminCurrency => 'العملة';

  @override
  String get adminCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get adminDashboard => 'لوحة التحكم';

  @override
  String get adminDefaultLanguage => 'اللغة الافتراضية';

  @override
  String get adminDiscard => 'تجاهل';

  @override
  String get adminDragToReorder => 'اسحب لإعادة الترتيب';

  @override
  String get adminDuplicate => 'نسخ';

  @override
  String get adminDuplicateCreated => 'تم إنشاء النسخة';

  @override
  String get adminEditCategory => 'تعديل القسم';

  @override
  String get adminEditContact => 'تعديل الرابط';

  @override
  String get adminEditProduct => 'تعديل المنتج';

  @override
  String get adminEmailLabel => 'البريد الإلكتروني';

  @override
  String get adminExitPreview => 'إنهاء المعاينة';

  @override
  String get adminFeatured => 'مميز';

  @override
  String get adminFilterAllCategories => 'كل الأقسام';

  @override
  String get adminFilterAllStatus => 'الكل';

  @override
  String get adminFilterDraft => 'مسودة';

  @override
  String get adminFilterPublished => 'منشور';

  @override
  String get adminForgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get adminGatewayTitle => 'بوابة الإدارة';

  @override
  String get adminHide => 'إخفاء';

  @override
  String get adminInquiries => 'الاستفسارات';

  @override
  String get adminInquiriesWeek => 'استفسارات هذا الأسبوع';

  @override
  String get adminInquiryDeleted => 'تم حذف الاستفسار';

  @override
  String get adminJustNow => 'الآن';

  @override
  String get adminKeepEditing => 'متابعة التحرير';

  @override
  String get adminLiveEdit => 'التحرير المباشر';

  @override
  String get adminLiveEditOff => 'التحرير المباشر مُطفأ';

  @override
  String get adminLiveEditOn =>
      'التحرير المباشر مُشغَّل — انقر القلم لتغيير ذلك النص';

  @override
  String get adminLivePreview => 'معاينة الزبون';

  @override
  String get adminLoginSubtitle => 'هذه المنطقة مخصصة لمالك المتجر فقط.';

  @override
  String get adminLoginTitle => 'دخول المالك';

  @override
  String get adminLogoPreview => 'معاينة الشعار';

  @override
  String get adminMarkPrimary => 'الرابط الأساسي';

  @override
  String get adminMedia => 'الوسائط';

  @override
  String get adminMostContacted => 'الأكثر تواصلًا';

  @override
  String get adminMoveProductsTo => 'نقل المنتجات إلى';

  @override
  String get adminNewPassword => 'كلمة المرور الجديدة';

  @override
  String get adminNoCategories =>
      'لا توجد أقسام بعد. أنشئ أول قسم لتجميع منتجاتك.';

  @override
  String get adminNoContacts =>
      'لا توجد روابط تواصل بعد. يبلغك الزوار من خلالها.';

  @override
  String get adminNoInquiries =>
      'لا توجد استفسارات بعد. ستظهر هنا نقرات الزوار على أزرار التواصل.';

  @override
  String get adminNoInquiriesYet =>
      'لا توجد نقرات مسجلة بعد. ستظهر هنا فور نقر أحد الزوار على زر التواصل.';

  @override
  String get adminNoMedia => 'لا توجد صور أو مقاطع فيديو بعد.';

  @override
  String get adminNoProducts =>
      'لا توجد منتجات بعد. أضف أول قطعة إلى الكتالوج.';

  @override
  String get adminNoProductsMatch => 'لا توجد منتجات مطابقة لعوامل التصفية.';

  @override
  String get adminNotAuthorised => 'هذا الحساب ليس مسؤولًا.';

  @override
  String get adminOtherSessionsSignedOut => 'تم تسجيل خروج الجلسات الأخرى.';

  @override
  String get adminPasswordChanged => 'تم تحديث كلمة المرور.';

  @override
  String get adminPasswordLabel => 'كلمة المرور';

  @override
  String get adminPreviewAsCustomer => 'معاينة كزبون';

  @override
  String get adminPreviewBadge => 'معاينة كزبون';

  @override
  String get adminPrice => 'السعر';

  @override
  String get adminPrimaryBadge => 'أساسي';

  @override
  String get adminProductColumn => 'المنتج';

  @override
  String get adminProductDeleted => 'تم حذف المنتج';

  @override
  String get adminProductDescriptionAr => 'الوصف (العربية)';

  @override
  String get adminProductDescriptionAm => 'الوصف (الأمهرية)';

  @override
  String get adminProductDescriptionOm => 'الوصف (أورومو)';

  @override
  String get adminProductDescription => 'الوصف (الإنجليزية)';

  @override
  String get adminProductSaved => 'تم حفظ المنتج';

  @override
  String get adminProductTitleAr => 'العنوان (العربية)';

  @override
  String get adminProductTitleAm => 'العنوان (الأمهرية)';

  @override
  String get adminProductTitleOm => 'العنوان (أورومو)';

  @override
  String get adminProductTitle => 'العنوان (الإنجليزية)';

  @override
  String get adminProducts => 'المنتجات';

  @override
  String get adminPublish => 'نشر';

  @override
  String get adminQuickActions => 'إجراءات سريعة';

  @override
  String get adminReauthPrompt =>
      'أدخل كلمة المرور الحالية لتأكيد هذا التغيير.';

  @override
  String get adminRemoveMedia => 'إزالة الوسائط';

  @override
  String get adminResetSent =>
      'تحقق من بريدك الإلكتروني للحصول على رابط إعادة التعيين.';

  @override
  String get adminSaveAndPublish => 'حفظ ونشر';

  @override
  String get adminSaveDraft => 'حفظ كمسودة';

  @override
  String get adminSearchProducts => 'بحث في المنتجات';

  @override
  String get adminSectionSoon => 'قادم في الشاشة التالية';

  @override
  String get adminSetCover => 'تعيين كغلاف';

  @override
  String get adminShow => 'إظهار';

  @override
  String get adminSignIn => 'تسجيل الدخول';

  @override
  String get adminSignOut => 'تسجيل الخروج';

  @override
  String get adminSignOutOthers => 'تسجيل الخروج من الجلسات الأخرى';

  @override
  String get adminSiteSettings => 'إعدادات الموقع';

  @override
  String get adminSiteSettingsSaved => 'تم حفظ الإعدادات';

  @override
  String get adminSlug => 'معرّف الرابط';

  @override
  String get adminSlugAuto => 'يُولَّد من الاسم الإنجليزي إذا تُرك فارغًا.';

  @override
  String get adminSortOrderHint => 'يظهر بالترتيب أدناه.';

  @override
  String get adminStatsCategories => 'الأقسام';

  @override
  String get adminStatsProducts => 'المنتجات';

  @override
  String get adminStoreName => 'اسم المتجر';

  @override
  String get adminStoreNameAm => 'اسم المتجر (أمهرية)';

  @override
  String get adminStoreNameAr => 'اسم المتجر (عربي)';

  @override
  String get adminStoreNameOm => 'اسم المتجر (الأورومو)';

  @override
  String get adminStrength => 'القوة';

  @override
  String get adminStrengthFair => 'متوسطة';

  @override
  String get adminStrengthStrong => 'قوية';

  @override
  String get adminStrengthWeak => 'ضعيفة';

  @override
  String get adminSystemCheck => 'فحص النظام';

  @override
  String get adminTagline => 'الشعار';

  @override
  String get adminTextEditor => 'النصوص واللغة';

  @override
  String get adminTextEditorAllScreens => 'كل الشاشات';

  @override
  String get adminTextEditorHasVariables => 'يحتوي على متغيرات';

  @override
  String get adminTextEditorHint =>
      'كل كلمات التطبيق، بجميع اللغات. عدّل كلمة فتتغير في كل مكان.';

  @override
  String get adminTextEditorMissing => 'الكلمات الناقصة';

  @override
  String get adminTextEditorMissingDone => 'لا يوجد نقص في هذه اللغة';

  @override
  String get adminTextEditorMissingHint =>
      'الكلمات التي لا تزال تظهر بالإنجليزية في هذه اللغة فقط — املأها واحدة تلو الأخرى.';

  @override
  String get adminTextEditorNoResults => 'لا يوجد نص يطابق بحثك';

  @override
  String get adminTextEditorPlaceholderHint =>
      'اترك المتغيرات بين الأقواس كما هي بالضبط.';

  @override
  String get adminTextEditorReset => 'استعادة الافتراضي';

  @override
  String get adminTextEditorResetDone => 'تمت استعادة النص الافتراضي';

  @override
  String get adminTextEditorSaved => 'تم حفظ النص';

  @override
  String get adminTextEditorSearch => 'ابحث عن كلمة';

  @override
  String get adminUnpublish => 'إلغاء النشر';

  @override
  String get adminUnpublished => 'غير منشور';

  @override
  String get adminUnsavedMessage =>
      'لديك تغييرات غير محفوظة. ستفقدها إذا غادرت الآن.';

  @override
  String get adminUnsavedTitle => 'هل تريد تجاهل التغييرات؟';

  @override
  String get adminUploadLogo => 'رفع الشعار';

  @override
  String get adminUploadQueue => 'قائمة الرفع';

  @override
  String get adminUploadRetrying => 'جارٍ إعادة المحاولة…';

  @override
  String adminUploadingCount(int done, int total) {
    return '$done من $total تم رفعها';
  }

  @override
  String get adminViewAll => 'عرض الكل';

  @override
  String get adminViewStore => 'عرض المتجر';

  @override
  String get adminVisibleInStore => 'ظاهر في المتجر';

  @override
  String get adminWhen => 'متى';

  @override
  String get appTitle => 'المجلس العربي عمو شريف';

  @override
  String get brandMonogram => 'ASM';

  @override
  String get brandNameAm => 'አሙ ሸሪፍ አረቢያን መጅሊስ';

  @override
  String get brandNameAr => 'المجلس العربي عمو شريف';

  @override
  String get brandNameEn => 'Amu Sharif Arabiyan Majlis';

  @override
  String get contactEmail => 'البريد الإلكتروني';

  @override
  String get contactFacebook => 'فيسبوك';

  @override
  String get contactInstagram => 'إنستغرام';

  @override
  String get contactLaunchFailed => 'تعذّر فتح هذا الرابط على هذا الجهاز.';

  @override
  String get contactLocation => 'الموقع';

  @override
  String get contactOther => 'أخرى';

  @override
  String get contactPhone => 'هاتف';

  @override
  String get contactTelegram => 'تيليجرام';

  @override
  String get contactTikTok => 'تيك توك';

  @override
  String get contactWebsite => 'الموقع الإلكتروني';

  @override
  String get contactWhatsApp => 'واتساب';

  @override
  String get contactYouTube => 'يوتيوب';

  @override
  String get errorAuth => 'تعذّر تسجيل دخولك.';

  @override
  String get errorBackendNotSetUp =>
      'قاعدة البيانات غير مجهّزة على خادم هذا البناء بعد. افتح فحص النظام في بوابة المالك لترى ما يجب تشغيله.';

  @override
  String get errorCheckViolation => 'إحدى القيم خارج النطاق المسموح.';

  @override
  String get errorConstraintViolation => 'بعض القيم غير مسموح بها.';

  @override
  String get errorDuplicate => 'هذه القيمة مستخدمة بالفعل.';

  @override
  String get errorEmailNotConfirmed =>
      'أكّد بريدك الإلكتروني قبل تسجيل الدخول.';

  @override
  String get errorForeignKey => 'البيانات المرتبطة مفقودة.';

  @override
  String get errorGateLocked => 'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String get errorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errorInvalidFormat => 'هذه القيمة ليست بالتنسيق المتوقع.';

  @override
  String get errorMedia => 'تعذّرت معالجة ذلك الملف.';

  @override
  String get errorMediaImageTooLarge =>
      'يجب ألا تتجاوز الصور 5 ميغابايت بعد الضغط.';

  @override
  String get errorMediaUnsupportedImage => 'استخدم صورة JPG أو PNG أو WebP.';

  @override
  String get errorMediaUnsupportedVideo => 'استخدم فيديو MP4.';

  @override
  String get errorMediaVideoTooLarge =>
      'يجب ألا تتجاوز مقاطع الفيديو 40 ميغابايت.';

  @override
  String get errorNetwork => 'لم نتمكن من الوصول إلى المتجر. تحقق من اتصالك.';

  @override
  String get errorNotAdmin =>
      'هذا الحساب مسجَّل الدخول لكنه غير موسوم كمالك المتجر. نفِّذ: update public.profiles set is_admin = true where id = \'<معرّف المستخدم>\';';

  @override
  String get errorNotFound => 'لم نتمكن من العثور على ما تبحث عنه.';

  @override
  String get errorNotSignedIn =>
      'حساب المالك في قاعدة البيانات غير مرتبط. افتح لوحة المالك (انقر الشعار خمس مرات) وسجّل الدخول.';

  @override
  String get errorPermission => 'ليس لديك إذن للقيام بذلك.';

  @override
  String get errorServer => 'الخدمة غير متاحة مؤقتًا. حاول مرة أخرى.';

  @override
  String get errorSessionExpired =>
      'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorStorage => 'تعذّر رفع الملف.';

  @override
  String get errorTimeout => 'استغرق الطلب وقتًا طويلًا. حاول مرة أخرى.';

  @override
  String get errorTooManyAttempts =>
      'محاولات كثيرة جدًا. انتظر قليلًا ثم حاول مرة أخرى.';

  @override
  String get errorUnknown => 'حدث أمر غير متوقع. حاول مرة أخرى.';

  @override
  String get errorValidation => 'يرجى تصحيح الحقول المحددة.';

  @override
  String get favouritesEmptyMessage => 'انقر على القلب لحفظ القطعة هنا.';

  @override
  String get favouritesEmptyTitle => 'لا مفضلات بعد';

  @override
  String get gateChangeTitle => 'كلمة مرور الدخول';

  @override
  String get gateChangeIntro =>
      'تفتح كلمة المرور هذه لوحة المالك على هذا الجهاز. غيّرها متى شئت.';

  @override
  String get gateChanged => 'تم تحديث كلمة مرور الدخول.';

  @override
  String get gateHint => 'تلميح: انقر الشعار خمس مرات لإعادة فتح هذه اللوحة.';

  @override
  String get gateLocked => 'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String get gateOwnerEmail => 'بريد المالك';

  @override
  String get gateOwnerHint =>
      'مطلوب مرة واحدة لكل جهاز: كلمة مرور اللوحة وحدها لا تسمح بالكتابة في قاعدة البيانات. سجّل الدخول ببريد المالك وكلمة مروره.';

  @override
  String get gateOwnerPassword => 'كلمة مرور المالك';

  @override
  String get gateOwnerTitle => 'حساب المالك في قاعدة البيانات';

  @override
  String get gateTitle => 'دخول المالك';

  @override
  String get gateUnlock => 'فتح';

  @override
  String get gateUnlocked => 'تم فتح دخول المالك.';

  @override
  String get gateUsername => 'اسم المستخدم';

  @override
  String get groupCommon => 'كلمات مشتركة';

  @override
  String get groupErrors => 'الأخطاء والحالات';

  @override
  String get groupStorefront => 'شاشات المتجر';

  @override
  String get groupValidation => 'رسائل التحقق';

  @override
  String inquiryMessageTemplate(String price, String product) {
    return 'مرحبًا! أنا مهتم بـ «$product» ($price).';
  }

  @override
  String get labelAvailable => 'متوفر';

  @override
  String labelDiscount(int percent) {
    return 'وفّر $percent%';
  }

  @override
  String labelDuration(int minutes, int seconds) {
    return '$minutesد $secondsث';
  }

  @override
  String labelFrom(String price) {
    return 'تبدأ من $price';
  }

  @override
  String get labelPrice => 'السعر';

  @override
  String get labelUnavailable => 'غير متوفر';

  @override
  String get navAbout => 'من نحن';

  @override
  String get navAdmin => 'الإدارة';

  @override
  String get navCategories => 'الفئات';

  @override
  String get navContact => 'اتصل بنا';

  @override
  String get navFavourites => 'المفضلة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get searchHint => 'ابحث عن مجالس أو كنب أو وسائد…';

  @override
  String searchNoResults(String query) {
    return 'لا توجد منتجات تطابق «$query»';
  }

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا توجد نتائج',
    );
    return '$_temp0';
  }

  @override
  String get sectionAllProducts => 'جميع المنتجات';

  @override
  String get sectionBrowseCategories => 'تصفح حسب الفئة';

  @override
  String get sectionFeatured => 'مميزة';

  @override
  String get sectionNewArrivals => 'وصل حديثًا';

  @override
  String get settingsAbout => 'حول التطبيق';

  @override
  String get settingsAdminEntry => 'الإدارة';

  @override
  String get settingsAdminHint => 'دخول المالك';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get stateEmptyMessage =>
      'ستظهر القطع الجديدة هنا بمجرد أن ينشرها المالك.';

  @override
  String get stateEmptyTitle => 'لا يوجد شيء بعد';

  @override
  String get stateErrorTitle => 'حدث خطأ ما';

  @override
  String get stateLoading => 'جارٍ التحميل…';

  @override
  String get stateNoResults => 'لا نتائج';

  @override
  String get stateNotFoundMessage => 'هذا الرابط لم يعد موجودًا.';

  @override
  String get stateNotFoundTitle => 'الصفحة غير موجودة';

  @override
  String get stateOffline =>
      'أنت غير متصل بالإنترنت. تحقق من اتصالك وأعد المحاولة.';

  @override
  String get stateSaved => 'تم الحفظ';

  @override
  String get stateSaving => 'جارٍ الحفظ…';

  @override
  String get systemCheckAccount => 'مسجّل الدخول باسم';

  @override
  String get systemCheckAllGood => 'كل ما يحتاجه هذا البناء متوفر في الخلفية.';

  @override
  String get systemCheckBuild => 'البناء';

  @override
  String get systemCheckFixDatabase =>
      'supabase db push — يطبّق كل الجداول والحاويات والسياسات';

  @override
  String get systemCheckFixFunction =>
      'supabase functions deploy inquiry — ينشر نقطة نهاية التواصل';

  @override
  String get systemCheckFixNetwork =>
      'تحقّق من رابط مشروع Supabase في إعدادات هذا البناء واتصالك بالإنترنت.';

  @override
  String get systemCheckFixSeed => 'supabase db seed — يضيف الصفوف الابتدائية';

  @override
  String get systemCheckMissing => 'لم يُجهَّز';

  @override
  String get systemCheckMissingSummary =>
      'بعض ما يحتاجه هذا البناء مفقود. شغّل هذه الأوامر في مجلد المشروع ثم أعد الفحص:';

  @override
  String get systemCheckNotSignedIn => 'غير مسجّل';

  @override
  String get systemCheckOk => 'جاهز';

  @override
  String get systemCheckProject => 'مشروع Supabase';

  @override
  String get systemCheckRestricted => 'جاهز · مقيّد';

  @override
  String get systemCheckRun => 'إعادة تشغيل الفحص';

  @override
  String get systemCheckTitle => 'فحص النظام';

  @override
  String get systemCheckUnreachable => 'لا يمكن الوصوله';

  @override
  String get systemCheckUnknown => 'غير معروف';

  @override
  String get tagline => 'مجالس وكنب عربية فاخرة، مصنوعة يدويًا لمنزلك';

  @override
  String get validateCompareAtPrice =>
      'يجب أن يكون السعر الأصلي مساويًا لسعر البيع على الأقل';

  @override
  String get validateEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get validateNegative => 'لا يمكن أن تكون القيمة سالبة';

  @override
  String get validateNumber => 'أدخل رقمًا صالحًا';

  @override
  String get validatePasswordLength => 'استخدم 10 أحرف على الأقل';

  @override
  String get validatePasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get validatePasswordStrength =>
      'أدخل حرفًا كبيرًا وحرفًا صغيرًا ورقمًا';

  @override
  String get validatePhone => 'أدخل رقم هاتف صالحًا';

  @override
  String get validatePositive => 'يجب أن تكون القيمة أكبر من صفر';

  @override
  String get validateRequired => 'هذا الحقل مطلوب';

  @override
  String get validateSlug => 'استخدم الحروف الصغيرة والأرقام والشرطات فقط';

  @override
  String get validateTelegramHandle =>
      'أدخل معرّف تيليجرام مثل ‎@username‎ أو رابط t.me';

  @override
  String get validateTooLong => 'هذه القيمة طويلة جدًا';

  @override
  String get validateTooShort => 'هذه القيمة قصيرة جدًا';

  @override
  String get validateUrl => 'أدخل رابطًا صالحًا يبدأ بـ https://';

  @override
  String get validateVideoTooLong => 'يجب ألا تتجاوز مدة الفيديو 60 ثانية';

  @override
  String get validateVideoUnreadable => 'تعذّر قراءة ذلك الفيديو';

  @override
  String get adminSiteContent => 'محتوى الموقع';

  @override
  String get adminSiteContentHint =>
      'إعادة كتابة الكلمات التي يراها الزبائن على الشاشة الرئيسية قبل الصياغة المدمجة.';

  @override
  String get adminSiteContentValue => 'قيمة';

  @override
  String get adminContactSettings => 'إعدادات التواصل';

  @override
  String get adminContactSettingsHint =>
      'القنوات التي يمكن للزبائن التواصل معك عبرها. اترك الحقل فارغًا لإخفائه.';

  @override
  String get adminOwnerPhone => 'هاتف المالك (tel:)';

  @override
  String get adminOwnerEmail => 'البريد الإلكتروني للمالك';

  @override
  String get adminWhatsappNumber => 'رقم واتساب';

  @override
  String get adminTelegramHandle => 'معرّف تيليجرام';

  @override
  String get adminInstagramHandle => 'معرّف إنستغرام';

  @override
  String get adminFacebookHandle => 'معرّف فيسبوك';

  @override
  String get adminTiktokHandle => 'معرّف تيك توك';

  @override
  String get adminYoutubeHandle => 'معرّف يوتيوب أو الرابط';

  @override
  String get adminWebsiteUrl => 'رابط الموقع';

  @override
  String get contactOwnerHint => 'تواصل مع المالك مباشرة بخصوص هذه القطعة.';
}
