/// Rule-based splitting — no AI. Keeps capture fast and predictable.
class LearningInputSplitter {
  static const int maxTopics = 10;

  /// Preview / commit split: multiline → one topic per non-empty line;
  /// single line → split on comma, semicolon, " and ", "&".
  static List<String> splitLearningInput(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return [];
    return [t];
  }

  /// First line as title; remainder as optional notes.
  static (String title, String? notes) titleAndNotes(String chunk) {
    final lines = chunk
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (lines.isEmpty) return ('', null);
    if (lines.length == 1) return (lines.first, null);
    return (lines.first, lines.skip(1).join('\n'));
  }
}
