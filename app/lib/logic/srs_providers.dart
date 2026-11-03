import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/srs_progress.dart';
import '../data/models/verb.dart';
import '../data/repositories/srs_repository.dart';
import 'verb_providers.dart';

final srsRepositoryProvider = Provider<SrsRepository>((ref) {
  return SrsRepository();
});

class SrsProgressNotifier extends AsyncNotifier<Map<String, SrsProgress>> {
  @override
  Future<Map<String, SrsProgress>> build() async {
    final repo = ref.watch(srsRepositoryProvider);
    return repo.getAllProgress();
  }

  Future<void> reviewVerb(String verbId, int grade) async {
    final repo = ref.read(srsRepositoryProvider);
    final updated = await repo.recordReview(verbId, grade);

    state = AsyncData({
      ...?state.value,
      verbId: updated,
    });
  }
}

final srsProgressProvider = AsyncNotifierProvider<SrsProgressNotifier, Map<String, SrsProgress>>(
  SrsProgressNotifier.new,
);

final dueVerbsProvider = Provider<AsyncValue<List<Verb>>>((ref) {
  final allVerbsAsync = ref.watch(allVerbsProvider);
  final progressAsync = ref.watch(srsProgressProvider);

  if (allVerbsAsync.isLoading || progressAsync.isLoading) {
    return const AsyncLoading();
  }

  if (allVerbsAsync.hasError) {
    return AsyncError(allVerbsAsync.error!, allVerbsAsync.stackTrace!);
  }

  final allVerbs = allVerbsAsync.value ?? [];
  final progressMap = progressAsync.value ?? {};
  final now = DateTime.now();

  final due = allVerbs.where((verb) {
    final progress = progressMap[verb.id];
    if (progress == null) return true; // Never studied yet
    return progress.isDue(now);
  }).toList();

  return AsyncData(due);
});
