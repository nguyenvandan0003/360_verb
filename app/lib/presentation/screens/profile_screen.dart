import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../logic/auth_provider.dart';
import '../../logic/gamification_providers.dart';
import '../../logic/iap_provider.dart';
import '../widgets/auth_modal.dart';
import '../widgets/paywall_modal.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationAsync = ref.watch(gamificationProvider);
    final authState = ref.watch(authProvider);
    final iapState = ref.watch(iapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ Cá Nhân'),
      ),
      body: gamificationAsync.when(
        data: (state) {
          final level = (state.totalXp / 100).floor() + 1;
          final nextLevelXp = level * 100;
          final currentLevelProgress = (state.totalXp % 100) / 100.0;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // User Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primarySubtle,
                          child: const Icon(Icons.person_rounded, size: 36, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authState.isAuthenticated ? (authState.user?.name ?? 'Học viên') : 'Khách vãng lai',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              if (authState.isAuthenticated)
                                Text(
                                  authState.user?.email ?? '',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                )
                              else
                                const Text(
                                  'Chưa đăng nhập • Chỉ xem offline',
                                  style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primarySubtle,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Cấp $level • Chiến binh ngữ pháp',
                                  style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!authState.isAuthenticated)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => AuthModal.show(context),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.login_rounded, size: 18),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Đăng nhập tài khoản',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 260;
                          final statusBanner = Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Gia sư AI: Đã kích hoạt',
                                    style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w700, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );

                          final logoutBtn = OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red.shade200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              ref.read(authProvider.notifier).logout();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã đăng xuất.')),
                              );
                            },
                            child: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                statusBanner,
                                const SizedBox(height: 8),
                                logoutBtn,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: statusBanner),
                              const SizedBox(width: 8),
                              logoutBtn,
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // VIP MEMBERSHIP STATUS CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: iapState.isPro
                      ? const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: iapState.isPro ? null : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: iapState.isPro ? Colors.transparent : Colors.amber.shade300,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (iapState.isPro ? const Color(0xFFF59E0B) : Colors.amber).withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 280;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: iapState.isPro ? Colors.white24 : Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.workspace_premium_rounded,
                                    color: iapState.isPro ? Colors.white : Colors.amber.shade900,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        iapState.isPro ? 'Thành Viên VIP PRO' : 'Gói Miễn Phí (Free)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: iapState.isPro ? Colors.white : Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        iapState.isPro
                                            ? 'Gói: ${iapState.planType.toUpperCase()} • ${iapState.planType == 'lifetime' ? 'Vĩnh viễn' : 'Đang hoạt động'}'
                                            : 'Giới hạn tính năng nâng cao',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: iapState.isPro ? Colors.white70 : Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (iapState.isPro && !isNarrow) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'ĐÃ KÍCH HOẠT',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (iapState.isPro && isNarrow) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'ĐÃ KÍCH HOẠT',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      iapState.isPro
                          ? 'Bạn đang sở hữu quyền truy cập không giới hạn Gia sư AI, trọn bộ 360 động từ & toàn bộ tính năng cao cấp.'
                          : 'Nâng cấp VIP PRO để mở khóa trọn đời (299k), gói 1 năm (199k) hoặc gói 1 tháng (19k) với trải nghiệm tốt nhất.',
                      style: TextStyle(
                        fontSize: 13,
                        color: iapState.isPro ? Colors.white.withValues(alpha: 0.9) : Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (!iapState.isPro)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF59E0B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => PaywallModal.show(context),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, size: 18),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Nâng Cấp VIP Ngay',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade800,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => ref.read(iapProvider.notifier).restorePurchases(),
                            child: const Text('Khôi phục', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Streak & Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildModernStatCard(
                      title: 'Chuỗi học',
                      value: '${state.currentStreak} ngày',
                      subtitle: 'Kỷ lục: ${state.longestStreak} ngày',
                      icon: Icons.local_fire_department_rounded,
                      gradient: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModernStatCard(
                      title: 'Kinh nghiệm',
                      value: '${state.totalXp} XP',
                      subtitle: 'Cần ${nextLevelXp - state.totalXp} XP lên cấp',
                      icon: Icons.star_rounded,
                      gradient: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // XP Progress Bar Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tiến độ Cấp $level', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('${(currentLevelProgress * 100).toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: currentLevelProgress,
                        backgroundColor: Colors.grey.shade100,
                        color: AppTheme.primary,
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Badges Section
              const Text('Huy hiệu danh giá', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildBadgePill('🌟 Khởi đầu mới', state.badges.contains('newbie_starter')),
                  _buildBadgePill('🔥 Chăm chỉ 3 ngày', state.currentStreak >= 3),
                  _buildBadgePill('⚡ Bậc thầy A-A-A', state.totalXp >= 150),
                  _buildBadgePill('🤖 Gia Sư AI Master', state.totalXp >= 250),
                ],
              ),
              const SizedBox(height: 20),

              // PocketBase Server Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.dns_rounded, color: Color(0xFF059669), size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Máy chủ PocketBase Golang',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'verd.phuongdan.io.vn • IAP & AI Gateway',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Online', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildModernStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildBadgePill(String title, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUnlocked ? AppTheme.primarySubtle : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked ? AppTheme.primary.withValues(alpha: 0.3) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isUnlocked ? AppTheme.primary : Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            size: 14,
            color: isUnlocked ? AppTheme.primary : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
