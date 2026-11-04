import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/verb.dart';
import '../../logic/verb_providers.dart';
import '../../logic/tts_provider.dart';
import 'verb_detail_screen.dart';

class DictionaryScreen extends ConsumerWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredVerbsAsync = ref.watch(filteredVerbsProvider);
    final selectedMorph = ref.watch(selectedMorphGroupProvider);
    final selectedCefr = ref.watch(selectedCefrLevelProvider);
    final tts = ref.watch(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Từ Điển 360 Động Từ'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo V1, V2, V3 hoặc nghĩa tiếng Việt...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).setQuery(val);
              },
            ),
          ),

          // Filter Chips Horizontal Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Tất cả 360',
                  isSelected: selectedMorph == null && selectedCefr == null,
                  onSelected: (_) {
                    ref.read(selectedMorphGroupProvider.notifier).setGroup(null);
                    ref.read(selectedCefrLevelProvider.notifier).setLevel(null);
                  },
                ),
                const SizedBox(width: 8),
                ...['AAA', 'ABB', 'ABC', 'ABA'].map((group) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: 'Nhóm $group',
                      isSelected: selectedMorph == group,
                      onSelected: (selected) {
                        ref.read(selectedMorphGroupProvider.notifier).setGroup(selected ? group : null);
                      },
                    ),
                  );
                }),
                Container(
                  height: 20,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                ),
                ...['A1', 'A2', 'B1', 'B2', 'C1'].map((cefr) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: cefr,
                      isSelected: selectedCefr == cefr,
                      onSelected: (selected) {
                        ref.read(selectedCefrLevelProvider.notifier).setLevel(selected ? cefr : null);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Verb List
          Expanded(
            child: filteredVerbsAsync.when(
              data: (verbs) {
                if (verbs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 14),
                        Text(
                          'Không tìm thấy động từ nào phù hợp',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: verbs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final verb = verbs[index];
                    return _buildModernVerbCard(context, verb, tts);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi tải dữ liệu: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppTheme.primarySubtle,
      side: BorderSide(
        color: isSelected ? AppTheme.primary : Colors.grey.shade300,
        width: isSelected ? 1.5 : 1,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? AppTheme.primary : Colors.black87,
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildModernVerbCard(BuildContext context, Verb verb, dynamic tts) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VerbDetailScreen(verb: verb)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Rank, Forms, Audio
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${verb.commonRank}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildFormTag(verb.v1, const Color(0xFF3B82F6)),
                          const Icon(Icons.arrow_right_alt_rounded, size: 16, color: Colors.grey),
                          _buildFormTag(verb.v2, const Color(0xFFF59E0B)),
                          const Icon(Icons.arrow_right_alt_rounded, size: 16, color: Colors.grey),
                          _buildFormTag(verb.v3, const Color(0xFF10B981)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primary, size: 22),
                      tooltip: 'Phát âm V1, V2, V3',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        tts.speak('${verb.v1}, ${verb.v2}, ${verb.v3}');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Meaning & IPA
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        verb.meaningVi,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Sub badges: IPA, MorphGroup, CEFR
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        verb.ipaV1,
                        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        verb.morphGroup,
                        style: TextStyle(fontSize: 10, color: Colors.purple.shade700, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        verb.cefrLevel,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF065F46), fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}
