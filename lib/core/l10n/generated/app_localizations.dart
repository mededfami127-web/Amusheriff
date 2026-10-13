import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Amu Sharif Arabiyan Majlis'**
  String get appTitle;

  /// No description provided for @brandNameEn.
  ///
  /// In en, this message translates to:
  /// **'Amu Sharif Arabiyan Majlis'**
  String get brandNameEn;

  /// No description provided for @brandNameAm.
  ///
  /// In en, this message translates to:
  /// **'አሙ ሸሪፍ አረቢያን መጅሊስ'**
  String get brandNameAm;

  /// No description provided for @brandNameAr.
  ///
  /// In en, this message translates to:
  /// **'المجلس العربي عمو شريف'**
  String get brandNameAr;

  /// No description provided for @brandMonogram.
  ///
  /// In en, this message translates to:
  /// **'ASM'**
  String get brandMonogram;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Luxury Arabic majlis & sofas, handcrafted for your home'**
  String get tagline;

  /// No description provided for @aboutFallback.
  ///
  /// In en, this message translates to:
  /// **'Amu Sharif Arabiyan Majlis crafts premium majlis seating, floor cushions and furnishings in the Arabian tradition.'**
  String get aboutFallback;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navAbout;

  /// No description provided for @navContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get navContact;

  /// No description provided for @navAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get navAdmin;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get actionViewDetails;

  /// No description provided for @actionContactOwner.
  ///
  /// In en, this message translates to:
  /// **'Contact the owner'**
  String get actionContactOwner;

  /// No description provided for @actionOrderNow.
  ///
  /// In en, this message translates to:
  /// **'Order now'**
  String get actionOrderNow;

  /// No description provided for @actionCallNow.
  ///
  /// In en, this message translates to:
  /// **'Call now'**
  String get actionCallNow;

  /// No description provided for @actionCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get actionCopyLink;

  /// No description provided for @actionCopySuccess.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get actionCopySuccess;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search majlis, sofas, cushions…'**
  String get searchHint;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No products match “{query}”'**
  String searchNoResults(String query);

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String searchResultsCount(int count);

  /// No description provided for @sectionFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get sectionFeatured;

  /// No description provided for @sectionBrowseCategories.
  ///
  /// In en, this message translates to:
  /// **'Browse by category'**
  String get sectionBrowseCategories;

  /// No description provided for @sectionAllProducts.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get sectionAllProducts;

  /// No description provided for @sectionNewArrivals.
  ///
  /// In en, this message translates to:
  /// **'New arrivals'**
  String get sectionNewArrivals;

  /// No description provided for @labelPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get labelPrice;

  /// No description provided for @labelFrom.
  ///
  /// In en, this message translates to:
  /// **'From {price}'**
  String labelFrom(String price);

  /// No description provided for @labelAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get labelAvailable;

  /// No description provided for @labelUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get labelUnavailable;

  /// No description provided for @labelDiscount.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String labelDiscount(int percent);

  /// No description provided for @labelDuration.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String labelDuration(int minutes, int seconds);

  /// No description provided for @contactWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get contactWhatsApp;

  /// No description provided for @contactTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get contactTelegram;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactPhone;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactEmail;

  /// No description provided for @contactInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get contactInstagram;

  /// No description provided for @contactFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get contactFacebook;

  /// No description provided for @contactTikTok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get contactTikTok;

  /// No description provided for @contactYouTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get contactYouTube;

  /// No description provided for @contactWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get contactWebsite;

  /// No description provided for @contactLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get contactLocation;

  /// No description provided for @contactOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get contactOther;

  /// No description provided for @contactLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open that link on this device.'**
  String get contactLaunchFailed;

  /// No description provided for @inquiryMessageTemplate.
  ///
  /// In en, this message translates to:
  /// **'Hello! I am interested in “{product}” ({price}).'**
  String inquiryMessageTemplate(String product, String price);

  /// No description provided for @stateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get stateLoading;

  /// No description provided for @stateEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get stateEmptyTitle;

  /// No description provided for @stateEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'New pieces will appear here as soon as the owner publishes them.'**
  String get stateEmptyMessage;

  /// No description provided for @stateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get stateErrorTitle;

  /// No description provided for @stateOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Check your connection and try again.'**
  String get stateOffline;

  /// No description provided for @stateNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get stateNotFoundTitle;

  /// No description provided for @stateNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'That link does not exist any more.'**
  String get stateNotFoundMessage;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'We could not reach the store. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The service is temporarily unavailable. Please try again.'**
  String get errorServer;

  /// No description provided for @errorAuth.
  ///
  /// In en, this message translates to:
  /// **'We could not sign you in.'**
  String get errorAuth;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email address before signing in.'**
  String get errorEmailNotConfirmed;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get errorTooManyAttempts;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get errorSessionExpired;

  /// No description provided for @errorPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get errorPermission;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We could not find what you were looking for.'**
  String get errorNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please correct the highlighted fields.'**
  String get errorValidation;

  /// No description provided for @errorMedia.
  ///
  /// In en, this message translates to:
  /// **'That file could not be processed.'**
  String get errorMedia;

  /// No description provided for @errorStorage.
  ///
  /// In en, this message translates to:
  /// **'The file could not be uploaded.'**
  String get errorStorage;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected happened. Please try again.'**
  String get errorUnknown;

  /// No description provided for @errorDuplicate.
  ///
  /// In en, this message translates to:
  /// **'That value is already in use.'**
  String get errorDuplicate;

  /// No description provided for @errorCheckViolation.
  ///
  /// In en, this message translates to:
  /// **'A value is outside the allowed range.'**
  String get errorCheckViolation;

  /// No description provided for @errorForeignKey.
  ///
  /// In en, this message translates to:
  /// **'Related data is missing.'**
  String get errorForeignKey;

  /// No description provided for @errorConstraintViolation.
  ///
  /// In en, this message translates to:
  /// **'Some values are not allowed.'**
  String get errorConstraintViolation;

  /// No description provided for @errorInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'That value is not in the expected format.'**
  String get errorInvalidFormat;

  /// No description provided for @validateRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validateRequired;

  /// No description provided for @validateTooShort.
  ///
  /// In en, this message translates to:
  /// **'This value is too short'**
  String get validateTooShort;

  /// No description provided for @validateTooLong.
  ///
  /// In en, this message translates to:
  /// **'This value is too long'**
  String get validateTooLong;

  /// No description provided for @validateSlug.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase letters, numbers and hyphens only'**
  String get validateSlug;

  /// No description provided for @validateEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validateEmail;

  /// No description provided for @validatePhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validatePhone;

  /// No description provided for @validateUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid link starting with https://'**
  String get validateUrl;

  /// No description provided for @validatePasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least 10 characters'**
  String get validatePasswordLength;

  /// No description provided for @validatePasswordStrength.
  ///
  /// In en, this message translates to:
  /// **'Include an uppercase letter, a lowercase letter and a number'**
  String get validatePasswordStrength;

  /// No description provided for @validatePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validatePasswordMismatch;

  /// No description provided for @validateNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validateNumber;

  /// No description provided for @validateNegative.
  ///
  /// In en, this message translates to:
  /// **'Value cannot be negative'**
  String get validateNegative;

  /// No description provided for @validatePositive.
  ///
  /// In en, this message translates to:
  /// **'Value must be greater than zero'**
  String get validatePositive;

  /// No description provided for @validateCompareAtPrice.
  ///
  /// In en, this message translates to:
  /// **'Original price must be at least the selling price'**
  String get validateCompareAtPrice;

  /// No description provided for @validateVideoTooLong.
  ///
  /// In en, this message translates to:
  /// **'Videos must be 60 seconds or shorter'**
  String get validateVideoTooLong;

  /// No description provided for @validateVideoUnreadable.
  ///
  /// In en, this message translates to:
  /// **'That video could not be read'**
  String get validateVideoUnreadable;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsAdminEntry.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get settingsAdminEntry;

  /// No description provided for @settingsAdminHint.
  ///
  /// In en, this message translates to:
  /// **'Owner sign in'**
  String get settingsAdminHint;

  /// No description provided for @adminLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner sign in'**
  String get adminLoginTitle;

  /// No description provided for @adminLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This area is restricted to the shop owner.'**
  String get adminLoginSubtitle;

  /// No description provided for @adminEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminEmailLabel;

  /// No description provided for @adminPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminPasswordLabel;

  /// No description provided for @adminSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get adminSignIn;

  /// No description provided for @adminSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get adminSignOut;

  /// No description provided for @adminForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get adminForgotPassword;

  /// No description provided for @adminChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get adminChangePassword;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboard;

  /// No description provided for @adminCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get adminCategories;

  /// No description provided for @adminProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get adminProducts;

  /// No description provided for @adminMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get adminMedia;

  /// No description provided for @adminContacts.
  ///
  /// In en, this message translates to:
  /// **'Contact links'**
  String get adminContacts;

  /// No description provided for @adminSiteSettings.
  ///
  /// In en, this message translates to:
  /// **'Site settings'**
  String get adminSiteSettings;

  /// No description provided for @adminInquiries.
  ///
  /// In en, this message translates to:
  /// **'Inquiries'**
  String get adminInquiries;

  /// No description provided for @adminNotAuthorised.
  ///
  /// In en, this message translates to:
  /// **'This account is not an administrator.'**
  String get adminNotAuthorised;

  /// No description provided for @adminCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get adminCurrentPassword;

  /// No description provided for @adminNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get adminNewPassword;

  /// No description provided for @adminConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get adminConfirmPassword;

  /// No description provided for @adminPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated.'**
  String get adminPasswordChanged;

  /// No description provided for @adminResetSent.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox for a reset link.'**
  String get adminResetSent;

  /// No description provided for @a11yProductImage.
  ///
  /// In en, this message translates to:
  /// **'Photo of {title}'**
  String a11yProductImage(String title);

  /// No description provided for @a11yVideoThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Play the video for {title}'**
  String a11yVideoThumbnail(String title);

  /// No description provided for @a11yOpenCategory.
  ///
  /// In en, this message translates to:
  /// **'Open the {name} category'**
  String a11yOpenCategory(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
