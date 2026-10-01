import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

void main() {
  test('public barrel export exposes core engine and models', () {
    final engine = FlutterInspectionEngine();
    expect(engine, isNotNull);

    const bounds = WidgetBounds.zero();
    expect(bounds.x, 0.0);

    const identity = WidgetIdentity.empty();
    expect(identity.widgetType, 'Unknown');

    const result = WidgetInspectionResult.unavailable();
    expect(result.isAvailable, isFalse);

    // Phase 2 exports
    final controller = AgentationController();
    expect(controller.mode, equals(InspectionMode.inactive));

    const style = HighlightStyle();
    expect(style.strokeWidth, equals(1.5));
    expect(style.fillColor, equals(Colors.transparent));

    // Phase 3 exports
    final storage = MemoryAnnotationStorage();
    expect(storage, isNotNull);

    final annotation = Annotation(
      id: 'test_ann',
      comment: 'Testing barrel export',
      timestamp: DateTime.now(),
      targetWidget: identity,
      bounds: bounds,
      intent: AnnotationIntent.note,
      severity: AnnotationSeverity.low,
      status: AnnotationStatus.pending,
    );
    expect(annotation.id, equals('test_ann'));
  });
}
