import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Resolved annotations are removed from running canvas and do not render markers', (tester) async {
    final storage = MemoryAnnotationStorage();
    final controller = AgentationController(storage: storage);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlutterAgentation(
            controller: controller,
            showToolbar: false,
            child: const Center(child: Text('Inspectable Widget')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Create an active annotation with valid inspection targetResult
    final ann = await controller.createAnnotation(
      comment: 'Fix the color',
      targetResult: const WidgetInspectionResult(
        identity: WidgetIdentity(id: 'w1', widgetType: 'Text'),
        bounds: WidgetBounds(x: 50, y: 50, width: 100, height: 30),
        context: WidgetContext.empty(),
        ancestors: [],
      ),
    );
    await tester.pumpAndSettle();

    // Verify marker pin is rendered on the running canvas
    expect(find.byType(AnnotationMarker), findsOneWidget);

    // 2. Mark the annotation as resolved
    await controller.updateAnnotation(ann.id, status: AnnotationStatus.resolved);
    await tester.pumpAndSettle();

    // Verify comment marker is removed from the running panel
    expect(find.byType(AnnotationMarker), findsNothing);
  });
}
