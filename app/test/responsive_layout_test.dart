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
import 'package:app/presentation/adaptive_scaffold.dart';
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

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('AdaptiveScaffold Breakpoint & Layout Tests', () {
    const destinations = [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        label: 'Trang chủ',
      ),
      NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        label: 'Tra cứu 360',
      ),
    ];

    final samplePages = [
      const Center(child: Text('Trang chủ Page')),
      const Center(child: Text('Tra cứu Page')),
    ];

    testWidgets('Mobile viewports (<768dp) display NavigationBar and hide NavigationRail', (tester) async {
      for (final entry in [
        ('Compact Phone 320x568', TestViewports.compactPhone),
        ('Standard Phone 390x844', TestViewports.standardPhone),
        ('Pixel 4 XL 412x869', TestViewports.pixel4xl),
      ]) {
        await pumpResponsiveWidget(
          tester,
          viewport: entry.$2,
          child: AdaptiveScaffold(
            pages: samplePages,
            destinations: destinations,
            initialIndex: 0,
          ),
        );

        expect(find.byType(NavigationBar), findsOneWidget, reason: '${entry.$1} must have NavigationBar');
        expect(find.byType(NavigationRail), findsNothing, reason: '${entry.$1} must not have NavigationRail');
        expect(find.text('Trang chủ Page'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Tablet viewports (>=768dp) display NavigationRail and hide NavigationBar', (tester) async {
      for (final entry in [
        ('Tablet Portrait 768x1024', TestViewports.tabletPortrait),
        ('Tablet Landscape 1024x768', TestViewports.tabletLandscape),
      ]) {
        await pumpResponsiveWidget(
          tester,
          viewport: entry.$2,
          child: AdaptiveScaffold(
            pages: samplePages,
            destinations: destinations,
            initialIndex: 0,
          ),
        );

        expect(find.byType(NavigationRail), findsOneWidget, reason: '${entry.$1} must have NavigationRail');
        expect(find.byType(NavigationBar), findsNothing, reason: '${entry.$1} must not have NavigationBar');
        expect(find.text('Verb360 AI'), findsOneWidget);
        expect(find.text('Trang chủ Page'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('HomeScreen Multi-Device Responsive Matrix', () {
    for (final entry in TestViewports.matrix.entries) {
      testWidgets('Renders cleanly on ${entry.key}', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: entry.value,
          child: HomeScreen(
            onNavigateToDictionary: () {},
          ),
        );

        expect(find.text('Verb360'), findsOneWidget);
        expect(find.text('SRS Spaced Repetition'), findsOneWidget);
        expect(find.text('Gia sư AI'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('DictionaryScreen Multi-Device Responsive Matrix', () {
    for (final entry in TestViewports.matrix.entries) {
      testWidgets('Renders search and filter chips on ${entry.key}', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: entry.value,
          child: const DictionaryScreen(),
        );

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Tất cả 360'), findsOneWidget);
        expect(find.text('Nhóm AAA'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('VerbDetailScreen Multi-Device Responsive Matrix', () {
    for (final entry in TestViewports.matrix.entries) {
      testWidgets('Renders standard verb on ${entry.key}', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: entry.value,
          child: const VerbDetailScreen(verb: MockData.verbBe),
        );

        expect(find.text('be'), findsWidgets);
        expect(find.text('thì, là, ở'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Renders polysyllabic verb without overflow on ${entry.key}', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: entry.value,
          child: const VerbDetailScreen(verb: MockData.verbMisunderstand),
        );

        expect(find.text('misunderstand'), findsWidgets);
        expect(find.text('hiểu lầm, hiểu sai ý'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('AI Writing Screen Multi-Device Responsive Matrix', () {
    for (final entry in TestViewports.matrix.entries) {
      testWidgets('Renders input state on ${entry.key}', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: entry.value,
          child: const AiWritingScreen(initialVerb: MockData.verbGo),
        );

        expect(find.text('Gia Sư AI Viết Câu'), findsOneWidget);
        expect(find.text('Kiểm tra câu với DeepSeek AI'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Renders evaluation result card on 320x568 and Pixel 4 XL', (tester) async {
      for (final viewport in [TestViewports.compactPhone, TestViewports.pixel4xl]) {
        await pumpResponsiveWidget(
          tester,
          viewport: viewport,
          overrides: [
            aiEvaluationProvider.overrideWith(() => FakeAiEvaluationNotifier(MockData.evaluationGood)),
          ],
          child: const AiWritingScreen(initialVerb: MockData.verbGo),
        );

        expect(find.text('Đạt chuẩn ngữ pháp'), findsOneWidget);
        expect(find.text('Điểm: 9/10'), findsOneWidget);
        expect(find.text('Câu gợi ý viết lại tự nhiên:'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('FlashcardScreen SRS Multi-Device Responsive Matrix', () {
    for (final entry in TestViewports.matrix.entries) {
      testWidgets('Renders front card on ${entry.key}', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: entry.value,
          child: const FlashcardScreen(),
        );

        expect(find.text('Chạm để lật thẻ xem đáp án'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Card flip and rating options render without overflow', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: TestViewports.pixel4xl,
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
      expect(tester.takeException(), isNull);
    });
  });

  group('FillBlanksScreen Multi-Device Responsive Matrix', () {
    for (final entry in TestViewports.matrix.entries) {
      testWidgets('Renders cleanly on ${entry.key}', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: entry.value,
          child: const FillBlanksScreen(),
        );

        expect(find.text('Điền Khuyết Động Từ'), findsOneWidget);
        expect(find.text('Kiểm tra đáp án'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Simulated on-screen soft keyboard does not overflow FillBlanksScreen', (tester) async {
      tester.view.physicalSize = TestViewports.pixel4xl;
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
                size: TestViewports.pixel4xl,
                viewInsets: EdgeInsets.only(bottom: 300), // Simulating open IME keyboard
              ),
              child: Material(child: FillBlanksScreen()),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Điền Khuyết Động Từ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('SpeedQuizScreen Responsive & Landscape Tests', () {
    testWidgets('Active quiz screen renders in portrait (Pixel 4 XL)', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: TestViewports.pixel4xl,
        child: const SpeedQuizScreen(),
      );

      expect(find.text('Phản Xạ Nhanh 60s'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Active quiz screen renders in compact portrait (320x568)', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: TestViewports.compactPhone,
        child: const SpeedQuizScreen(),
      );

      expect(find.text('Phản Xạ Nhanh 60s'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Game Over view renders in landscape orientation (1024x768)', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: TestViewports.tabletLandscape,
        child: const SpeedQuizScreen(),
      );

      // Fast-forward 61 seconds to trigger Game Over
      await tester.pump(const Duration(seconds: 61));
      await tester.pump();

      expect(find.text('Hết giờ!'), findsOneWidget);
      expect(find.text('Chơi lại'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ProfileScreen Multi-Device Responsive Matrix', () {
    for (final entry in TestViewports.matrix.entries) {
      testWidgets('Renders free user state on ${entry.key}', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: entry.value,
          child: const ProfileScreen(),
        );

        expect(find.text('Hồ Sơ Cá Nhân'), findsOneWidget);
        expect(find.text('Gói Miễn Phí (Free)'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Renders active VIP Pro status on 320x568 and Pixel 4 XL', (tester) async {
      final vipProduct = IapProductModel.defaultProducts.first;
      final vipState = IapState(
        isPro: true,
        planType: 'lifetime',
        selectedProduct: vipProduct,
      );

      for (final viewport in [TestViewports.compactPhone, TestViewports.pixel4xl]) {
        await pumpResponsiveWidget(
          tester,
          viewport: viewport,
          overrides: [
            iapProvider.overrideWith(() => FakeIapNotifier(vipState)),
          ],
          child: const ProfileScreen(),
        );

        expect(find.text('Thành Viên VIP PRO'), findsOneWidget);
        expect(find.text('ĐÃ KÍCH HOẠT'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('PaywallModal Multi-Device Responsive Tests', () {
    for (final entry in [
      ('Compact Phone 320x568', TestViewports.compactPhone),
      ('Standard Phone 390x844', TestViewports.standardPhone),
      ('Pixel 4 XL 412x869', TestViewports.pixel4xl),
      ('Tablet Portrait 768x1024', TestViewports.tabletPortrait),
    ]) {
      testWidgets('Renders without overflow on ${entry.$1}', (tester) async {
        await pumpResponsiveWidget(
          tester,
          viewport: entry.$2,
          child: const Scaffold(
            body: SingleChildScrollView(
              child: PaywallModal(),
            ),
          ),
        );

        expect(find.text('Verb360 VIP PRO'), findsOneWidget);
        expect(find.text('Khôi phục gói mua'), findsOneWidget);
        expect(find.text('Điều khoản (EULA)'), findsOneWidget);
        expect(find.text('Bảo mật'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('AuthModal Responsive & Validation Tests', () {
    testWidgets('Renders Login tab without overflow across viewports', (tester) async {
      for (final viewport in [TestViewports.compactPhone, TestViewports.pixel4xl]) {
        await pumpResponsiveWidget(
          tester,
          viewport: viewport,
          child: const Scaffold(
            body: SingleChildScrollView(
              child: AuthModal(),
            ),
          ),
        );

        expect(find.text('Đăng nhập'), findsWidgets);
        expect(find.widgetWithText(Tab, 'Tạo tài khoản'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Register tab form validation error expansion check', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: TestViewports.compactPhone,
        child: const Scaffold(
          body: SingleChildScrollView(
            child: AuthModal(),
          ),
        ),
      );

      // Switch to Register Tab
      await tester.tap(find.widgetWithText(Tab, 'Tạo tài khoản'));
      await tester.pumpAndSettle();

      // Tap submit with empty inputs to trigger validation messages
      await tester.tap(find.text('Tạo tài khoản & Bắt đầu'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Vui lòng nhập tên của bạn'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Fake Notifiers for state injection in tests
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
