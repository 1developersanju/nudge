import '../data/models.dart';
import 'scheduling_profile.dart';

/// Pure spaced-repetition rules: building schedules and querying **due** topics.
///
/// [LearningTopic.nextPendingDue] / [pendingDue] stay on the model; this layer
/// composes **list-level** operations so UI, [LearningRepository], and background
/// work use the **same** ordering and counting.
abstract final class SpacedRepetition {
  /// Three pending [ReviewEvent]s for a new capture at [anchor], using [profile].
  static List<ReviewEvent> buildInitialSchedule(
    DateTime anchor,
    String Function() newId,
    SchedulingProfile profile,
  ) {
    return [
      ReviewEvent(
        id: newId(),
        dueAt: anchor.add(profile.waveDelays[0]),
        wave: ReviewWave.day1,
      ),
      ReviewEvent(
        id: newId(),
        dueAt: anchor.add(profile.waveDelays[1]),
        wave: ReviewWave.day7,
      ),
      ReviewEvent(
        id: newId(),
        dueAt: anchor.add(profile.waveDelays[2]),
        wave: ReviewWave.day30,
      ),
    ];
  }

  /// Topics with at least one **pending** review with `dueAt <= now`, earliest due first.
  static List<LearningTopic> dueTopicsSorted(
    List<LearningTopic> topics,
    DateTime now,
  ) {
    final list = topics.where((t) => t.nextPendingDue(now) != null).toList();
    list.sort((a, b) {
      final da = a.nextPendingDue(now)!.dueAt;
      final db = b.nextPendingDue(now)!.dueAt;
      return da.compareTo(db);
    });
    return list;
  }

  static int countDue(List<LearningTopic> topics, DateTime now) =>
      dueTopicsSorted(topics, now).length;
}
