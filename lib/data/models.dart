enum ReviewStatus { pending, done }

enum ReviewWave { day1, day7, day30 }

class ReviewEvent {
  ReviewEvent({
    required this.id,
    required this.dueAt,
    required this.wave,
    this.status = ReviewStatus.pending,
  });

  final String id;

  /// When this revisit is due; stored as **UTC** in JSON.
  DateTime dueAt;
  final ReviewWave wave;
  ReviewStatus status;

  bool get isPending => status == ReviewStatus.pending;

  Map<String, dynamic> toJson() => {
    'id': id,
    'dueAt': dueAt.toUtc().toIso8601String(),
    'wave': wave.index,
    'status': status.index,
  };

  factory ReviewEvent.fromJson(Map<String, dynamic> j) {
    return ReviewEvent(
      id: j['id'] as String,
      dueAt: DateTime.parse(j['dueAt'] as String).toUtc(),
      wave: ReviewWave.values[(j['wave'] as int?) ?? 0],
      status: ReviewStatus.values[(j['status'] as int?) ?? 0],
    );
  }
}

class LearningTopic {
  LearningTopic({
    required this.id,
    required this.title,
    required this.createdAt,
    this.notes,
    List<ReviewEvent>? reviews,
  }) : reviews = reviews ?? [];

  final String id;
  String title;
  String? notes;

  /// Capture instant (wall clock) stored as **UTC** in JSON; use [toLocal] for calendar UI.
  final DateTime createdAt;
  final List<ReviewEvent> reviews;

  /// Pending reviews for this topic, ordered by due time then wave.
  List<ReviewEvent> pendingDue(DateTime now) {
    final list =
        reviews.where((r) => r.isPending && !r.dueAt.isAfter(now)).toList()
          ..sort((a, b) {
            final c = a.dueAt.compareTo(b.dueAt);
            if (c != 0) return c;
            return a.wave.index.compareTo(b.wave.index);
          });
    return list;
  }

  ReviewEvent? nextPendingDue(DateTime now) {
    final d = pendingDue(now);
    return d.isEmpty ? null : d.first;
  }

  ReviewEvent? nextPending() {
    final list = reviews.where((r) => r.isPending).toList()
      ..sort((a, b) {
        final c = a.dueAt.compareTo(b.dueAt);
        if (c != 0) return c;
        return a.wave.index.compareTo(b.wave.index);
      });
    return list.isEmpty ? null : list.first;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'notes': notes,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'reviews': reviews.map((e) => e.toJson()).toList(),
  };

  factory LearningTopic.fromJson(Map<String, dynamic> j) {
    return LearningTopic(
      id: j['id'] as String,
      title: j['title'] as String,
      notes: j['notes'] as String?,
      createdAt: DateTime.parse(j['createdAt'] as String).toUtc(),
      reviews: (j['reviews'] as List<dynamic>? ?? [])
          .map((e) => ReviewEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
