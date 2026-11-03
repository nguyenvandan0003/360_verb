import 'package:flutter_test/flutter_test.dart';
import 'package:app/data/models/verb.dart';
import 'package:app/data/models/srs_progress.dart';
import 'package:app/data/models/gamification_state.dart';

void main() {
  group('Model Serializations', () {
    test('Verb fromJson and toJson', () {
      final json = {
        'id': 'go',
        'v1': 'go',
        'v2': 'went',
        'v3': 'gone',
        'ipa_v1': '/ɡəʊ/',
        'ipa_v2': '/went/',
        'ipa_v3': '/ɡɒn/',
        'meaning_vi': 'đi',
        'morph_group': 'ABC',
        'cefr_level': 'A1',
        'common_rank': 5,
        'example_sentence': 'They went to Paris.',
        'example_sentence_vi': 'Họ đã đi Paris.',
      };

      final verb = Verb.fromJson(json);
      expect(verb.id, 'go');
      expect(verb.v2, 'went');
      expect(verb.morphGroup, 'ABC');
      expect(verb.commonRank, 5);

      final out = verb.toJson();
      expect(out['v3'], 'gone');
    });

    test('SrsProgress isDue check', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final progress = SrsProgress(
        verbId: 'take',
        repetitions: 2,
        intervalDays: 6,
        easinessFactor: 2.6,
        nextReviewAt: pastDate,
      );

      expect(progress.isDue(), isTrue);

      final futureProgress = SrsProgress(
        verbId: 'take',
        repetitions: 2,
        intervalDays: 6,
        easinessFactor: 2.6,
        nextReviewAt: DateTime.now().add(const Duration(days: 3)),
      );
      expect(futureProgress.isDue(), isFalse);
    });

    test('GamificationState initial values', () {
      final state = GamificationState.initial();
      expect(state.currentStreak, 1);
      expect(state.totalXp, 50);
      expect(state.badges, contains('newbie_starter'));
    });
  });
}
