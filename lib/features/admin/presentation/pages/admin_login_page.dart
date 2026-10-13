import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/gradients.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/gold_divider.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Owner sign-in. Reached only from the discreet Settings entry or a deep link.
///
/// Public e-mail sign-up is disabled in Supabase Auth, so this form can only
/// ever authenticate the single owner account.
class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({
    super.key,
    this.returnTo,
    this.showNotAuthorised = false,
  });

  final String? returnTo;
  final bool showNotAuthorised;

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bool ok = await ref
        .read(adminAuthControllerProvider.notifier)
        .signIn(email: _email.text, password: _password.text);

    if (!mounted || !ok) return;
    context.go(widget.returnTo ?? Routes.adminRoot);
  }

  Future<void> _forgotPassword() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (Validators.email(_email.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validateEmail)),
      );
      return;
    }
    final bool sent = await ref
        .read(adminAuthControllerProvider.notifier)
        .sendPasswordReset(_email.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(sent ? l10n.adminResetSent : l10n.errorServer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final AsyncValue<void> state = ref.watch(adminAuthControllerProvider);
    final AppFailure? failure = state.error is AppFailure
        ? state.error as AppFailure
        : (state.hasError ? UnknownFailure(cause: state.error) : null);

    return AppScaffold(
      showLockup: false,
      title: l10n.adminLoginTitle,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: BrandGradients.brandVertical,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'assets/brand/logo_transparent.png',
                          height: 58,
                          filterQuality: FilterQuality.high,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.adminLoginTitle,
                          style: BrandTypography.brandTitle.copyWith(
                            fontSize: 24,
                            color: BrandColors.ivory,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    l10n.adminLoginSubtitle,
                    textAlign: TextAlign.center,
                    style: BrandTypography.bodySmall.copyWith(
                      color: BrandTypography.mutedOn(
                        Theme.of(context).brightness,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.showNotAuthorised)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: InlineFailureBanner(
                        failure: PermissionFailure(),
                      ),
                    ),
                  if (failure != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InlineFailureBanner(
                        failure: failure,
                        onRetry: () => ref
                            .read(adminAuthControllerProvider.notifier)
                            .reset(),
                      ),
                    ),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const <String>[AutofillHints.username],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.adminEmailLabel,
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                    ),
                    validator: (String? value) {
                      final String? key = Validators.email(value);
                      return key == null
                          ? null
                          : l10n.errorValidation;
                    },
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (String? value) => (value ?? '').isEmpty
                        ? l10n.validateRequired
                        : null,
                  ),
                  const SizedBox(height: 22),
                  GradientButton(
                    label: l10n.adminSignIn,
                    icon: Icons.login_rounded,
                    isLoading: state.isLoading,
                    onPressed: state.isLoading ? null : _submit,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: state.isLoading ? null : _forgotPassword,
                    child: Text(l10n.adminForgotPassword),
                  ),
                  const SizedBox(height: 20),
                  const GoldDivider(),
                  const SizedBox(height: 14),
                  Text(
                    'ASM · ${dark ? 'dark' : 'light'}',
                    textAlign: TextAlign.center,
                    style: BrandTypography.bodySmall.copyWith(
                      color: BrandTypography.mutedOn(
                        Theme.of(context).brightness,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
