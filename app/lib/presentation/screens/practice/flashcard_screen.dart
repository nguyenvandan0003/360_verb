import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/verb.dart';
import '../../../logic/gamification_providers.dart';
import '../../../logic/srs_providers.dart';
import '../../../logic/tts_provider.dart';
import '../../../logic/verb_providers.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({super.key});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  int _currentIndex = 0;
  int _reviewedCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  void _submitGrade(Verb currentVerb, int grade, int totalCards) {
    ref.read(srsProgressProvider.notifier).reviewVerb(currentVerb.id, grade);
    ref.read(gamificationProvider.notifier).addXp(10);

    setState(() {
      _reviewedCount++;
      if (_currentIndex < totalCards - 1) {
        _currentIndex++;
        _isFront = true;
        _controller.reset();
      } else {
        _currentIndex = totalCards; // Completed
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dueVerbsAsync = ref.watch(dueVerbsProvider);
    final allVerbsAsync = ref.watch(allVerbsProvider);
    final tts = ref.watch(ttsServiceProvider);

    final verbsList = dueVerbsAsync.value?.isNotEmpty == true
        ? dueVerbsAsync.value!
        : (allVerbsAsync.value ?? []);

    if (verbsList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thẻ nhớ Flashcard SRS')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentIndex >= verbsList.length) {
      // Completion View
      return Scaffold(
        appBar: AppBar(title: const Text('Hoàn thành')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text(
                  'Tuyệt vời!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn đã hoàn thành phiên ôn tập $_reviewedCount thẻ hôm nay.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${_reviewedCount * 10} XP Kinh nghiệm',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Quay lại Trang chủ', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final verb = verbsList[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Thẻ ${_currentIndex + 1} / ${verbsList.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () => tts.speak(verb.v1),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: (_currentIndex + 1) / verbsList.length,
                backgroundColor: Colors.grey.shade200,
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 20),

              // Flip Card Area
              Expanded(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final angle = _animation.value * pi;
                      final isFrontVisible = angle < pi / 2;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: isFrontVisible
                            ? _buildFrontCard(verb, tts)
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _buildBackCard(verb, tts),
                              ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              if (_isFront)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _flipCard,
                  icon: const Icon(Icons.touch_app_rounded),
                  label: const Text('Chạm để lật thẻ xem đáp án', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              else
                Column(
                  children: [
                    const Text(
                      'Đánh giá mức độ ghi nhớ của bạn:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildGradeButton('Quên', '1 ngày', Colors.red, () => _submitGrade(verb, 1, verbsList.length)),
                        const SizedBox(width: 8),
                        _buildGradeButton('Khó', '2 ngày', Colors.orange, () => _submitGrade(verb, 3, verbsList.length)),
                        const SizedBox(width: 8),
                        _buildGradeButton('Tốt', '4 ngày', Colors.blue, () => _submitGrade(verb, 4, verbsList.length)),
                        const SizedBox(width: 8),
                        _buildGradeButton('Dễ', '7 ngày', const Color(0xFF10B981), () => _submitGrade(verb, 5, verbsList.length)),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(Verb verb, dynamic tts) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Dạng V1 (Infinitive) • ${verb.cefrLevel}',
                  style: TextStyle(color: Colors.indigo.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                verb.v1,
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                verb.ipaV1,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, size: 28, color: AppTheme.primary),
                onPressed: () => tts.speak(verb.v1),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chạm vào thẻ để xem V2, V3 & Nghĩa',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard(Verb verb, dynamic tts) {
    return Card(
      elevation: 3,
      color: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              verb.meaningVi,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Quá khứ (V2)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(verb.v2, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
                      Text(verb.ipaV2, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey)),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Column(
                    children: [
                      const Text('Phân từ (V3)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(verb.v3, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                      Text(verb.ipaV3, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    verb.exampleSentence,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    verb.exampleSentenceVi,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeButton(String label, String interval, Color color, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(interval, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
