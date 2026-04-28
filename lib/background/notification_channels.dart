import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Call from a post-frame callback (after [runApp]) so a host [Activity] exists.
///
/// Android 13+ needs [POST_NOTIFICATIONS] at runtime; Android 12+ may need the
/// user to allow exact alarms for reliable [zonedSchedule] times.
Future<void> requestAndroidReviewNotificationPermissions() async {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.android) return;

  final android = FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (android == null) return;

  try {
    await android.requestNotificationsPermission();
  } catch (_) {}
  try {
    await android.requestExactAlarmsPermission();
  } catch (_) {}
}

/// Shared Android channel + plugin init for foreground, background isolate, and schedulers.
Future<void> ensureReviewNotificationChannels(
  FlutterLocalNotificationsPlugin plugin,
) async {
  const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const init = InitializationSettings(android: androidInit, iOS: iosInit);
  await plugin.initialize(init);

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    await plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
    await plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  const channel = AndroidNotificationChannel(
    'review_due_v1',
    'Review reminders',
    description: 'Alerts when spaced-repetition reviews are due',
    importance: Importance.high,
  );
  await plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}
