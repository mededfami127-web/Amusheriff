// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'አሙ ሸሪፍ አረቢያን መጅሊስ';

  @override
  String get brandNameEn => 'Amu Sharif Arabiyan Majlis';

  @override
  String get brandNameAm => 'አሙ ሸሪፍ አረቢያን መጅሊስ';

  @override
  String get brandNameAr => 'المجلس العربي عمو شريف';

  @override
  String get brandMonogram => 'ASM';

  @override
  String get tagline => 'የቅንጦት የአረብ መጅሊስ እና ሶፋዎች፣ ለቤትዎ በእጅ የተሰሩ';

  @override
  String get aboutFallback =>
      'አሙ ሸሪፍ አረቢያን መጅሊስ በአረብ ወግ መሰረት ጥራት ያላቸው የመጅሊስ ወንበሮች፣ የመሬት ትራሶች እና የቤት እቃዎችን ያመርታል።';

  @override
  String get navHome => 'መነሻ';

  @override
  String get navCategories => 'ምድቦች';

  @override
  String get navAbout => 'ስለ እኛ';

  @override
  String get navContact => 'አግኙን';

  @override
  String get navAdmin => 'አስተዳዳሪ';

  @override
  String get navSettings => 'ቅንብሮች';

  @override
  String get actionRetry => 'እንደገና ሞክር';

  @override
  String get actionCancel => 'ሰርዝ';

  @override
  String get actionSave => 'አስቀምጥ';

  @override
  String get actionDelete => 'አጥፋ';

  @override
  String get actionEdit => 'አስተካክል';

  @override
  String get actionClose => 'ዝጋ';

  @override
  String get actionSearch => 'ፈልግ';

  @override
  String get actionShare => 'አጋራ';

  @override
  String get actionContinue => 'ቀጥል';

  @override
  String get actionViewDetails => 'ዝርዝር ይመልከቱ';

  @override
  String get actionContactOwner => 'ባለቤቱን ያግኙ';

  @override
  String get actionOrderNow => 'አሁን ያዙ';

  @override
  String get actionCallNow => 'አሁን ይደውሉ';

  @override
  String get actionCopyLink => 'አገናኝ ቅዳ';

  @override
  String get actionCopySuccess => 'አገናኙ ተቀድቷል';

  @override
  String get searchHint => 'መጅሊስ፣ ሶፋ፣ ትራስ ይፈልጉ…';

  @override
  String searchNoResults(String query) {
    return 'ከ“$query” ጋር የሚዛመድ ምርት አልተገኘም';
  }

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ውጤቶች',
      one: '1 ውጤት',
      zero: 'ውጤት የለም',
    );
    return '$_temp0';
  }

  @override
  String get sectionFeatured => 'የተመረጡ';

  @override
  String get sectionBrowseCategories => 'በምድብ ያስሱ';

  @override
  String get sectionAllProducts => 'ሁሉም ምርቶች';

  @override
  String get sectionNewArrivals => 'አዲስ የገቡ';

  @override
  String get labelPrice => 'ዋጋ';

  @override
  String labelFrom(String price) {
    return 'ከ$price ጀምሮ';
  }

  @override
  String get labelAvailable => 'ይገኛል';

  @override
  String get labelUnavailable => 'ከመጋዘን አልቋል';

  @override
  String labelDiscount(int percent) {
    return '$percent% ይቆጥቡ';
  }

  @override
  String labelDuration(int minutes, int seconds) {
    return '$minutesደ $secondsሰ';
  }

  @override
  String get contactWhatsApp => 'ዋትስአፕ';

  @override
  String get contactTelegram => 'ቴሌግራም';

  @override
  String get contactPhone => 'ስልክ';

  @override
  String get contactEmail => 'ኢሜይል';

  @override
  String get contactInstagram => 'ኢንስታግራም';

  @override
  String get contactFacebook => 'ፌስቡክ';

  @override
  String get contactTikTok => 'ቲክቶክ';

  @override
  String get contactYouTube => 'ዩቲዩብ';

  @override
  String get contactWebsite => 'ድህረ ገጽ';

  @override
  String get contactLocation => 'አድራሻ';

  @override
  String get contactOther => 'ሌላ';

  @override
  String get contactLaunchFailed => 'ይህን አገናኝ በዚህ መሳሪያ ላይ መክፈት አልተቻለም።';

  @override
  String inquiryMessageTemplate(String product, String price) {
    return 'ሰላም! በ“$product” ($price) ፍላጎት አለኝ።';
  }

  @override
  String get stateLoading => 'በመጫን ላይ…';

  @override
  String get stateEmptyTitle => 'እስካሁን ምንም የለም';

  @override
  String get stateEmptyMessage => 'ባለቤቱ ሲያትም አዲስ ዕቃዎች እዚህ ይታያሉ።';

  @override
  String get stateErrorTitle => 'የሆነ ችግር ተፈጥሯል';

  @override
  String get stateOffline => 'ከመስመር ውጭ ነዎት። ግንኙነትዎን አረጋግጠው እንደገና ይሞክሩ።';

  @override
  String get stateNotFoundTitle => 'ገጹ አልተገኘም';

  @override
  String get stateNotFoundMessage => 'ያ አገናኝ ከእንግዲህ የለም።';

  @override
  String get errorNetwork => 'ሱቁን ማግኘት አልቻልንም። ግንኙነትዎን ያረጋግጡ።';

  @override
  String get errorTimeout => 'ጥያቄው በጣም ረጅም ወሰደ። እንደገና ይሞክሩ።';

  @override
  String get errorServer => 'አገልግሎቱ ለጊዜው አይገኝም። እንደገና ይሞክሩ።';

  @override
  String get errorAuth => 'መግቢያ አልተሳካም።';

  @override
  String get errorInvalidCredentials => 'የተሳሳተ ኢሜይል ወይም የይለፍ ቃል።';

  @override
  String get errorEmailNotConfirmed => 'ከመግባትዎ በፊት ኢሜይልዎን ያረጋግጡ።';

  @override
  String get errorTooManyAttempts => 'ብዙ ሙከራዎች። ትንሽ ቆይተው እንደገና ይሞክሩ።';

  @override
  String get errorSessionExpired => 'ክፍለ ጊዜዎ አልቋል። እንደገና ይግቡ።';

  @override
  String get errorPermission => 'ይህን ለማድረግ ፈቃድ የለዎትም።';

  @override
  String get errorNotFound => 'የፈለጉትን ማግኘት አልቻልንም።';

  @override
  String get errorValidation => 'እባክዎ የተመለከቱትን መስኮች ያስተካክሉ።';

  @override
  String get errorMedia => 'ያ ፋይል ሊሰራ አልቻለም።';

  @override
  String get errorStorage => 'ፋይሉ ሊጫን አልቻለም።';

  @override
  String get errorUnknown => 'ያልተጠበቀ ነገር ተፈጥሯል። እንደገና ይሞክሩ።';

  @override
  String get errorDuplicate => 'ያ እሴት አስቀድሞ ጥቅም ላይ ውሏል።';

  @override
  String get errorCheckViolation => 'አንድ እሴት ከተፈቀደው ክልል ውጭ ነው።';

  @override
  String get errorForeignKey => 'ተዛማጅ መረጃ ጎድሏል።';

  @override
  String get errorConstraintViolation => 'አንዳንድ እሴቶች አይፈቀዱም።';

  @override
  String get errorInvalidFormat => 'ያ እሴት በሚጠበቀው ቅርጸት አይደለም።';

  @override
  String get validateRequired => 'ይህ መስክ ያስፈልጋል';

  @override
  String get validateTooShort => 'ይህ እሴት በጣም አጭር ነው';

  @override
  String get validateTooLong => 'ይህ እሴት በጣም ረጅም ነው';

  @override
  String get validateSlug => 'ትንንሽ ፊደላት፣ ቁጥሮች እና ሰረዞችን ብቻ ይጠቀሙ';

  @override
  String get validateEmail => 'ትክክለኛ ኢሜይል ያስገቡ';

  @override
  String get validatePhone => 'ትክክለኛ ስልክ ቁጥር ያስገቡ';

  @override
  String get validateUrl => 'በ https:// የሚጀምር ትክክለኛ አገናኝ ያስገቡ';

  @override
  String get validatePasswordLength => 'ቢያንስ 10 ቁምፊዎችን ይጠቀሙ';

  @override
  String get validatePasswordStrength =>
      'አንድ አቢይ ፊደል፣ አንድ ትንሽ ፊደል እና አንድ ቁጥር ያካትቱ';

  @override
  String get validatePasswordMismatch => 'የይለፍ ቃላቱ አይመሳሰሉም';

  @override
  String get validateNumber => 'ትክክለኛ ቁጥር ያስገቡ';

  @override
  String get validateNegative => 'እሴቱ አሉታዊ መሆን አይችልም';

  @override
  String get validatePositive => 'እሴቱ ከዜሮ በላይ መሆን አለበት';

  @override
  String get validateCompareAtPrice => 'የመጀመሪያው ዋጋ ከሽያጭ ዋጋ መብለጥ አለበት';

  @override
  String get validateVideoTooLong => 'ቪዲዮዎች 60 ሰከንድ ወይም ከዚያ በታች መሆን አለባቸው';

  @override
  String get validateVideoUnreadable => 'ያ ቪዲዮ ሊነበብ አልቻለም';

  @override
  String get settingsTitle => 'ቅንብሮች';

  @override
  String get settingsLanguage => 'ቋንቋ';

  @override
  String get settingsTheme => 'አቀራረብ';

  @override
  String get settingsThemeSystem => 'የስርዓቱ';

  @override
  String get settingsThemeLight => 'ብሩህ';

  @override
  String get settingsThemeDark => 'ጨለማ';

  @override
  String get settingsAbout => 'ስለ መተግበሪያው';

  @override
  String get settingsVersion => 'ስሪት';

  @override
  String get settingsAdminEntry => 'አስተዳዳሪ';

  @override
  String get settingsAdminHint => 'የባለቤት መግቢያ';

  @override
  String get adminLoginTitle => 'የባለቤት መግቢያ';

  @override
  String get adminLoginSubtitle => 'ይህ ክፍል ለሱቁ ባለቤት ብቻ ነው።';

  @override
  String get adminEmailLabel => 'ኢሜይል';

  @override
  String get adminPasswordLabel => 'የይለፍ ቃል';

  @override
  String get adminSignIn => 'ግባ';

  @override
  String get adminSignOut => 'ውጣ';

  @override
  String get adminForgotPassword => 'የይለፍ ቃል ረሱ?';

  @override
  String get adminChangePassword => 'የይለፍ ቃል ቀይር';

  @override
  String get adminDashboard => 'ዳሽቦርድ';

  @override
  String get adminCategories => 'ምድቦች';

  @override
  String get adminProducts => 'ምርቶች';

  @override
  String get adminMedia => 'ሚዲያ';

  @override
  String get adminContacts => 'የመገኛ አገናኞች';

  @override
  String get adminSiteSettings => 'የጣቢያ ቅንብሮች';

  @override
  String get adminInquiries => 'ጥያቄዎች';

  @override
  String get adminNotAuthorised => 'ይህ አካውንት አስተዳዳሪ አይደለም።';

  @override
  String get adminCurrentPassword => 'የአሁኑ የይለፍ ቃል';

  @override
  String get adminNewPassword => 'አዲስ የይለፍ ቃል';

  @override
  String get adminConfirmPassword => 'አዲሱን የይለፍ ቃል ያረጋግጡ';

  @override
  String get adminPasswordChanged => 'የይለፍ ቃልዎ ተቀይሯል።';

  @override
  String get adminResetSent => 'የመቀየሪያ አገናኝ ኢሜይልዎን ይመልከቱ።';

  @override
  String a11yProductImage(String title) {
    return 'የ$title ፎቶ';
  }

  @override
  String a11yVideoThumbnail(String title) {
    return 'የ$title ቪዲዮ አጫውት';
  }

  @override
  String a11yOpenCategory(String name) {
    return 'የ$name ምድብ ክፈት';
  }
}
