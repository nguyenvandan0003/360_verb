class Verb {
  final String id;
  final String v1;
  final String v2;
  final String v3;
  final String ipaV1;
  final String ipaV2;
  final String ipaV3;
  final String meaningVi;
  final String morphGroup; // AAA, ABA, ABB, ABC
  final String cefrLevel; // A1, A2, B1, B2, C1, C2
  final int commonRank;
  final String exampleSentence;
  final String exampleSentenceVi;
  final String? audioV1;
  final String? audioV2;
  final String? audioV3;

  const Verb({
    required this.id,
    required this.v1,
    required this.v2,
    required this.v3,
    required this.ipaV1,
    required this.ipaV2,
    required this.ipaV3,
    required this.meaningVi,
    required this.morphGroup,
    required this.cefrLevel,
    required this.commonRank,
    required this.exampleSentence,
    required this.exampleSentenceVi,
    this.audioV1,
    this.audioV2,
    this.audioV3,
  });

  factory Verb.fromJson(Map<String, dynamic> json) {
    return Verb(
      id: json['id'] as String? ?? '',
      v1: json['v1'] as String? ?? '',
      v2: json['v2'] as String? ?? '',
      v3: json['v3'] as String? ?? '',
      ipaV1: json['ipa_v1'] as String? ?? '',
      ipaV2: json['ipa_v2'] as String? ?? '',
      ipaV3: json['ipa_v3'] as String? ?? '',
      meaningVi: json['meaning_vi'] as String? ?? '',
      morphGroup: json['morph_group'] as String? ?? 'ABB',
      cefrLevel: json['cefr_level'] as String? ?? 'A1',
      commonRank: (json['common_rank'] as num?)?.toInt() ?? 999,
      exampleSentence: json['example_sentence'] as String? ?? '',
      exampleSentenceVi: json['example_sentence_vi'] as String? ?? '',
      audioV1: json['audio_v1'] as String?,
      audioV2: json['audio_v2'] as String?,
      audioV3: json['audio_v3'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'v1': v1,
        'v2': v2,
        'v3': v3,
        'ipa_v1': ipaV1,
        'ipa_v2': ipaV2,
        'ipa_v3': ipaV3,
        'meaning_vi': meaningVi,
        'morph_group': morphGroup,
        'cefr_level': cefrLevel,
        'common_rank': commonRank,
        'example_sentence': exampleSentence,
        'example_sentence_vi': exampleSentenceVi,
        'audio_v1': audioV1,
        'audio_v2': audioV2,
        'audio_v3': audioV3,
      };
}
