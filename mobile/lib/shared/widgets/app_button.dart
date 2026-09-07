import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Mirrors web/src/components/ui/Button.tsx: rounded-xl, px-4 py-2.5,
/// font-semibold, four variants, disabled = 50% opacity (not Material's
/// default disabled-gray). Built on Material + InkWell rather than
/// wrapping ElevatedButton so shape/shadow match the web spec exactly.
enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;

  /// Stretches to fill available width — the common case for form CTAs.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600);

    final (Color bg, Color fg, BoxBorder? border) = switch (variant) {
      AppButtonVariant.primary => (scheme.primary, scheme.onPrimary, null),
      AppButtonVariant.secondary => (scheme.onSurface, scheme.surface, null),
      AppButtonVariant.ghost => (Colors.transparent, scheme.onSurface, Border.all(color: semantic.line)),
      AppButtonVariant.danger => (scheme.error, scheme.onError, null),
    };

    final disabled = onPressed == null || loading;

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
        else if (icon != null)
          Icon(icon, size: 18, color: fg),
        if (loading || icon != null) const SizedBox(width: 8),
        Text(label, style: textStyle?.copyWith(color: fg)),
      ],
    );

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : onPressed,
          child: Container(
            width: expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: border),
            child: child,
          ),
        ),
      ),
    );
  }
}
