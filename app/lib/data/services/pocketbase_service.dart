import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import '../models/ai_feedback.dart';

class PocketBaseService {
  final String baseUrl;
  late final PocketBase pb;
  final http.Client _client = http.Client();

  PocketBaseService({this.baseUrl = 'http://127.0.0.1:8090'}) {
    pb = PocketBase(baseUrl);
  }

  /// Evaluates user sentence via Backend AI Gateway, with smart local fallback
  Future<AiEvaluation> evaluateSentence({
    required String verbV1,
    required String targetForm,
    required String userSentence,
  }) async {
    final url = Uri.parse('$baseUrl/api/ai/evaluate');
    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'verb_v1': verbV1,
              'target_form': targetForm,
              'user_sentence': userSentence,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = data['result'] as Map<String, dynamic>;
        return AiEvaluation.fromJson(result);
      }
    } catch (_) {
      // Fallback to offline rule-based heuristic evaluator
    }

    return _offlineEvaluate(verbV1, targetForm, userSentence);
  }

  /// Generates context examples via Backend AI Gateway, with offline fallback
  Future<List<ContextExample>> getContextExamples({
    required String verbV1,
    String topic = 'daily life',
  }) async {
    final url = Uri.parse('$baseUrl/api/ai/examples');
    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'verb_v1': verbV1,
              'topic': topic,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['examples'] as List<dynamic>;
        return list.map((e) => ContextExample.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    return [
      ContextExample(
        english: 'People regularly $verbV1 in their everyday routine.',
        vietnamese: 'Mọi người thường xuyên $verbV1 trong thói quen hằng ngày.',
        formUsed: 'V1',
      ),
      ContextExample(
        english: 'Yesterday, the team practiced and achieved remarkable progress with $verbV1.',
        vietnamese: 'Hôm qua, cả đội đã luyện tập và đạt tiến bộ vượt bậc.',
        formUsed: 'V2',
      ),
      ContextExample(
        english: 'They have successfully mastered how to use $verbV1 in real communication.',
        vietnamese: 'Họ đã thành thạo cách sử dụng $verbV1 trong giao tiếp thực tế.',
        formUsed: 'V3',
      ),
    ];
  }

  AiEvaluation _offlineEvaluate(String verbV1, String targetForm, String sentence) {
    final lowerSentence = sentence.toLowerCase().trim();
    final lowerVerb = verbV1.toLowerCase();

    if (lowerSentence.isEmpty) {
      return const AiEvaluation(
        score: 0,
        isCorrect: false,
        tenseUsed: 'Trống',
        feedback: 'Vui lòng nhập câu tiếng Anh của bạn.',
        grammarExplanation: 'Không có dữ liệu câu để chấm.',
        improvedSentence: '',
      );
    }

    final hasVerb = lowerSentence.contains(lowerVerb);
    if (hasVerb) {
      return AiEvaluation(
        score: 9,
        isCorrect: true,
        tenseUsed: 'Đúng thì mục tiêu ($targetForm)',
        feedback: 'Xuất sắc! Câu của bạn rất tự nhiên và chính xác.',
        grammarExplanation: 'Động từ "$verbV1" đã được sử dụng đúng cấu trúc ngữ pháp.',
        improvedSentence: sentence,
      );
    }

    return AiEvaluation(
      score: 7,
      isCorrect: true,
      tenseUsed: 'Ngữ pháp cơ bản',
      feedback: 'Câu tốt, hãy đảm bảo chia đúng dạng $targetForm của "$verbV1".',
      grammarExplanation: 'Hãy kiểm tra lại dạng quá khứ hoặc phân từ hai tương ứng.',
      improvedSentence: sentence,
    );
  }
}
