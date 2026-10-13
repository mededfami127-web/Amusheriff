// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Amu Sharif Arabiyan Majlis';

  @override
  String get brandNameEn => 'Amu Sharif Arabiyan Majlis';

  @override
  String get brandNameAm => 'አሙ ሸሪፍ አረቢያን መጅሊስ';

  @override
  String get brandNameAr => 'المجلس العربي عمو شريف';

  @override
  String get brandMonogram => 'ASM';

  @override
  String get tagline =>
      'Luxury Arabic majlis & sofas, handcrafted for your home';

  @override
  String get aboutFallback =>
      'Amu Sharif Arabiyan Majlis crafts premium majlis seating, floor cushions and furnishings in the Arabian tradition.';

  @override
  String get navHome => 'Home';

  @override
  String get navCategories => 'Categories';

  @override
  String get navAbout => 'About';

  @override
  String get navContact => 'Contact';

  @override
  String get navAdmin => 'Admin';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionShare => 'Share';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionViewDetails => 'View details';

  @override
  String get actionContactOwner => 'Contact the owner';

  @override
  String get actionOrderNow => 'Order now';

  @override
  String get actionCallNow => 'Call now';

  @override
  String get actionCopyLink => 'Copy link';

  @override
  String get actionCopySuccess => 'Link copied';

  @override
  String get searchHint => 'Search majlis, sofas, cushions…';

  @override
  String searchNoResults(String query) {
    return 'No products match “$query”';
  }

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get sectionFeatured => 'Featured';

  @override
  String get sectionBrowseCategories => 'Browse by category';

  @override
  String get sectionAllProducts => 'All products';

  @override
  String get sectionNewArrivals => 'New arrivals';

  @override
  String get labelPrice => 'Price';

  @override
  String labelFrom(String price) {
    return 'From $price';
  }

  @override
  String get labelAvailable => 'Available';

  @override
  String get labelUnavailable => 'Out of stock';

  @override
  String labelDiscount(int percent) {
    return 'Save $percent%';
  }

  @override
  String labelDuration(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String get contactWhatsApp => 'WhatsApp';

  @override
  String get contactTelegram => 'Telegram';

  @override
  String get contactPhone => 'Phone';

  @override
  String get contactEmail => 'Email';

  @override
  String get contactInstagram => 'Instagram';

  @override
  String get contactFacebook => 'Facebook';

  @override
  String get contactTikTok => 'TikTok';

  @override
  String get contactYouTube => 'YouTube';

  @override
  String get contactWebsite => 'Website';

  @override
  String get contactLocation => 'Location';

  @override
  String get contactOther => 'Other';

  @override
  String get contactLaunchFailed => 'Could not open that link on this device.';

  @override
  String inquiryMessageTemplate(String product, String price) {
    return 'Hello! I am interested in “$product” ($price).';
  }

  @override
  String get stateLoading => 'Loading…';

  @override
  String get stateEmptyTitle => 'Nothing here yet';

  @override
  String get stateEmptyMessage =>
      'New pieces will appear here as soon as the owner publishes them.';

  @override
  String get stateErrorTitle => 'Something went wrong';

  @override
  String get stateOffline =>
      'You are offline. Check your connection and try again.';

  @override
  String get stateNotFoundTitle => 'Page not found';

  @override
  String get stateNotFoundMessage => 'That link does not exist any more.';

  @override
  String get errorNetwork =>
      'We could not reach the store. Check your connection.';

  @override
  String get errorTimeout => 'The request took too long. Please try again.';

  @override
  String get errorServer =>
      'The service is temporarily unavailable. Please try again.';

  @override
  String get errorAuth => 'We could not sign you in.';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorEmailNotConfirmed =>
      'Confirm your email address before signing in.';

  @override
  String get errorTooManyAttempts =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get errorSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get errorPermission => 'You do not have permission to do that.';

  @override
  String get errorNotFound => 'We could not find what you were looking for.';

  @override
  String get errorValidation => 'Please correct the highlighted fields.';

  @override
  String get errorMedia => 'That file could not be processed.';

  @override
  String get errorStorage => 'The file could not be uploaded.';

  @override
  String get errorUnknown => 'Something unexpected happened. Please try again.';

  @override
  String get errorDuplicate => 'That value is already in use.';

  @override
  String get errorCheckViolation => 'A value is outside the allowed range.';

  @override
  String get errorForeignKey => 'Related data is missing.';

  @override
  String get errorConstraintViolation => 'Some values are not allowed.';

  @override
  String get errorInvalidFormat => 'That value is not in the expected format.';

  @override
  String get validateRequired => 'This field is required';

  @override
  String get validateTooShort => 'This value is too short';

  @override
  String get validateTooLong => 'This value is too long';

  @override
  String get validateSlug => 'Use lowercase letters, numbers and hyphens only';

  @override
  String get validateEmail => 'Enter a valid email address';

  @override
  String get validatePhone => 'Enter a valid phone number';

  @override
  String get validateUrl => 'Enter a valid link starting with https://';

  @override
  String get validatePasswordLength => 'Use at least 10 characters';

  @override
  String get validatePasswordStrength =>
      'Include an uppercase letter, a lowercase letter and a number';

  @override
  String get validatePasswordMismatch => 'Passwords do not match';

  @override
  String get validateNumber => 'Enter a valid number';

  @override
  String get validateNegative => 'Value cannot be negative';

  @override
  String get validatePositive => 'Value must be greater than zero';

  @override
  String get validateCompareAtPrice =>
      'Original price must be at least the selling price';

  @override
  String get validateVideoTooLong => 'Videos must be 60 seconds or shorter';

  @override
  String get validateVideoUnreadable => 'That video could not be read';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsAdminEntry => 'Admin';

  @override
  String get settingsAdminHint => 'Owner sign in';

  @override
  String get adminLoginTitle => 'Owner sign in';

  @override
  String get adminLoginSubtitle => 'This area is restricted to the shop owner.';

  @override
  String get adminEmailLabel => 'Email';

  @override
  String get adminPasswordLabel => 'Password';

  @override
  String get adminSignIn => 'Sign in';

  @override
  String get adminSignOut => 'Sign out';

  @override
  String get adminForgotPassword => 'Forgot password?';

  @override
  String get adminChangePassword => 'Change password';

  @override
  String get adminDashboard => 'Dashboard';

  @override
  String get adminCategories => 'Categories';

  @override
  String get adminProducts => 'Products';

  @override
  String get adminMedia => 'Media';

  @override
  String get adminContacts => 'Contact links';

  @override
  String get adminSiteSettings => 'Site settings';

  @override
  String get adminInquiries => 'Inquiries';

  @override
  String get adminNotAuthorised => 'This account is not an administrator.';

  @override
  String get adminCurrentPassword => 'Current password';

  @override
  String get adminNewPassword => 'New password';

  @override
  String get adminConfirmPassword => 'Confirm new password';

  @override
  String get adminPasswordChanged => 'Your password has been updated.';

  @override
  String get adminResetSent => 'Check your inbox for a reset link.';

  @override
  String a11yProductImage(String title) {
    return 'Photo of $title';
  }

  @override
  String a11yVideoThumbnail(String title) {
    return 'Play the video for $title';
  }

  @override
  String a11yOpenCategory(String name) {
    return 'Open the $name category';
  }
}
