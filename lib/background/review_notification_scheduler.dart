import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/models.dart';
import '../data/prefs_keys.dart';
import '../domain/scheduling_profile.dart';
import 'notification_channels.dart';
import 'review_notification_ids.dart';

/// Android caps pending alarms (~500). Schedule the soonest N future revisits only.
const int kMaxScheduledReviewNotifications = 120;

class _PendingScheduleRow {
  _PendingScheduleRow({required this.topic, required this.event});

  final LearningTopic topic;
  final ReviewEvent event;
}

Future<List<int>> _readTrackedIds(SharedPreferences prefs) async {
  final raw = prefs.getString(PrefsKeys.scheduledNotificationIds);
  if (raw == null || raw.isEmpty) return [];
  final list = jsonDecode(raw) as List<dynamic>;
  return list.map((e) => (e as num).toInt()).toList();
}

Future<void> _writeTrackedIds(SharedPreferences prefs, List<int> ids) async {
  if (ids.isEmpty) {
    await prefs.remove(PrefsKeys.scheduledNotificationIds);
    return;
  }
  await prefs.setString(PrefsKeys.scheduledNotificationIds, jsonEncode(ids));
}

Future<void> _cancelNotificationIds(
  FlutterLocalNotificationsPlugin plugin,
  Iterable<int> ids,
) async {
  for (final id in ids) {
    try {
      await plugin.cancel(id);
    } catch (_) {}
  }
}

NotificationDetails _details() {
  const androidDetails = AndroidNotificationDetails(
    'review_due_v1',
    'Review reminders',
    channelDescription: 'Alerts when spaced-repetition reviews are due',
    importance: Importance.high,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  return const NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
    macOS: iosDetails,
  );
}

String _shortTitle(String title) {
  final t = title.trim();
  if (t.length <= 42) return t.isEmpty ? 'Review' : t;
  return '${t.substring(0, 39)}…';
}

/// Cancels every OS alarm we track, plus legacy single-id schedule (9002).
Future<void> _cancelAllPreviouslyTracked(
  FlutterLocalNotificationsPlugin plugin,
  SharedPreferences prefs,
) async {
  final tracked = await _readTrackedIds(prefs);
  await _cancelNotificationIds(plugin, tracked);
  await _cancelNotificationIds(plugin, [ReviewNotificationIds.legacyNextOnly]);
  await prefs.remove(PrefsKeys.scheduledNotificationIds);
}

Future<void> _zonedScheduleOne(
  FlutterLocalNotificationsPlugin plugin,
  int id,
  String title,
  String body,
  tz.TZDateTime when,
) async {
  Future<void> exact() => plugin.zonedSchedule(
    id,
    title,
    body,
    when,
    _details(),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );

  Future<void> inexact() => plugin.zonedSchedule(
    id,
    title,
    body,
    when,
    _details(),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );

  if (Platform.isAndroid) {
    try {
      await exact();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('review notif exact failed, inexact: $e');
      }
      await inexact();
    }
  } else {
    await inexact();
  }
}

/// Rebuilds per–review-event `zonedSchedule` alarms from current topic data.
///
/// Call after saves, on app resume (timezone / DST), and from WorkManager recovery
/// (reboot / OEM may drop exact alarms until rescheduled).
Future<void> rescheduleReviewNotificationsFromTopics(
  List<LearningTopic> topics,
  SchedulingProfile profile,
) async {
  try {
    final plugin = FlutterLocalNotificationsPlugin();
    await ensureReviewNotificationChannels(plugin);

    final prefs = await SharedPreferences.getInstance();
    await _cancelAllPreviouslyTracked(plugin, prefs);

    final nowUtc = DateTime.now().toUtc();
    final rows = <_PendingScheduleRow>[];
    for (final t in topics) {
      for (final r in t.reviews) {
        if (!r.isPending) continue;
        if (!r.dueAt.toUtc().isAfter(nowUtc)) continue;
        rows.add(_PendingScheduleRow(topic: t, event: r));
      }
    }
    rows.sort((a, b) => a.event.dueAt.compareTo(b.event.dueAt));
    final picked = rows.take(kMaxScheduledReviewNotifications).toList();

    final scheduledIds = <int>[];

    for (final row in picked) {
      final id = ReviewNotificationIds.forPendingEvent(
        row.topic.id,
        row.event.id,
      );
      var when = tz.TZDateTime.fromMillisecondsSinceEpoch(
        tz.local,
        row.event.dueAt.toUtc().millisecondsSinceEpoch,
      );
      final tzNow = tz.TZDateTime.now(tz.local);
      if (!when.isAfter(tzNow)) {
        when = tzNow.add(const Duration(seconds: 5));
      }

      final wave = profile.labelFor(row.event.wave);
      final title = 'Revise · ${_shortTitle(row.topic.title)}';
      final body = '$wave revisit due';

      await _zonedScheduleOne(plugin, id, title, body, when);
      scheduledIds.add(id);
    }

    await _writeTrackedIds(prefs, scheduledIds);
  } catch (e, st) {
    if (kDebugMode && !e.toString().contains('LateInitializationError')) {
      debugPrint('rescheduleReviewNotificationsFromTopics: $e\n$st');
    }
  }
}
