import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/srs_progress.dart';
import '../models/verb.dart';
import '../../core/srs/sm2_calculator.dart';

class SrsRepository {
  static const _keySrsData = 'srs_progress_map_v1';

  Future<Map<String, SrsProgress>> getAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySrsData);
    if (raw == null || raw.isEmpty) return {};

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((key, value) => MapEntry(
            key,
            SrsProgress.fromJson(value as Map<String, dynamic>),
          ));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveProgress(SrsProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllProgress();
    all[progress.verbId] = progress;

    final jsonMap = all.map((key, val) => MapEntry(key, val.toJson()));
    await prefs.setString(_keySrsData, jsonEncode(jsonMap));
  }

  /// Record user review grade (0-5) and calculate next interval with SM-2
  Future<SrsProgress> recordReview(String verbId, int grade) async {
    final all = await getAllProgress();
    final current = all[verbId] ?? SrsProgress.initial(verbId);

    final sm2 = SM2Calculator.calculate(
      repetitions: current.repetitions,
      intervalDays: current.intervalDays,
      easinessFactor: current.easinessFactor,
      grade: grade,
    );

    final updated = SrsProgress(
      verbId: verbId,
      repetitions: sm2.repetitions,
      intervalDays: sm2.intervalDays,
      easinessFactor: sm2.easinessFactor,
      lastReviewedAt: DateTime.now(),
      nextReviewAt: sm2.nextReviewAt,
      consecutiveCorrect: grade >= 3 ? current.consecutiveCorrect + 1 : 0,
      totalMistakes: grade < 3 ? current.totalMistakes + 1 : current.totalMistakes,
    );

    await saveProgress(updated);
    return updated;
  }

  /// Returns verbs due for review today
  Future<List<Verb>> getDueVerbs(List<Verb> allVerbs) async {
    final allProgress = await getAllProgress();
    final now = DateTime.now();

    final due = <Verb>[];
    for (final verb in allVerbs) {
      final p = allProgress[verb.id];
      if (p == null || p.isDue(now)) {
        due.add(verb);
      }
    }

    return due;
  }
}
