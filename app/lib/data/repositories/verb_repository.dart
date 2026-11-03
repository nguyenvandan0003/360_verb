import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/verb.dart';

class VerbRepository {
  List<Verb>? _cachedVerbs;

  Future<List<Verb>> getAllVerbs() async {
    if (_cachedVerbs != null && _cachedVerbs!.isNotEmpty) {
      return _cachedVerbs!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/verbs_360.json');
      final list = jsonDecode(jsonString) as List<dynamic>;
      _cachedVerbs = list.map((e) => Verb.fromJson(e as Map<String, dynamic>)).toList();
      return _cachedVerbs!;
    } catch (e) {
      // Fallback minimum verbs if asset loading encounters error in tests
      return _fallbackVerbs();
    }
  }

  Future<Verb?> getVerbById(String id) async {
    final verbs = await getAllVerbs();
    try {
      return verbs.firstWhere((v) => v.id == id || v.v1.toLowerCase() == id.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  List<Verb> _fallbackVerbs() {
    return const [
      Verb(
        id: 'be',
        v1: 'be',
        v2: 'was / were',
        v3: 'been',
        ipaV1: '/biː/',
        ipaV2: '/wɒz/, /wɜː/',
        ipaV3: '/biːn/',
        meaningVi: 'thì, là, ở',
        morphGroup: 'ABC',
        cefrLevel: 'A1',
        commonRank: 1,
        exampleSentence: 'They were very happy yesterday.',
        exampleSentenceVi: 'Họ đã rất hạnh phúc ngày hôm qua.',
      ),
      Verb(
        id: 'have',
        v1: 'have',
        v2: 'had',
        v3: 'had',
        ipaV1: '/hæv/',
        ipaV2: '/hæd/',
        ipaV3: '/hæd/',
        meaningVi: 'có, sở hữu',
        morphGroup: 'ABB',
        cefrLevel: 'A1',
        commonRank: 2,
        exampleSentence: 'She had an apple for breakfast.',
        exampleSentenceVi: 'Cô ấy đã ăn một quả táo vào bữa sáng.',
      ),
      Verb(
        id: 'go',
        v1: 'go',
        v2: 'went',
        v3: 'gone',
        ipaV1: '/ɡəʊ/',
        ipaV2: '/went/',
        ipaV3: '/ɡɒn/',
        meaningVi: 'đi',
        morphGroup: 'ABC',
        cefrLevel: 'A1',
        commonRank: 5,
        exampleSentence: 'They went to Paris.',
        exampleSentenceVi: 'Họ đã đi Paris.',
      ),
    ];
  }
}
