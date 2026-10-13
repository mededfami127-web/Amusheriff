import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/admin_scaffold.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  int _failedAttempts = 0;
  bool _isLocked = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLocked || _isLoading) return;
    if (!formKey.currentState!.validate()) return;

    _isLoading = true;
    setState(() {});

    final bool ok = await ref
        .read(adminAuthControllerProvider.notifier)
        .signIn(email: _emailController.text, password: _passwordController.text);

    if (!mounted) return;
    _isLoading = false;
    setState(() {});

    if (ok) {
      if (widget.returnTo != null && widget.returnTo!.isNotEmpty) {
        context.go(widget.returnTo!);
      } else {
        context.go(Routes.adminRoot);
      }
    } else {
      _failedAttempts++;
      if (_failedAttempts >= 5) {
        _isLocked = true;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLocked
              ? 'Too many failed attempts. Try again later.'
              : 'Invalid email or password.'),
        ),
      );
    }
  }

  Future<void> _forgotPassword() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email first')),
      );
      return;
    }

    final bool sent = await ref
        .read(adminAuthControllerProvider.notifier)
        .forgotPassword(email: _emailController.text);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent ? l10n.adminResetSent : l10n.errorServer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<void> state = ref.watch(adminAuthControllerProvider);

    return AdminScaffold(
      title: l10n.adminLoginTitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: BrandGradients.brandVertical,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/brand/logo.png',
                      height: 58,
                      color: BrandColors.ivory,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.adminLoginTitle,
                      style: BrandTypography.brandTitle.copyWith(
                        fontSize: 24,
                        color: BrandColors.ivory,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.brandNameAm,
                      style: BrandTypography.bodySmall.copyWith(
                        color: BrandColors.ivory.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.adminLoginSubtitle,
                textAlign: TextAlign.center,
                style: BrandTypography.bodySmall,
              ),
              const SizedBox(height: 24),
              if (widget.showNotAuthorised)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(l10n.adminNotAuthorised),
                    ),
                  ),
                ),
              if (_isLocked)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(l10n.adminLockoutMessage),
                    ),
                  ),
                ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.adminEmailLabel,
                  prefixIcon: const Icon(Icons.mail_outlined),
                ),
                validator: (v) =>
                    Validators.email(v)?.toString(),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: l10n.adminPasswordLabel,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  ),
                ),
                validator: (v) =>
                    (v?.isEmpty ?? true) ? l10n.validateRequired : null,
              ),
              if (_failedAttempts > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${(_failedAttempts)} failures',
                    style: BrandTypography.bodySmall,
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login_outlined),
                label: Text(l10n.adminSignIn),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _failedAttempts >= 5 ? null : _forgotPassword,
                child: Text(l10n.adminForgotPassword),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
