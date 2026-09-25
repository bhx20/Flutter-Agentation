import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('InspectionDemoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const InspectionDemoApp());
    expect(find.text('FlutterAgentation Visual Overlay Demo'), findsOneWidget);
    expect(find.text('Primary Action'), findsOneWidget);
  });
}
