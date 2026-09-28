import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/models/annotation.dart';
import 'package:flutter_agentation/src/models/annotation_intent.dart';
import 'package:flutter_agentation/src/models/annotation_severity.dart';
import 'package:flutter_agentation/src/models/annotation_status.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/output/clipboard_exporter.dart';
import 'package:flutter_agentation/src/storage/memory_annotation_storage.dart';
import 'package:flutter_agentation/src/toolbar/agentation_toolbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String? mockClipboardText;

  setUp(() {
    mockClipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
      if (methodCall.method == 'Clipboard.setData') {
        mockClipboardText = (methodCall.arguments as Map)['text'] as String?;
        return null;
      }
      if (methodCall.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': mockClipboardText};
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('ClipboardExporter', () {
    const exporter = ClipboardExporter();

    final testAnnotation = Annotation(
      id: 'ann_001',
      comment: 'Fix contrast',
      timestamp: DateTime.parse('2026-09-25T12:00:00.000Z'),
      targetWidget: const WidgetIdentity(
        id: 'submit_btn',
        widgetType: 'ElevatedButton',
      ),
      bounds: const WidgetBounds(x: 10.0, y: 20.0, width: 100.0, height: 40.0),
      intent: AnnotationIntent.change,
      severity: AnnotationSeverity.suggestion,
      status: AnnotationStatus.pending,
    );

    test('formatAnnotations formats markdown, json, agentationJson, and feedback', () {
      final feedback = exporter.formatAnnotations([testAnnotation], format: ExportFormat.feedback);
      expect(feedback, contains('[Flutter UI Feedback]'));
      expect(feedback, contains('Widget: ElevatedButton'));
      expect(feedback, contains('Comment: Fix contrast'));

      final md = exporter.formatAnnotations([testAnnotation], format: ExportFormat.markdown);
      expect(md, contains('ElevatedButton'));
      expect(md, contains('Fix contrast'));

      final json = exporter.formatAnnotations([testAnnotation], format: ExportFormat.json);
      expect(json, contains('"id": "ann_001"'));

      final agentation = exporter.formatAnnotations([testAnnotation], format: ExportFormat.agentationJson);
      expect(agentation, contains('"source": "flutter_agentation"'));
      expect(agentation, contains('"platform": "flutter"'));
    });

    test('copyToClipboard returns null if annotations list is empty', () async {
      final result = await exporter.copyToClipboard([]);
      expect(result, isNull);
    });

    test('copyToClipboard copies to system clipboard', () async {
      final result = await exporter.copyToClipboard([testAnnotation]);
      expect(result, isNotNull);
      final clipData = await Clipboard.getData(Clipboard.kTextPlain);
      expect(clipData?.text, equals(result));
    });
  });

  group('AgentationController & Toolbar Export Action', () {
    late MemoryAnnotationStorage storage;
    late AgentationController controller;

    setUp(() {
      storage = MemoryAnnotationStorage();
      controller = AgentationController(storage: storage);
    });

    tearDown(() {
      controller.dispose();
    });

    test('controller.exportAnnotations delegates to ClipboardExporter', () async {
      await controller.createAnnotation(comment: 'Test note');
      expect(controller.annotations.length, equals(1));

      final exported = await controller.exportAnnotations();
      expect(exported, contains('Test note'));
    });

    testWidgets('toolbar displays copy action and provides feedback on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: Stack(
                children: [
                  const Center(child: Text('App Content')),
                  AgentationToolbar(
                    controller: controller,
                    initialAlignment: Alignment.topRight,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify Export button exists
      final copyButtonFinder = find.byKey(const ValueKey('toolbar_copy'));
      expect(copyButtonFinder, findsOneWidget);

      // Tap when empty -> should show "No annotations to export"
      await tester.tap(copyButtonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No annotations to export'), findsOneWidget);

      // Clear first snackbar so it does not block the second tap
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).clearSnackBars();
      await tester.pumpAndSettle();

      // Add an annotation and tap again
      await controller.createAnnotation(comment: 'Make header bold');
      await tester.pump();

      await tester.tap(copyButtonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Copied 1 annotation to clipboard!'), findsOneWidget);
    });
  });
}
