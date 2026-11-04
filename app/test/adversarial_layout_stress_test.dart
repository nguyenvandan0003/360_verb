import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/data/models/ai_feedback.dart';
import 'package:app/data/models/iap_product.dart';
import 'package:app/logic/ai_providers.dart';
import 'package:app/logic/iap_provider.dart';
import 'package:app/logic/verb_providers.dart';
import 'package:app/presentation/screens/dictionary_screen.dart';
import 'package:app/presentation/screens/home_screen.dart';
import 'package:app/presentation/screens/practice/ai_writing_screen.dart';
import 'package:app/presentation/screens/practice/fill_blanks_screen.dart';
import 'package:app/presentation/screens/practice/flashcard_screen.dart';
import 'package:app/presentation/screens/practice/speed_quiz_screen.dart';
import 'package:app/presentation/screens/profile_screen.dart';
import 'package:app/presentation/screens/verb_detail_screen.dart';
import 'package:app/presentation/widgets/auth_modal.dart';
import 'package:app/presentation/widgets/paywall_modal.dart';

import 'helpers/test_helpers.dart';

class FakeAiEvaluationNotifier extends AiEvaluationNotifier {
  final AiEvaluation? _initial;
  FakeAiEvaluationNotifier(this._initial);

  @override
  AsyncValue<AiEvaluation?> build() => AsyncData(_initial);
}

class FakeIapNotifier extends IapNotifier {
  final IapState _injectedState;
  FakeIapNotifier(this._injectedState);

  @override
  IapState build() => _injectedState;
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  const extremeNarrowViewport = Size(300, 600);
  const galaxyFoldCoverViewport = Size(280, 653);

  group('Adversarial Stress Test: PaywallModal', () {
    for (final scale in [1.0, 1.3, 1.5]) {
      testWidgets('PaywallModal at 300dp width with text scale ${scale}x', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: extremeNarrowViewport,
          textScale: scale,
          child: const Scaffold(
            body: SingleChildScrollView(
              child: PaywallModal(),
            ),
          ),
        );

        expect(find.text('Verb360 VIP PRO'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'PaywallModal must not overflow at 300dp with textScale $scale');
      });
    }

    testWidgets('PaywallModal at ultra-narrow 280dp (Galaxy Fold) with 1.3x text scale', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: galaxyFoldCoverViewport,
        textScale: 1.3,
        child: const Scaffold(
          body: SingleChildScrollView(
            child: PaywallModal(),
          ),
        ),
      );

      expect(find.text('Verb360 VIP PRO'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'PaywallModal must not overflow at 280dp with 1.3x text scale');
    });
  });

  group('Adversarial Stress Test: AuthModal', () {
    for (final scale in [1.0, 1.3, 1.5]) {
      testWidgets('AuthModal Login tab at 300dp with text scale ${scale}x', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: extremeNarrowViewport,
          textScale: scale,
          child: const Scaffold(
            body: SingleChildScrollView(
              child: AuthModal(),
            ),
          ),
        );

        expect(find.text('Đăng nhập'), findsWidgets);
        expect(tester.takeException(), isNull, reason: 'AuthModal Login tab must not overflow at 300dp with textScale $scale');
      });

      testWidgets('AuthModal Register tab with validation errors at 300dp with text scale ${scale}x', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: extremeNarrowViewport,
          textScale: scale,
          child: const Scaffold(
            body: SingleChildScrollView(
              child: AuthModal(),
            ),
          ),
        );

        // Tap on register tab
        await tester.tap(find.widgetWithText(Tab, 'Tạo tài khoản'));
        await tester.pumpAndSettle();

        // Submit to trigger validation errors
        await tester.tap(find.text('Tạo tài khoản & Bắt đầu'));
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('Vui lòng nhập tên của bạn'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'AuthModal Register tab must not overflow on validation errors at 300dp with textScale $scale');
      });
    }
  });

  group('Adversarial Stress Test: AiWritingScreen', () {
    for (final scale in [1.0, 1.3, 1.5]) {
      testWidgets('AiWritingScreen input state at 300dp with text scale ${scale}x', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: extremeNarrowViewport,
          textScale: scale,
          child: const AiWritingScreen(initialVerb: MockData.verbMisunderstand),
        );

        expect(find.text('Gia Sư AI Viết Câu'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'AiWritingScreen must not overflow at 300dp with textScale $scale');
      });

      testWidgets('AiWritingScreen evaluation card at 300dp with text scale ${scale}x', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: extremeNarrowViewport,
          textScale: scale,
          overrides: [
            aiEvaluationProvider.overrideWith(() => FakeAiEvaluationNotifier(MockData.evaluationGood)),
          ],
          child: const AiWritingScreen(initialVerb: MockData.verbMisunderstand),
        );

        expect(find.text('Đạt chuẩn ngữ pháp'), findsOneWidget);
        expect(find.text('Điểm: 9/10'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'AiWritingScreen evaluation card must not overflow at 300dp with textScale $scale');
      });
    }
  });

  group('Adversarial Stress Test: ProfileScreen', () {
    for (final scale in [1.0, 1.3, 1.5]) {
      testWidgets('ProfileScreen free user state at 300dp with text scale ${scale}x', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: extremeNarrowViewport,
          textScale: scale,
          child: const ProfileScreen(),
        );

        expect(find.text('Hồ Sơ Cá Nhân'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'ProfileScreen free user state must not overflow at 300dp with textScale $scale');
      });

      testWidgets('ProfileScreen VIP active state at 300dp with text scale ${scale}x', (tester) async {
        final vipProduct = IapProductModel.defaultProducts.first;
        final vipState = IapState(
          isPro: true,
          planType: 'lifetime',
          selectedProduct: vipProduct,
        );

        await pumpResponsiveWidget(
          tester,
          viewport: extremeNarrowViewport,
          textScale: scale,
          overrides: [
            iapProvider.overrideWith(() => FakeIapNotifier(vipState)),
          ],
          child: const ProfileScreen(),
        );

        expect(find.text('Thành Viên VIP PRO'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'ProfileScreen VIP active state must not overflow at 300dp with textScale $scale');
      });
    }
  });

  group('Adversarial Stress Test: SpeedQuizScreen', () {
    for (final scale in [1.0, 1.3, 1.5]) {
      testWidgets('SpeedQuiz active quiz grid at 300dp with text scale ${scale}x', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: extremeNarrowViewport,
          textScale: scale,
          child: const SpeedQuizScreen(),
        );

        expect(find.text('Phản Xạ Nhanh 60s'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'SpeedQuiz active grid must not overflow at 300dp with textScale $scale');
      });

      testWidgets('SpeedQuiz Game Over screen at 300dp with text scale ${scale}x', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: extremeNarrowViewport,
          textScale: scale,
          child: const SpeedQuizScreen(),
        );

        // Fast forward timer to 61s
        await tester.pump(const Duration(seconds: 61));
        await tester.pump();

        expect(find.text('Hết giờ!'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'SpeedQuiz Game Over must not overflow at 300dp with textScale $scale');
      });
    }

    testWidgets('SpeedQuiz Game Over screen in constrained landscape (600x300) with 1.3x text scale', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: const Size(600, 300),
        textScale: 1.3,
        child: const SpeedQuizScreen(),
      );

      await tester.pump(const Duration(seconds: 61));
      await tester.pump();

      expect(find.text('Hết giờ!'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'SpeedQuiz Game Over must not overflow in constrained landscape with 1.3x scale');
    });
  });

  group('Adversarial Stress Test: FlashcardScreen', () {
    for (final scale in [1.0, 1.3, 1.5]) {
      testWidgets('Flashcard front card at 300dp with text scale ${scale}x', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: extremeNarrowViewport,
          textScale: scale,
          child: const FlashcardScreen(),
        );

        expect(find.text('Chạm để lật thẻ xem đáp án'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Flashcard front card must not overflow at 300dp with textScale $scale');
      });

      testWidgets('Flashcard back card with rating buttons at 300dp with text scale ${scale}x', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: extremeNarrowViewport,
          textScale: scale,
          child: const FlashcardScreen(),
        );

        // Tap to flip card
        await tester.tap(find.text('Chạm để lật thẻ xem đáp án'));
        await tester.pump(const Duration(milliseconds: 350));

        expect(find.text('Đánh giá mức độ ghi nhớ của bạn:'), findsOneWidget);
        expect(find.text('Quên'), findsOneWidget);
        expect(find.text('Khó'), findsOneWidget);
        expect(find.text('Tốt'), findsOneWidget);
        expect(find.text('Dễ'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Flashcard back card must not overflow at 300dp with textScale $scale');
      });
    }
  });

  group('Adversarial Stress Test: Other Screens at 300dp & 1.5x Text Scale', () {
    testWidgets('HomeScreen renders cleanly at 300dp with 1.5x text scale', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: extremeNarrowViewport,
        textScale: 1.5,
        child: HomeScreen(
          onNavigateToDictionary: () {},
        ),
      );

      expect(find.text('360 Động từ bất quy tắc'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'HomeScreen must not overflow at 300dp with 1.5x text scale');
    });

    testWidgets('DictionaryScreen renders cleanly at 300dp with 1.5x text scale', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: extremeNarrowViewport,
        textScale: 1.5,
        child: const DictionaryScreen(),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'DictionaryScreen must not overflow at 300dp with 1.5x text scale');
    });

    testWidgets('VerbDetailScreen with polysyllabic verb at 300dp with 1.5x text scale', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: extremeNarrowViewport,
        textScale: 1.5,
        child: const VerbDetailScreen(verb: MockData.verbMisunderstand),
      );

      expect(find.text('misunderstand'), findsWidgets);
      expect(tester.takeException(), isNull, reason: 'VerbDetailScreen must not overflow with polysyllabic verb at 300dp with 1.5x text scale');
    });

    testWidgets('FillBlanksScreen with soft keyboard at 300dp with 1.3x text scale', (tester) async {
      tester.view.physicalSize = extremeNarrowViewport;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allVerbsProvider.overrideWith((ref) => FakeVerbRepository().getAllVerbs()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MediaQuery(
              data: MediaQueryData(
                size: extremeNarrowViewport,
                textScaler: TextScaler.linear(1.3),
                viewInsets: EdgeInsets.only(bottom: 250), // soft keyboard
              ),
              child: Material(child: FillBlanksScreen()),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Điền Khuyết Động Từ'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'FillBlanksScreen must not overflow at 300dp with soft keyboard');
    });
  });
}
