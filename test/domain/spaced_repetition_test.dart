import 'package:flutter_test/flutter_test.dart';
import 'package:lognreview/data/models.dart';
import 'package:lognreview/domain/scheduling_profile.dart';
import 'package:lognreview/domain/spaced_repetition.dart';

void main() {
  group('SpacedRepetition.buildInitialSchedule', () {
    test('uses profile delays and stable wave order', () {
      final anchor = DateTime.utc(2026, 4, 17, 12);
      var n = 0;
      String id() => 'id_${n++}';
      final events = SpacedRepetition.buildInitialSchedule(anchor, id, SchedulingProfile.test);
      expect(events, hasLength(3));
      expect(events[0].wave, ReviewWave.day1);
      expect(events[1].wave, ReviewWave.day7);
      expect(events[2].wave, ReviewWave.day30);
      expect(events[0].dueAt, anchor.add(const Duration(minutes: 16)));
      expect(events[1].dueAt, anchor.add(const Duration(minutes: 20)));
      expect(events[2].dueAt, anchor.add(const Duration(minutes: 25)));
      expect(events.every((e) => e.isPending), isTrue);
    });
  });

  group('SpacedRepetition.dueTopicsSorted / countDue', () {
    late DateTime anchor;
    var topicSeq = 0;

    setUp(() {
      anchor = DateTime.utc(2026, 4, 17, 12, 0, 0);
      topicSeq = 0;
    });

    LearningTopic topicWithSchedule(List<Duration> offsetsFromAnchor) {
      final topicId = 'topic_${topicSeq++}';
      return LearningTopic(
        id: topicId,
        title: 't',
        createdAt: anchor,
        reviews: [
          for (var i = 0; i < offsetsFromAnchor.length; i++)
            ReviewEvent(
              id: '${topicId}_ev_$i',
              dueAt: anchor.add(offsetsFromAnchor[i]),
              wave: ReviewWave.values[i],
            ),
        ],
      );
    }

    test('empty list yields empty due and zero count', () {
      expect(SpacedRepetition.dueTopicsSorted([], anchor), isEmpty);
      expect(SpacedRepetition.countDue([], anchor), 0);
    });

    test('excludes topics with no pending due review', () {
      final t = topicWithSchedule([const Duration(minutes: 10)]);
      expect(SpacedRepetition.countDue([t], anchor), 0);
    });

    test('orders by earliest due first', () {
      final now = anchor.add(const Duration(minutes: 5));
      final a = topicWithSchedule([const Duration(minutes: 2)]);
      final b = topicWithSchedule([const Duration(minutes: 1)]);
      final sorted = SpacedRepetition.dueTopicsSorted([a, b], now);
      expect(sorted.map((x) => x.id), [b.id, a.id]);
    });

    test('respects done status', () {
      final t = topicWithSchedule([Duration.zero]);
      t.reviews.first.status = ReviewStatus.done;
      expect(SpacedRepetition.countDue([t], anchor), 0);
    });

    test('countDue matches dueTopicsSorted length', () {
      final now = anchor.add(const Duration(minutes: 90));
      final topics = [
        topicWithSchedule([Duration.zero]),
        topicWithSchedule([const Duration(minutes: 1)]),
        topicWithSchedule([const Duration(hours: 2)]),
      ];
      expect(
        SpacedRepetition.countDue(topics, now),
        SpacedRepetition.dueTopicsSorted(topics, now).length,
      );
      expect(SpacedRepetition.countDue(topics, now), 2);
    });
  });
}
