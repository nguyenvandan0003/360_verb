import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/srs/sm2_calculator.dart';

void main() {
  group('SM2Calculator Tests', () {
    final baseTime = DateTime(2026, 11, 3, 12, 0, 0);

    test('Initial review with perfect score (grade 5)', () {
      final res = SM2Calculator.calculate(
        repetitions: 0,
        intervalDays: 0,
        easinessFactor: 2.5,
        grade: 5,
        now: baseTime,
      );

      expect(res.repetitions, 1);
      expect(res.intervalDays, 1);
      expect(res.easinessFactor, 2.6);
      expect(res.nextReviewAt, baseTime.add(const Duration(days: 1)));
    });

    test('Second review with good score (grade 4)', () {
      final res = SM2Calculator.calculate(
        repetitions: 1,
        intervalDays: 1,
        easinessFactor: 2.6,
        grade: 4,
        now: baseTime,
      );

      expect(res.repetitions, 2);
      expect(res.intervalDays, 6);
      expect(res.easinessFactor, 2.6);
      expect(res.nextReviewAt, baseTime.add(const Duration(days: 6)));
    });

    test('Failure review resets repetitions to 0', () {
      final res = SM2Calculator.calculate(
        repetitions: 4,
        intervalDays: 20,
        easinessFactor: 2.5,
        grade: 2,
        now: baseTime,
      );

      expect(res.repetitions, 0);
      expect(res.intervalDays, 1);
      expect(res.easinessFactor, lessThan(2.5));
    });

    test('Easiness factor never drops below 1.3', () {
      final res = SM2Calculator.calculate(
        repetitions: 0,
        intervalDays: 0,
        easinessFactor: 1.3,
        grade: 0,
        now: baseTime,
      );

      expect(res.easinessFactor, 1.3);
    });
  });
}
