import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/gamification_state.dart';
import '../data/repositories/gamification_repository.dart';

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  return GamificationRepository();
});

class GamificationNotifier extends AsyncNotifier<GamificationState> {
  @override
  Future<GamificationState> build() async {
    final repo = ref.watch(gamificationRepositoryProvider);
    return repo.getState();
  }

  Future<void> addXp(int xp) async {
    final repo = ref.read(gamificationRepositoryProvider);
    final updated = await repo.addXp(xp);
    state = AsyncData(updated);
  }

  Future<void> unlockBadge(String badgeId) async {
    final repo = ref.read(gamificationRepositoryProvider);
    final updated = await repo.unlockBadge(badgeId);
    state = AsyncData(updated);
  }
}

final gamificationProvider = AsyncNotifierProvider<GamificationNotifier, GamificationState>(
  GamificationNotifier.new,
);
