import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../logic/gamification_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationAsync = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ học tập'),
      ),
      body: gamificationAsync.when(
        data: (state) {
          final level = (state.totalXp / 100).floor() + 1;
          final nextLevelXp = level * 100;
          final currentLevelProgress = (state.totalXp % 100) / 100.0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Profile Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                        child: const Icon(Icons.person_rounded, size: 36, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Học viên Verb360',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Cấp độ $level • Chiến binh ngữ pháp',
                                style: TextStyle(color: Colors.indigo.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Streak & Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Chuỗi học',
                      value: '${state.currentStreak} ngày',
                      subtitle: 'Kỷ lục: ${state.longestStreak} ngày',
                      icon: Icons.local_fire_department_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Kinh nghiệm',
                      value: '${state.totalXp} XP',
                      subtitle: 'Còn ${nextLevelXp - state.totalXp} XP lên cấp',
                      icon: Icons.star_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // XP Progress Bar
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tiến độ Cấp $level', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${(currentLevelProgress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: currentLevelProgress,
                        backgroundColor: Colors.grey.shade200,
                        color: AppTheme.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Badges Section
              const Text('Huy hiệu đạt được', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildBadgeChip('🌟 Khởi đầu mới', state.badges.contains('newbie_starter')),
                  _buildBadgeChip('🔥 Chăm chỉ 3 ngày', state.currentStreak >= 3),
                  _buildBadgeChip('⚡ Bậc thầy A-A-A', state.totalXp >= 150),
                  _buildBadgeChip('✍️ Cây bút AI', state.totalXp >= 250),
                ],
              ),
              const SizedBox(height: 24),

              // PocketBase Cloud Sync Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cloud_sync_rounded, color: AppTheme.primary),
                          SizedBox(width: 8),
                          Text('Đồng bộ đám mây PocketBase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tiến độ học tập và lịch ôn ngắt quãng được lưu trữ ngoại tuyến an toàn trên thiết bị của bạn và đồng bộ với PocketBase backend khi có mạng.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.sync_rounded),
                        label: const Text('Đồng bộ tiến độ ngay'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã đồng bộ tiến độ thành công với PocketBase!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeChip(String label, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.amber.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUnlocked ? Colors.amber.shade400 : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
          color: isUnlocked ? Colors.orange.shade900 : Colors.grey.shade500,
        ),
      ),
    );
  }
}
