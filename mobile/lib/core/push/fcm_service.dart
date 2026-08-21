import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api/autoserve_api.dart';

/// Guarded FCM init — missing/absent Firebase config must not crash app
/// boot, same no-op-safe pattern already used for backend's
/// apps/notifications/services/fcm.py and web/'s src/lib/firebase.ts. No
/// Firebase project exists yet (Phase 1 human-account-setup item still
/// open) — `Firebase.initializeApp()` throws if `google-services.json`/
/// `GoogleService-Info.plist` aren't present, so every entrypoint here is
/// wrapped and fails soft.
class FcmService {
  FcmService(this._api);

  final AutoserveApi _api;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Deep-link tap-through: set by the router at startup. Kept
  /// deliberately shallow — every notification just opens the
  /// notifications list rather than routing to the specific entity, since
  /// a JOB_ALERT/DISPATCH/ORDER_UPDATE/etc. can each point at a
  /// differently-shaped screen and this app has no server-side "deep
  /// link target" field to key off yet.
  void Function()? onNotificationTapped;

  /// Called once at app start. Registers the current token and listens
  /// for onTokenRefresh, per PLAN.md §5.4/§7. Silently does nothing if
  /// Firebase isn't configured for this build.
  Future<void> initialize({required String platform}) async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      developer.log('Firebase not configured — push disabled for this build.', error: e);
      return;
    }
    _initialized = true;

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await FirebaseMessaging.instance.requestPermission();

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _registerToken(token, platform);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((t) => _registerToken(t, platform));

    // FCM data-only messages don't auto-display a heads-up alert —
    // flutter_local_notifications bridges that gap while the app is
    // foregrounded (PLAN §7 item 8).
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // Deep-link tap-through: app opened from a tapped notification while
    // backgrounded, or cold-started from one (terminated state).
    FirebaseMessaging.onMessageOpenedApp.listen((_) => onNotificationTapped?.call());
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) onNotificationTapped?.call();
  }

  bool get isInitialized => _initialized;

  Future<void> _registerToken(String token, String platform) async {
    try {
      await _api.registerDeviceToken(fcmToken: token, platform: platform);
    } catch (e) {
      developer.log('Device token registration failed.', error: e);
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'autoserve_default',
          'AutoServe notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
