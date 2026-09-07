import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

/// Mirrors web/src/components/ui/FitmentTag.tsx — the app's one
/// signature "die-cut parts ticket" element: dashed border, white
/// surface, mono font for the SKU/fitment line (the one deliberate mono
/// usage in the whole app, matching web's `.fitment-tag` CSS class).
///
/// The web version rotates -1deg and turns its border green on :hover;
/// touch has no hover, so this uses a brief press-down scale instead —
/// an intentional touch-equivalent reinterpretation, not a dropped
/// feature.
class FitmentTag extends StatefulWidget {
  const FitmentTag({super.key, required this.sku, this.make, this.model, this.yearStart, this.yearEnd});

  final String sku;
  final String? make;
  final String? model;
  final int? yearStart;
  final int? yearEnd;

  @override
  State<FitmentTag> createState() => _FitmentTagState();
}

class _FitmentTagState extends State<FitmentTag> {
  bool _pressed = false;

  String get _fitmentLine {
    final parts = [widget.make, widget.model].whereType<String>().where((s) => s.isNotEmpty);
    final fitment = parts.join(' ');
    final years = widget.yearStart != null
        ? (widget.yearEnd != null && widget.yearEnd != widget.yearStart
              ? '${widget.yearStart}-${widget.yearEnd}'
              : '${widget.yearStart}')
        : null;
    return [fitment, years].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final fitmentLine = _fitmentLine;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 100),
        child: CustomPaint(
          painter: _DashedBorderPainter(color: _pressed ? scheme.primary : semantic.line, radius: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.sku, style: AppTypography.monoMd(scheme.onSurface)),
                if (fitmentLine.isNotEmpty)
                  Text(fitmentLine, style: AppTypography.monoSm(semantic.steelSoft)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  // dashWidth/dashGap are tunable knobs kept for callers that want a
  // different dash cadence than the default "parts ticket" look; no
  // current call site overrides them.
  // ignore: unused_element_parameter
  _DashedBorderPainter({required this.color, this.radius = 12, this.dashWidth = 4, this.dashGap = 3});

  final Color color;
  final double radius;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}
