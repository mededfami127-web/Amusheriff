import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/validators.dart';
import '../providers/admin_gate_providers.dart';
import '../widgets/admin_scaffold.dart';

/// Changes the password that opens the owner panel on this device.
///
/// Separate from [AdminChangePasswordPage], which changes the *Supabase* account
/// password: the gateway is a device-local convenience, so it gets its own,
/// clearly-labelled section in the sidebar.
class AdminGatePasswordPage extends ConsumerStatefulWidget {
  const AdminGatePasswordPage({super.key});

  @override
  ConsumerState<AdminGatePasswordPage> createState() =>
      _AdminGatePasswordPageState();
}

class _AdminGatePasswordPageState extends ConsumerState<AdminGatePasswordPage> {
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
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bool ok = await ref.read(adminGateProvider.notifier).changePassword(
          current: _current.text,
          next: _next.text,
        );

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? l10n.gateChanged : l10n.gateLocked)),
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
    final AdminGateState state = ref.watch(adminGateProvider);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return AdminScaffold(
      title: l10n.gateChangeTitle,
      selectedRoute: Routes.adminGatePassword,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: BrandColors.gold.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: BrandColors.goldHairline),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: BrandColors.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.gateChangeIntro,
                        style: BrandTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _current,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.adminCurrentPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: const OutlineInputBorder(),
                ),
                validator: (String? v) =>
                    (v ?? '').isEmpty ? l10n.validateRequired : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _next,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.adminNewPassword,
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  border: const OutlineInputBorder(),
                ),
                validator: (String? v) {
                  if ((v ?? '').isEmpty) return l10n.validateRequired;
                  // The shipped default is short by necessity; a *replacement*
                  // is held to the same rule as the Supabase password.
                  return Validators.strongPassword(v) == null
                      ? null
                      : l10n.validatePasswordStrength;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.adminConfirmPassword,
                  prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                  border: const OutlineInputBorder(),
                ),
                validator: (String? v) =>
                    Validators.confirmPassword(v, _next.text) == null
                        ? null
                        : l10n.validatePasswordMismatch,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.validatePasswordStrength,
                style: BrandTypography.bodySmall.copyWith(
                  color: BrandTypography.mutedOn(
                    dark ? Brightness.dark : Brightness.light,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: BrandColors.royalViolet,
                  foregroundColor: BrandColors.ivory,
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: state.busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Icon(Icons.password_rounded),
                label: Text(l10n.actionSave),
                onPressed: state.busy ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
