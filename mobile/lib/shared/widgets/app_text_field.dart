import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Mirrors web/src/components/ui/Field.tsx: small steel-colored label
/// above the control, stop-colored error line below. The label is
/// rendered by this widget for exact color/size control; the error line
/// is left to TextFormField/DropdownButtonFormField's own decoration
/// (styled stop-colored + text-xs via InputDecorationTheme.errorStyle in
/// core/theme/app_theme.dart) so it stays wired up correctly with
/// Form.validate() / [validator] — a manually-rendered error line would
/// otherwise fight FormField's own error overlay.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.errorText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController? controller;

  /// Manually-driven error (e.g. an async/server-side check). Ignored on
  /// a field that also fires [validator], since FormField overlays its
  /// own error text once a validator returns non-null.
  final String? errorText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: semantic.steelSoft, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          enabled: enabled,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(hintText: hintText, suffixIcon: suffixIcon, errorText: errorText),
        ),
      ],
    );
  }
}

/// Mirrors web/src/components/ui/Field.tsx's Select — a labeled dropdown
/// sharing AppTextField's label/error visual treatment.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.errorText,
    this.validator,
    this.hint,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final String? Function(T?)? validator;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: semantic.steelSoft, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(hintText: hint, errorText: errorText),
        ),
      ],
    );
  }
}
