import 'package:flutter_test/flutter_test.dart';
import 'package:learnos_mobile/main.dart';

void main() {
  testWidgets(
    'LearnOS app mounts successfully',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const LearnOSApp(),
      );

      await tester.pump(
        const Duration(
          seconds: 3,
        ),
      );

      expect(
        find.byType(LearnOSApp),
        findsOneWidget,
      );
    },
  );
}