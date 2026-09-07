import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_theme_extension.dart';
import 'app_typography.dart';

export 'app_status.dart' show AppTone, statusToneFor;
export 'app_theme_extension.dart' show AppSemanticColors;

/// AutoServe design tokens — fintech-dashboard palette shared with web/:
/// warm off-white surface, deep pine-green brand/CTA color, calm modern
/// typography (Plus Jakarta Sans display + Inter body). See
/// mobile/lib/shared/widgets for the components built on these tokens,
/// and mobile/lib/core/theme/app_colors.dart for the raw hex values.
///
/// Component theme overrides below (appBarTheme, navigationBarTheme,
/// cardTheme, inputDecorationTheme, button themes, dialogTheme,
/// chipTheme) mean built-in Material widgets already look right by
/// default — the shared/widgets/ components exist for the small set of
/// cases (button variants, badges, fitment tags) that need an API Material
/// doesn't offer, not because raw widgets look wrong.
class AppTheme {
  AppTheme._();

  static final ThemeData light = _build(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.signal,
      onSecondary: Colors.white,
      error: AppColors.stop,
      onError: Colors.white,
      errorContainer: AppColors.stopBg,
      onErrorContainer: AppColors.stop,
      surface: AppColors.surfaceRaised,
      onSurface: AppColors.asphalt,
      surfaceContainerHighest: AppColors.surface,
      onSurfaceVariant: AppColors.steel,
      outline: AppColors.line,
      outlineVariant: AppColors.line,
    ),
    scaffoldBackground: AppColors.surface,
    bodyColor: AppColors.asphalt,
    displayColor: AppColors.asphalt,
    semanticColors: AppSemanticColors.light,
  );

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: AppColors.primaryDark,
      primaryContainer: AppColors.primarySoftDark,
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.signalLightDark,
      onSecondary: AppColors.surfaceDark,
      error: AppColors.stopDark,
      onError: AppColors.surfaceDark,
      errorContainer: AppColors.stopBgDark,
      onErrorContainer: AppColors.stopDark,
      surface: AppColors.surfaceRaisedDark,
      onSurface: AppColors.asphaltDark,
      surfaceContainerHighest: AppColors.surfaceDark,
      onSurfaceVariant: AppColors.steelDark,
      outline: AppColors.lineDark,
      outlineVariant: AppColors.lineDark,
    ),
    scaffoldBackground: AppColors.surfaceDark,
    bodyColor: AppColors.asphaltDark,
    displayColor: AppColors.asphaltDark,
    semanticColors: AppSemanticColors.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color bodyColor,
    required Color displayColor,
    required AppSemanticColors semanticColors,
  }) {
    final textTheme = AppTypography.textTheme(bodyColor, displayColor);
    final radiusMd = BorderRadius.circular(12); // buttons, inputs — rounded-xl/lg
    final radiusLg = BorderRadius.circular(16); // cards, dialogs — rounded-2xl

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      extensions: [semanticColors],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape: const StadiumBorder(),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? colorScheme.onPrimaryContainer : semanticColors.steelSoft,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? colorScheme.onPrimaryContainer : semanticColors.steelSoft);
        }),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radiusLg,
          side: BorderSide(color: semanticColors.line),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radiusLg),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: semanticColors.neutralBg,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        shape: const StadiumBorder(),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: semanticColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: semanticColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: semanticColors.steelSoft),
        // Matches web/'s Field.tsx error convention (text-xs text-stop).
        // AppTextField (shared/widgets) renders the label above the
        // field itself; the error line below is left to this decoration
        // so it stays correctly wired to Form.validate()/validator.
        errorStyle: textTheme.labelSmall?.copyWith(color: colorScheme.error),
        errorMaxLines: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          side: BorderSide(color: semanticColors.line),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(color: semanticColors.line, space: 1, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scaffoldBackground),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
