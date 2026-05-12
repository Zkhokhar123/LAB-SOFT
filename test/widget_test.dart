import 'package:flutter_test/flutter_test.dart';

import 'package:goodlucksoft/main.dart';

void main() {
  testWidgets('Loads navigator home', (WidgetTester tester) async {
    await tester.pumpWidget(const NishtarNavApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Nishtar'), findsWidgets);
    expect(find.text('Show walking route'), findsOneWidget);
  });
}
