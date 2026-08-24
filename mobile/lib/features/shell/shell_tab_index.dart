import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared across CustomerShell/ProviderShell so an FCM notification tap
/// (main.dart's FcmService.onNotificationTapped) can land the already-open
/// shell on the Notifications tab without go_router needing a distinct
/// route for it — each shell's inner tabs are local `IndexedStack`
/// pages, not routes.
final shellTabIndexProvider = StateProvider<int>((ref) => 0);
