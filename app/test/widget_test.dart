import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('Verb360App smoke test builds and displays navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Verb360App(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Verb360 AI'), findsWidgets);
    expect(find.text('Trang chủ'), findsWidgets);
    expect(find.text('Tra cứu 360'), findsWidgets);
    expect(find.text('Gia sư AI'), findsWidgets);
  });
}
