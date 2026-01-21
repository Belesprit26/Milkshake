import 'package:flutter_test/flutter_test.dart';

import 'package:milkshake/presentation/app/app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Log in'), findsOneWidget);
  });
}
