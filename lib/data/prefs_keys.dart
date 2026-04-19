/// SharedPreferences keys shared by [LearningRepository], schedulers, and background workers.
abstract final class PrefsKeys {
  static const topics = 'learning_topics_v1';
  static const legacyTopics = 'learning_units_v1';

  /// JSON list of int notification ids last written by [rescheduleReviewNotificationsFromTopics].
  static const scheduledNotificationIds =
      'scheduled_review_notification_ids_v1';

  /// JSON for global revisit spacing — see [SpacingConfigCodec].
  static const spacingConfig = 'review_spacing_config_v1';
}
