import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/verb.dart';
import '../data/repositories/verb_repository.dart';

final verbRepositoryProvider = Provider<VerbRepository>((ref) {
  return VerbRepository();
});

final allVerbsProvider = FutureProvider<List<Verb>>((ref) async {
  final repo = ref.watch(verbRepositoryProvider);
  return repo.getAllVerbs();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String q) => state = q;
  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class MorphFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setGroup(String? group) => state = group;
}

final selectedMorphGroupProvider = NotifierProvider<MorphFilterNotifier, String?>(MorphFilterNotifier.new);

class CefrFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setLevel(String? level) => state = level;
}

final selectedCefrLevelProvider = NotifierProvider<CefrFilterNotifier, String?>(CefrFilterNotifier.new);

final filteredVerbsProvider = Provider<AsyncValue<List<Verb>>>((ref) {
  final allVerbsAsync = ref.watch(allVerbsProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final morph = ref.watch(selectedMorphGroupProvider);
  final cefr = ref.watch(selectedCefrLevelProvider);

  return allVerbsAsync.whenData((verbs) {
    return verbs.where((verb) {
      if (query.isNotEmpty) {
        final matchesQuery = verb.v1.toLowerCase().contains(query) ||
            verb.v2.toLowerCase().contains(query) ||
            verb.v3.toLowerCase().contains(query) ||
            verb.meaningVi.toLowerCase().contains(query);
        if (!matchesQuery) return false;
      }
      if (morph != null && verb.morphGroup != morph) {
        return false;
      }
      if (cefr != null && verb.cefrLevel != cefr) {
        return false;
      }
      return true;
    }).toList();
  });
});
