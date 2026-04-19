import 'package:flutter/foundation.dart';

import '../data/models.dart';

/// Spaced-repetition **delays**, **snooze**, and user-facing **wave labels**.
///
/// Use built-in [production] / [test] or [fromCustomMinutes] for user-defined gaps.
@immutable
class SchedulingProfile {
  const SchedulingProfile({
    required this.waveDelays,
    required this.waveLabels,
    required this.snooze,
    required this.automationFooterLine,
  });

  final List<Duration> waveDelays;
  final List<String> waveLabels;
  final Duration snooze;

  /// Shown under the review section (automation transparency).
  final String automationFooterLine;

  /// **QA / dev** — first revisits at +16m, +20m, +25m; snooze 30s.
  static const test = SchedulingProfile(
    waveDelays: [
      Duration(minutes: 16),
      Duration(minutes: 20),
      Duration(minutes: 25),
    ],
    waveLabels: ['16 min', '20 min', '25 min'],
    snooze: Duration(seconds: 30),
    automationFooterLine: 'AUTO-REVISING IN 16 MIN • 20 MIN • 25 MIN',
  );

  /// **Production** — +1d, +7d, +30d; snooze 6h.
  static const production = SchedulingProfile(
    waveDelays: [Duration(days: 1), Duration(days: 7), Duration(days: 30)],
    waveLabels: ['24h', '7d', '30d'],
    snooze: Duration(hours: 6),
    automationFooterLine: 'AUTO-REVISING IN 24H • 7D • 30D',
  );

  /// Upper bound for each custom gap (minutes), inclusive.
  static const maxCustomMinutes = 525600; // 365 days

  /// Whether [minutes] can be used for a custom profile (exactly three ints in range).
  static bool isValidCustomMinutesList(List<int> minutes) {
    if (minutes.length != 3) return false;
    for (final m in minutes) {
      if (m < 1 || m > maxCustomMinutes) return false;
    }
    return true;
  }

  /// Three positive minute values → profile with generated labels and snooze heuristic.
  factory SchedulingProfile.fromCustomMinutes(List<int> minutes) {
    if (!isValidCustomMinutesList(minutes)) return SchedulingProfile.production;
    final waves = minutes.map((m) => Duration(minutes: m)).toList();
    final labels = waves.map(_waveDelayLabel).toList();
    final maxWave = waves.reduce((a, b) => a > b ? a : b);
    final snooze = maxWave < const Duration(hours: 6)
        ? const Duration(seconds: 30)
        : const Duration(hours: 6);
    final banner = labels.map((e) => e.toUpperCase()).join(' • ');
    return SchedulingProfile(
      waveDelays: waves,
      waveLabels: labels,
      snooze: snooze,
      automationFooterLine: 'AUTO-REVISING IN $banner',
    );
  }

  static String _waveDelayLabel(Duration d) {
    if (d.inDays >= 1 && d.inHours % 24 == 0 && d.inMinutes % (24 * 60) == 0) {
      return '${d.inDays}d';
    }
    if (d.inHours >= 1 && d.inMinutes % 60 == 0) {
      return '${d.inHours}h';
    }
    if (d.inMinutes >= 1) {
      return '${d.inMinutes} min';
    }
    return '${d.inSeconds}s';
  }

  String labelFor(ReviewWave wave) => waveLabels[wave.index];

  /// Settings row subtitle — keeps copy aligned with [waveLabels].
  String get aboutSettingsSubtitle =>
      'Local-only MVP. No AI. Revisit spacing: ${waveLabels.join(' · ')}.';
}
