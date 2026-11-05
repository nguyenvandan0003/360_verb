import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/verb.dart';
import '../../logic/auth_provider.dart';
import '../../logic/gamification_providers.dart';
import '../../logic/iap_provider.dart';
import '../../logic/srs_providers.dart';
import '../../logic/tts_provider.dart';
import '../../logic/verb_providers.dart';
import '../widgets/auth_modal.dart';
import '../widgets/paywall_modal.dart';
import 'practice/fill_blanks_screen.dart';
import 'practice/speed_quiz_screen.dart';
import 'practice/ai_writing_screen.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onNavigateToDictionary;

  const HomeScreen({super.key, required this.onNavigateToDictionary});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationAsync = ref.watch(gamificationProvider);
    final dueVerbsAsync = ref.watch(dueVerbsProvider);
    final allVerbsAsync = ref.watch(allVerbsProvider);
    final authState = ref.watch(authProvider);
    final iapState = ref.watch(iapProvider);
    final tts = ref.watch(ttsServiceProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth <= 360;
    final isMobilePhone = screenWidth < 500;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: isCompact ? 8 : 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                '360 Động từ bất quy tắc',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          // Gamification streak & xp
          gamificationAsync.maybeWhen(
            data: (state) => Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFEA580C)),
                  const SizedBox(width: 2),
                  Text(
                    '${state.currentStreak}',
                    style: TextStyle(fontWeight: FontWeight.w800, color: Colors.amber.shade900, fontSize: 11),
                  ),
                  if (!isMobilePhone) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.star_rounded, size: 13, color: Color(0xFFD97706)),
                    const SizedBox(width: 1),
                    Text(
                      '${state.totalXp}',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),

          // VIP Crown Button
          InkWell(
            onTap: () => PaywallModal.show(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: iapState.isPro
                    ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)])
                    : null,
                color: iapState.isPro ? null : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: 13,
                    color: iapState.isPro ? Colors.white : Colors.amber.shade900,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    iapState.isPro ? 'VIP' : 'PRO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: iapState.isPro ? Colors.white : Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User Profile / Login quick button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: authState.isAuthenticated
                ? InkWell(
                    onTap: () => _showUserMenu(context, ref, authState),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                      ),
                      child: const CircleAvatar(
                        radius: 13,
                        backgroundColor: Color(0xFFEFF6FF),
                        child: Icon(Icons.person_rounded, size: 15, color: AppTheme.primary),
                      ),
                    ),
                  )
                : (isMobilePhone
                    ? IconButton(
                        icon: const Icon(Icons.login_rounded, size: 20, color: AppTheme.primary),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Đăng nhập',
                        onPressed: () => AuthModal.show(context),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => AuthModal.show(context),
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      )),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Greeting & Learning Subtitle
          Row(
            children: [
              Flexible(
                child: Text(
                  authState.isAuthenticated
                      ? '${_getGreeting()}, ${authState.user?.name ?? 'bạn'}!'
                      : '${_getGreeting()}!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.waving_hand_rounded, size: 22, color: Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '360 Động từ',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Gia sư AI',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                ),
              ),
              Text(
                'Làm chủ 360 động từ với SRS & phản xạ.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Banner SRS Review Due Card (Spaced Repetition Golden Time)
          dueVerbsAsync.when(
            data: (dueVerbs) {
              final count = dueVerbs.length;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 16),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'SRS Spaced Repetition',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count từ cần ôn',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      count > 0 ? 'Hôm nay có $count từ đến hạn ôn tập!' : 'Tuyệt vời! Bạn đã hoàn thành hết bài ôn hôm nay!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      count > 0
                          ? 'Ôn lại đúng thời điểm vàng giúp kích hoạt trí nhớ dài hạn vĩnh viễn.'
                          : 'Hãy rèn luyện thêm với Gia sư AI hoặc thử thách phản xạ.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FillBlanksScreen()),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 20),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              count > 0 ? 'Bắt đầu ôn tập ngay' : 'Luyện điền khuyết',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 20),

          // Daily Verb Spotlight Card (Động từ nổi bật hôm nay)
          allVerbsAsync.maybeWhen(
            data: (verbs) {
              if (verbs.isEmpty) return const SizedBox.shrink();
              final dayIndex = DateTime.now().day % verbs.length;
              final featured = verbs[dayIndex];
              return _buildSpotlightCard(context, featured, tts);
            },
            orElse: () => const SizedBox.shrink(),
          ),

          const SizedBox(height: 22),

          // Section Title: Practice Modes
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Chế độ Luyện tập',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1 Hero AI Chat Card (Interactive Chat)
          _buildHeroAiChatCard(context),
          const SizedBox(height: 12),

          // 2 Grid Cards (Fill blanks & Speed Quiz)
          Row(
            children: [
              Expanded(
                child: _buildModernPracticeCard(
                  context,
                  title: 'Điền khuyết',
                  subtitle: 'Luyện chia dạng V2 & V3 theo ngữ cảnh',
                  icon: Icons.edit_note_rounded,
                  gradient: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                  tag: 'Ngữ pháp',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FillBlanksScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernPracticeCard(
                  context,
                  title: 'Phản xạ nhanh',
                  subtitle: 'Thử thách tốc độ phản xạ 60 giây',
                  icon: Icons.bolt_rounded,
                  gradient: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                  tag: 'Tính giờ',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SpeedQuizScreen()),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          // Morphological Rules Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quy luật biến đổi 360 từ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                    ),
                    Text(
                      'Phân nhóm thông minh giúp học nhanh hơn gấp 3 lần',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onNavigateToDictionary,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Xem tất cả', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildRuleGroupTile(
            title: 'Nhóm A - A - A',
            subtitle: '3 dạng giống hệt nhau (V1 = V2 = V3)',
            examples: 'cut - cut - cut • put - put - put • let - let - let • cost - cost - cost',
            count: '32 từ',
            color: const Color(0xFF3B82F6),
            onTap: onNavigateToDictionary,
          ),
          _buildRuleGroupTile(
            title: 'Nhóm A - B - B',
            subtitle: 'Quá khứ & Phân từ giống nhau (V2 = V3)',
            examples: 'buy - bought - bought • think - thought - thought • find - found - found',
            count: '148 từ',
            color: const Color(0xFF8B5CF6),
            onTap: onNavigateToDictionary,
          ),
          _buildRuleGroupTile(
            title: 'Nhóm A - B - C',
            subtitle: '3 dạng hoàn toàn khác biệt',
            examples: 'go - went - gone • speak - spoke - spoken • take - took - taken',
            count: '162 từ',
            color: const Color(0xFFEC4899),
            onTap: onNavigateToDictionary,
          ),
          _buildRuleGroupTile(
            title: 'Nhóm A - B - A',
            subtitle: 'Nguyên thể & Phân từ giống nhau (V1 = V3)',
            examples: 'come - came - come • run - ran - run • become - became - become',
            count: '18 từ',
            color: const Color(0xFF10B981),
            onTap: onNavigateToDictionary,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSpotlightCard(BuildContext context, Verb verb, dynamic tts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: Color(0xFF2563EB)),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'TỪ NỔI BẬT HÔM NAY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1D4ED8),
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, size: 20, color: AppTheme.primary),
                tooltip: 'Nghe phát âm',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => tts.speak('${verb.v1}, ${verb.v2}, ${verb.v3}'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                verb.v1,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A)),
              ),
              Text(
                '→ ${verb.v2} → ${verb.v3}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            verb.meaningVi,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.25)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: const Text(
                'Luyện đàm thoại với Gia sư AI',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AiWritingScreen(initialVerb: verb)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAiChatCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiWritingScreen()),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.35),
              width: 1.5,
            ),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                const Color(0xFF10B981).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gia sư AI',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          'Đàm thoại tương tác 1:1',
                          style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'MỚI: Dạng Chat',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.format_quote_rounded, size: 16, color: Color(0xFF10B981)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'AI đặt câu hỏi thách đố, bạn trả lời & nhận đánh giá ngữ pháp chuẩn xác tức thì.',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Gia sư AI • Chấm điểm tức thì',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bắt đầu chat',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernPracticeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required String tag,
    bool isAi = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isAi ? const Color(0xFF10B981).withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06),
              width: isAi ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.first.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAi ? const Color(0xFF10B981).withValues(alpha: 0.12) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isAi ? const Color(0xFF059669) : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleGroupTile({
    required String title,
    required String subtitle,
    required String examples,
    required String count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count,
                              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        examples,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context, WidgetRef ref, AuthState authState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primarySubtle,
                    child: const Icon(Icons.person_rounded, size: 28, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.name ?? 'Học viên',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                        ),
                        Text(
                          authState.user?.email ?? '',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF10B981)),
                title: const Text('Trạng thái Gia sư AI'),
                subtitle: const Text('Đã kích hoạt • Gateway PocketBase'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(authProvider.notifier).logout();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã đăng xuất tài khoản.')),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
