// GENERATED FILE — DO NOT EDIT BY HAND.
//
// Run `dart run tool/gen_text_overlay.dart` after changing any
// lib/l10n/app_*.arb file or regenerating the localizations.
// ignore_for_file: type=lint

import 'generated/app_localizations.dart';

/// [AppLocalizations] that renders the owner's own wording where
/// one exists and the shipped ARB wording everywhere else.
///
/// Every screen already reads its strings through
/// `AppLocalizations.of(context)`, so wrapping that instance is what
/// makes an edit appear on all of them at once.
class OverridableAppLocalizations extends AppLocalizations {
  OverridableAppLocalizations(this._base, this._overrides)
    : super(_base.localeName);

  final AppLocalizations _base;

  /// The owner's wording for THIS locale, keyed by ARB key.
  final Map<String, String> _overrides;

  /// Whether the owner has rewritten [key] for this locale.
  bool owns(String key) => _overrides.containsKey(key);

  String _text(String key, String fallback) => _overrides[key] ?? fallback;

  /// Applies an override that carries `{variable}` placeholders, so
  /// a rewritten message still names the product it is about.
  String _filled(String key, String fallback, Map<String, String> params) {
    final String? override = _overrides[key];
    if (override == null) return fallback;
    String result = override;
    params.forEach((String name, String value) {
      result = result.replaceAll('{$name}', value);
    });
    return result;
  }

  @override
  String a11yOpenCategory(String name) => _filled(
    'a11yOpenCategory',
    _base.a11yOpenCategory(name),
    <String, String>{'name': '${name}'},
  );

  @override
  String a11yProductImage(String title) => _filled(
    'a11yProductImage',
    _base.a11yProductImage(title),
    <String, String>{'title': '${title}'},
  );

  @override
  String a11yVideoThumbnail(String title) => _filled(
    'a11yVideoThumbnail',
    _base.a11yVideoThumbnail(title),
    <String, String>{'title': '${title}'},
  );

  @override
  String get aboutFallback => _text('aboutFallback', _base.aboutFallback);

  @override
  String get actionAdd => _text('actionAdd', _base.actionAdd);

  @override
  String get actionCallNow => _text('actionCallNow', _base.actionCallNow);

  @override
  String get actionCancel => _text('actionCancel', _base.actionCancel);

  @override
  String get actionClear => _text('actionClear', _base.actionClear);

  @override
  String get actionClose => _text('actionClose', _base.actionClose);

  @override
  String get actionConfirm => _text('actionConfirm', _base.actionConfirm);

  @override
  String get actionContactOwner =>
      _text('actionContactOwner', _base.actionContactOwner);

  @override
  String get actionContinue => _text('actionContinue', _base.actionContinue);

  @override
  String get actionCopyLink => _text('actionCopyLink', _base.actionCopyLink);

  @override
  String get actionCopySuccess =>
      _text('actionCopySuccess', _base.actionCopySuccess);

  @override
  String get actionCreate => _text('actionCreate', _base.actionCreate);

  @override
  String get actionDelete => _text('actionDelete', _base.actionDelete);

  @override
  String get actionDiscardAll =>
      _text('actionDiscardAll', _base.actionDiscardAll);

  @override
  String get actionEdit => _text('actionEdit', _base.actionEdit);

  @override
  String get actionFavourite => _text('actionFavourite', _base.actionFavourite);

  @override
  String get actionMove => _text('actionMove', _base.actionMove);

  @override
  String get actionOrderNow => _text('actionOrderNow', _base.actionOrderNow);

  @override
  String get actionRetry => _text('actionRetry', _base.actionRetry);

  @override
  String get actionSave => _text('actionSave', _base.actionSave);

  @override
  String get actionSearch => _text('actionSearch', _base.actionSearch);

  @override
  String get actionSelectImage =>
      _text('actionSelectImage', _base.actionSelectImage);

  @override
  String get actionShare => _text('actionShare', _base.actionShare);

  @override
  String get actionUnfavourite =>
      _text('actionUnfavourite', _base.actionUnfavourite);

  @override
  String get actionViewDetails =>
      _text('actionViewDetails', _base.actionViewDetails);

  @override
  String get adminAbout => _text('adminAbout', _base.adminAbout);

  @override
  String get adminAccount => _text('adminAccount', _base.adminAccount);

  @override
  String get adminAddContact => _text('adminAddContact', _base.adminAddContact);

  @override
  String get adminAddImages => _text('adminAddImages', _base.adminAddImages);

  @override
  String get adminAddProduct => _text('adminAddProduct', _base.adminAddProduct);

  @override
  String get adminAddVideo => _text('adminAddVideo', _base.adminAddVideo);

  @override
  String get adminAnonymous => _text('adminAnonymous', _base.adminAnonymous);

  @override
  String get adminBackToGateway =>
      _text('adminBackToGateway', _base.adminBackToGateway);

  @override
  String get adminCategories => _text('adminCategories', _base.adminCategories);

  @override
  String get adminCategoryAddSubcategory =>
      _text('adminCategoryAddSubcategory', _base.adminCategoryAddSubcategory);

  @override
  String get adminCategoryCreated =>
      _text('adminCategoryCreated', _base.adminCategoryCreated);

  @override
  String get adminCategoryDeleted =>
      _text('adminCategoryDeleted', _base.adminCategoryDeleted);

  @override
  String adminCategoryHasProducts(int count) => _filled(
    'adminCategoryHasProducts',
    _base.adminCategoryHasProducts(count),
    <String, String>{'count': '${count}'},
  );

  @override
  String get adminCategoryHasSubcategories => _text(
    'adminCategoryHasSubcategories',
    _base.adminCategoryHasSubcategories,
  );

  @override
  String get adminCategoryHidden =>
      _text('adminCategoryHidden', _base.adminCategoryHidden);

  @override
  String get adminCategoryName =>
      _text('adminCategoryName', _base.adminCategoryName);

  @override
  String get adminCategoryNameAm =>
      _text('adminCategoryNameAm', _base.adminCategoryNameAm);

  @override
  String get adminCategoryNameAr =>
      _text('adminCategoryNameAr', _base.adminCategoryNameAr);

  @override
  String get adminCategoryUpdated =>
      _text('adminCategoryUpdated', _base.adminCategoryUpdated);

  @override
  String get adminChangePassword =>
      _text('adminChangePassword', _base.adminChangePassword);

  @override
  String get adminChannel => _text('adminChannel', _base.adminChannel);

  @override
  String get adminClearInquiries =>
      _text('adminClearInquiries', _base.adminClearInquiries);

  @override
  String get adminCompareAtPrice =>
      _text('adminCompareAtPrice', _base.adminCompareAtPrice);

  @override
  String get adminConfirmDeleteCategory =>
      _text('adminConfirmDeleteCategory', _base.adminConfirmDeleteCategory);

  @override
  String get adminConfirmDeleteContact =>
      _text('adminConfirmDeleteContact', _base.adminConfirmDeleteContact);

  @override
  String get adminConfirmDeleteMessage =>
      _text('adminConfirmDeleteMessage', _base.adminConfirmDeleteMessage);

  @override
  String get adminConfirmDeleteProduct =>
      _text('adminConfirmDeleteProduct', _base.adminConfirmDeleteProduct);

  @override
  String get adminConfirmPassword =>
      _text('adminConfirmPassword', _base.adminConfirmPassword);

  @override
  String get adminContactDeleted =>
      _text('adminContactDeleted', _base.adminContactDeleted);

  @override
  String get adminContactLabel =>
      _text('adminContactLabel', _base.adminContactLabel);

  @override
  String get adminContactSaved =>
      _text('adminContactSaved', _base.adminContactSaved);

  @override
  String get adminContactValue =>
      _text('adminContactValue', _base.adminContactValue);

  @override
  String get adminContacts => _text('adminContacts', _base.adminContacts);

  @override
  String get adminCover => _text('adminCover', _base.adminCover);

  @override
  String get adminCoverImage => _text('adminCoverImage', _base.adminCoverImage);

  @override
  String get adminCreateCategory =>
      _text('adminCreateCategory', _base.adminCreateCategory);

  @override
  String get adminCurrency => _text('adminCurrency', _base.adminCurrency);

  @override
  String get adminCurrentPassword =>
      _text('adminCurrentPassword', _base.adminCurrentPassword);

  @override
  String get adminDashboard => _text('adminDashboard', _base.adminDashboard);

  @override
  String get adminDefaultLanguage =>
      _text('adminDefaultLanguage', _base.adminDefaultLanguage);

  @override
  String get adminDiscard => _text('adminDiscard', _base.adminDiscard);

  @override
  String get adminDragToReorder =>
      _text('adminDragToReorder', _base.adminDragToReorder);

  @override
  String get adminDuplicate => _text('adminDuplicate', _base.adminDuplicate);

  @override
  String get adminDuplicateCreated =>
      _text('adminDuplicateCreated', _base.adminDuplicateCreated);

  @override
  String get adminEditCategory =>
      _text('adminEditCategory', _base.adminEditCategory);

  @override
  String get adminEditContact =>
      _text('adminEditContact', _base.adminEditContact);

  @override
  String get adminEditProduct =>
      _text('adminEditProduct', _base.adminEditProduct);

  @override
  String get adminEmailLabel => _text('adminEmailLabel', _base.adminEmailLabel);

  @override
  String get adminExitPreview =>
      _text('adminExitPreview', _base.adminExitPreview);

  @override
  String get adminFeatured => _text('adminFeatured', _base.adminFeatured);

  @override
  String get adminFilterAllCategories =>
      _text('adminFilterAllCategories', _base.adminFilterAllCategories);

  @override
  String get adminFilterAllStatus =>
      _text('adminFilterAllStatus', _base.adminFilterAllStatus);

  @override
  String get adminFilterDraft =>
      _text('adminFilterDraft', _base.adminFilterDraft);

  @override
  String get adminFilterPublished =>
      _text('adminFilterPublished', _base.adminFilterPublished);

  @override
  String get adminForgotPassword =>
      _text('adminForgotPassword', _base.adminForgotPassword);

  @override
  String get adminGatewayTitle =>
      _text('adminGatewayTitle', _base.adminGatewayTitle);

  @override
  String get adminHide => _text('adminHide', _base.adminHide);

  @override
  String get adminInquiries => _text('adminInquiries', _base.adminInquiries);

  @override
  String get adminInquiriesWeek =>
      _text('adminInquiriesWeek', _base.adminInquiriesWeek);

  @override
  String get adminInquiryDeleted =>
      _text('adminInquiryDeleted', _base.adminInquiryDeleted);

  @override
  String get adminJustNow => _text('adminJustNow', _base.adminJustNow);

  @override
  String get adminKeepEditing =>
      _text('adminKeepEditing', _base.adminKeepEditing);

  @override
  String get adminLiveEdit => _text('adminLiveEdit', _base.adminLiveEdit);

  @override
  String get adminLiveEditOff =>
      _text('adminLiveEditOff', _base.adminLiveEditOff);

  @override
  String get adminLiveEditOn => _text('adminLiveEditOn', _base.adminLiveEditOn);

  @override
  String get adminLivePreview =>
      _text('adminLivePreview', _base.adminLivePreview);

  @override
  String get adminLoginSubtitle =>
      _text('adminLoginSubtitle', _base.adminLoginSubtitle);

  @override
  String get adminLoginTitle => _text('adminLoginTitle', _base.adminLoginTitle);

  @override
  String get adminLogoPreview =>
      _text('adminLogoPreview', _base.adminLogoPreview);

  @override
  String get adminMarkPrimary =>
      _text('adminMarkPrimary', _base.adminMarkPrimary);

  @override
  String get adminMedia => _text('adminMedia', _base.adminMedia);

  @override
  String get adminMostContacted =>
      _text('adminMostContacted', _base.adminMostContacted);

  @override
  String get adminMoveProductsTo =>
      _text('adminMoveProductsTo', _base.adminMoveProductsTo);

  @override
  String get adminNewPassword =>
      _text('adminNewPassword', _base.adminNewPassword);

  @override
  String get adminNoCategories =>
      _text('adminNoCategories', _base.adminNoCategories);

  @override
  String get adminNoContacts => _text('adminNoContacts', _base.adminNoContacts);

  @override
  String get adminNoInquiries =>
      _text('adminNoInquiries', _base.adminNoInquiries);

  @override
  String get adminNoInquiriesYet =>
      _text('adminNoInquiriesYet', _base.adminNoInquiriesYet);

  @override
  String get adminNoMedia => _text('adminNoMedia', _base.adminNoMedia);

  @override
  String get adminNoProducts => _text('adminNoProducts', _base.adminNoProducts);

  @override
  String get adminNoProductsMatch =>
      _text('adminNoProductsMatch', _base.adminNoProductsMatch);

  @override
  String get adminNotAuthorised =>
      _text('adminNotAuthorised', _base.adminNotAuthorised);

  @override
  String get adminOtherSessionsSignedOut =>
      _text('adminOtherSessionsSignedOut', _base.adminOtherSessionsSignedOut);

  @override
  String get adminPasswordChanged =>
      _text('adminPasswordChanged', _base.adminPasswordChanged);

  @override
  String get adminPasswordLabel =>
      _text('adminPasswordLabel', _base.adminPasswordLabel);

  @override
  String get adminPreviewAsCustomer =>
      _text('adminPreviewAsCustomer', _base.adminPreviewAsCustomer);

  @override
  String get adminPreviewBadge =>
      _text('adminPreviewBadge', _base.adminPreviewBadge);

  @override
  String get adminPrice => _text('adminPrice', _base.adminPrice);

  @override
  String get adminPrimaryBadge =>
      _text('adminPrimaryBadge', _base.adminPrimaryBadge);

  @override
  String get adminProductColumn =>
      _text('adminProductColumn', _base.adminProductColumn);

  @override
  String get adminProductDeleted =>
      _text('adminProductDeleted', _base.adminProductDeleted);

  @override
  String get adminProductDescriptionAr =>
      _text('adminProductDescriptionAr', _base.adminProductDescriptionAr);

  @override
  String get adminProductDescriptionAm =>
      _text('adminProductDescriptionAm', _base.adminProductDescriptionAm);

  @override
  String get adminProductDescription =>
      _text('adminProductDescription', _base.adminProductDescription);

  @override
  String get adminProductSaved =>
      _text('adminProductSaved', _base.adminProductSaved);

  @override
  String get adminProductTitleAr =>
      _text('adminProductTitleAr', _base.adminProductTitleAr);

  @override
  String get adminProductTitleAm =>
      _text('adminProductTitleAm', _base.adminProductTitleAm);

  @override
  String get adminProductTitle =>
      _text('adminProductTitle', _base.adminProductTitle);

  @override
  String get adminProducts => _text('adminProducts', _base.adminProducts);

  @override
  String get adminPublish => _text('adminPublish', _base.adminPublish);

  @override
  String get adminQuickActions =>
      _text('adminQuickActions', _base.adminQuickActions);

  @override
  String get adminReauthPrompt =>
      _text('adminReauthPrompt', _base.adminReauthPrompt);

  @override
  String get adminRemoveMedia =>
      _text('adminRemoveMedia', _base.adminRemoveMedia);

  @override
  String get adminResetSent => _text('adminResetSent', _base.adminResetSent);

  @override
  String get adminSaveAndPublish =>
      _text('adminSaveAndPublish', _base.adminSaveAndPublish);

  @override
  String get adminSaveDraft => _text('adminSaveDraft', _base.adminSaveDraft);

  @override
  String get adminSearchProducts =>
      _text('adminSearchProducts', _base.adminSearchProducts);

  @override
  String get adminSectionSoon =>
      _text('adminSectionSoon', _base.adminSectionSoon);

  @override
  String get adminSetCover => _text('adminSetCover', _base.adminSetCover);

  @override
  String get adminShow => _text('adminShow', _base.adminShow);

  @override
  String get adminSignIn => _text('adminSignIn', _base.adminSignIn);

  @override
  String get adminSignOut => _text('adminSignOut', _base.adminSignOut);

  @override
  String get adminSignOutOthers =>
      _text('adminSignOutOthers', _base.adminSignOutOthers);

  @override
  String get adminSiteSettings =>
      _text('adminSiteSettings', _base.adminSiteSettings);

  @override
  String get adminSiteSettingsSaved =>
      _text('adminSiteSettingsSaved', _base.adminSiteSettingsSaved);

  @override
  String get adminSlug => _text('adminSlug', _base.adminSlug);

  @override
  String get adminSlugAuto => _text('adminSlugAuto', _base.adminSlugAuto);

  @override
  String get adminSortOrderHint =>
      _text('adminSortOrderHint', _base.adminSortOrderHint);

  @override
  String get adminStatsCategories =>
      _text('adminStatsCategories', _base.adminStatsCategories);

  @override
  String get adminStatsProducts =>
      _text('adminStatsProducts', _base.adminStatsProducts);

  @override
  String get adminStoreName => _text('adminStoreName', _base.adminStoreName);

  @override
  String get adminStoreNameAm =>
      _text('adminStoreNameAm', _base.adminStoreNameAm);

  @override
  String get adminStoreNameAr =>
      _text('adminStoreNameAr', _base.adminStoreNameAr);

  @override
  String get adminStoreNameOm =>
      _text('adminStoreNameOm', _base.adminStoreNameOm);

  @override
  String get adminStrength => _text('adminStrength', _base.adminStrength);

  @override
  String get adminStrengthFair =>
      _text('adminStrengthFair', _base.adminStrengthFair);

  @override
  String get adminStrengthStrong =>
      _text('adminStrengthStrong', _base.adminStrengthStrong);

  @override
  String get adminStrengthWeak =>
      _text('adminStrengthWeak', _base.adminStrengthWeak);

  @override
  String get adminSystemCheck =>
      _text('adminSystemCheck', _base.adminSystemCheck);

  @override
  String get adminTagline => _text('adminTagline', _base.adminTagline);

  @override
  String get adminTextEditor => _text('adminTextEditor', _base.adminTextEditor);

  @override
  String get adminTextEditorAllScreens =>
      _text('adminTextEditorAllScreens', _base.adminTextEditorAllScreens);

  @override
  String get adminTextEditorHasVariables =>
      _text('adminTextEditorHasVariables', _base.adminTextEditorHasVariables);

  @override
  String get adminTextEditorHint =>
      _text('adminTextEditorHint', _base.adminTextEditorHint);

  @override
  String get adminTextEditorMissing =>
      _text('adminTextEditorMissing', _base.adminTextEditorMissing);

  @override
  String get adminTextEditorMissingDone =>
      _text('adminTextEditorMissingDone', _base.adminTextEditorMissingDone);

  @override
  String get adminTextEditorMissingHint =>
      _text('adminTextEditorMissingHint', _base.adminTextEditorMissingHint);

  @override
  String get adminTextEditorNoResults =>
      _text('adminTextEditorNoResults', _base.adminTextEditorNoResults);

  @override
  String get adminTextEditorPlaceholderHint => _text(
    'adminTextEditorPlaceholderHint',
    _base.adminTextEditorPlaceholderHint,
  );

  @override
  String get adminTextEditorReset =>
      _text('adminTextEditorReset', _base.adminTextEditorReset);

  @override
  String get adminTextEditorResetDone =>
      _text('adminTextEditorResetDone', _base.adminTextEditorResetDone);

  @override
  String get adminTextEditorSaved =>
      _text('adminTextEditorSaved', _base.adminTextEditorSaved);

  @override
  String get adminTextEditorSearch =>
      _text('adminTextEditorSearch', _base.adminTextEditorSearch);

  @override
  String get adminUnpublish => _text('adminUnpublish', _base.adminUnpublish);

  @override
  String get adminUnpublished =>
      _text('adminUnpublished', _base.adminUnpublished);

  @override
  String get adminUnsavedMessage =>
      _text('adminUnsavedMessage', _base.adminUnsavedMessage);

  @override
  String get adminUnsavedTitle =>
      _text('adminUnsavedTitle', _base.adminUnsavedTitle);

  @override
  String get adminUploadLogo => _text('adminUploadLogo', _base.adminUploadLogo);

  @override
  String get adminUploadQueue =>
      _text('adminUploadQueue', _base.adminUploadQueue);

  @override
  String get adminUploadRetrying =>
      _text('adminUploadRetrying', _base.adminUploadRetrying);

  @override
  String adminUploadingCount(int done, int total) => _filled(
    'adminUploadingCount',
    _base.adminUploadingCount(done, total),
    <String, String>{'done': '${done}', 'total': '${total}'},
  );

  @override
  String get adminViewAll => _text('adminViewAll', _base.adminViewAll);

  @override
  String get adminViewStore => _text('adminViewStore', _base.adminViewStore);

  @override
  String get adminVisibleInStore =>
      _text('adminVisibleInStore', _base.adminVisibleInStore);

  @override
  String get adminWhen => _text('adminWhen', _base.adminWhen);

  @override
  String get appTitle => _text('appTitle', _base.appTitle);

  @override
  String get brandMonogram => _text('brandMonogram', _base.brandMonogram);

  @override
  String get brandNameAm => _text('brandNameAm', _base.brandNameAm);

  @override
  String get brandNameAr => _text('brandNameAr', _base.brandNameAr);

  @override
  String get brandNameEn => _text('brandNameEn', _base.brandNameEn);

  @override
  String get contactEmail => _text('contactEmail', _base.contactEmail);

  @override
  String get contactFacebook => _text('contactFacebook', _base.contactFacebook);

  @override
  String get contactInstagram =>
      _text('contactInstagram', _base.contactInstagram);

  @override
  String get contactLaunchFailed =>
      _text('contactLaunchFailed', _base.contactLaunchFailed);

  @override
  String get contactLocation => _text('contactLocation', _base.contactLocation);

  @override
  String get contactOther => _text('contactOther', _base.contactOther);

  @override
  String get contactPhone => _text('contactPhone', _base.contactPhone);

  @override
  String get contactTelegram => _text('contactTelegram', _base.contactTelegram);

  @override
  String get contactTikTok => _text('contactTikTok', _base.contactTikTok);

  @override
  String get contactWebsite => _text('contactWebsite', _base.contactWebsite);

  @override
  String get contactWhatsApp => _text('contactWhatsApp', _base.contactWhatsApp);

  @override
  String get contactYouTube => _text('contactYouTube', _base.contactYouTube);

  @override
  String get errorAuth => _text('errorAuth', _base.errorAuth);

  @override
  String get errorBackendNotSetUp =>
      _text('errorBackendNotSetUp', _base.errorBackendNotSetUp);

  @override
  String get errorCheckViolation =>
      _text('errorCheckViolation', _base.errorCheckViolation);

  @override
  String get errorConstraintViolation =>
      _text('errorConstraintViolation', _base.errorConstraintViolation);

  @override
  String get errorDuplicate => _text('errorDuplicate', _base.errorDuplicate);

  @override
  String get errorEmailNotConfirmed =>
      _text('errorEmailNotConfirmed', _base.errorEmailNotConfirmed);

  @override
  String get errorForeignKey => _text('errorForeignKey', _base.errorForeignKey);

  @override
  String get errorGateLocked => _text('errorGateLocked', _base.errorGateLocked);

  @override
  String get errorInvalidCredentials =>
      _text('errorInvalidCredentials', _base.errorInvalidCredentials);

  @override
  String get errorInvalidFormat =>
      _text('errorInvalidFormat', _base.errorInvalidFormat);

  @override
  String get errorMedia => _text('errorMedia', _base.errorMedia);

  @override
  String get errorMediaImageTooLarge =>
      _text('errorMediaImageTooLarge', _base.errorMediaImageTooLarge);

  @override
  String get errorMediaUnsupportedImage =>
      _text('errorMediaUnsupportedImage', _base.errorMediaUnsupportedImage);

  @override
  String get errorMediaUnsupportedVideo =>
      _text('errorMediaUnsupportedVideo', _base.errorMediaUnsupportedVideo);

  @override
  String get errorMediaVideoTooLarge =>
      _text('errorMediaVideoTooLarge', _base.errorMediaVideoTooLarge);

  @override
  String get errorNetwork => _text('errorNetwork', _base.errorNetwork);

  @override
  String get errorNotAdmin => _text('errorNotAdmin', _base.errorNotAdmin);

  @override
  String get errorNotFound => _text('errorNotFound', _base.errorNotFound);

  @override
  String get errorNotSignedIn =>
      _text('errorNotSignedIn', _base.errorNotSignedIn);

  @override
  String get errorPermission => _text('errorPermission', _base.errorPermission);

  @override
  String get errorServer => _text('errorServer', _base.errorServer);

  @override
  String get errorSessionExpired =>
      _text('errorSessionExpired', _base.errorSessionExpired);

  @override
  String get errorStorage => _text('errorStorage', _base.errorStorage);

  @override
  String get errorTimeout => _text('errorTimeout', _base.errorTimeout);

  @override
  String get errorTooManyAttempts =>
      _text('errorTooManyAttempts', _base.errorTooManyAttempts);

  @override
  String get errorUnknown => _text('errorUnknown', _base.errorUnknown);

  @override
  String get errorValidation => _text('errorValidation', _base.errorValidation);

  @override
  String get favouritesEmptyMessage =>
      _text('favouritesEmptyMessage', _base.favouritesEmptyMessage);

  @override
  String get favouritesEmptyTitle =>
      _text('favouritesEmptyTitle', _base.favouritesEmptyTitle);

  @override
  String get gateChangeTitle => _text('gateChangeTitle', _base.gateChangeTitle);

  @override
  String get gateChangeIntro => _text('gateChangeIntro', _base.gateChangeIntro);

  @override
  String get gateChanged => _text('gateChanged', _base.gateChanged);

  @override
  String get gateHint => _text('gateHint', _base.gateHint);

  @override
  String get gateLocked => _text('gateLocked', _base.gateLocked);

  @override
  String get gateOwnerEmail => _text('gateOwnerEmail', _base.gateOwnerEmail);

  @override
  String get gateOwnerHint => _text('gateOwnerHint', _base.gateOwnerHint);

  @override
  String get gateOwnerPassword =>
      _text('gateOwnerPassword', _base.gateOwnerPassword);

  @override
  String get gateOwnerTitle => _text('gateOwnerTitle', _base.gateOwnerTitle);

  @override
  String get gateTitle => _text('gateTitle', _base.gateTitle);

  @override
  String get gateUnlock => _text('gateUnlock', _base.gateUnlock);

  @override
  String get gateUnlocked => _text('gateUnlocked', _base.gateUnlocked);

  @override
  String get gateUsername => _text('gateUsername', _base.gateUsername);

  @override
  String get groupCommon => _text('groupCommon', _base.groupCommon);

  @override
  String get groupErrors => _text('groupErrors', _base.groupErrors);

  @override
  String get groupStorefront => _text('groupStorefront', _base.groupStorefront);

  @override
  String get groupValidation => _text('groupValidation', _base.groupValidation);

  @override
  String inquiryMessageTemplate(String price, String product) => _filled(
    'inquiryMessageTemplate',
    _base.inquiryMessageTemplate(price, product),
    <String, String>{'price': '${price}', 'product': '${product}'},
  );

  @override
  String get labelAvailable => _text('labelAvailable', _base.labelAvailable);

  @override
  String labelDiscount(int percent) => _filled(
    'labelDiscount',
    _base.labelDiscount(percent),
    <String, String>{'percent': '${percent}'},
  );

  @override
  String labelDuration(int minutes, int seconds) => _filled(
    'labelDuration',
    _base.labelDuration(minutes, seconds),
    <String, String>{'minutes': '${minutes}', 'seconds': '${seconds}'},
  );

  @override
  String labelFrom(String price) => _filled(
    'labelFrom',
    _base.labelFrom(price),
    <String, String>{'price': '${price}'},
  );

  @override
  String get labelPrice => _text('labelPrice', _base.labelPrice);

  @override
  String get labelUnavailable =>
      _text('labelUnavailable', _base.labelUnavailable);

  @override
  String get navAbout => _text('navAbout', _base.navAbout);

  @override
  String get navAdmin => _text('navAdmin', _base.navAdmin);

  @override
  String get navCategories => _text('navCategories', _base.navCategories);

  @override
  String get navContact => _text('navContact', _base.navContact);

  @override
  String get navFavourites => _text('navFavourites', _base.navFavourites);

  @override
  String get navHome => _text('navHome', _base.navHome);

  @override
  String get navSettings => _text('navSettings', _base.navSettings);

  @override
  String get searchHint => _text('searchHint', _base.searchHint);

  @override
  String searchNoResults(String query) => _filled(
    'searchNoResults',
    _base.searchNoResults(query),
    <String, String>{'query': '${query}'},
  );

  @override
  String searchResultsCount(int count) => _base.searchResultsCount(count);

  @override
  String get sectionAllProducts =>
      _text('sectionAllProducts', _base.sectionAllProducts);

  @override
  String get sectionBrowseCategories =>
      _text('sectionBrowseCategories', _base.sectionBrowseCategories);

  @override
  String get sectionFeatured => _text('sectionFeatured', _base.sectionFeatured);

  @override
  String get sectionNewArrivals =>
      _text('sectionNewArrivals', _base.sectionNewArrivals);

  @override
  String get settingsAbout => _text('settingsAbout', _base.settingsAbout);

  @override
  String get settingsAdminEntry =>
      _text('settingsAdminEntry', _base.settingsAdminEntry);

  @override
  String get settingsAdminHint =>
      _text('settingsAdminHint', _base.settingsAdminHint);

  @override
  String get settingsLanguage =>
      _text('settingsLanguage', _base.settingsLanguage);

  @override
  String get settingsTheme => _text('settingsTheme', _base.settingsTheme);

  @override
  String get settingsThemeDark =>
      _text('settingsThemeDark', _base.settingsThemeDark);

  @override
  String get settingsThemeLight =>
      _text('settingsThemeLight', _base.settingsThemeLight);

  @override
  String get settingsThemeSystem =>
      _text('settingsThemeSystem', _base.settingsThemeSystem);

  @override
  String get settingsTitle => _text('settingsTitle', _base.settingsTitle);

  @override
  String get settingsVersion => _text('settingsVersion', _base.settingsVersion);

  @override
  String get stateEmptyMessage =>
      _text('stateEmptyMessage', _base.stateEmptyMessage);

  @override
  String get stateEmptyTitle => _text('stateEmptyTitle', _base.stateEmptyTitle);

  @override
  String get stateErrorTitle => _text('stateErrorTitle', _base.stateErrorTitle);

  @override
  String get stateLoading => _text('stateLoading', _base.stateLoading);

  @override
  String get stateNoResults => _text('stateNoResults', _base.stateNoResults);

  @override
  String get stateNotFoundMessage =>
      _text('stateNotFoundMessage', _base.stateNotFoundMessage);

  @override
  String get stateNotFoundTitle =>
      _text('stateNotFoundTitle', _base.stateNotFoundTitle);

  @override
  String get stateOffline => _text('stateOffline', _base.stateOffline);

  @override
  String get stateSaved => _text('stateSaved', _base.stateSaved);

  @override
  String get stateSaving => _text('stateSaving', _base.stateSaving);

  @override
  String get systemCheckAccount =>
      _text('systemCheckAccount', _base.systemCheckAccount);

  @override
  String get systemCheckAllGood =>
      _text('systemCheckAllGood', _base.systemCheckAllGood);

  @override
  String get systemCheckBuild =>
      _text('systemCheckBuild', _base.systemCheckBuild);

  @override
  String get systemCheckFixDatabase =>
      _text('systemCheckFixDatabase', _base.systemCheckFixDatabase);

  @override
  String get systemCheckFixFunction =>
      _text('systemCheckFixFunction', _base.systemCheckFixFunction);

  @override
  String get systemCheckFixNetwork =>
      _text('systemCheckFixNetwork', _base.systemCheckFixNetwork);

  @override
  String get systemCheckFixSeed =>
      _text('systemCheckFixSeed', _base.systemCheckFixSeed);

  @override
  String get systemCheckMissing =>
      _text('systemCheckMissing', _base.systemCheckMissing);

  @override
  String get systemCheckMissingSummary =>
      _text('systemCheckMissingSummary', _base.systemCheckMissingSummary);

  @override
  String get systemCheckNotSignedIn =>
      _text('systemCheckNotSignedIn', _base.systemCheckNotSignedIn);

  @override
  String get systemCheckOk => _text('systemCheckOk', _base.systemCheckOk);

  @override
  String get systemCheckProject =>
      _text('systemCheckProject', _base.systemCheckProject);

  @override
  String get systemCheckRestricted =>
      _text('systemCheckRestricted', _base.systemCheckRestricted);

  @override
  String get systemCheckRun => _text('systemCheckRun', _base.systemCheckRun);

  @override
  String get systemCheckTitle =>
      _text('systemCheckTitle', _base.systemCheckTitle);

  @override
  String get systemCheckUnreachable =>
      _text('systemCheckUnreachable', _base.systemCheckUnreachable);

  @override
  String get systemCheckUnknown =>
      _text('systemCheckUnknown', _base.systemCheckUnknown);

  @override
  String get tagline => _text('tagline', _base.tagline);

  @override
  String get validateCompareAtPrice =>
      _text('validateCompareAtPrice', _base.validateCompareAtPrice);

  @override
  String get validateEmail => _text('validateEmail', _base.validateEmail);

  @override
  String get validateNegative =>
      _text('validateNegative', _base.validateNegative);

  @override
  String get validateNumber => _text('validateNumber', _base.validateNumber);

  @override
  String get validatePasswordLength =>
      _text('validatePasswordLength', _base.validatePasswordLength);

  @override
  String get validatePasswordMismatch =>
      _text('validatePasswordMismatch', _base.validatePasswordMismatch);

  @override
  String get validatePasswordStrength =>
      _text('validatePasswordStrength', _base.validatePasswordStrength);

  @override
  String get validatePhone => _text('validatePhone', _base.validatePhone);

  @override
  String get validatePositive =>
      _text('validatePositive', _base.validatePositive);

  @override
  String get validateRequired =>
      _text('validateRequired', _base.validateRequired);

  @override
  String get validateSlug => _text('validateSlug', _base.validateSlug);

  @override
  String get validateTelegramHandle =>
      _text('validateTelegramHandle', _base.validateTelegramHandle);

  @override
  String get validateTooLong => _text('validateTooLong', _base.validateTooLong);

  @override
  String get validateTooShort =>
      _text('validateTooShort', _base.validateTooShort);

  @override
  String get validateUrl => _text('validateUrl', _base.validateUrl);

  @override
  String get validateVideoTooLong =>
      _text('validateVideoTooLong', _base.validateVideoTooLong);

  @override
  String get validateVideoUnreadable =>
      _text('validateVideoUnreadable', _base.validateVideoUnreadable);
}
