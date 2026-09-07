import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Mirrors web/src/components/ui/Card.tsx: rounded-2xl, shadow-sm.
/// `default_` = bordered surface-raised card; `highlight` = solid
/// primary-green promo tile (pulled from the fintech-dashboard reference
/// screenshot's "Define standing orders" tile). Unlike the web version,
/// `highlight` also overrides DefaultTextStyle/IconTheme so children get
/// white text/icons automatically instead of every call site setting
/// `text-white` by hand.
enum AppCardVariant { default_, highlight }

enum AppCardPadding { sm, md, lg }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.default_,
    this.padding = AppCardPadding.md,
    this.onTap,
  });

  final Widget child;
  final AppCardVariant variant;
  final AppCardPadding padding;
  final VoidCallback? onTap;

  EdgeInsets get _padding => switch (padding) {
    AppCardPadding.sm => const EdgeInsets.all(16),
    AppCardPadding.md => const EdgeInsets.all(24),
    AppCardPadding.lg => const EdgeInsets.all(32),
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final highlight = variant == AppCardVariant.highlight;

    final bg = highlight ? scheme.primary : scheme.surface;
    final inner = Padding(
      padding: _padding,
      child: highlight
          ? DefaultTextStyle.merge(
              style: TextStyle(color: scheme.onPrimary),
              child: IconTheme.merge(
                data: IconThemeData(color: scheme.onPrimary),
                child: child,
              ),
            )
          : child,
    );

    // Fill/border/shadow live on Material so InkWell's ripple (when
    // onTap is set) shows through instead of being hidden behind an
    // opaque Container.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
        ],
      ),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: highlight ? BorderSide.none : BorderSide(color: semantic.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? inner : InkWell(onTap: onTap, child: inner),
      ),
    );
  }
}
