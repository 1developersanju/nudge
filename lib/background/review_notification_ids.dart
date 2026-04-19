/// Collision-safe notification ids for per-review [zonedSchedule] calls.
///
/// [wmAggregate] / [legacyNextOnly] are reserved for non–per-event notifications.
abstract final class ReviewNotificationIds {
  static const int wmAggregate = 9001;
  static const int legacyNextOnly = 9002;

  /// Deterministic id from topic id + review event id (stable across restarts).
  /// Pinned into a high range to avoid the small reserved block.
  static int forPendingEvent(String topicId, String eventId) {
    final h = Object.hash('lognreview.review', topicId, eventId);
    return 1_000_000 + (h.abs() % 2_000_000_000);
  }
}
