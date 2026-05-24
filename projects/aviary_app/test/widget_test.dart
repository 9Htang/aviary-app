import 'package:flutter_test/flutter_test.dart';
import 'package:aviary_app/main.dart';

void main() {
  testWidgets('App renders task screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AviaryApp());
    expect(find.byType(AviaryApp), findsOneWidget);
  });
}
