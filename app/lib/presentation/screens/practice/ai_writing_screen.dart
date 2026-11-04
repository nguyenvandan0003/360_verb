import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/verb.dart';
import '../../../logic/ai_providers.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/gamification_providers.dart';
import '../../../logic/iap_provider.dart';
import '../../../logic/tts_provider.dart';
import '../../../logic/verb_providers.dart';
import '../../widgets/auth_modal.dart';
import '../../widgets/paywall_modal.dart';

class AiWritingScreen extends ConsumerStatefulWidget {
  final Verb? initialVerb;

  const AiWritingScreen({super.key, this.initialVerb});

  @override
  ConsumerState<AiWritingScreen> createState() => _AiWritingScreenState();
}

class _AiWritingScreenState extends ConsumerState<AiWritingScreen> {
  late Verb? _selectedVerb;
  String _targetForm = 'V2';
  final _sentenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedVerb = widget.initialVerb;
  }

  @override
  void dispose() {
    _sentenceController.dispose();
    super.dispose();
  }

  void _submitSentence() {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      AuthModal.show(context);
      return;
    }

    final verb = _selectedVerb;
    final text = _sentenceController.text.trim();
    if (verb == null || text.isEmpty) return;

    ref.read(aiEvaluationProvider.notifier).evaluate(
          verbV1: verb.v1,
          targetForm: _targetForm,
          userSentence: text,
          token: authState.token,
        );

    ref.read(gamificationProvider.notifier).addXp(25);
  }

  @override
  Widget build(BuildContext context) {
    final allVerbsAsync = ref.watch(allVerbsProvider);
    final evalAsync = ref.watch(aiEvaluationProvider);
    final authState = ref.watch(authProvider);
    final iapState = ref.watch(iapProvider);
    final tts = ref.watch(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gia Sư AI Viết Câu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm lại câu mới',
            onPressed: () {
              _sentenceController.clear();
              ref.read(aiEvaluationProvider.notifier).reset();
            },
          ),
        ],
      ),
      body: allVerbsAsync.when(
              data: (verbs) {
                if (verbs.isEmpty) return const Center(child: Text('Không có dữ liệu'));
                _selectedVerb ??= verbs.first;
                final verb = _selectedVerb!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header badge
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iapState.isPro
                              ? Colors.amber.shade50
                              : const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: iapState.isPro
                                ? Colors.amber.shade300
                                : const Color(0xFF10B981).withValues(alpha: 0.2),
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                            final isCompact = constraints.maxWidth < 340 || (constraints.maxWidth < 400 && textScale > 1.15);

                            if (isCompact && !iapState.isPro) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.verified_user_rounded,
                                        color: Color(0xFF059669),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Đã kết nối DeepSeek AI (${authState.user?.name ?? 'Tài khoản'})',
                                          style: const TextStyle(
                                            color: Color(0xFF065F46),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => PaywallModal.show(context),
                                      style: TextButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('Nâng cấp VIP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Icon(
                                  iapState.isPro ? Icons.workspace_premium_rounded : Icons.verified_user_rounded,
                                  color: iapState.isPro ? Colors.amber.shade900 : const Color(0xFF059669),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    iapState.isPro
                                        ? 'VIP PRO: AI DeepSeek Không giới hạn (${authState.user?.name ?? 'Tài khoản'})'
                                        : 'Đã kết nối DeepSeek AI (${authState.user?.name ?? 'Tài khoản'})',
                                    style: TextStyle(
                                      color: iapState.isPro ? Colors.amber.shade900 : const Color(0xFF065F46),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (!iapState.isPro)
                                  TextButton(
                                    onPressed: () => PaywallModal.show(context),
                                    child: const Text('Nâng cấp VIP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Step 1: Select Verb & Target Form
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
                            const Text('1. Chọn Động Từ & Thể Luyện', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<Verb>(
                              initialValue: verb,
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: verbs.map((v) {
                                return DropdownMenuItem<Verb>(
                                  value: v,
                                  child: Text(
                                    '${v.v1} (${v.v2} - ${v.v3}) : ${v.meaningVi}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (newVerb) {
                                if (newVerb != null) {
                                  setState(() {
                                    _selectedVerb = newVerb;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text('Yêu cầu chia thì:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ChoiceChip(
                                  label: Text('V2: ${verb.v2} (Quá khứ)'),
                                  selected: _targetForm == 'V2',
                                  selectedColor: AppTheme.primarySubtle,
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _targetForm == 'V2' ? AppTheme.primary : Colors.black87,
                                  ),
                                  onSelected: (val) {
                                    if (val) setState(() => _targetForm = 'V2');
                                  },
                                ),
                                ChoiceChip(
                                  label: Text('V3: ${verb.v3} (Phân từ)'),
                                  selected: _targetForm == 'V3',
                                  selectedColor: AppTheme.primarySubtle,
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _targetForm == 'V3' ? AppTheme.primary : Colors.black87,
                                  ),
                                  onSelected: (val) {
                                    if (val) setState(() => _targetForm = 'V3');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Step 2: Input User Sentence
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
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                const Text('2. Viết câu tiếng Anh của bạn', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                Text('Mục tiêu: ${_targetForm == 'V2' ? verb.v2 : verb.v3}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _sentenceController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Ví dụ: ${_targetForm == 'V2' ? 'Yesterday, I ${verb.v2} to the store.' : 'She has ${verb.v3} a new car.'}',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: evalAsync.isLoading ? null : _submitSentence,
                                icon: evalAsync.isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.send_rounded, size: 18),
                                label: Text(
                                  evalAsync.isLoading ? 'DeepSeek đang chấm...' : 'Kiểm tra câu với DeepSeek AI',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Step 3: Evaluation Result
                      evalAsync.when(
                        data: (eval) {
                          if (eval == null) return const SizedBox.shrink();
                          final isGood = eval.score >= 7;

                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isGood ? const Color(0xFF10B981) : Colors.orange,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isGood ? const Color(0xFF10B981) : Colors.orange).withValues(alpha: 0.1),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isGood ? const Color(0xFF10B981).withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isGood ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                              color: isGood ? const Color(0xFF059669) : Colors.orange.shade800,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              isGood ? 'Đạt chuẩn ngữ pháp' : 'Cần điều chỉnh',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: isGood ? const Color(0xFF065F46) : Colors.orange.shade900,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isGood ? const Color(0xFF10B981) : Colors.orange,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Điểm: ${eval.score}/10',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Thì nhận diện: ${eval.tenseUsed}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  eval.feedback,
                                  style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  eval.grammarExplanation,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                                ),
                                if (eval.improvedSentence.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 18),
                                      const SizedBox(width: 6),
                                      const Expanded(
                                        child: Text(
                                          'Câu gợi ý viết lại tự nhiên:',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.volume_up_rounded, size: 20, color: AppTheme.primary),
                                        tooltip: 'Phát âm mẫu',
                                        onPressed: () => tts.speak(eval.improvedSentence),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.grey),
                                        tooltip: 'Sao chép',
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: eval.improvedSentence));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Đã sao chép câu gợi ý.')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      eval.improvedSentence,
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (err, _) => Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            'Lỗi kết nối AI: $err',
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi tải dữ liệu: $err')),
            ),
    );
  }
}

