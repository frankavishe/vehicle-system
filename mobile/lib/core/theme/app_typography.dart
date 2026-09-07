import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the app's two-typeface system, mirroring web/'s font stack:
/// Plus Jakarta Sans for display/headline text (headings, big stat
/// numbers), Inter for everything else. IBM Plex Mono is exposed
/// separately below — deliberately NOT part of either TextTheme, since
/// web/ reserves mono for exactly one thing (fitment/SKU "parts ticket"
/// tags) rather than treating it as a general-purpose typeface.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color bodyColor, Color displayColor) {
    final base = GoogleFonts.interTextTheme();
    final display = GoogleFonts.plusJakartaSansTextTheme();
    return base
        .copyWith(
          displayLarge: display.displayLarge?.copyWith(fontWeight: FontWeight.w800),
          displayMedium: display.displayMedium?.copyWith(fontWeight: FontWeight.w800),
          displaySmall: display.displaySmall?.copyWith(fontWeight: FontWeight.w700),
          headlineLarge: display.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
          headlineMedium: display.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: bodyColor, displayColor: displayColor);
  }

  /// The app's one deliberate mono usage — fitment/SKU tag text only.
  /// Not wired into any ThemeData.textTheme; consumed directly by
  /// FitmentTag (shared/widgets/fitment_tag.dart).
  static TextStyle monoSm(Color color) =>
      GoogleFonts.ibmPlexMono(fontSize: 12, fontWeight: FontWeight.w500, color: color);

  static TextStyle monoMd(Color color) =>
      GoogleFonts.ibmPlexMono(fontSize: 13, fontWeight: FontWeight.w500, color: color);
}

// Note on offline/runtime fetching: google_fonts fetches font files over
// the network on first use and caches them (GoogleFonts.config.
// allowRuntimeFetching, default true). This app already requires a live
// API to function, so the default is acceptable here. If offline first
// launch becomes a requirement, pre-bundle these three families as local
// assets and set allowRuntimeFetching = false in main() — not done in
// this pass.
