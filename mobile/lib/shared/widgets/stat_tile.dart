import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'app_card.dart';

/// Mirrors web/src/components/ui/Stat.tsx: an AppCard with a big
/// display-font number. Used for admin oversight KPIs and request/order
/// summary counts.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.helper,
    this.highlight = false,
    this.loading = false,
    this.padding = AppCardPadding.sm,
  });

  final String label;
  final String value;
  final String? helper;
  final bool highlight;
  final bool loading;
  final AppCardPadding padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final labelColor = highlight ? scheme.onPrimary.withValues(alpha: 0.8) : semantic.steelSoft;
    final helperColor = highlight ? scheme.onPrimary.withValues(alpha: 0.7) : semantic.steelSoft;

    return AppCard(
      variant: highlight ? AppCardVariant.highlight : AppCardVariant.default_,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: labelColor)),
          const SizedBox(height: 8),
          Text(
            loading ? '…' : value,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontSize: 28, color: highlight ? scheme.onPrimary : null),
          ),
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(helper!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: helperColor)),
          ],
        ],
      ),
    );
  }
}
