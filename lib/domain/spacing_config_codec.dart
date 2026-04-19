import 'dart:convert';

import 'scheduling_profile.dart';

/// JSON string (prefs) ↔ [SchedulingProfile] for global revisit spacing.
abstract final class SpacingConfigCodec {
  /// `{"p":"production"|"test"}` or `{"m":[16,20,25]}` (minutes, exactly three).
  static SchedulingProfile decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return SchedulingProfile.production;
    }
    try {
      final o = jsonDecode(raw) as Map<String, dynamic>;
      if (o['m'] is List) {
        final list = (o['m'] as List).map((e) => (e as num).toInt()).toList();
        if (SchedulingProfile.isValidCustomMinutesList(list)) {
          return SchedulingProfile.fromCustomMinutes(list);
        }
      }
      final p = o['p'] as String?;
      if (p == 'test') return SchedulingProfile.test;
      return SchedulingProfile.production;
    } catch (_) {
      return SchedulingProfile.production;
    }
  }
}
