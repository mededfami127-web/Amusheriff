import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/brand_colors.dart';
import '../theme/typography.dart';

/// Keeps a build failure inside one screen.
///
/// Flutter has no `try/catch` around a widget build: an exception is reported
/// and the failing subtree is replaced by `ErrorWidget.builder`. This boundary
/// supplies two things that make that replacement useful:
///
/// * a scope the fallback can find, so it can offer **Retry**;
/// * a generation key, so Retry rebuilds the screen from scratch instead of
///   reusing the broken element tree.
///
/// In debug builds `ErrorWidget.builder` is left at Flutter's red screen —
/// a developer should see the stack. In release `bootstrap()` points it at
/// [BrandedErrorFallback], which is what a customer sees.
class AppErrorBoundary extends StatefulWidget {
  const AppErrorBoundary({super.key, required this.child});

  final Widget child;

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  int _generation = 0;

  void _retry() => setState(() => _generation++);

  @override
  Widget build(BuildContext context) {
    return _ErrorBoundaryScope(
      onRetry: _retry,
      child: KeyedSubtree(key: ValueKey<int>(_generation), child: widget.child),
    );
  }
}

class _ErrorBoundaryScope extends InheritedWidget {
  const _ErrorBoundaryScope({required this.onRetry, required super.child});

  final VoidCallback onRetry;

  static _ErrorBoundaryScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ErrorBoundaryScope>();

  @override
  bool updateShouldNotify(_ErrorBoundaryScope oldWidget) =>
      oldWidget.onRetry != onRetry;
}

/// The release-mode replacement for the red screen.
///
/// No exception text and no stack trace: a customer gets the store's name, one
/// sentence and a Retry button. The real error has already gone to the log and
/// Sentry through [AppErrorReporter].
class BrandedErrorFallback extends StatelessWidget {
  const BrandedErrorFallback({super.key});

  @override
  Widget build(BuildContext context) {
    final _ErrorBoundaryScope? scope = _ErrorBoundaryScope.maybeOf(context);
    final AppLocalizations? l10n = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    final String title = l10n?.stateErrorTitle ?? 'Something went wrong';
    final String message =
        l10n?.errorUnknown ?? 'Please try again in a moment.';
    final String retry = l10n?.actionRetry ?? 'Retry';

    return Material(
      color: BrandColors.deepPlum,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.shield_outlined,
                size: 42,
                color: BrandColors.gold,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: BrandTypography.titleMedium.copyWith(
                  color: BrandColors.goldLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: BrandTypography.bodySmall.copyWith(
                  color: BrandColors.ivory.withValues(alpha: 0.8),
                ),
              ),
              if (scope != null) ...<Widget>[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: scope.onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(retry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
