import 'package:flutter_test/flutter_test.dart';

import 'package:goodlucksoft/main.dart';

void main() {
  testWidgets('Loads navigator home', (WidgetTester tester) async {
    await tester.pumpWidget(const ApniLabApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('ApniLab.pk'), findsWidgets);
    expect(find.textContaining('Dashboard'), findsWidgets);
  });
}
