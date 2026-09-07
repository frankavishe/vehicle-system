import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Mirrors web/src/components/ui/Badge.tsx: pill shape, four tones
/// (go/stop/signal/neutral). `AppBadge.status(...)` is the direct
/// replacement for every old `Chip(backgroundColor: statusColor(...))`
/// call site — see core/theme/app_status.dart for the status->tone map.
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, this.tone = AppTone.neutral});

  /// Resolves [status] to a tone via [statusToneFor] and title-cases it
  /// for display (backend statuses are SCREAMING_SNAKE_CASE).
  factory AppBadge.status(String status) {
    return AppBadge(label: _humanize(status), tone: statusToneFor(status));
  }

  final String label;
  final AppTone tone;

  static String _humanize(String status) =>
      status.split('_').map((w) => w.isEmpty ? w : '${w[0]}${w.substring(1).toLowerCase()}').join(' ');

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final (fg, bg) = semantic.colorsFor(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
