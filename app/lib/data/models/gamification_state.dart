class GamificationState {
  final int currentStreak;
  final int longestStreak;
  final int totalXp;
  final List<String> badges;
  final String lastActiveDate; // YYYY-MM-DD

  const GamificationState({
    this.currentStreak = 1,
    this.longestStreak = 1,
    this.totalXp = 50,
    this.badges = const ['newbie_starter'],
    required this.lastActiveDate,
  });

  factory GamificationState.initial() {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return GamificationState(lastActiveDate: dateStr);
  }

  factory GamificationState.fromJson(Map<String, dynamic> json) {
    return GamificationState(
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 1,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 1,
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 50,
      badges: (json['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['newbie_starter'],
      lastActiveDate: json['last_active_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'total_xp': totalXp,
        'badges': badges,
        'last_active_date': lastActiveDate,
      };

  GamificationState copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalXp,
    List<String>? badges,
    String? lastActiveDate,
  }) {
    return GamificationState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalXp: totalXp ?? this.totalXp,
      badges: badges ?? this.badges,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
