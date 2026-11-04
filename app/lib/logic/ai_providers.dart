import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/ai_feedback.dart';
import '../data/services/pocketbase_service.dart';

final pocketBaseServiceProvider = Provider<PocketBaseService>((ref) {
  return PocketBaseService();
});

class AiEvaluationNotifier extends Notifier<AsyncValue<AiEvaluation?>> {
  @override
  AsyncValue<AiEvaluation?> build() => const AsyncData(null);

  Future<AiEvaluation> evaluate({
    required String verbV1,
    required String targetForm,
    required String userSentence,
    String? token,
  }) async {
    state = const AsyncLoading();
    final pbService = ref.read(pocketBaseServiceProvider);

    try {
      final eval = await pbService.evaluateSentence(
        verbV1: verbV1,
        targetForm: targetForm,
        userSentence: userSentence,
        token: token,
      );
      state = AsyncData(eval);
      return eval;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  void reset() => state = const AsyncData(null);
}

final aiEvaluationProvider = NotifierProvider<AiEvaluationNotifier, AsyncValue<AiEvaluation?>>(
  AiEvaluationNotifier.new,
);

final contextExamplesFamilyProvider = FutureProvider.family<List<ContextExample>, ({String verbV1, String topic, String? token})>(
  (ref, arg) async {
    final pbService = ref.watch(pocketBaseServiceProvider);
    return pbService.getContextExamples(verbV1: arg.verbV1, topic: arg.topic, token: arg.token);
  },
);
