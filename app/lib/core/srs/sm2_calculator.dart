/// SuperMemo-2 (SM-2) Spaced Repetition calculation algorithm
class SM2CalculationResult {
  final int repetitions;
  final int intervalDays;
  final double easinessFactor;
  final DateTime nextReviewAt;

  const SM2CalculationResult({
    required this.repetitions,
    required this.intervalDays,
    required this.easinessFactor,
    required this.nextReviewAt,
  });

  Map<String, dynamic> toJson() => {
        'repetitions': repetitions,
        'intervalDays': intervalDays,
        'easinessFactor': easinessFactor,
        'nextReviewAt': nextReviewAt.toIso8601String(),
      };
}

class SM2Calculator {
  /// Calculates the next review date and EF based on the response grade:
  /// 0: Complete blackout
  /// 1: Incorrect, correct remembered
  /// 2: Incorrect, correct seemed easy
  /// 3: Correct with serious difficulty (Again / Hard)
  /// 4: Correct after hesitation (Good)
  /// 5: Perfect response (Easy)
  static SM2CalculationResult calculate({
    required int repetitions,
    required int intervalDays,
    required double easinessFactor,
    required int grade,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();
    double currentEF = easinessFactor < 1.3 ? 1.3 : easinessFactor;

    int newReps;
    int newInterval;

    if (grade >= 3) {
      if (repetitions == 0) {
        newInterval = 1;
      } else if (repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (intervalDays * currentEF).round();
      }
      newReps = repetitions + 1;
    } else {
      newReps = 0;
      newInterval = 1;
    }

    // EF' = EF + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02))
    final diff = (5 - grade).toDouble();
    double newEF = currentEF + (0.1 - diff * (0.08 + diff * 0.02));
    if (newEF < 1.3) {
      newEF = 1.3;
    }
    // Round to 2 decimals
    newEF = (newEF * 100).round() / 100.0;

    final nextReview = effectiveNow.add(Duration(days: newInterval));

    return SM2CalculationResult(
      repetitions: newReps,
      intervalDays: newInterval,
      easinessFactor: newEF,
      nextReviewAt: nextReview,
    );
  }
}
