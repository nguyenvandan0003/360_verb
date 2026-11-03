class AiEvaluation {
  final int score;
  final bool isCorrect;
  final String tenseUsed;
  final String feedback;
  final String grammarExplanation;
  final String improvedSentence;

  const AiEvaluation({
    required this.score,
    required this.isCorrect,
    required this.tenseUsed,
    required this.feedback,
    required this.grammarExplanation,
    required this.improvedSentence,
  });

  factory AiEvaluation.fromJson(Map<String, dynamic> json) {
    return AiEvaluation(
      score: (json['score'] as num?)?.toInt() ?? 0,
      isCorrect: json['is_correct'] as bool? ?? false,
      tenseUsed: json['tense_used'] as String? ?? '',
      feedback: json['feedback'] as String? ?? '',
      grammarExplanation: json['grammar_explanation'] as String? ?? '',
      improvedSentence: json['improved_sentence'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'is_correct': isCorrect,
        'tense_used': tenseUsed,
        'feedback': feedback,
        'grammar_explanation': grammarExplanation,
        'improved_sentence': improvedSentence,
      };
}

class ContextExample {
  final String english;
  final String vietnamese;
  final String formUsed;

  const ContextExample({
    required this.english,
    required this.vietnamese,
    required this.formUsed,
  });

  factory ContextExample.fromJson(Map<String, dynamic> json) {
    return ContextExample(
      english: json['english'] as String? ?? '',
      vietnamese: json['vietnamese'] as String? ?? '',
      formUsed: json['form_used'] as String? ?? 'V1',
    );
  }

  Map<String, dynamic> toJson() => {
        'english': english,
        'vietnamese': vietnamese,
        'form_used': formUsed,
      };
}
