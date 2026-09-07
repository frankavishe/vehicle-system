import 'package:flutter/material.dart';

/// AutoServe design tokens — mirrors web/src/app/globals.css's
/// "fintech-dashboard palette" verbatim for light mode: warm off-white
/// surface, deep pine-green brand/CTA color, calm modern typography (see
/// app_typography.dart). The dark palette below has no web equivalent
/// (the web app is light-only) — it's a mobile-only derivation that keeps
/// the same brand hue and semantic tones, with warm-neutral (not cold
/// gray) dark surfaces and tones lightened for AA contrast.
class AppColors {
  AppColors._();

  // Light — transcribed 1:1 from web/src/app/globals.css :root.
  static const surface = Color(0xFFF4F3EF);
  static const surfaceRaised = Color(0xFFFFFFFF);
  static const asphalt = Color(0xFF16181D);
  static const steel = Color(0xFF4B5563);
  static const steelSoft = Color(0xFF8A9099);
  static const line = Color(0xFFE5E3DB);
  static const primary = Color(0xFF123524);
  static const primaryDark = Color(0xFF0B2419);
  static const primarySoft = Color(0xFFE4ECE7);
  static const signal = Color(0xFF2563EB);
  static const signalDark = Color(0xFF1D4ED8);
  static const go = Color(0xFF1C7A4C);
  static const goBg = Color(0xFFE1F3E9);
  static const stop = Color(0xFFD92D20);
  static const stopBg = Color(0xFFFBE7E4);

  // Dark — derived, not present in web/. Same brand hue, warm-neutral
  // surfaces, tones lightened ~10-15% for contrast on dark backgrounds.
  static const surfaceDark = Color(0xFF15171A);
  static const surfaceRaisedDark = Color(0xFF1D2024);
  static const asphaltDark = Color(0xFFF4F3EF);
  static const steelDark = Color(0xFF9AA3AE);
  static const steelSoftDark = Color(0xFF6B7280);
  static const lineDark = Color(0xFF2C2F34);
  // `primary` itself stays the same deep green for brand recognition;
  // `primaryLight` is used where green needs to read as foreground text/
  // icon color against a dark card (raw `primary` is too dark there).
  static const primaryLight = Color(0xFF3E8863);
  static const primarySoftDark = Color(0xFF1B2E24);
  static const signalLightDark = Color(0xFF5B8DEF);
  static const goDark = Color(0xFF3FA873);
  static const goBgDark = Color(0xFF13291E);
  static const stopDark = Color(0xFFEF5B4E);
  static const stopBgDark = Color(0xFF2E1613);
}
