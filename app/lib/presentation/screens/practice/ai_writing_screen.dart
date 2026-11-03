import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/verb.dart';
import '../../../logic/ai_providers.dart';
import '../../../logic/gamification_providers.dart';
import '../../../logic/tts_provider.dart';
import '../../../logic/verb_providers.dart';

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
    final verb = _selectedVerb;
    final text = _sentenceController.text.trim();
    if (verb == null || text.isEmpty) return;

    ref.read(aiEvaluationProvider.notifier).evaluate(
          verbV1: verb.v1,
          targetForm: _targetForm,
          userSentence: text,
        );

    ref.read(gamificationProvider.notifier).addXp(20);
  }

  @override
  Widget build(BuildContext context) {
    final allVerbsAsync = ref.watch(allVerbsProvider);
    final evalAsync = ref.watch(aiEvaluationProvider);
    final tts = ref.watch(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Gia Sư: Luyện Viết Câu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm lại / Xóa câu',
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Verb Selection & Target Form
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('1. Chọn Động Từ & Thể cần luyện tập', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Verb>(
                          initialValue: verb,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: verbs.map((v) {
                            return DropdownMenuItem<Verb>(
                              value: v,
                              child: Text('${v.v1} (${v.v2} - ${v.v3}) : ${v.meaningVi}'),
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
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Thể yêu cầu:', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(width: 12),
                            ChoiceChip(
                              label: Text('V2: ${verb.v2}'),
                              selected: _targetForm == 'V2',
                              onSelected: (val) {
                                if (val) setState(() => _targetForm = 'V2');
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text('V3: ${verb.v3}'),
                              selected: _targetForm == 'V3',
                              onSelected: (val) {
                                if (val) setState(() => _targetForm = 'V3');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sentence Input Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('2. Viết câu tiếng Anh của bạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          'Yêu cầu: Đặt câu hoàn chỉnh có chứa từ "${_targetForm == "V2" ? verb.v2 : verb.v3}".',
                          style: TextStyle(fontSize: 12, color: Colors.indigo.shade600),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _sentenceController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Nhập câu tiếng Anh tại đây...',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: evalAsync.isLoading ? null : _submitSentence,
                          icon: evalAsync.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.psychology_rounded),
                          label: Text(
                            evalAsync.isLoading ? 'AI đang chấm câu...' : 'Gia sư AI Chấm & Phân Tích',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Evaluation Results Card
                evalAsync.when(
                  data: (eval) {
                    if (eval == null) return const SizedBox.shrink();

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: eval.isCorrect ? Colors.green.shade300 : Colors.orange.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      eval.isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                                      color: eval.isCorrect ? Colors.green : Colors.orange,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      eval.isCorrect ? 'Đánh giá tốt' : 'Cần lưu ý',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: eval.isCorrect ? Colors.green.shade900 : Colors.orange.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${eval.score} / 10 Điểm',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            _buildFeedbackSection('Thì sử dụng', eval.tenseUsed),
                            const SizedBox(height: 8),
                            _buildFeedbackSection('Nhận xét AI', eval.feedback),
                            const SizedBox(height: 8),
                            _buildFeedbackSection('Giải thích ngữ pháp', eval.grammarExplanation),
                            if (eval.improvedSentence.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Gợi ý viết tự nhiên hơn:',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            eval.improvedSentence,
                                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal.shade900),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.volume_up_rounded, color: Colors.teal),
                                      onPressed: () => tts.speak(eval.improvedSentence),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (err, _) => Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Lỗi chấm câu: $err', style: TextStyle(color: Colors.red.shade900)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildFeedbackSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(content, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
