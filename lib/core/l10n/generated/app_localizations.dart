import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_om.dart';

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
    Locale('om'),
  ];

  /// No description provided for @a11yOpenCategory.
  ///
  /// In en, this message translates to:
  /// **'Open the {name} category'**
  String a11yOpenCategory(String name);

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

  /// No description provided for @aboutFallback.
  ///
  /// In en, this message translates to:
  /// **'Amu Sharif Arabiyan Majlis crafts premium majlis seating, floor cushions and furnishings in the Arabian tradition.'**
  String get aboutFallback;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionCallNow.
  ///
  /// In en, this message translates to:
  /// **'Call now'**
  String get actionCallNow;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionContactOwner.
  ///
  /// In en, this message translates to:
  /// **'Contact the owner'**
  String get actionContactOwner;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

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

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionDiscardAll.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscardAll;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionFavourite.
  ///
  /// In en, this message translates to:
  /// **'Save to favourites'**
  String get actionFavourite;

  /// No description provided for @actionLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get actionLoadMore;

  /// No description provided for @actionMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get actionMove;

  /// No description provided for @actionOrderNow.
  ///
  /// In en, this message translates to:
  /// **'Order now'**
  String get actionOrderNow;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get actionSelectImage;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionUnfavourite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get actionUnfavourite;

  /// No description provided for @actionViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get actionViewDetails;

  /// No description provided for @adminAbout.
  ///
  /// In en, this message translates to:
  /// **'About the store'**
  String get adminAbout;

  /// No description provided for @adminAccount.
  ///
  /// In en, this message translates to:
  /// **'Owner account'**
  String get adminAccount;

  /// No description provided for @adminAddContact.
  ///
  /// In en, this message translates to:
  /// **'Add link'**
  String get adminAddContact;

  /// No description provided for @adminAddImages.
  ///
  /// In en, this message translates to:
  /// **'Add images'**
  String get adminAddImages;

  /// No description provided for @adminAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get adminAddProduct;

  /// No description provided for @adminAddVideo.
  ///
  /// In en, this message translates to:
  /// **'Add video'**
  String get adminAddVideo;

  /// No description provided for @adminAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get adminAnonymous;

  /// No description provided for @adminBackToGateway.
  ///
  /// In en, this message translates to:
  /// **'Back to gateway'**
  String get adminBackToGateway;

  /// No description provided for @adminCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get adminCategories;

  /// No description provided for @adminCategoryAddSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Add subcategory'**
  String get adminCategoryAddSubcategory;

  /// No description provided for @adminCategoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created'**
  String get adminCategoryCreated;

  /// No description provided for @adminCategoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get adminCategoryDeleted;

  /// No description provided for @adminCategoryHasProducts.
  ///
  /// In en, this message translates to:
  /// **'This category still has {count} products. Move them to another category first, or delete the products.'**
  String adminCategoryHasProducts(int count);

  /// No description provided for @adminCategoryHasSubcategories.
  ///
  /// In en, this message translates to:
  /// **'This category still has subcategories. Delete them first.'**
  String get adminCategoryHasSubcategories;

  /// No description provided for @adminCategoryHidden.
  ///
  /// In en, this message translates to:
  /// **'Category hidden'**
  String get adminCategoryHidden;

  /// No description provided for @adminCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get adminCategoryName;

  /// No description provided for @adminCategoryNameAm.
  ///
  /// In en, this message translates to:
  /// **'Name (Amharic)'**
  String get adminCategoryNameAm;

  /// No description provided for @adminCategoryNameAr.
  ///
  /// In en, this message translates to:
  /// **'Name (Arabic)'**
  String get adminCategoryNameAr;

  /// No description provided for @adminCategoryNameOm.
  ///
  /// In en, this message translates to:
  /// **'Name (Oromo)'**
  String get adminCategoryNameOm;

  /// No description provided for @adminCategoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get adminCategoryUpdated;

  /// No description provided for @adminChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get adminChangePassword;

  /// No description provided for @adminChannel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get adminChannel;

  /// No description provided for @adminClearInquiries.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get adminClearInquiries;

  /// No description provided for @adminCompareAtPrice.
  ///
  /// In en, this message translates to:
  /// **'Compare-at price (optional)'**
  String get adminCompareAtPrice;

  /// No description provided for @adminConfirmDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete this category?'**
  String get adminConfirmDeleteCategory;

  /// No description provided for @adminConfirmDeleteContact.
  ///
  /// In en, this message translates to:
  /// **'Remove this link?'**
  String get adminConfirmDeleteContact;

  /// No description provided for @adminConfirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get adminConfirmDeleteMessage;

  /// No description provided for @adminConfirmDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete this product?'**
  String get adminConfirmDeleteProduct;

  /// No description provided for @adminConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get adminConfirmPassword;

  /// No description provided for @adminContactDeleted.
  ///
  /// In en, this message translates to:
  /// **'Link removed'**
  String get adminContactDeleted;

  /// No description provided for @adminContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get adminContactLabel;

  /// No description provided for @adminContactSaved.
  ///
  /// In en, this message translates to:
  /// **'Link saved'**
  String get adminContactSaved;

  /// No description provided for @adminContactValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get adminContactValue;

  /// No description provided for @adminContacts.
  ///
  /// In en, this message translates to:
  /// **'Contact links'**
  String get adminContacts;

  /// No description provided for @adminCover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get adminCover;

  /// No description provided for @adminCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Cover image'**
  String get adminCoverImage;

  /// No description provided for @adminCreateCategory.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get adminCreateCategory;

  /// No description provided for @adminCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get adminCurrency;

  /// No description provided for @adminCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get adminCurrentPassword;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboard;

  /// No description provided for @adminDefaultLanguage.
  ///
  /// In en, this message translates to:
  /// **'Default language'**
  String get adminDefaultLanguage;

  /// No description provided for @adminDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get adminDiscard;

  /// No description provided for @adminDragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get adminDragToReorder;

  /// No description provided for @adminDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get adminDuplicate;

  /// No description provided for @adminDuplicateCreated.
  ///
  /// In en, this message translates to:
  /// **'Copy created'**
  String get adminDuplicateCreated;

  /// No description provided for @adminEditCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get adminEditCategory;

  /// No description provided for @adminEditContact.
  ///
  /// In en, this message translates to:
  /// **'Edit link'**
  String get adminEditContact;

  /// No description provided for @adminEditProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get adminEditProduct;

  /// No description provided for @adminEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminEmailLabel;

  /// No description provided for @adminExitPreview.
  ///
  /// In en, this message translates to:
  /// **'Exit preview'**
  String get adminExitPreview;

  /// No description provided for @adminFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get adminFeatured;

  /// No description provided for @adminFilterAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get adminFilterAllCategories;

  /// No description provided for @adminFilterAllStatus.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminFilterAllStatus;

  /// No description provided for @adminFilterDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get adminFilterDraft;

  /// No description provided for @adminFilterPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get adminFilterPublished;

  /// No description provided for @adminForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get adminForgotPassword;

  /// No description provided for @adminGatewayTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin gateway'**
  String get adminGatewayTitle;

  /// No description provided for @adminHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get adminHide;

  /// No description provided for @adminInquiries.
  ///
  /// In en, this message translates to:
  /// **'Inquiries'**
  String get adminInquiries;

  /// No description provided for @adminInquiriesWeek.
  ///
  /// In en, this message translates to:
  /// **'Inquiries this week'**
  String get adminInquiriesWeek;

  /// No description provided for @adminInquiryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Inquiry cleared'**
  String get adminInquiryDeleted;

  /// No description provided for @adminJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get adminJustNow;

  /// No description provided for @adminKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get adminKeepEditing;

  /// No description provided for @adminLiveEdit.
  ///
  /// In en, this message translates to:
  /// **'Live edit'**
  String get adminLiveEdit;

  /// No description provided for @adminLiveEditOff.
  ///
  /// In en, this message translates to:
  /// **'Live editing off'**
  String get adminLiveEditOff;

  /// No description provided for @adminLiveEditOn.
  ///
  /// In en, this message translates to:
  /// **'Live editing on — tap a pencil to rewrite that text'**
  String get adminLiveEditOn;

  /// No description provided for @adminLivePreview.
  ///
  /// In en, this message translates to:
  /// **'Customer preview'**
  String get adminLivePreview;

  /// No description provided for @adminLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This area is restricted to the shop owner.'**
  String get adminLoginSubtitle;

  /// No description provided for @adminLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner sign in'**
  String get adminLoginTitle;

  /// No description provided for @adminLogoPreview.
  ///
  /// In en, this message translates to:
  /// **'Logo preview'**
  String get adminLogoPreview;

  /// No description provided for @adminMarkPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary link'**
  String get adminMarkPrimary;

  /// No description provided for @adminMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get adminMedia;

  /// No description provided for @adminMostContacted.
  ///
  /// In en, this message translates to:
  /// **'Most contacted'**
  String get adminMostContacted;

  /// No description provided for @adminMoveProductsTo.
  ///
  /// In en, this message translates to:
  /// **'Move products to'**
  String get adminMoveProductsTo;

  /// No description provided for @adminNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get adminNewPassword;

  /// No description provided for @adminNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet. Create the first one to group your products.'**
  String get adminNoCategories;

  /// No description provided for @adminNoContacts.
  ///
  /// In en, this message translates to:
  /// **'No contact links yet. Customers reach you through these.'**
  String get adminNoContacts;

  /// No description provided for @adminNoInquiries.
  ///
  /// In en, this message translates to:
  /// **'No inquiries yet. Customer taps on a contact button will show up here.'**
  String get adminNoInquiries;

  /// No description provided for @adminNoInquiriesYet.
  ///
  /// In en, this message translates to:
  /// **'No customer taps recorded yet. They will appear here as soon as someone taps a contact button.'**
  String get adminNoInquiriesYet;

  /// No description provided for @adminNoMedia.
  ///
  /// In en, this message translates to:
  /// **'No images or videos yet.'**
  String get adminNoMedia;

  /// No description provided for @adminNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet. Add your first piece to the catalogue.'**
  String get adminNoProducts;

  /// No description provided for @adminNoProductsMatch.
  ///
  /// In en, this message translates to:
  /// **'No products match your filters.'**
  String get adminNoProductsMatch;

  /// No description provided for @adminNotAuthorised.
  ///
  /// In en, this message translates to:
  /// **'This account is not an administrator.'**
  String get adminNotAuthorised;

  /// No description provided for @adminOtherSessionsSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Other sessions were signed out.'**
  String get adminOtherSessionsSignedOut;

  /// No description provided for @adminPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated.'**
  String get adminPasswordChanged;

  /// No description provided for @adminPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminPasswordLabel;

  /// No description provided for @adminPreviewAsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Preview as customer'**
  String get adminPreviewAsCustomer;

  /// No description provided for @adminPreviewBadge.
  ///
  /// In en, this message translates to:
  /// **'Previewing as customer'**
  String get adminPreviewBadge;

  /// No description provided for @adminPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get adminPrice;

  /// No description provided for @adminPrimaryBadge.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get adminPrimaryBadge;

  /// No description provided for @adminProductColumn.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get adminProductColumn;

  /// No description provided for @adminProductDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get adminProductDeleted;

  /// No description provided for @adminProductDescriptionAr.
  ///
  /// In en, this message translates to:
  /// **'Description (Arabic)'**
  String get adminProductDescriptionAr;

  /// No description provided for @adminProductDescriptionAm.
  ///
  /// In en, this message translates to:
  /// **'Description (Amharic)'**
  String get adminProductDescriptionAm;

  /// No description provided for @adminProductDescriptionOm.
  ///
  /// In en, this message translates to:
  /// **'Description (Oromo)'**
  String get adminProductDescriptionOm;

  /// No description provided for @adminProductDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (English)'**
  String get adminProductDescription;

  /// No description provided for @adminProductSaved.
  ///
  /// In en, this message translates to:
  /// **'Product saved'**
  String get adminProductSaved;

  /// No description provided for @adminProductTitleAr.
  ///
  /// In en, this message translates to:
  /// **'Title (Arabic)'**
  String get adminProductTitleAr;

  /// No description provided for @adminProductTitleAm.
  ///
  /// In en, this message translates to:
  /// **'Title (Amharic)'**
  String get adminProductTitleAm;

  /// No description provided for @adminProductTitleOm.
  ///
  /// In en, this message translates to:
  /// **'Title (Oromo)'**
  String get adminProductTitleOm;

  /// No description provided for @adminProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Title (English)'**
  String get adminProductTitle;

  /// No description provided for @adminProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get adminProducts;

  /// No description provided for @adminPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get adminPublish;

  /// No description provided for @adminQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get adminQuickActions;

  /// No description provided for @adminReauthPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password to confirm this change.'**
  String get adminReauthPrompt;

  /// No description provided for @adminRemoveMedia.
  ///
  /// In en, this message translates to:
  /// **'Remove media'**
  String get adminRemoveMedia;

  /// No description provided for @adminResetSent.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox for a reset link.'**
  String get adminResetSent;

  /// No description provided for @adminSaveAndPublish.
  ///
  /// In en, this message translates to:
  /// **'Save and publish'**
  String get adminSaveAndPublish;

  /// No description provided for @adminSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get adminSaveDraft;

  /// No description provided for @adminSearchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get adminSearchProducts;

  /// No description provided for @adminSectionSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming in the next screen'**
  String get adminSectionSoon;

  /// No description provided for @adminSetCover.
  ///
  /// In en, this message translates to:
  /// **'Set as cover'**
  String get adminSetCover;

  /// No description provided for @adminShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get adminShow;

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

  /// No description provided for @adminSignOutOthers.
  ///
  /// In en, this message translates to:
  /// **'Sign out other sessions'**
  String get adminSignOutOthers;

  /// No description provided for @adminSiteSettings.
  ///
  /// In en, this message translates to:
  /// **'Site settings'**
  String get adminSiteSettings;

  /// No description provided for @adminSiteSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get adminSiteSettingsSaved;

  /// No description provided for @adminSlug.
  ///
  /// In en, this message translates to:
  /// **'URL slug'**
  String get adminSlug;

  /// No description provided for @adminSlugAuto.
  ///
  /// In en, this message translates to:
  /// **'Generated from the English name if left empty.'**
  String get adminSlugAuto;

  /// No description provided for @adminSortOrderHint.
  ///
  /// In en, this message translates to:
  /// **'Shown in the order below.'**
  String get adminSortOrderHint;

  /// No description provided for @adminStatsCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get adminStatsCategories;

  /// No description provided for @adminStatsProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get adminStatsProducts;

  /// No description provided for @adminStoreName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get adminStoreName;

  /// No description provided for @adminStoreNameAm.
  ///
  /// In en, this message translates to:
  /// **'Store name (Amharic)'**
  String get adminStoreNameAm;

  /// No description provided for @adminStoreNameAr.
  ///
  /// In en, this message translates to:
  /// **'Store name (Arabic)'**
  String get adminStoreNameAr;

  /// No description provided for @adminStoreNameOm.
  ///
  /// In en, this message translates to:
  /// **'Store name (Oromo)'**
  String get adminStoreNameOm;

  /// No description provided for @adminStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get adminStrength;

  /// No description provided for @adminStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get adminStrengthFair;

  /// No description provided for @adminStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get adminStrengthStrong;

  /// No description provided for @adminStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get adminStrengthWeak;

  /// No description provided for @adminSystemCheck.
  ///
  /// In en, this message translates to:
  /// **'System check'**
  String get adminSystemCheck;

  /// No description provided for @adminTagline.
  ///
  /// In en, this message translates to:
  /// **'Tagline'**
  String get adminTagline;

  /// No description provided for @adminTextEditor.
  ///
  /// In en, this message translates to:
  /// **'Text & language'**
  String get adminTextEditor;

  /// No description provided for @adminTextEditorAllScreens.
  ///
  /// In en, this message translates to:
  /// **'All screens'**
  String get adminTextEditorAllScreens;

  /// No description provided for @adminTextEditorHasVariables.
  ///
  /// In en, this message translates to:
  /// **'Has variables'**
  String get adminTextEditorHasVariables;

  /// No description provided for @adminTextEditorHint.
  ///
  /// In en, this message translates to:
  /// **'Every word of the app, in every language. Edit one and it changes everywhere.'**
  String get adminTextEditorHint;

  /// No description provided for @adminTextEditorMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing words'**
  String get adminTextEditorMissing;

  /// No description provided for @adminTextEditorMissingDone.
  ///
  /// In en, this message translates to:
  /// **'Nothing is missing in this language'**
  String get adminTextEditorMissingDone;

  /// No description provided for @adminTextEditorMissingHint.
  ///
  /// In en, this message translates to:
  /// **'Only the words still showing English in this language — fill them in one by one.'**
  String get adminTextEditorMissingHint;

  /// No description provided for @adminTextEditorNoResults.
  ///
  /// In en, this message translates to:
  /// **'No text matches your search'**
  String get adminTextEditorNoResults;

  /// No description provided for @adminTextEditorPlaceholderHint.
  ///
  /// In en, this message translates to:
  /// **'Keep the variables in brackets exactly as written.'**
  String get adminTextEditorPlaceholderHint;

  /// No description provided for @adminTextEditorReset.
  ///
  /// In en, this message translates to:
  /// **'Restore default'**
  String get adminTextEditorReset;

  /// No description provided for @adminTextEditorResetDone.
  ///
  /// In en, this message translates to:
  /// **'Default wording restored'**
  String get adminTextEditorResetDone;

  /// No description provided for @adminTextEditorSaved.
  ///
  /// In en, this message translates to:
  /// **'Text saved'**
  String get adminTextEditorSaved;

  /// No description provided for @adminTextEditorSearch.
  ///
  /// In en, this message translates to:
  /// **'Search a word'**
  String get adminTextEditorSearch;

  /// No description provided for @adminUnpublish.
  ///
  /// In en, this message translates to:
  /// **'Unpublish'**
  String get adminUnpublish;

  /// No description provided for @adminUnpublished.
  ///
  /// In en, this message translates to:
  /// **'Unpublished'**
  String get adminUnpublished;

  /// No description provided for @adminUnsavedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Leaving now will lose them.'**
  String get adminUnsavedMessage;

  /// No description provided for @adminUnsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get adminUnsavedTitle;

  /// No description provided for @adminUploadLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload logo'**
  String get adminUploadLogo;

  /// No description provided for @adminUploadQueue.
  ///
  /// In en, this message translates to:
  /// **'Upload queue'**
  String get adminUploadQueue;

  /// No description provided for @adminUploadRetrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying…'**
  String get adminUploadRetrying;

  /// No description provided for @adminUploadingCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} uploaded'**
  String adminUploadingCount(int done, int total);

  /// No description provided for @adminViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get adminViewAll;

  /// No description provided for @adminViewStore.
  ///
  /// In en, this message translates to:
  /// **'View store'**
  String get adminViewStore;

  /// No description provided for @adminVisibleInStore.
  ///
  /// In en, this message translates to:
  /// **'Visible in store'**
  String get adminVisibleInStore;

  /// No description provided for @adminWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get adminWhen;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Amu Sharif Arabiyan Majlis'**
  String get appTitle;

  /// No description provided for @brandMonogram.
  ///
  /// In en, this message translates to:
  /// **'ASM'**
  String get brandMonogram;

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

  /// No description provided for @brandNameEn.
  ///
  /// In en, this message translates to:
  /// **'Amu Sharif Arabiyan Majlis'**
  String get brandNameEn;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactEmail;

  /// No description provided for @contactFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get contactFacebook;

  /// No description provided for @contactInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get contactInstagram;

  /// No description provided for @contactLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open that link on this device.'**
  String get contactLaunchFailed;

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

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactPhone;

  /// No description provided for @contactTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get contactTelegram;

  /// No description provided for @contactTikTok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get contactTikTok;

  /// No description provided for @contactWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get contactWebsite;

  /// No description provided for @contactWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get contactWhatsApp;

  /// No description provided for @contactYouTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get contactYouTube;

  /// No description provided for @errorAuth.
  ///
  /// In en, this message translates to:
  /// **'We could not sign you in.'**
  String get errorAuth;

  /// No description provided for @errorBackendNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'The database is not set up on this build\'s server yet. Open the owner gateway\'s system check to see what to run.'**
  String get errorBackendNotSetUp;

  /// No description provided for @errorCheckViolation.
  ///
  /// In en, this message translates to:
  /// **'A value is outside the allowed range.'**
  String get errorCheckViolation;

  /// No description provided for @errorConstraintViolation.
  ///
  /// In en, this message translates to:
  /// **'Some values are not allowed.'**
  String get errorConstraintViolation;

  /// No description provided for @errorDuplicate.
  ///
  /// In en, this message translates to:
  /// **'That value is already in use.'**
  String get errorDuplicate;

  /// No description provided for @errorEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email address before signing in.'**
  String get errorEmailNotConfirmed;

  /// No description provided for @errorForeignKey.
  ///
  /// In en, this message translates to:
  /// **'Related data is missing.'**
  String get errorForeignKey;

  /// No description provided for @errorGateLocked.
  ///
  /// In en, this message translates to:
  /// **'Incorrect username or password.'**
  String get errorGateLocked;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'That value is not in the expected format.'**
  String get errorInvalidFormat;

  /// No description provided for @errorMedia.
  ///
  /// In en, this message translates to:
  /// **'That file could not be processed.'**
  String get errorMedia;

  /// No description provided for @errorMediaImageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Images must be 5 MB or smaller after compression.'**
  String get errorMediaImageTooLarge;

  /// No description provided for @errorMediaUnsupportedImage.
  ///
  /// In en, this message translates to:
  /// **'Use a JPG, PNG or WebP image.'**
  String get errorMediaUnsupportedImage;

  /// No description provided for @errorMediaUnsupportedVideo.
  ///
  /// In en, this message translates to:
  /// **'Use an MP4 video.'**
  String get errorMediaUnsupportedVideo;

  /// No description provided for @errorMediaVideoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Videos must be 40 MB or smaller.'**
  String get errorMediaVideoTooLarge;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'We could not reach the store. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorNotAdmin.
  ///
  /// In en, this message translates to:
  /// **'This account is signed in but is not flagged as the shop owner. Run: update public.profiles set is_admin = true where id = \'<your user id>\';'**
  String get errorNotAdmin;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We could not find what you were looking for.'**
  String get errorNotFound;

  /// No description provided for @errorNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'The owner database account is not connected. Open the owner panel (tap the logo five times) and sign in.'**
  String get errorNotSignedIn;

  /// No description provided for @errorPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get errorPermission;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The service is temporarily unavailable. Please try again.'**
  String get errorServer;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get errorSessionExpired;

  /// No description provided for @errorStorage.
  ///
  /// In en, this message translates to:
  /// **'The file could not be uploaded.'**
  String get errorStorage;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get errorTooManyAttempts;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected happened. Please try again.'**
  String get errorUnknown;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please correct the highlighted fields.'**
  String get errorValidation;

  /// No description provided for @favouritesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a piece to keep it here.'**
  String get favouritesEmptyMessage;

  /// No description provided for @favouritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get favouritesEmptyTitle;

  /// No description provided for @gateChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Gateway password'**
  String get gateChangeTitle;

  /// No description provided for @gateChangeIntro.
  ///
  /// In en, this message translates to:
  /// **'This password opens the owner panel on this device. Change it whenever you like.'**
  String get gateChangeIntro;

  /// No description provided for @gateChanged.
  ///
  /// In en, this message translates to:
  /// **'Gateway password updated.'**
  String get gateChanged;

  /// No description provided for @gateHint.
  ///
  /// In en, this message translates to:
  /// **'Tip: tap the logo five times to reopen this panel.'**
  String get gateHint;

  /// No description provided for @gateLocked.
  ///
  /// In en, this message translates to:
  /// **'Incorrect username or password.'**
  String get gateLocked;

  /// No description provided for @gateOwnerEmail.
  ///
  /// In en, this message translates to:
  /// **'Owner e-mail'**
  String get gateOwnerEmail;

  /// No description provided for @gateOwnerHint.
  ///
  /// In en, this message translates to:
  /// **'Needed once per device: the panel password alone cannot authorise a database write. Sign in with the shop owner\'s e-mail and password.'**
  String get gateOwnerHint;

  /// No description provided for @gateOwnerPassword.
  ///
  /// In en, this message translates to:
  /// **'Owner password'**
  String get gateOwnerPassword;

  /// No description provided for @gateOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner database account'**
  String get gateOwnerTitle;

  /// No description provided for @gateTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner access'**
  String get gateTitle;

  /// No description provided for @gateUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get gateUnlock;

  /// No description provided for @gateUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Owner access unlocked.'**
  String get gateUnlocked;

  /// No description provided for @gateUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get gateUsername;

  /// No description provided for @groupCommon.
  ///
  /// In en, this message translates to:
  /// **'Shared words'**
  String get groupCommon;

  /// No description provided for @groupErrors.
  ///
  /// In en, this message translates to:
  /// **'Errors & states'**
  String get groupErrors;

  /// No description provided for @groupStorefront.
  ///
  /// In en, this message translates to:
  /// **'Storefront screens'**
  String get groupStorefront;

  /// No description provided for @groupValidation.
  ///
  /// In en, this message translates to:
  /// **'Validation messages'**
  String get groupValidation;

  /// No description provided for @inquiryMessageTemplate.
  ///
  /// In en, this message translates to:
  /// **'Hello! I am interested in “{product}” ({price}).'**
  String inquiryMessageTemplate(String price, String product);

  /// No description provided for @labelAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get labelAvailable;

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

  /// No description provided for @labelFrom.
  ///
  /// In en, this message translates to:
  /// **'From {price}'**
  String labelFrom(String price);

  /// No description provided for @labelPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get labelPrice;

  /// No description provided for @labelUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get labelUnavailable;

  /// No description provided for @navAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navAbout;

  /// No description provided for @navAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get navAdmin;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get navContact;

  /// No description provided for @navFavourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get navFavourites;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

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

  /// No description provided for @sectionAllProducts.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get sectionAllProducts;

  /// No description provided for @sectionBrowseCategories.
  ///
  /// In en, this message translates to:
  /// **'Browse by category'**
  String get sectionBrowseCategories;

  /// No description provided for @sectionFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get sectionFeatured;

  /// No description provided for @sectionNewArrivals.
  ///
  /// In en, this message translates to:
  /// **'New arrivals'**
  String get sectionNewArrivals;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

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

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @stateEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'New pieces will appear here as soon as the owner publishes them.'**
  String get stateEmptyMessage;

  /// No description provided for @stateEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get stateEmptyTitle;

  /// No description provided for @stateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get stateErrorTitle;

  /// No description provided for @stateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get stateLoading;

  /// No description provided for @stateNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get stateNoResults;

  /// No description provided for @stateNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'That link does not exist any more.'**
  String get stateNotFoundMessage;

  /// No description provided for @stateNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get stateNotFoundTitle;

  /// No description provided for @stateOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Check your connection and try again.'**
  String get stateOffline;

  /// No description provided for @stateSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get stateSaved;

  /// No description provided for @stateSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get stateSaving;

  /// No description provided for @systemCheckAccount.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get systemCheckAccount;

  /// No description provided for @systemCheckAllGood.
  ///
  /// In en, this message translates to:
  /// **'Everything this build needs is present on the backend.'**
  String get systemCheckAllGood;

  /// No description provided for @systemCheckBuild.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get systemCheckBuild;

  /// No description provided for @systemCheckFixDatabase.
  ///
  /// In en, this message translates to:
  /// **'supabase db push — applies every table, bucket and policy'**
  String get systemCheckFixDatabase;

  /// No description provided for @systemCheckFixFunction.
  ///
  /// In en, this message translates to:
  /// **'supabase functions deploy inquiry — deploys the contact endpoint'**
  String get systemCheckFixFunction;

  /// No description provided for @systemCheckFixNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check the Supabase project URL in this build\'s config and your internet connection.'**
  String get systemCheckFixNetwork;

  /// No description provided for @systemCheckFixSeed.
  ///
  /// In en, this message translates to:
  /// **'supabase db seed — adds the starter rows'**
  String get systemCheckFixSeed;

  /// No description provided for @systemCheckMissing.
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get systemCheckMissing;

  /// No description provided for @systemCheckMissingSummary.
  ///
  /// In en, this message translates to:
  /// **'Some of what this build needs is missing on the backend. Run these in the project folder, then run the checks again:'**
  String get systemCheckMissingSummary;

  /// No description provided for @systemCheckNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get systemCheckNotSignedIn;

  /// No description provided for @systemCheckOk.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get systemCheckOk;

  /// No description provided for @systemCheckProject.
  ///
  /// In en, this message translates to:
  /// **'Supabase project'**
  String get systemCheckProject;

  /// No description provided for @systemCheckRestricted.
  ///
  /// In en, this message translates to:
  /// **'Ready · restricted'**
  String get systemCheckRestricted;

  /// No description provided for @systemCheckRun.
  ///
  /// In en, this message translates to:
  /// **'Run checks again'**
  String get systemCheckRun;

  /// No description provided for @systemCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'System check'**
  String get systemCheckTitle;

  /// No description provided for @systemCheckUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Unreachable'**
  String get systemCheckUnreachable;

  /// No description provided for @systemCheckUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get systemCheckUnknown;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Luxury Arabic majlis & sofas, handcrafted for your home'**
  String get tagline;

  /// No description provided for @validateCompareAtPrice.
  ///
  /// In en, this message translates to:
  /// **'Original price must be at least the selling price'**
  String get validateCompareAtPrice;

  /// No description provided for @validateEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validateEmail;

  /// No description provided for @validateNegative.
  ///
  /// In en, this message translates to:
  /// **'Value cannot be negative'**
  String get validateNegative;

  /// No description provided for @validateNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validateNumber;

  /// No description provided for @validatePasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least 10 characters'**
  String get validatePasswordLength;

  /// No description provided for @validatePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validatePasswordMismatch;

  /// No description provided for @validatePasswordStrength.
  ///
  /// In en, this message translates to:
  /// **'Include an uppercase letter, a lowercase letter and a number'**
  String get validatePasswordStrength;

  /// No description provided for @validatePhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validatePhone;

  /// No description provided for @validatePositive.
  ///
  /// In en, this message translates to:
  /// **'Value must be greater than zero'**
  String get validatePositive;

  /// No description provided for @validateRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validateRequired;

  /// No description provided for @validateSlug.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase letters, numbers and hyphens only'**
  String get validateSlug;

  /// No description provided for @validateTelegramHandle.
  ///
  /// In en, this message translates to:
  /// **'Enter a Telegram handle like @username or a t.me link'**
  String get validateTelegramHandle;

  /// No description provided for @validateTooLong.
  ///
  /// In en, this message translates to:
  /// **'This value is too long'**
  String get validateTooLong;

  /// No description provided for @validateTooShort.
  ///
  /// In en, this message translates to:
  /// **'This value is too short'**
  String get validateTooShort;

  /// No description provided for @validateUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid link starting with https://'**
  String get validateUrl;

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

  /// No description provided for @adminSiteContent.
  ///
  /// In en, this message translates to:
  /// **'Site content'**
  String get adminSiteContent;

  /// No description provided for @adminSiteContentHint.
  ///
  /// In en, this message translates to:
  /// **'Rewrite the words customers see on the home screen before the built-in wording.'**
  String get adminSiteContentHint;

  /// No description provided for @adminSiteContentValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get adminSiteContentValue;

  /// No description provided for @adminContactSettings.
  ///
  /// In en, this message translates to:
  /// **'Contact settings'**
  String get adminContactSettings;

  /// No description provided for @adminContactSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'The channels customers can use to reach you. Leave a field empty to hide it.'**
  String get adminContactSettingsHint;

  /// No description provided for @adminOwnerPhone.
  ///
  /// In en, this message translates to:
  /// **'Owner phone (tel:)'**
  String get adminOwnerPhone;

  /// No description provided for @adminOwnerEmail.
  ///
  /// In en, this message translates to:
  /// **'Owner e-mail'**
  String get adminOwnerEmail;

  /// No description provided for @adminWhatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get adminWhatsappNumber;

  /// No description provided for @adminTelegramHandle.
  ///
  /// In en, this message translates to:
  /// **'Telegram handle'**
  String get adminTelegramHandle;

  /// No description provided for @adminInstagramHandle.
  ///
  /// In en, this message translates to:
  /// **'Instagram handle'**
  String get adminInstagramHandle;

  /// No description provided for @adminFacebookHandle.
  ///
  /// In en, this message translates to:
  /// **'Facebook handle'**
  String get adminFacebookHandle;

  /// No description provided for @adminTiktokHandle.
  ///
  /// In en, this message translates to:
  /// **'TikTok handle'**
  String get adminTiktokHandle;

  /// No description provided for @adminYoutubeHandle.
  ///
  /// In en, this message translates to:
  /// **'YouTube handle or URL'**
  String get adminYoutubeHandle;

  /// No description provided for @adminWebsiteUrl.
  ///
  /// In en, this message translates to:
  /// **'Website URL'**
  String get adminWebsiteUrl;

  /// No description provided for @contactOwnerHint.
  ///
  /// In en, this message translates to:
  /// **'Reach the owner directly about this piece.'**
  String get contactOwnerHint;
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
      <String>['am', 'ar', 'en', 'om'].contains(locale.languageCode);

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
    case 'om':
      return AppLocalizationsOm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
