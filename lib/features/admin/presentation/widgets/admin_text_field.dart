import 'package:flutter/material.dart';

import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';

/// Small, consistent text field used across admin edit forms.
class AdminTextField extends StatefulWidget {
  const AdminTextField({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.onSubmitted,
    this.onSuffixTap,
    this.suffixIcon,
    this.error,
    this.maxLines = 1,
    this.readOnly = false,
    this.autofocus = false,
    this.textInputAction,
    this.keyboardType,
  });

  final String label;
  final String value;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onSuffixTap;
  final Widget? suffixIcon;
  final String? error;
  final int maxLines;
  final bool readOnly;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;

  @override
  State<AdminTextField> createState() => _AdminTextFieldState();
}

class _AdminTextFieldState extends State<AdminTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(_sync);
  }

  @override
  void didUpdateWidget(covariant AdminTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  void _sync() {
    if (_controller.text == widget.value) return;
    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color ink = dark ? BrandColors.ivory : BrandColors.charcoal;

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
                    maxLines: widget.maxLines,
                    minLines: widget.maxLines > 1 ? 3 : 1,
                    readOnly: widget.readOnly,
                    autofocus: widget.autofocus,
                    textInputAction: widget.textInputAction,
                    keyboardType: widget.keyboardType,
                    style: BrandTypography.bodyMedium.copyWith(color: ink),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onSubmitted: widget.onSubmitted,
                  ),
                ),
                if (widget.suffixIcon != null) ...<Widget>[
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: widget.onSuffixTap,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: widget.suffixIcon,
                    ),
                  ),
                ],
                if (widget.onSuffixTap != null && widget.suffixIcon == null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: widget.onSuffixTap,
                    color: BrandColors.gold,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
              ],
            ),
          ),
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
