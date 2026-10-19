import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../providers/admin_gate_providers.dart';

/// The owner panel behind five taps on the logo.
///
/// Deliberately plain: a username, a password, one button. It is the doorway the
/// owner opens without hunting for a sign-in screen, and it says nothing about
/// the credentials on screen — they are the owner's to know.
///
/// When the device holds no Supabase session the panel also asks for the owner
/// account, because the panel password alone cannot authorise anything in the
/// database: without a JWT `auth.uid()` is NULL and every admin policy denies
/// the write. That block disappears once the session exists.
Future<void> showAdminGateSheet(
  BuildContext context, {
  String? returnTo,
  bool alreadyUnlocked = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? BrandColors.deepPlum
        : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) =>
        _AdminGateSheet(returnTo: returnTo, alreadyUnlocked: alreadyUnlocked),
  );
}

class _AdminGateSheet extends ConsumerStatefulWidget {
  const _AdminGateSheet({this.returnTo, this.alreadyUnlocked = false});

  final String? returnTo;
  final bool alreadyUnlocked;

  @override
  ConsumerState<_AdminGateSheet> createState() => _AdminGateSheetState();
}

class _AdminGateSheetState extends ConsumerState<_AdminGateSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _ownerEmail = TextEditingController();
  final TextEditingController _ownerPassword = TextEditingController();
  bool _obscure = true;
  bool _obscureOwner = true;

  @override
  void initState() {
    super.initState();
    // Prefills the e-mail of the last owner account linked on this device; the
    // password is never stored, and the session carries the JWT afterwards.
    _ownerEmail.text = ref.read(adminGateStoreProvider).ownerEmail;
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _ownerEmail.dispose();
    _ownerPassword.dispose();
    super.dispose();
  }

  /// Where the owner lands after unlocking.
  String get _destination =>
      widget.returnTo != null && widget.returnTo!.isNotEmpty
      ? widget.returnTo!
      : Routes.adminRoot;

  Future<void> _submit() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bool ok = await ref
        .read(adminGateProvider.notifier)
        .unlock(
          username: _username.text,
          password: _password.text,
          email: _ownerEmail.text,
          databasePassword: _ownerPassword.text,
        );
    if (!ok || !mounted) return;

    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(l10n.gateUnlocked)));
    if (mounted) context.go(_destination);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AdminGateState state = ref.watch(adminGateProvider);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final bool hasSession = ref.watch(currentSessionProvider) != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 22,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: BrandGradients.brandVertical,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      'assets/brand/logo.png',
                      height: 42,
                      color: BrandColors.ivory,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.gateTitle,
                            style: BrandTypography.brandTitle.copyWith(
                              fontSize: 20,
                              color: BrandColors.ivory,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.adminGatewayTitle,
                            style: BrandTypography.bodySmall.copyWith(
                              color: BrandColors.ivory.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: BrandColors.ivory,
                      ),
                      tooltip: l10n.actionClose,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              if (widget.alreadyUnlocked) ...<Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.lock_open_rounded,
                    color: BrandColors.success,
                  ),
                  title: Text(
                    l10n.gateUnlocked,
                    style: BrandTypography.bodyMedium,
                  ),
                  trailing: TextButton(
                    onPressed: () => context.go(_destination),
                    child: Text(l10n.actionContinue),
                  ),
                ),
                const Divider(),
              ],

              TextFormField(
                controller: _username,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.username],
                decoration: InputDecoration(
                  labelText: l10n.gateUsername,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: const OutlineInputBorder(),
                ),
                validator: (String? v) =>
                    (v ?? '').trim().isEmpty ? l10n.validateRequired : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                autofillHints: const <String>[AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.adminPasswordLabel,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (String? v) =>
                    (v ?? '').isEmpty ? l10n.validateRequired : null,
              ),

              if (!hasSession) ...<Widget>[
                const Divider(height: 30),
                Text(
                  l10n.gateOwnerTitle,
                  style: BrandTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.gateOwnerHint,
                  style: BrandTypography.bodySmall.copyWith(
                    color: BrandTypography.mutedOn(
                      dark ? Brightness.dark : Brightness.light,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ownerEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: l10n.gateOwnerEmail,
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? v) =>
                      (v ?? '').trim().isEmpty ? l10n.validateRequired : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ownerPassword,
                  obscureText: _obscureOwner,
                  autofillHints: const <String>[AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: l10n.gateOwnerPassword,
                    prefixIcon: const Icon(Icons.key_rounded),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureOwner
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureOwner = !_obscureOwner),
                    ),
                  ),
                  validator: (String? v) =>
                      (v ?? '').isEmpty ? l10n.validateRequired : null,
                ),
              ],

              if (state.wrongPassword) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  l10n.gateLocked,
                  style: BrandTypography.bodySmall.copyWith(
                    color: BrandColors.danger,
                  ),
                ),
              ],

              if (state.failure != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  localizeFailure(l10n, state.failure!),
                  style: BrandTypography.bodySmall.copyWith(
                    color: BrandColors.danger,
                  ),
                ),
              ],

              const SizedBox(height: 18),
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
                    : const Icon(Icons.lock_open_rounded),
                label: Text(l10n.gateUnlock),
                onPressed: state.busy ? null : _submit,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.gateHint,
                textAlign: TextAlign.center,
                style: BrandTypography.bodySmall.copyWith(
                  color: BrandTypography.mutedOn(
                    dark ? Brightness.dark : Brightness.light,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
