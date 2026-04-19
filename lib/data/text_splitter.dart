/// Rule-based splitting — no AI. Keeps capture fast and predictable.
class LearningInputSplitter {
  static const int maxTopics = 10;

  /// Preview / commit split: multiline → one topic per non-empty line;
  /// single line → split on comma, semicolon, " and ", "&".
  static List<String> splitLearningInput(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return [];

    final lines = t
        .split(RegExp(r'\r?\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (lines.length > 1) {
      return lines.take(maxTopics).toList();
    }

    final single = lines.isEmpty ? t : lines.first;
    final parts = single.split(
      RegExp(r'[,;]|(?:\s+and\s+)|(?:\s*&\s*)', caseSensitive: false),
    );
    return parts
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .take(maxTopics)
        .toList();
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
