import 'package:flutter/material.dart';

/// Reuses the storefront's (web/) "workshop parts-counter" identity —
/// hazard-amber as the brand/CTA color — so the two clients read as the
/// same product. Everything else (typography, surfaces) is Material 3
/// defaults; this app is four operational dashboards, not a marketing
/// surface, so the design investment goes into flows, not chrome.
const _seedColor = Color(0xFFF5A623); // hazard amber

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
  );
}

/// Status-chip colors shared across job-list/detail screens — one place
/// so MECHANIC/RECOVERY/CUSTOMER screens render the same status the same
/// way.
Color statusColor(String status) {
  switch (status) {
    case 'PENDING':
      return Colors.orange;
    case 'ACCEPTED':
    case 'APPROVED':
      return Colors.blue;
    case 'EN_ROUTE':
      return Colors.indigo;
    case 'IN_PROGRESS':
      return Colors.purple;
    case 'COMPLETED':
    case 'ORDERED':
      return Colors.green;
    case 'CANCELLED':
    case 'REJECTED':
    case 'FAILED':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
