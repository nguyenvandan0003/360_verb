import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/verb.dart';
import '../../../logic/gamification_providers.dart';
import '../../../logic/tts_provider.dart';
import '../../../logic/verb_providers.dart';

class FillBlanksScreen extends ConsumerStatefulWidget {
  const FillBlanksScreen({super.key});

  @override
  ConsumerState<FillBlanksScreen> createState() => _FillBlanksScreenState();
}

class _FillBlanksScreenState extends ConsumerState<FillBlanksScreen> {
  final _v2Controller = TextEditingController();
  final _v3Controller = TextEditingController();
  int _currentIndex = 0;
  bool _submitted = false;
  bool _isCorrect = false;
  int _score = 0;

  @override
  void dispose() {
    _v2Controller.dispose();
    _v3Controller.dispose();
    super.dispose();
  }

  void _checkAnswer(Verb verb) {
    final v2Ans = _v2Controller.text.trim().toLowerCase();
    final v3Ans = _v3Controller.text.trim().toLowerCase();

    final v2Expected = verb.v2.toLowerCase();
    final v3Expected = verb.v3.toLowerCase();

    // Support multiple forms e.g. "got / gotten"
    final isV2Ok = v2Expected.contains(v2Ans) && v2Ans.isNotEmpty;
    final isV3Ok = v3Expected.contains(v3Ans) && v3Ans.isNotEmpty;

    setState(() {
      _submitted = true;
      _isCorrect = isV2Ok && isV3Ok;
      if (_isCorrect) {
        _score += 15;
        ref.read(gamificationProvider.notifier).addXp(15);
      }
    });
  }

  void _nextWord(int total) {
    setState(() {
      _v2Controller.clear();
      _v3Controller.clear();
      _submitted = false;
      _currentIndex = (_currentIndex + 1) % total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allVerbsAsync = ref.watch(allVerbsProvider);
    final tts = ref.watch(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Điền khuyết V2 & V3'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Điểm: $_score',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
              ),
            ),
          ),
        ],
      ),
      body: allVerbsAsync.when(
        data: (verbs) {
          if (verbs.isEmpty) return const Center(child: Text('Không có dữ liệu'));
          final verb = verbs[_currentIndex];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / 20.0,
                  backgroundColor: Colors.grey.shade200,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 24),

                // Question Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Từ #${verb.commonRank} • ${verb.morphGroup}',
                            style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              verb.v1,
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary),
                              onPressed: () => tts.speak(verb.v1),
                            ),
                          ],
                        ),
                        Text(
                          verb.ipaV1,
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nghĩa: ${verb.meaningVi}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Input V2
                TextField(
                  controller: _v2Controller,
                  enabled: !_submitted,
                  decoration: InputDecoration(
                    labelText: 'Dạng quá khứ (V2 / Past Simple)',
                    hintText: 'ví dụ: ${verb.v1 == "go" ? "went" : ""}',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Input V3
                TextField(
                  controller: _v3Controller,
                  enabled: !_submitted,
                  decoration: InputDecoration(
                    labelText: 'Dạng phân từ (V3 / Past Participle)',
                    hintText: 'ví dụ: ${verb.v1 == "go" ? "gone" : ""}',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit or Feedback
                if (!_submitted)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _checkAnswer(verb),
                    child: const Text('Kiểm tra đáp án', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _isCorrect ? Colors.green : Colors.red),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isCorrect ? Icons.check_circle : Icons.cancel, color: _isCorrect ? Colors.green : Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              _isCorrect ? 'Chính xác! (+15 XP)' : 'Chưa đúng rồi!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _isCorrect ? Colors.green.shade900 : Colors.red.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Đáp án đúng: V2 = ${verb.v2} | V3 = ${verb.v3}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _nextWord(verbs.length),
                    child: const Text('Từ tiếp theo →', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}
