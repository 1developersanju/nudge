import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../data/prefs_keys.dart';
import '../data/topic_codec.dart';
import '../domain/spaced_repetition.dart';
import '../domain/spacing_config_codec.dart';
import 'notification_channels.dart';
import 'review_notification_ids.dart';
import 'review_notification_scheduler.dart';

const _wmUniquePeriodic = 'com.lognreview.review-due-periodic';
const _wmTaskPeriodic = 'reviewDuePeriodic';
const _androidChannelId = 'review_due_v1';
const _androidChannelName = 'Review reminders';

/// How often WorkManager can run a periodic check (Android minimum is 15 minutes).
const Duration kReviewBackgroundInterval = Duration(minutes: 15);

Future<void> showReviewDueNotification(int dueCount) async {
  if (dueCount <= 0) return;
  final plugin = FlutterLocalNotificationsPlugin();
  await ensureReviewNotificationChannels(plugin);

  const androidDetails = AndroidNotificationDetails(
    _androidChannelId,
    _androidChannelName,
    channelDescription: 'Alerts when spaced-repetition reviews are due',
    importance: Importance.high,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  const details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
    macOS: iosDetails,
  );

  await plugin.show(
    ReviewNotificationIds.wmAggregate,
    'Revise today',
    dueCount == 1
        ? '1 topic is ready to review'
        : '$dueCount topics are ready to review',
    details,
  );
}

/// WorkManager entry point (separate isolate). Reads prefs and shows a notification if reviews are due.
@pragma('vm:entry-point')
void reviewBackgroundDispatcher() {
  Workmanager().executeTask((
    String taskName,
    Map<String, dynamic>? inputData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final topics = await TopicCodec.loadFromPrefs(prefs);
      final profile = SpacingConfigCodec.decode(
        prefs.getString(PrefsKeys.spacingConfig),
      );
      final n = SpacedRepetition.countDue(topics, DateTime.now());
      if (n > 0) {
        await showReviewDueNotification(n);
      }
      await rescheduleReviewNotificationsFromTopics(topics, profile);
      return true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('reviewBackgroundDispatcher: $e\n$st');
      }
      return false;
    }
  });
}

/// Registers periodic background checks (WorkManager) after plugin init.
Future<void> registerReviewBackgroundWork() async {
  await Workmanager().initialize(reviewBackgroundDispatcher);
  await Workmanager().registerPeriodicTask(
    _wmUniquePeriodic,
    _wmTaskPeriodic,
    frequency: kReviewBackgroundInterval,
    constraints: Constraints(networkType: NetworkType.notRequired),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );
}

/// Initializes notification channels on the main isolate (call before requesting OS permission).
Future<void> configureLocalNotifications() async {
  await ensureReviewNotificationChannels(FlutterLocalNotificationsPlugin());
}
