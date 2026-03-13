import 'package:flutter_test/flutter_test.dart';
import 'package:daily_burn/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DailyBurnApp());
  });
}
