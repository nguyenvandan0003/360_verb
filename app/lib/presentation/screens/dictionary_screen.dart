import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        title: const Text('Tra cứu 360 Động Từ'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm V1, V2, V3 hoặc nghĩa tiếng Việt...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).setQuery(val);
              },
            ),
          ),

          // Filter Chips Horizontal Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Tất cả',
                  isSelected: selectedMorph == null && selectedCefr == null,
                  onSelected: (_) {
                    ref.read(selectedMorphGroupProvider.notifier).setGroup(null);
                    ref.read(selectedCefrLevelProvider.notifier).setLevel(null);
                  },
                ),
                const SizedBox(width: 6),
                ...['AAA', 'ABB', 'ABC', 'ABA'].map((group) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildFilterChip(
                      label: 'Nhóm $group',
                      isSelected: selectedMorph == group,
                      onSelected: (selected) {
                        ref.read(selectedMorphGroupProvider.notifier).setGroup(selected ? group : null);
                      },
                    ),
                  );
                }),
                const VerticalDivider(width: 16, thickness: 1),
                ...['A1', 'A2', 'B1', 'B2', 'C1'].map((cefr) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
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
          const Divider(height: 12),

          // Verb List
          Expanded(
            child: filteredVerbsAsync.when(
              data: (verbs) {
                if (verbs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Không tìm thấy động từ nào phù hợp', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: verbs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final verb = verbs[index];
                    return _buildVerbCard(context, verb, tts);
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
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.15),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildVerbCard(BuildContext context, Verb verb, dynamic tts) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VerbDetailScreen(verb: verb)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Rank badge
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${verb.commonRank}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo.shade700),
                ),
              ),
              const SizedBox(width: 12),

              // Forms & Meaning
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          verb.v1,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '→ ${verb.v2} → ${verb.v3}',
                          style: TextStyle(fontSize: 13, color: Colors.indigo.shade600, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      verb.meaningVi,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          verb.ipaV1,
                          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            verb.morphGroup,
                            style: TextStyle(fontSize: 10, color: Colors.purple.shade700, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            verb.cefrLevel,
                            style: TextStyle(fontSize: 10, color: Colors.teal.shade700, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Audio Pronounce Button
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF4F46E5)),
                tooltip: 'Phát âm V1, V2, V3',
                onPressed: () {
                  tts.speak('${verb.v1}, ${verb.v2}, ${verb.v3}');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
