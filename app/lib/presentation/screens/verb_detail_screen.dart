import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/verb.dart';
import '../../logic/ai_providers.dart';
import '../../logic/tts_provider.dart';
import 'practice/ai_writing_screen.dart';

class VerbDetailScreen extends ConsumerStatefulWidget {
  final Verb verb;

  const VerbDetailScreen({super.key, required this.verb});

  @override
  ConsumerState<VerbDetailScreen> createState() => _VerbDetailScreenState();
}

class _VerbDetailScreenState extends ConsumerState<VerbDetailScreen> {
  String _selectedTopic = 'daily life';
  bool _loadAiExamples = false;

  final List<({String key, String label})> _topics = const [
    (key: 'daily life', label: 'Đời sống'),
    (key: 'travel', label: 'Du lịch'),
    (key: 'business', label: 'Công việc'),
    (key: 'technology', label: 'Công nghệ'),
  ];

  @override
  Widget build(BuildContext context) {
    final verb = widget.verb;
    final tts = ref.watch(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(verb.v1),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () => tts.speak('${verb.v1}, ${verb.v2}, ${verb.v3}'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 3 Columns Card (V1 - V2 - V3)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFormColumn('V1 (Infinitive)', verb.v1, verb.ipaV1, () => tts.speak(verb.v1)),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 18),
                      _buildFormColumn('V2 (Past Simple)', verb.v2, verb.ipaV2, () => tts.speak(verb.v2)),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 18),
                      _buildFormColumn('V3 (Past Participle)', verb.v3, verb.ipaV3, () => tts.speak(verb.v3)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Nhóm hình thái: ${verb.morphGroup}',
                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Trình độ: ${verb.cefrLevel}',
                          style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    verb.meaningVi,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Standard Example Sentence
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.format_quote_rounded, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text('Ví dụ thực tế', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    verb.exampleSentence,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    verb.exampleSentenceVi,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.volume_up_outlined, size: 18),
                      label: const Text('Nghe câu'),
                      onPressed: () => tts.speak(verb.exampleSentence),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // AI Context Generator Section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.purple, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Gia Sư: Sinh ví dụ theo ngữ cảnh',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _topics.map((t) {
                      final isSelected = _selectedTopic == t.key;
                      return ChoiceChip(
                        label: Text(t.label),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _selectedTopic = t.key;
                              _loadAiExamples = true;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  if (!_loadAiExamples)
                    Center(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.psychology_outlined),
                        label: const Text('Tạo 3 ví dụ AI theo chủ đề'),
                        onPressed: () {
                          setState(() => _loadAiExamples = true);
                        },
                      ),
                    )
                  else
                    Consumer(
                      builder: (context, ref, _) {
                        final examplesAsync = ref.watch(
                          contextExamplesFamilyProvider((verbV1: verb.v1, topic: _selectedTopic)),
                        );

                        return examplesAsync.when(
                          data: (examples) {
                            return Column(
                              children: examples.map((ex) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.purple.shade100),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.purple,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          ex.formUsed,
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(ex.english, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                            const SizedBox(height: 2),
                                            Text(ex.vietnamese, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.volume_up_outlined, size: 18),
                                        onPressed: () => tts.speak(ex.english),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (err, _) => Center(child: Text('Lỗi sinh ví dụ: $err')),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Button to Practice Writing
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('Thực hành viết câu AI với từ này', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AiWritingScreen(initialVerb: verb)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormColumn(String title, String form, String ipa, VoidCallback onPlay) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(form, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(ipa, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
        const SizedBox(height: 4),
        IconButton(
          icon: const Icon(Icons.volume_up_rounded, size: 20, color: AppTheme.primary),
          onPressed: onPlay,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
