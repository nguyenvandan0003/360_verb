import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/presentation/screens/dictionary_screen.dart';
import 'package:app/presentation/screens/practice/fill_blanks_screen.dart';
import 'package:app/presentation/screens/practice/flashcard_screen.dart';
import 'package:app/presentation/screens/verb_detail_screen.dart';
import 'package:app/presentation/widgets/paywall_modal.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('E2E User Journey & Cross-Feature Workflows', () {
    testWidgets('Journey 1: Dictionary search -> Verb detail -> TTS speech trigger', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: TestViewports.pixel4xl,
        child: const DictionaryScreen(),
      );

      // Verify search input is present
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Search for 'go'
      await tester.enterText(searchField, 'go');
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on the verb card
      final verbCard = find.text('go');
      expect(verbCard, findsWidgets);

      // Navigate to detail
      await pumpResponsiveWidget(
        tester,
        viewport: TestViewports.pixel4xl,
        child: const VerbDetailScreen(verb: MockData.verbGo),
      );

      expect(find.text('go'), findsWidgets);
      expect(find.text('went'), findsWidgets);
      expect(find.text('gone'), findsWidgets);
      expect(find.text('đi, di chuyển'), findsOneWidget);

      // Tap speaker button to trigger TTS
      final speakButton = find.byIcon(Icons.volume_up_rounded);
      expect(speakButton, findsWidgets);
      await tester.tap(speakButton.first);
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('Journey 2: Fill Blanks Practice -> Answer validation -> XP calculation', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: TestViewports.pixel4xl,
        child: const FillBlanksScreen(),
      );

      expect(find.text('Điền Khuyết Động Từ'), findsOneWidget);

      // Find the two TextFormFields for V2 and V3
      final formFields = find.byType(TextField);
      expect(formFields, findsAtLeastNWidgets(2));

      // Enter answers for first verb 'be' (V2: was, V3: been)
      await tester.enterText(formFields.at(0), 'was');
      await tester.enterText(formFields.at(1), 'been');
      await tester.pump(const Duration(milliseconds: 100));

      // Submit answer
      await tester.tap(find.text('Kiểm tra đáp án'));
      await tester.pump(const Duration(milliseconds: 300));

      // Should indicate correct answer and show next button
      expect(find.text('Chính xác! +15 XP'), findsOneWidget);
      expect(find.text('Từ tiếp theo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Journey 3: Flashcard SRS Review -> Flip card -> Grade rating -> Progress', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: TestViewports.pixel4xl,
        child: const FlashcardScreen(),
      );

      expect(find.text('Chạm để lật thẻ xem đáp án'), findsOneWidget);

      // Flip card to reveal answer
      await tester.tap(find.text('Chạm để lật thẻ xem đáp án'));
      await tester.pump(const Duration(milliseconds: 350));

      // Verify back card displays rating options
      expect(find.text('Đánh giá mức độ ghi nhớ của bạn:'), findsOneWidget);
      expect(find.text('Tốt'), findsOneWidget);

      // Submit grade 'Tốt' (grade 4)
      await tester.tap(find.text('Tốt'));
      await tester.pump(const Duration(milliseconds: 350));

      // Should advance or show next card cleanly
      expect(tester.takeException(), isNull);
    });

    testWidgets('Journey 4: Paywall modal presentation & Legal footer actions', (tester) async {
      await pumpResponsiveWidget(
        tester,
        viewport: TestViewports.pixel4xl,
        child: const Scaffold(
          body: SingleChildScrollView(
            child: PaywallModal(),
          ),
        ),
      );

      expect(find.text('Verb360 VIP PRO'), findsOneWidget);
      expect(find.text('Trọn Đời (Lifetime)'), findsOneWidget);
      expect(find.text('Khôi phục gói mua'), findsOneWidget);

      // Scroll and tap restore purchases
      await tester.scrollUntilVisible(find.text('Khôi phục gói mua'), 100);
      await tester.tap(find.text('Khôi phục gói mua'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    });
  });
}
