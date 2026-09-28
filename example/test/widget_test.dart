import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

void main() {
  testWidgets('InspectionDemoApp inspect workflow test', (WidgetTester tester) async {
    await tester.pumpWidget(const InspectionDemoApp());
    expect(find.text('FlutterAgentation Visual Overlay Demo'), findsOneWidget);
    expect(find.text('Primary Action'), findsOneWidget);

    // 1. Verify Pause/Inspect and Inspect/Comments buttons are present
    final pauseBtn = find.byKey(const ValueKey('toolbar_pause'));
    final commentsBtn = find.byKey(const ValueKey('toolbar_inspect'));
    expect(pauseBtn, findsOneWidget);
    expect(commentsBtn, findsOneWidget);

    // 2. Tap Pause/Inspect button to enter Inspect mode
    await tester.tap(pauseBtn);
    await tester.pump(const Duration(milliseconds: 200));

    // 3. Tap on "Primary Action" button to inspect it
    final primaryActionBtn = find.text('Primary Action');
    await tester.tap(primaryActionBtn, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 200));

    // Verify AnnotationPopup appeared
    expect(find.byType(AnnotationPopup), findsOneWidget);
    expect(find.text('ElevatedButton'), findsWidgets);
    expect(find.text('What should change?'), findsOneWidget);

    // 4. Enter a comment and save it
    final popupTextField = find.descendant(
      of: find.byType(AnnotationPopup),
      matching: find.byType(TextField),
    );
    await tester.enterText(popupTextField, 'Test comment on Primary Action');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify comment marker is visible
    expect(find.byType(AnnotationMarker), findsOneWidget);

    // 5. Toggle comment visibility with toolbar_inspect (Eye icon)
    await tester.tap(commentsBtn);
    await tester.pumpAndSettle();

    // Comment marker should be hidden now
    expect(find.byType(AnnotationMarker), findsNothing);

    // Toggle back on
    await tester.tap(commentsBtn);
    await tester.pumpAndSettle();
    expect(find.byType(AnnotationMarker), findsOneWidget);
  });
}

