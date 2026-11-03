class SrsProgress {
  final String verbId;
  final int repetitions;
  final int intervalDays;
  final double easinessFactor;
  final DateTime? lastReviewedAt;
  final DateTime nextReviewAt;
  final int consecutiveCorrect;
  final int totalMistakes;

  const SrsProgress({
    required this.verbId,
    required this.repetitions,
    required this.intervalDays,
    required this.easinessFactor,
    this.lastReviewedAt,
    required this.nextReviewAt,
    this.consecutiveCorrect = 0,
    this.totalMistakes = 0,
  });

  bool isDue([DateTime? now]) {
    final effectiveNow = now ?? DateTime.now();
    return nextReviewAt.isBefore(effectiveNow) || nextReviewAt.isAtSameMomentAs(effectiveNow);
  }

  factory SrsProgress.initial(String verbId) {
    return SrsProgress(
      verbId: verbId,
      repetitions: 0,
      intervalDays: 0,
      easinessFactor: 2.5,
      nextReviewAt: DateTime.now(),
    );
  }

  factory SrsProgress.fromJson(Map<String, dynamic> json) {
    return SrsProgress(
      verbId: json['verb_id'] as String? ?? '',
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      intervalDays: (json['interval_days'] as num?)?.toInt() ?? 0,
      easinessFactor: (json['easiness_factor'] as num?)?.toDouble() ?? 2.5,
      lastReviewedAt: json['last_reviewed_at'] != null
          ? DateTime.tryParse(json['last_reviewed_at'] as String)
          : null,
      nextReviewAt: json['next_review_at'] != null
          ? (DateTime.tryParse(json['next_review_at'] as String) ?? DateTime.now())
          : DateTime.now(),
      consecutiveCorrect: (json['consecutive_correct'] as num?)?.toInt() ?? 0,
      totalMistakes: (json['total_mistakes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'verb_id': verbId,
        'repetitions': repetitions,
        'interval_days': intervalDays,
        'easiness_factor': easinessFactor,
        'last_reviewed_at': lastReviewedAt?.toIso8601String(),
        'next_review_at': nextReviewAt.toIso8601String(),
        'consecutive_correct': consecutiveCorrect,
        'total_mistakes': totalMistakes,
      };
}
