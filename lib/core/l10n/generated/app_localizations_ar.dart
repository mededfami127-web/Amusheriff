// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'المجلس العربي عمو شريف';

  @override
  String get brandNameEn => 'Amu Sharif Arabiyan Majlis';

  @override
  String get brandNameAm => 'አሙ ሸሪፍ አረቢያን መጅሊስ';

  @override
  String get brandNameAr => 'المجلس العربي عمو شريف';

  @override
  String get brandMonogram => 'ASM';

  @override
  String get tagline => 'مجالس وكنب عربية فاخرة، مصنوعة يدويًا لمنزلك';

  @override
  String get aboutFallback =>
      'المجلس العربي عمو شريف يصنع مجالس وكنب وأثاثًا فاخرًا وفق التقاليد العربية.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCategories => 'الفئات';

  @override
  String get navAbout => 'من نحن';

  @override
  String get navContact => 'اتصل بنا';

  @override
  String get navAdmin => 'الإدارة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get actionRetry => 'أعد المحاولة';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionShare => 'مشاركة';

  @override
  String get actionContinue => 'متابعة';

  @override
  String get actionViewDetails => 'عرض التفاصيل';

  @override
  String get actionContactOwner => 'تواصل مع المالك';

  @override
  String get actionOrderNow => 'اطلب الآن';

  @override
  String get actionCallNow => 'اتصل الآن';

  @override
  String get actionCopyLink => 'انسخ الرابط';

  @override
  String get actionCopySuccess => 'تم نسخ الرابط';

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
  String get sectionFeatured => 'مميزة';

  @override
  String get sectionBrowseCategories => 'تصفح حسب الفئة';

  @override
  String get sectionAllProducts => 'جميع المنتجات';

  @override
  String get sectionNewArrivals => 'وصل حديثًا';

  @override
  String get labelPrice => 'السعر';

  @override
  String labelFrom(String price) {
    return 'تبدأ من $price';
  }

  @override
  String get labelAvailable => 'متوفر';

  @override
  String get labelUnavailable => 'غير متوفر';

  @override
  String labelDiscount(int percent) {
    return 'وفّر $percent%';
  }

  @override
  String labelDuration(int minutes, int seconds) {
    return '$minutesد $secondsث';
  }

  @override
  String get contactWhatsApp => 'واتساب';

  @override
  String get contactTelegram => 'تيليجرام';

  @override
  String get contactPhone => 'هاتف';

  @override
  String get contactEmail => 'البريد الإلكتروني';

  @override
  String get contactInstagram => 'إنستغرام';

  @override
  String get contactFacebook => 'فيسبوك';

  @override
  String get contactTikTok => 'تيك توك';

  @override
  String get contactYouTube => 'يوتيوب';

  @override
  String get contactWebsite => 'الموقع الإلكتروني';

  @override
  String get contactLocation => 'الموقع';

  @override
  String get contactOther => 'أخرى';

  @override
  String get contactLaunchFailed => 'تعذّر فتح هذا الرابط على هذا الجهاز.';

  @override
  String inquiryMessageTemplate(String product, String price) {
    return 'مرحبًا! أنا مهتم بـ «$product» ($price).';
  }

  @override
  String get stateLoading => 'جارٍ التحميل…';

  @override
  String get stateEmptyTitle => 'لا يوجد شيء بعد';

  @override
  String get stateEmptyMessage =>
      'ستظهر القطع الجديدة هنا بمجرد أن ينشرها المالك.';

  @override
  String get stateErrorTitle => 'حدث خطأ ما';

  @override
  String get stateOffline =>
      'أنت غير متصل بالإنترنت. تحقق من اتصالك وأعد المحاولة.';

  @override
  String get stateNotFoundTitle => 'الصفحة غير موجودة';

  @override
  String get stateNotFoundMessage => 'هذا الرابط لم يعد موجودًا.';

  @override
  String get errorNetwork => 'لم نتمكن من الوصول إلى المتجر. تحقق من اتصالك.';

  @override
  String get errorTimeout => 'استغرق الطلب وقتًا طويلًا. حاول مرة أخرى.';

  @override
  String get errorServer => 'الخدمة غير متاحة مؤقتًا. حاول مرة أخرى.';

  @override
  String get errorAuth => 'تعذّر تسجيل دخولك.';

  @override
  String get errorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errorEmailNotConfirmed =>
      'أكّد بريدك الإلكتروني قبل تسجيل الدخول.';

  @override
  String get errorTooManyAttempts =>
      'محاولات كثيرة جدًا. انتظر قليلًا ثم حاول مرة أخرى.';

  @override
  String get errorSessionExpired =>
      'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorPermission => 'ليس لديك إذن للقيام بذلك.';

  @override
  String get errorNotFound => 'لم نتمكن من العثور على ما تبحث عنه.';

  @override
  String get errorValidation => 'يرجى تصحيح الحقول المحددة.';

  @override
  String get errorMedia => 'تعذّرت معالجة ذلك الملف.';

  @override
  String get errorStorage => 'تعذّر رفع الملف.';

  @override
  String get errorUnknown => 'حدث أمر غير متوقع. حاول مرة أخرى.';

  @override
  String get errorDuplicate => 'هذه القيمة مستخدمة بالفعل.';

  @override
  String get errorCheckViolation => 'إحدى القيم خارج النطاق المسموح.';

  @override
  String get errorForeignKey => 'البيانات المرتبطة مفقودة.';

  @override
  String get errorConstraintViolation => 'بعض القيم غير مسموح بها.';

  @override
  String get errorInvalidFormat => 'هذه القيمة ليست بالتنسيق المتوقع.';

  @override
  String get validateRequired => 'هذا الحقل مطلوب';

  @override
  String get validateTooShort => 'هذه القيمة قصيرة جدًا';

  @override
  String get validateTooLong => 'هذه القيمة طويلة جدًا';

  @override
  String get validateSlug => 'استخدم الحروف الصغيرة والأرقام والشرطات فقط';

  @override
  String get validateEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get validatePhone => 'أدخل رقم هاتف صالحًا';

  @override
  String get validateUrl => 'أدخل رابطًا صالحًا يبدأ بـ https://';

  @override
  String get validatePasswordLength => 'استخدم 10 أحرف على الأقل';

  @override
  String get validatePasswordStrength =>
      'أدخل حرفًا كبيرًا وحرفًا صغيرًا ورقمًا';

  @override
  String get validatePasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get validateNumber => 'أدخل رقمًا صالحًا';

  @override
  String get validateNegative => 'لا يمكن أن تكون القيمة سالبة';

  @override
  String get validatePositive => 'يجب أن تكون القيمة أكبر من صفر';

  @override
  String get validateCompareAtPrice =>
      'يجب أن يكون السعر الأصلي مساويًا لسعر البيع على الأقل';

  @override
  String get validateVideoTooLong => 'يجب ألا تتجاوز مدة الفيديو 60 ثانية';

  @override
  String get validateVideoUnreadable => 'تعذّر قراءة ذلك الفيديو';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsAbout => 'حول التطبيق';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get settingsAdminEntry => 'الإدارة';

  @override
  String get settingsAdminHint => 'دخول المالك';

  @override
  String get adminLoginTitle => 'دخول المالك';

  @override
  String get adminLoginSubtitle => 'هذه المنطقة مخصصة لمالك المتجر فقط.';

  @override
  String get adminEmailLabel => 'البريد الإلكتروني';

  @override
  String get adminPasswordLabel => 'كلمة المرور';

  @override
  String get adminSignIn => 'تسجيل الدخول';

  @override
  String get adminSignOut => 'تسجيل الخروج';

  @override
  String get adminForgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get adminChangePassword => 'تغيير كلمة المرور';

  @override
  String get adminDashboard => 'لوحة التحكم';

  @override
  String get adminCategories => 'الفئات';

  @override
  String get adminProducts => 'المنتجات';

  @override
  String get adminMedia => 'الوسائط';

  @override
  String get adminContacts => 'روابط التواصل';

  @override
  String get adminSiteSettings => 'إعدادات الموقع';

  @override
  String get adminInquiries => 'الاستفسارات';

  @override
  String get adminNotAuthorised => 'هذا الحساب ليس مسؤولًا.';

  @override
  String get adminCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get adminNewPassword => 'كلمة المرور الجديدة';

  @override
  String get adminConfirmPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get adminPasswordChanged => 'تم تحديث كلمة المرور.';

  @override
  String get adminResetSent =>
      'تحقق من بريدك الإلكتروني للحصول على رابط إعادة التعيين.';

  @override
  String a11yProductImage(String title) {
    return 'صورة $title';
  }

  @override
  String a11yVideoThumbnail(String title) {
    return 'تشغيل فيديو $title';
  }

  @override
  String a11yOpenCategory(String name) {
    return 'افتح فئة $name';
  }
}
