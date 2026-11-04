import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/verb.dart';
import '../../logic/ai_providers.dart';
import '../../logic/auth_provider.dart';
import '../../logic/tts_provider.dart';
import '../widgets/auth_modal.dart';
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
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(verb.v1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Phát âm cả 3 thể',
            onPressed: () => tts.speak('${verb.v1}, ${verb.v2}, ${verb.v3}'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 3 Columns Card (V1 - V2 - V3)
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
                // 3 Cards Row
                Row(
                  children: [
                    Expanded(child: _buildFormCard('V1: Nguyên thể', verb.v1, verb.ipaV1, const Color(0xFF3B82F6), () => tts.speak(verb.v1))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormCard('V2: Quá khứ', verb.v2, verb.ipaV2, const Color(0xFFF59E0B), () => tts.speak(verb.v2))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFormCard('V3: Phân từ II', verb.v3, verb.ipaV3, const Color(0xFF10B981), () => tts.speak(verb.v3))),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Tags & Meaning
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Quy luật: ${verb.morphGroup}',
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Cấp độ: ${verb.cefrLevel}',
                        style: const TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  verb.meaningVi,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Standard Example Sentence
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
                const Row(
                  children: [
                    Icon(Icons.format_quote_rounded, color: AppTheme.primary, size: 20),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ví dụ chuẩn',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  verb.exampleSentence,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  verb.exampleSentenceVi,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.volume_up_outlined, size: 18),
                    label: const Text('Nghe phát âm', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => tts.speak(verb.exampleSentence),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // AI Context Generator Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gia Sư AI',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          Text(
                            'Sinh 3 ví dụ thực tế theo ngữ cảnh',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Topics Wrap
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _topics.map((t) {
                    final isSelected = _selectedTopic == t.key;
                    return ChoiceChip(
                      label: Text(t.label),
                      selected: isSelected,
                      selectedColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: isSelected ? const Color(0xFF065F46) : Colors.black87,
                      ),
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
                const SizedBox(height: 14),

                if (!_loadAiExamples)
                  Center(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF059669),
                        side: const BorderSide(color: Color(0xFF10B981)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (!authState.isAuthenticated) {
                          AuthModal.show(context);
                          return;
                        }
                        setState(() => _loadAiExamples = true);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.psychology_outlined, size: 20),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Tạo 3 ví dụ AI theo chủ đề',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Consumer(
                    builder: (context, ref, _) {
                      final examplesAsync = ref.watch(
                        contextExamplesFamilyProvider((
                          verbV1: verb.v1,
                          topic: _selectedTopic,
                          token: authState.token,
                        )),
                      );

                      return examplesAsync.when(
                        data: (examples) {
                          return Column(
                            children: examples.map((ex) {
                              final isV1 = ex.formUsed == 'V1';
                              final isV2 = ex.formUsed == 'V2';
                              final badgeColor = isV1
                                  ? const Color(0xFF3B82F6)
                                  : (isV2 ? const Color(0xFFF59E0B) : const Color(0xFF10B981));

                              return Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: badgeColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ex.formUsed,
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(ex.english, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.3)),
                                          const SizedBox(height: 3),
                                          Text(ex.vietnamese, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.volume_up_outlined, size: 20, color: AppTheme.primary),
                                      visualDensity: VisualDensity.compact,
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
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: Color(0xFF10B981)),
                          ),
                        ),
                        error: (err, _) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text('Lỗi sinh ví dụ: $err', style: const TextStyle(color: Colors.red)),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Button to Practice Writing
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AiWritingScreen(initialVerb: verb)),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_note_rounded),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Luyện Viết Câu Với Gia Sư AI',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFormCard(String title, String form, String ipa, Color color, VoidCallback onPlay) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              form,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              ipa,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          IconButton(
            icon: Icon(Icons.volume_up_rounded, size: 18, color: color),
            onPressed: onPlay,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
