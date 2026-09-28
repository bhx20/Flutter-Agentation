import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgentationKeymap & Keyboard Shortcuts Test Suite', () {
    late AgentationController controller;
    late MemoryAnnotationStorage storage;

    setUp(() {
      storage = MemoryAnnotationStorage();
      controller = AgentationController(
        storage: storage,
      );
    });

    test('AgentationKeymap generates valid shortcuts map with all actions', () {
      const keymap = AgentationKeymap();
      final map = keymap.toShortcutsMap();

      expect(map.containsKey(const SingleActivator(LogicalKeyboardKey.delete)), isTrue);
      expect(map.containsKey(const SingleActivator(LogicalKeyboardKey.backspace)), isTrue);
      expect(map.containsKey(const SingleActivator(LogicalKeyboardKey.escape)), isTrue);
      expect(map.containsKey(const SingleActivator(LogicalKeyboardKey.enter, control: true)), isTrue);
      expect(map.containsKey(const SingleActivator(LogicalKeyboardKey.keyI, alt: true)), isTrue);
      expect(map.containsKey(const SingleActivator(LogicalKeyboardKey.keyV, alt: true)), isTrue);
      expect(map.containsKey(const SingleActivator(LogicalKeyboardKey.keyZ, control: true)), isTrue);
    });

    testWidgets('selecting a comment marker and pressing Delete key deletes the comment from page', (tester) async {
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

      // 1. Create an annotation on the page
      final ann = await controller.createAnnotation(
        comment: 'Needs higher contrast',
        targetResult: const WidgetInspectionResult(
          identity: WidgetIdentity(id: 'w1', widgetType: 'Text'),
          bounds: WidgetBounds(x: 50, y: 50, width: 100, height: 30),
          context: WidgetContext.empty(),
          ancestors: [],
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.annotations.length, equals(1));
      expect(find.byType(AnnotationMarker), findsOneWidget);

      // 2. Select the comment marker
      final marker = find.byType(AnnotationMarker);
      await tester.tap(marker);
      await tester.pumpAndSettle();

      expect(controller.activeAnnotation, isNotNull);
      expect(controller.activeAnnotation!.id, equals(ann.id));
      expect(find.byType(AnnotationDetailCard), findsOneWidget);

      // 3. Tap the Delete key on the keyboard
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();

      // 4. Verify comment was deleted and detail card closed
      expect(controller.annotations.isEmpty, isTrue);
      expect(controller.activeAnnotation, isNull);
      expect(find.byType(AnnotationMarker), findsNothing);
      expect(find.byType(AnnotationDetailCard), findsNothing);
    });

    testWidgets('selecting a comment marker and pressing Backspace key deletes the comment', (tester) async {
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

      final ann = await controller.createAnnotation(
        comment: 'Misaligned icon',
        targetResult: const WidgetInspectionResult(
          identity: WidgetIdentity(id: 'w2', widgetType: 'Icon'),
          bounds: WidgetBounds(x: 80, y: 80, width: 24, height: 24),
          context: WidgetContext.empty(),
          ancestors: [],
        ),
      );
      await tester.pumpAndSettle();

      // Select comment
      controller.viewAnnotation(ann);
      await tester.pumpAndSettle();
      expect(find.byType(AnnotationDetailCard), findsOneWidget);

      // Tap Backspace
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();

      expect(controller.annotations.isEmpty, isTrue);
      expect(find.byType(AnnotationDetailCard), findsNothing);
    });

    testWidgets('pressing Escape key dismisses active comment detail card', (tester) async {
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

      final ann = await controller.createAnnotation(
        comment: 'Check padding',
        targetResult: const WidgetInspectionResult(
          identity: WidgetIdentity(id: 'w3', widgetType: 'Card'),
          bounds: WidgetBounds(x: 20, y: 20, width: 200, height: 100),
          context: WidgetContext.empty(),
          ancestors: [],
        ),
      );
      await tester.pumpAndSettle();

      controller.viewAnnotation(ann);
      await tester.pumpAndSettle();
      expect(find.byType(AnnotationDetailCard), findsOneWidget);

      // Tap Escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Annotation still exists, but detail card was dismissed
      expect(controller.annotations.length, equals(1));
      expect(controller.activeAnnotation, isNull);
      expect(find.byType(AnnotationDetailCard), findsNothing);
    });

    testWidgets('in AnnotationPopup pressing Escape dismisses popup without adding note', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterAgentation(
              controller: controller,
              showToolbar: false,
              child: const Center(child: Text('Target Button')),
            ),
          ),
        ),
      );

      controller.activate();
      controller.selectResult(const WidgetInspectionResult(
        identity: WidgetIdentity(id: 'btn1', widgetType: 'ElevatedButton'),
        bounds: WidgetBounds(x: 100, y: 100, width: 120, height: 40),
        context: WidgetContext.empty(),
        ancestors: [],
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AnnotationPopup), findsOneWidget);

      // Press Escape
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(AnnotationPopup), findsNothing);
      expect(controller.annotations.isEmpty, isTrue);
    });

    testWidgets('in AnnotationPopup pressing Ctrl+Enter saves the annotation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterAgentation(
              controller: controller,
              showToolbar: false,
              child: const Center(child: Text('Target Button')),
            ),
          ),
        ),
      );

      controller.activate();
      controller.selectResult(const WidgetInspectionResult(
        identity: WidgetIdentity(id: 'btn2', widgetType: 'ElevatedButton'),
        bounds: WidgetBounds(x: 100, y: 100, width: 120, height: 40),
        context: WidgetContext.empty(),
        ancestors: [],
      ));
      await tester.pumpAndSettle();

      // Enter comment
      final textField = find.descendant(of: find.byType(AnnotationPopup), matching: find.byType(TextField));
      await tester.enterText(textField, 'Shortcut saved note');
      await tester.pump();

      // Send Ctrl+Enter
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Verify annotation was saved
      expect(controller.annotations.length, equals(1));
      expect(controller.annotations.first.comment, equals('Shortcut saved note'));
      expect(find.byType(AnnotationPopup), findsNothing);
    });
  });
}
