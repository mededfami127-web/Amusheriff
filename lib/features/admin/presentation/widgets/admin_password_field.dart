import 'package:flutter/material.dart';

import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/utils/validators.dart';

class AdminPasswordField extends StatefulWidget {
  const AdminPasswordField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.onSubmitted,
    this.error,
    this.strength,
    this.autofocus = false,
    this.textInputAction,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? error;
  final double? strength;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  State<AdminPasswordField> createState() => _AdminPasswordFieldState();
}

class _AdminPasswordFieldState extends State<AdminPasswordField> {
  late final TextEditingController _controller;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(_sync);
  }

  @override
  void didUpdateWidget(covariant AdminPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  void _sync() {
    if (_controller.text == widget.value) return;
    widget.onChanged(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    _controller.dispose();
    super.dispose();
  }

  Color _colorFor(double ratio) {
    if (ratio <= 0.4) return BrandColors.danger;
    if (ratio <= 0.7) return const Color(0xFFFFB454);
    return BrandColors.goldLight;
  }

  String _labelFor(double ratio) {
    if (ratio <= 0.4) return 'Weak';
    if (ratio <= 0.7) return 'Fair';
    return 'Strong';
  }

  double _strengthRatio() {
    final String v = widget.value;
    if (v.isEmpty) return 0;
    final String? failure = Validators.strongPassword(v);
    final int score = _score(v, failure: failure);
    const int max = 4;
    return (score / max).clamp(0.0, 1.0);
  }

  int _score(String v, {String? failure}) {
    int s = 0;
    if (v.length >= 10) s++;
    if (RegExp(r'[A-Z]').hasMatch(v)) s++;
    if (RegExp(r'[a-z]').hasMatch(v)) s++;
    if (RegExp(r'[0-9]').hasMatch(v)) s++;
    if (failure == null) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color ink = dark ? BrandColors.ivory : BrandColors.charcoal;
    final double strengthRatio = widget.strength ?? _strengthRatio();

    return Semantics(
      label: widget.label,
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label,
              style:
                  BrandTypography.labelLarge.copyWith(color: BrandColors.goldLight),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: dark ? BrandColors.deepPlum : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BrandColors.goldHairline),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    obscureText: _obscure,
                    autofocus: widget.autofocus,
                    textInputAction: widget.textInputAction,
                    style: BrandTypography.bodyMedium.copyWith(color: ink),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onSubmitted: widget.onSubmitted,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: BrandColors.gold,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ],
            ),
          ),
          if (widget.strength != null) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: strengthRatio,
                      backgroundColor: BrandColors.goldHairline,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _colorFor(strengthRatio),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _labelFor(strengthRatio),
                  style: BrandTypography.labelSmall.copyWith(
                    color: _colorFor(strengthRatio),
                  ),
                ),
              ],
            ),
          ],
          if (widget.error != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              widget.error!,
              style:
                  BrandTypography.bodySmall.copyWith(color: BrandColors.danger),
            ),
          ],
        ],
      ),
    );
  }
}
