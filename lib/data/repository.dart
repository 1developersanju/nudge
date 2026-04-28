import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../background/review_notification_scheduler.dart';
import '../domain/spaced_repetition.dart';
import '../theme/review_spacing_controller.dart';
import 'database_helper.dart';
import 'models.dart';
import 'prefs_keys.dart';
import 'text_splitter.dart';
import 'topic_codec.dart';

class LearningRepository extends ChangeNotifier {
  LearningRepository({required ReviewSpacingController spacing})
    : _spacing = spacing;

  final ReviewSpacingController _spacing;

  static const _streakKey = 'streak_v1';

  final List<LearningTopic> _topics = [];
  final Random _rand = Random();

  int _reviewsCompletedToday = 0;
  int get reviewsCompletedToday => _reviewsCompletedToday;

  int _streak = 0;
  int get streak => _streak;
  DateTime? _lastActiveDay;

  String _reviewsDoneKey(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return 'reviews_done_${x.toIso8601String()}';
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_rand.nextInt(1 << 30)}';

  /// Calendar date in the user’s local timezone (topics store UTC instants).
  DateTime _dateOnly(DateTime d) {
    final l = d.toLocal();
    return DateTime(l.year, l.month, l.day);
  }

  LearningTopic? _byId(String id) {
    for (final t in _topics) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<void> _syncReviewNotificationAlarms() async {
    await rescheduleReviewNotificationsFromTopics(
      List<LearningTopic>.from(_topics),
      _spacing.profile,
    );
  }

  /// Reschedule OS alarms from current in-memory topics (timezone change, resume, etc.).
  Future<void> rescheduleNotificationAlarms() async {
    await rescheduleReviewNotificationsFromTopics(
      List<LearningTopic>.from(_topics),
      _spacing.profile,
    );
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final legacyTopics = await TopicCodec.loadFromPrefs(prefs);
    if (legacyTopics.isNotEmpty) {
      for (final t in legacyTopics) {
        await DatabaseHelper.instance.insertTopic(t);
      }
      await prefs.remove(PrefsKeys.topics);
      await prefs.remove(PrefsKeys.legacyTopics);
    }
    
    final dbTopics = await DatabaseHelper.instance.getAllTopics();
    _topics
      ..clear()
      ..addAll(dbTopics);

    final streakRaw = prefs.getString(_streakKey);
    if (streakRaw != null) {
      final m = jsonDecode(streakRaw) as Map<String, dynamic>;
      _streak = (m['streak'] as num?)?.toInt() ?? 0;
      final last = m['last'] as String?;
      _lastActiveDay = last != null ? DateTime.parse(last).toUtc() : null;
    }

    _reconcileStreak();
    await _persistStreak();

    _reviewsCompletedToday = prefs.getInt(_reviewsDoneKey(DateTime.now())) ?? 0;

    notifyListeners();
    await _syncReviewNotificationAlarms();
  }

  void _reconcileStreak() {
    final today = _dateOnly(DateTime.now());
    if (_lastActiveDay == null) return;
    final last = _dateOnly(_lastActiveDay!);
    final diff = today.difference(last).inDays;
    if (diff > 1) {
      _streak = 0;
    }
  }

  Future<void> recordActivity() async {
    final today = _dateOnly(DateTime.now());
    final lastDay = _lastActiveDay == null ? null : _dateOnly(_lastActiveDay!);
    if (lastDay == today) {
      await _persistStreak();
      return;
    }
    if (lastDay == null) {
      _streak = 1;
    } else {
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) {
        _streak += 1;
      } else if (diff > 1) {
        _streak = 1;
      }
    }
    _lastActiveDay = DateTime.now();
    await _persistStreak();
  }

  Future<void> _persistStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _streakKey,
      jsonEncode({
        'streak': _streak,
        'last': _lastActiveDay?.toUtc().toIso8601String(),
      }),
    );
  }

  Future<void> _saveTopics() async {
    await _syncReviewNotificationAlarms();
  }

  Future<void> _setReviewsDoneCount(int n) async {
    final prefs = await SharedPreferences.getInstance();
    _reviewsCompletedToday = n;
    await prefs.setInt(_reviewsDoneKey(DateTime.now()), n);
  }

  Future<void> addTopicsFromChunks(List<String> chunks) async {
    if (chunks.isEmpty) return;
    for (final chunk in chunks) {
      final (title, notes) = LearningInputSplitter.titleAndNotes(chunk);
      if (title.isEmpty) continue;
      final capturedAt = DateTime.now().toUtc();
      final newTopic = LearningTopic(
        id: _newId(),
        title: title,
        notes: notes,
        createdAt: capturedAt,
        reviews: SpacedRepetition.buildInitialSchedule(
          capturedAt,
          _newId,
          _spacing.profile,
        ),
      );
      _topics.add(newTopic);
      await DatabaseHelper.instance.insertTopic(newTopic);
    }
    await recordActivity();
    await _saveTopics();
    notifyListeners();
  }

  Future<void> updateTopic(
    String id, {
    required String title,
    String? notes,
  }) async {
    final t = _byId(id);
    if (t == null) return;
    t.title = title;
    t.notes = notes;
    await DatabaseHelper.instance.updateTopic(t);
    await _saveTopics();
    notifyListeners();
  }

  Future<void> deleteTopic(String id) async {
    _topics.removeWhere((t) => t.id == id);
    await DatabaseHelper.instance.deleteTopic(id);
    await _saveTopics();
    notifyListeners();
  }

  List<LearningTopic> todayTopics(DateTime now) {
    final d = _dateOnly(now);
    return _topics.where((t) => _dateOnly(t.createdAt) == d).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<LearningTopic> topicsLoggedOnDay(DateTime day) {
    final d = _dateOnly(day);
    return _topics.where((t) => _dateOnly(t.createdAt) == d).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  DateTime earliestSelectableLogDay() {
    if (_topics.isEmpty) {
      return _dateOnly(DateTime.now()).subtract(const Duration(days: 365));
    }
    var oldest = _topics.first.createdAt;
    for (final t in _topics) {
      if (t.createdAt.isBefore(oldest)) oldest = t.createdAt;
    }
    return _dateOnly(oldest);
  }

  List<LearningTopic> dueTopics(DateTime now) =>
      SpacedRepetition.dueTopicsSorted(_topics, now);

  (int done, int total) reviewProgress(DateTime now) {
    final due = dueTopics(now).length;
    final total = (_reviewsCompletedToday + due).clamp(1, 999);
    return (_reviewsCompletedToday, total);
  }

  Future<void> completeNextReview(String topicId) async {
    final topic = _byId(topicId);
    if (topic == null) return;
    final ev = topic.nextPendingDue(DateTime.now());
    if (ev == null) return;
    ev.status = ReviewStatus.done;
    await DatabaseHelper.instance.updateReview(ev);
    await _setReviewsDoneCount(_reviewsCompletedToday + 1);
    await recordActivity();
    await _saveTopics();
    notifyListeners();
  }

  Future<void> snoozeNextReview(String topicId) async {
    final topic = _byId(topicId);
    if (topic == null) return;
    final ev = topic.nextPendingDue(DateTime.now());
    if (ev == null) return;
    ev.dueAt = ev.dueAt.add(_spacing.profile.snooze);
    await DatabaseHelper.instance.updateReview(ev);
    await recordActivity();
    await _saveTopics();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _topics.clear();
    await DatabaseHelper.instance.clearAll();
    await _setReviewsDoneCount(0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.topics);
    await prefs.remove(PrefsKeys.legacyTopics);
    notifyListeners();
    await _syncReviewNotificationAlarms();
  }
}
