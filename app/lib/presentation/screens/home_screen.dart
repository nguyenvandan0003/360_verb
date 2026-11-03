import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../logic/gamification_providers.dart';
import '../../logic/srs_providers.dart';
import 'practice/flashcard_screen.dart';
import 'practice/fill_blanks_screen.dart';
import 'practice/speed_quiz_screen.dart';
import 'practice/ai_writing_screen.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onNavigateToDictionary;

  const HomeScreen({super.key, required this.onNavigateToDictionary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationAsync = ref.watch(gamificationProvider);
    final dueVerbsAsync = ref.watch(dueVerbsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verb360 AI'),
        actions: [
          gamificationAsync.maybeWhen(
            data: (state) => Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    '${state.currentStreak} ngày',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  const Text('⭐', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 2),
                  Text(
                    '${state.totalXp} XP',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                  ),
                ],
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Review Due Card
          dueVerbsAsync.when(
            data: (dueVerbs) {
              final count = dueVerbs.length;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lặp lại ngắt quãng (SRS)',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count từ cần ôn',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      count > 0 ? 'Bạn có $count động từ cần ôn tập hôm nay!' : 'Chúc mừng! Bạn đã hoàn thành bài ôn hôm nay!',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FlashcardScreen()),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        count > 0 ? 'Bắt đầu ôn tập ngay' : 'Học thêm từ mới',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),
          const Text(
            'Chế độ Luyện tập',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 4 Modes Grid
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildPracticeCard(
                context,
                title: 'Flashcard SRS',
                subtitle: 'Ghi nhớ ngắt quãng',
                icon: Icons.style_rounded,
                color: const Color(0xFF6366F1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FlashcardScreen()),
                  );
                },
              ),
              _buildPracticeCard(
                context,
                title: 'Điền khuyết',
                subtitle: 'Chia dạng V2 / V3',
                icon: Icons.edit_note_rounded,
                color: const Color(0xFF0EA5E9),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FillBlanksScreen()),
                  );
                },
              ),
              _buildPracticeCard(
                context,
                title: 'Phản xạ nhanh',
                subtitle: '60 giây thử thách',
                icon: Icons.timer_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SpeedQuizScreen()),
                  );
                },
              ),
              _buildPracticeCard(
                context,
                title: 'Gia sư AI',
                subtitle: 'Chấm & sửa câu tức thì',
                icon: Icons.psychology_rounded,
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AiWritingScreen()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Quy luật biến đổi hình thái',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: onNavigateToDictionary,
                child: const Text('Xem tất cả 360 từ'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _buildGroupTile(
            title: 'Nhóm A - A - A (3 dạng giống hệt nhau)',
            examples: 'cut - cut - cut • put - put - put • set - set - set',
            count: '32 từ',
            color: const Color(0xFF3B82F6),
            onTap: onNavigateToDictionary,
          ),
          _buildGroupTile(
            title: 'Nhóm A - B - B (V2 và V3 giống nhau)',
            examples: 'buy - bought - bought • keep - kept - kept • find - found - found',
            count: '148 từ',
            color: const Color(0xFF8B5CF6),
            onTap: onNavigateToDictionary,
          ),
          _buildGroupTile(
            title: 'Nhóm A - B - C (3 dạng hoàn toàn khác nhau)',
            examples: 'do - did - done • go - went - gone • speak - spoke - spoken',
            count: '162 từ',
            color: const Color(0xFFEC4899),
            onTap: onNavigateToDictionary,
          ),
          _buildGroupTile(
            title: 'Nhóm A - B - A (V1 và V3 giống nhau)',
            examples: 'come - came - come • run - ran - run • become - became - become',
            count: '18 từ',
            color: const Color(0xFF10B981),
            onTap: onNavigateToDictionary,
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupTile({
    required String title,
    required String examples,
    required String count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.folder_special_rounded, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(examples, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(count, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
