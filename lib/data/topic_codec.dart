import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'prefs_keys.dart';

/// JSON + [SharedPreferences] I/O for the topic catalog. Used by [LearningRepository]
/// and background workers so **decode rules** (including legacy migration) stay in one place.
abstract final class TopicCodec {
  static List<LearningTopic> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => LearningTopic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String encodeList(List<LearningTopic> topics) =>
      jsonEncode(topics.map((t) => t.toJson()).toList());

  /// Reads topics key, migrates legacy key once if needed, returns parsed list.
  static Future<List<LearningTopic>> loadFromPrefs(
    SharedPreferences prefs,
  ) async {
    var raw = prefs.getString(PrefsKeys.topics);
    if (raw == null || raw.isEmpty) {
      raw = prefs.getString(PrefsKeys.legacyTopics);
      if (raw != null && raw.isNotEmpty) {
        await prefs.setString(PrefsKeys.topics, raw);
        await prefs.remove(PrefsKeys.legacyTopics);
      }
    }
    return decodeList(raw);
  }

  static Future<void> saveToPrefs(
    SharedPreferences prefs,
    List<LearningTopic> topics,
  ) async {
    await prefs.setString(PrefsKeys.topics, encodeList(topics));
  }
}
