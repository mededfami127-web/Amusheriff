import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/inline_failure_banner.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Changing the owner password re-authenticates first: Supabase deliberately
/// offers no "verify password" endpoint, so the current password is confirmed
/// by signing in again before the new one is written.
class AdminChangePasswordPage extends ConsumerStatefulWidget {
  const AdminChangePasswordPage({super.key});

  @override
  ConsumerState<AdminChangePasswordPage> createState() =>
      _AdminChangePasswordPageState();
}

class _AdminChangePasswordPageState
    extends ConsumerState<AdminChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final String? email = ref.read(currentUserProvider)?.email;
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSessionExpired)),
      );
      return;
    }

    final bool ok =
        await ref.read(adminAuthControllerProvider.notifier).changePassword(
              email: email,
              currentPassword: _current.text,
              newPassword: _next.text,
            );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.adminPasswordChanged : l10n.errorAuth),
      ),
    );
    if (ok) {
      _current.clear();
      _next.clear();
      _confirm.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<void> state = ref.watch(adminAuthControllerProvider);
    final AppFailure? failure = state.error is AppFailure
        ? state.error as AppFailure
        : (state.hasError ? UnknownFailure(cause: state.error) : null);

    return AppScaffold(
      showLockup: false,
      title: l10n.adminChangePassword,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 48),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (failure != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InlineFailureBanner(
                    failure: failure,
                    onDismiss: () => ref
                        .read(adminAuthControllerProvider.notifier)
                        .reset(),
                  ),
                ),
              TextFormField(
                controller: _current,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.adminCurrentPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                ),
                validator: (String? value) => (value ?? '').isEmpty
                    ? l10n.validateRequired
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _next,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.adminNewPassword,
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                ),
                validator: (String? value) =>
                    Validators.strongPassword(value) == null
                        ? null
                        : l10n.validatePasswordStrength,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.adminConfirmPassword,
                  prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                ),
                validator: (String? value) =>
                    Validators.confirmPassword(value, _next.text) == null
                        ? null
                        : l10n.validatePasswordMismatch,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.validatePasswordStrength,
                style: BrandTypography.bodySmall,
              ),
              const SizedBox(height: 22),
              GradientButton(
                label: l10n.adminChangePassword,
                icon: Icons.password_rounded,
                isLoading: state.isLoading,
                onPressed: state.isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
