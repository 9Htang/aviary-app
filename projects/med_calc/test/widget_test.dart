import 'package:flutter_test/flutter_test.dart';
import 'package:med_calc/main.dart';

void main() {
  testWidgets('App loads calculator screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MedCalcApp());
    expect(find.text('🦜 药物计算器'), findsOneWidget);
  });
}
