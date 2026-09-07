import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_status.dart';

/// Semantic/status colors and a couple of tokens that have no slot in
/// Flutter's ColorScheme (steelSoft, line). Widgets read these via
/// `Theme.of(context).extension<AppSemanticColors>()!` rather than
/// importing app_colors.dart's raw hex directly, so there is exactly one
/// lookup pattern for "how do I get a themed color" across shared/widgets.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.line,
    required this.steelSoft,
    required this.go,
    required this.goBg,
    required this.stop,
    required this.stopBg,
    required this.signal,
    required this.signalBg,
    required this.neutral,
    required this.neutralBg,
  });

  final Color line;
  final Color steelSoft;
  final Color go;
  final Color goBg;
  final Color stop;
  final Color stopBg;
  final Color signal;
  final Color signalBg;
  final Color neutral;
  final Color neutralBg;

  static const light = AppSemanticColors(
    line: AppColors.line,
    steelSoft: AppColors.steelSoft,
    go: AppColors.go,
    goBg: AppColors.goBg,
    stop: AppColors.stop,
    stopBg: AppColors.stopBg,
    signal: AppColors.signal,
    signalBg: AppColors.primarySoft,
    neutral: AppColors.steel,
    neutralBg: AppColors.line,
  );

  static const dark = AppSemanticColors(
    line: AppColors.lineDark,
    steelSoft: AppColors.steelSoftDark,
    go: AppColors.goDark,
    goBg: AppColors.goBgDark,
    stop: AppColors.stopDark,
    stopBg: AppColors.stopBgDark,
    signal: AppColors.signalLightDark,
    signalBg: AppColors.primarySoftDark,
    neutral: AppColors.steelDark,
    neutralBg: AppColors.lineDark,
  );

  /// Resolves a status tone to its (foreground, background) color pair.
  (Color, Color) colorsFor(AppTone tone) {
    switch (tone) {
      case AppTone.go:
        return (go, goBg);
      case AppTone.stop:
        return (stop, stopBg);
      case AppTone.signal:
        return (signal, signalBg);
      case AppTone.neutral:
        return (neutral, neutralBg);
    }
  }

  @override
  AppSemanticColors copyWith({
    Color? line,
    Color? steelSoft,
    Color? go,
    Color? goBg,
    Color? stop,
    Color? stopBg,
    Color? signal,
    Color? signalBg,
    Color? neutral,
    Color? neutralBg,
  }) {
    return AppSemanticColors(
      line: line ?? this.line,
      steelSoft: steelSoft ?? this.steelSoft,
      go: go ?? this.go,
      goBg: goBg ?? this.goBg,
      stop: stop ?? this.stop,
      stopBg: stopBg ?? this.stopBg,
      signal: signal ?? this.signal,
      signalBg: signalBg ?? this.signalBg,
      neutral: neutral ?? this.neutral,
      neutralBg: neutralBg ?? this.neutralBg,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      line: Color.lerp(line, other.line, t)!,
      steelSoft: Color.lerp(steelSoft, other.steelSoft, t)!,
      go: Color.lerp(go, other.go, t)!,
      goBg: Color.lerp(goBg, other.goBg, t)!,
      stop: Color.lerp(stop, other.stop, t)!,
      stopBg: Color.lerp(stopBg, other.stopBg, t)!,
      signal: Color.lerp(signal, other.signal, t)!,
      signalBg: Color.lerp(signalBg, other.signalBg, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      neutralBg: Color.lerp(neutralBg, other.neutralBg, t)!,
    );
  }
}
