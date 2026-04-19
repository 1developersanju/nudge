import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Loads IANA zones and sets [tz.local] for [zonedSchedule] notifications.
Future<void> configureReviewTimeZone() async {
  tzdata.initializeTimeZones();
  final id = (await FlutterTimezone.getLocalTimezone()).identifier;
  try {
    tz.setLocalLocation(tz.getLocation(id));
    return;
  } catch (_) {}
  try {
    tz.setLocalLocation(tz.getLocation(id.replaceAll(' ', '_')));
  } catch (_) {
    tz.setLocalLocation(tz.UTC);
  }
}
