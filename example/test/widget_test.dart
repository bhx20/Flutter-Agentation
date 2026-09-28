import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

void main() {
  testWidgets('InspectionDemoApp inspect workflow test', (WidgetTester tester) async {
    await tester.pumpWidget(const InspectionDemoApp());
    expect(find.text('FlutterAgentation Visual Overlay Demo'), findsOneWidget);
    expect(find.text('Primary Action'), findsOneWidget);

    // 1. Verify Inspect button is present
    final inspectBtn = find.byKey(const ValueKey('toolbar_inspect'));
    expect(inspectBtn, findsOneWidget);

    // 2. Tap Inspect button to enter Inspect mode
    await tester.tap(inspectBtn);
    await tester.pump(const Duration(milliseconds: 200));

    // 3. Tap on "Primary Action" button to inspect it
    final primaryActionBtn = find.text('Primary Action');
    await tester.tap(primaryActionBtn, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 200));

    // Verify AnnotationPopup appeared
    expect(find.byType(AnnotationPopup), findsOneWidget);
    expect(find.text('ElevatedButton'), findsWidgets);
    expect(find.text('What should change?'), findsOneWidget);
  });
}
