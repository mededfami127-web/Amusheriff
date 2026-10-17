import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';
import 'app_failure.dart';

/// Resolves an [AppFailure.messageKey] against the generated ARB catalogue.
///
/// Kept as one exhaustive switch so a typo in a message key is a runtime
/// fallback rather than a crash, and so Part 2 can add cases without touching
/// every surface.
String localizeFailure(AppLocalizations l10n, AppFailure failure) {
  final String extra =
      failure is ValidationFailure && failure.fieldErrors.isNotEmpty
      ? ' ${l10n.errorValidation}'
      : '';

  final String message = switch (failure.messageKey) {
    'errorNetwork' => l10n.errorNetwork,
    'errorBackendNotSetUp' => l10n.errorBackendNotSetUp,
    'errorTimeout' => l10n.errorTimeout,
    'errorServer' => l10n.errorServer,
    'errorAuth' => l10n.errorAuth,
    'errorInvalidCredentials' => l10n.errorInvalidCredentials,
    'errorEmailNotConfirmed' => l10n.errorEmailNotConfirmed,
    'errorTooManyAttempts' => l10n.errorTooManyAttempts,
    'errorSessionExpired' => l10n.errorSessionExpired,
    'errorPermission' => l10n.errorPermission,
    'errorNotFound' => l10n.errorNotFound,
    'errorValidation' => l10n.errorValidation,
    'errorMedia' => l10n.errorMedia,
    'errorMediaImageTooLarge' => l10n.errorMediaImageTooLarge,
    'errorMediaVideoTooLarge' => l10n.errorMediaVideoTooLarge,
    'errorMediaUnsupportedImage' => l10n.errorMediaUnsupportedImage,
    'errorMediaUnsupportedVideo' => l10n.errorMediaUnsupportedVideo,
    'errorStorage' => l10n.errorStorage,
    'errorUnknown' => l10n.errorUnknown,
    'errorDuplicate' => l10n.errorDuplicate,
    'errorCheckViolation' => l10n.errorCheckViolation,
    'errorForeignKey' => l10n.errorForeignKey,
    'errorConstraintViolation' => l10n.errorConstraintViolation,
    'errorInvalidFormat' => l10n.errorInvalidFormat,
    _ => l10n.errorUnknown,
  };

  return extra.isEmpty ? message : '${message.trim()}$extra';
}

/// Resolves a validator/field message key (used by form widgets in Part 2).
///
/// An unrecognised key is never shown to the owner: a raw `validateFoo` string
/// sitting under a field reads exactly like the error-code text this app
/// promises not to show. Debug builds still get the key back, so a typo is
/// visible while the form is being written.
String localizeFieldKey(AppLocalizations l10n, String? key) {
  if (key == null || key.isEmpty) return '';
  return switch (key) {
    'validateRequired' => l10n.validateRequired,
    'validateTooShort' => l10n.validateTooShort,
    'validateTooLong' => l10n.validateTooLong,
    'validateSlug' => l10n.validateSlug,
    'validateEmail' => l10n.validateEmail,
    'validatePhone' => l10n.validatePhone,
    'validateUrl' => l10n.validateUrl,
    'validatePasswordLength' => l10n.validatePasswordLength,
    'validatePasswordStrength' => l10n.validatePasswordStrength,
    'validatePasswordMismatch' => l10n.validatePasswordMismatch,
    'validateNumber' => l10n.validateNumber,
    'validateNegative' => l10n.validateNegative,
    'validatePositive' => l10n.validatePositive,
    'validateCompareAtPrice' => l10n.validateCompareAtPrice,
    'validateVideoTooLong' => l10n.validateVideoTooLong,
    'validateVideoUnreadable' => l10n.validateVideoUnreadable,
    'errorConstraintViolation' => l10n.errorConstraintViolation,
    'errorDuplicate' => l10n.errorDuplicate,
    'errorInvalidFormat' => l10n.errorInvalidFormat,
    _ => kDebugMode ? key : l10n.errorValidation,
  };
}

extension AppFailureLocalization on AppFailure {
  /// Convenience: `failure.localized(context)`.
  String localized(BuildContext context) =>
      localizeFailure(AppLocalizations.of(context), this);
}
