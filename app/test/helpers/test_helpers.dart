import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/data/models/ai_feedback.dart';
import 'package:app/data/models/gamification_state.dart';
import 'package:app/data/models/srs_progress.dart';
import 'package:app/data/models/verb.dart';
import 'package:app/data/repositories/verb_repository.dart';
import 'package:app/data/services/pocketbase_service.dart';
import 'package:app/data/services/tts_service.dart';
import 'package:app/logic/gamification_providers.dart';
import 'package:app/logic/srs_providers.dart';
import 'package:app/logic/tts_provider.dart';
import 'package:app/logic/verb_providers.dart';

/// Multi-device viewport definitions matching TEST_INFRA.md matrix
class TestViewports {
  /// P1: Compact phone (iPhone SE 1st gen / narrow Android)
  static const Size compactPhone = Size(320, 568);

  /// P2: Standard phone (iPhone 12/13/14 / Galaxy S21)
  static const Size standardPhone = Size(390, 844);

  /// P3: Connected test device - Google Pixel 4 XL (99051FFBA004TL)
  /// Logical size: 1440 / 3.5 = 411.42, 3040 / 3.5 = 868.57
  static const Size pixel4xl = Size(412, 869);

  /// P4: Tablet portrait (iPad Mini / Android tablet portrait) - triggers NavigationRail (>=768dp)
  static const Size tabletPortrait = Size(768, 1024);

  /// P5: Tablet landscape (iPad Pro / Desktop web)
  static const Size tabletLandscape = Size(1024, 768);

  /// All 5 canonical viewports for matrix looping
  static const Map<String, Size> matrix = {
    'Compact Phone (320x568)': compactPhone,
    'Standard Phone (390x844)': standardPhone,
    'Pixel 4 XL (412x869)': pixel4xl,
    'Tablet Portrait (768x1024)': tabletPortrait,
    'Tablet Landscape (1024x768)': tabletLandscape,
  };
}

/// Comprehensive mock datasets for testing
class MockData {
  static const Verb verbBe = Verb(
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
  );

  static const Verb verbGo = Verb(
    id: 'go',
    v1: 'go',
    v2: 'went',
    v3: 'gone',
    ipaV1: '/ɡəʊ/',
    ipaV2: '/went/',
    ipaV3: '/ɡɒn/',
    meaningVi: 'đi, di chuyển',
    morphGroup: 'ABC',
    cefrLevel: 'A1',
    commonRank: 2,
    exampleSentence: 'She went to school early this morning.',
    exampleSentenceVi: 'Cô ấy đã đến trường sớm sáng nay.',
  );

  /// Long polysyllabic verb to test layout squeezes and text wrapping
  static const Verb verbMisunderstand = Verb(
    id: 'misunderstand',
    v1: 'misunderstand',
    v2: 'misunderstood',
    v3: 'misunderstood',
    ipaV1: '/ˌmɪsʌndəˈstænd/',
    ipaV2: '/ˌmɪsʌndəˈstʊd/',
    ipaV3: '/ˌmɪsʌndəˈstʊd/',
    meaningVi: 'hiểu lầm, hiểu sai ý',
    morphGroup: 'ABB',
    cefrLevel: 'B2',
    commonRank: 142,
    exampleSentence: 'I misunderstood the instructions for the project.',
    exampleSentenceVi: 'Tôi đã hiểu lầm các chỉ dẫn cho dự án.',
  );

  static const Verb verbTelecast = Verb(
    id: 'telecast',
    v1: 'telecast',
    v2: 'telecast / telecasted',
    v3: 'telecast / telecasted',
    ipaV1: '/ˈtelɪkɑːst/',
    ipaV2: '/ˈtelɪkɑːst/',
    ipaV3: '/ˈtelɪkɑːst/',
    meaningVi: 'phát sóng trên truyền hình',
    morphGroup: 'AAA',
    cefrLevel: 'C1',
    commonRank: 289,
    exampleSentence: 'The event was telecast live around the globe.',
    exampleSentenceVi: 'Sự kiện đã được truyền hình trực tiếp toàn cầu.',
  );

  static List<Verb> get standardVerbs => [
        verbBe,
        verbGo,
        verbMisunderstand,
        verbTelecast,
      ];

  static const AiEvaluation evaluationGood = AiEvaluation(
    score: 9,
    isCorrect: true,
    tenseUsed: 'Past Simple',
    feedback: 'Câu văn ngữ pháp hoàn hảo và tự nhiên!',
    grammarExplanation: 'Động từ "go" ở thì Quá khứ đơn (Past Simple) có dạng V2 là "went".',
    improvedSentence: 'She went to school early this morning with her friends.',
  );

  static const AiEvaluation evaluationNeedsFix = AiEvaluation(
    score: 4,
    isCorrect: false,
    tenseUsed: 'Present Simple',
    feedback: 'Cần chú ý chia đúng động từ ở dạng quá khứ.',
    grammarExplanation: 'Khi diễn tả hành động đã kết thúc trong quá khứ, dùng V2 "went" thay vì V1 "go".',
    improvedSentence: 'He went to the local supermarket yesterday evening.',
  );

  static const GamificationState activeGamification = GamificationState(
    currentStreak: 7,
    longestStreak: 7,
    totalXp: 350,
    badges: ['newbie_starter', 'streak_7', 'master_v2'],
    lastActiveDate: '2026-11-04',
  );
}

/// Fake TTS Service for deterministic headless testing
class FakeTtsService extends TtsService {
  final List<String> spokenTexts = [];

  @override
  Future<void> speak(String text) async {
    spokenTexts.add(text);
  }

  @override
  Future<void> stop() async {}
}

/// Fake PocketBase Service for deterministic headless testing
class FakePocketBaseService extends PocketBaseService {
  AiEvaluation evalToReturn = MockData.evaluationGood;

  @override
  Future<AiEvaluation> evaluateSentence({
    required String verbV1,
    required String targetForm,
    required String userSentence,
    String? token,
  }) async {
    return evalToReturn;
  }
}

/// Mock Verb Repository returning controlled in-memory verb data
class FakeVerbRepository extends VerbRepository {
  final List<Verb> _verbs;
  FakeVerbRepository([List<Verb>? verbs]) : _verbs = verbs ?? MockData.standardVerbs;

  @override
  Future<List<Verb>> getAllVerbs() async => _verbs;

  @override
  Future<Verb?> getVerbById(String id) async {
    try {
      return _verbs.firstWhere((v) => v.id == id || v.v1.toLowerCase() == id.toLowerCase());
    } catch (_) {
      return null;
    }
  }
}

/// Fake Gamification Notifier returning instant in-memory stats
class FakeGamificationNotifier extends GamificationNotifier {
  final GamificationState _state;
  FakeGamificationNotifier([GamificationState? state]) : _state = state ?? MockData.activeGamification;

  @override
  Future<GamificationState> build() async => _state;
}

/// Fake SRS Progress Notifier returning instant in-memory map
class FakeSrsProgressNotifier extends SrsProgressNotifier {
  final Map<String, SrsProgress> _progress;
  FakeSrsProgressNotifier([Map<String, SrsProgress>? progress]) : _progress = progress ?? {};

  @override
  Future<Map<String, SrsProgress>> build() async => _progress;
}

/// Harness helper to pump widgets with specific viewport, devicePixelRatio, and textScaler
Future<void> pumpResponsiveWidget(
  WidgetTester tester, {
  required Widget child,
  required Size viewport,
  double textScale = 1.0,
  dynamic overrides = const [],
  bool settle = false,
  Duration pumpDuration = const Duration(milliseconds: 300),
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final fakeTts = FakeTtsService();
  final fakeRepo = FakeVerbRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ttsServiceProvider.overrideWithValue(fakeTts),
        verbRepositoryProvider.overrideWithValue(fakeRepo),
        allVerbsProvider.overrideWith((ref) => fakeRepo.getAllVerbs()),
        gamificationProvider.overrideWith(() => FakeGamificationNotifier()),
        srsProgressProvider.overrideWith(() => FakeSrsProgressNotifier()),
        ...?overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: MediaQueryData(
            size: viewport,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Material(child: child),
        ),
      ),
    ),
  );

  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(pumpDuration);
  }
}
