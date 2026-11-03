import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gamification_state.dart';

class GamificationRepository {
  static const _keyGamification = 'gamification_state_v1';

  Future<GamificationState> getState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyGamification);
    if (raw == null || raw.isEmpty) {
      final initial = GamificationState.initial();
      await saveState(initial);
      return initial;
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final state = GamificationState.fromJson(json);
      return _checkDailyStreak(state);
    } catch (_) {
      return GamificationState.initial();
    }
  }

  Future<void> saveState(GamificationState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGamification, jsonEncode(state.toJson()));
  }

  Future<GamificationState> addXp(int xp) async {
    final state = await getState();
    final updated = state.copyWith(totalXp: state.totalXp + xp);
    await saveState(updated);
    return updated;
  }

  Future<GamificationState> unlockBadge(String badgeId) async {
    final state = await getState();
    if (!state.badges.contains(badgeId)) {
      final updatedBadges = List<String>.from(state.badges)..add(badgeId);
      final updated = state.copyWith(
        badges: updatedBadges,
        totalXp: state.totalXp + 50, // Bonus XP for badge
      );
      await saveState(updated);
      return updated;
    }
    return state;
  }

  GamificationState _checkDailyStreak(GamificationState current) {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (current.lastActiveDate == todayStr) {
      return current;
    }

    // Check if yesterday was active
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    if (current.lastActiveDate == yesterdayStr) {
      final newStreak = current.currentStreak + 1;
      final longest = newStreak > current.longestStreak ? newStreak : current.longestStreak;
      return current.copyWith(
        currentStreak: newStreak,
        longestStreak: longest,
        lastActiveDate: todayStr,
      );
    }

    // Streak broken if gap is larger than 1 day
    return current.copyWith(
      currentStreak: 1,
      lastActiveDate: todayStr,
    );
  }
}
