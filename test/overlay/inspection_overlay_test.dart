import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/flutter_agentation.dart';
import 'package:flutter_agentation/src/models/widget_inspection_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InspectionOverlay & FlutterAgentation', () {
    testWidgets(
        'inactive mode allows 100% gesture passthrough to host app widgets',
        (tester) async {
      int tapCount = 0;
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: false, // test overlay in isolation
            child: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => tapCount++,
                  child: const Text('Host Button'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(controller.isInactive, isTrue);

      // Tap host button
      await tester.tap(find.text('Host Button'));
      await tester.pump();

      expect(tapCount, equals(1));
      expect(controller.selectedResult, isNull);
    });

    testWidgets(
        'active inspection mode intercepts tap and resolves widget inspection',
        (tester) async {
      int hostTapCount = 0;
      WidgetInspectionResult? selectedCallbackResult;
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: false,
            onWidgetSelected: (res) => selectedCallbackResult = res,
            child: Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('target_button'),
                  onPressed: () => hostTapCount++,
                  child: const Text('Inspect Me'),
                ),
              ),
            ),
          ),
        ),
      );

      // Activate inspection
      controller.activate();
      await tester.pump();

      expect(controller.isInspecting, isTrue);

      // Tap the button
      await tester.tap(find.text('Inspect Me'), warnIfMissed: false);
      await tester.pump();

      // Host button should NOT have been pressed because inspection mode intercepted
      expect(hostTapCount, equals(0));

      // Controller should have recorded the inspection result
      expect(controller.selectedResult, isNotNull);
      expect(controller.selectedResult!.isAvailable, isTrue);
      expect(controller.selectedResult!.identity.widgetType,
          equals('ElevatedButton'));
      expect(selectedCallbackResult, equals(controller.selectedResult));
    });

    testWidgets('deactivating inspection clears selection and restores input',
        (tester) async {
      int hostTapCount = 0;
      final controller = AgentationController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: false,
            child: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => hostTapCount++,
                  child: const Text('Toggle Target'),
                ),
              ),
            ),
          ),
        ),
      );

      controller.activate();
      await tester.pump();

      await tester.tap(find.text('Toggle Target'), warnIfMissed: false);
      await tester.pump();
      expect(hostTapCount, equals(0));
      expect(controller.selectedResult, isNotNull);

      // Deactivate
      controller.deactivate();
      await tester.pump();

      expect(controller.isInactive, isTrue);
      expect(controller.selectedResult, isNull);

      // Now tap should trigger host button
      await tester.tap(find.text('Toggle Target'));
      await tester.pump();
      expect(hostTapCount, equals(1));
    });
  });
}
