import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/core/flutter_agentation.dart';
import 'package:flutter_agentation/src/overlay/annotation_marker.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: avoid_relative_lib_imports
import '../../example/lib/main.dart';

void main() {
  group('Scroll Interaction During Inspection', () {
    testWidgets('mouse wheel scrolls page while inspection is active',
        (tester) async {
      final controller = AgentationController();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: false,
            child: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: 100,
                itemBuilder: (context, index) => SizedBox(
                  height: 60.0,
                  child: Text('Item $index'),
                ),
              ),
            ),
          ),
        ),
      );

      controller.activate();
      await tester.pumpAndSettle();

      expect(controller.isInspecting, isTrue);
      expect(scrollController.offset, equals(0.0));

      // Dispatch mouse wheel scroll event
      final center = tester.getCenter(find.text('Item 0'));
      final scrollEvent = PointerScrollEvent(
        position: center,
        scrollDelta: const Offset(0.0, 120.0),
      );
      tester.binding.handlePointerEvent(scrollEvent);
      await tester.pumpAndSettle();

      // Page must have scrolled down
      expect(scrollController.offset, greaterThan(0.0));
      // No widget should be selected from a wheel scroll
      expect(controller.selectedResult, isNull);
    });

    testWidgets('drag-to-scroll moves page and does not select widget',
        (tester) async {
      final controller = AgentationController();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: false,
            child: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: 100,
                itemBuilder: (context, index) => SizedBox(
                  height: 60.0,
                  child: Text('Item $index'),
                ),
              ),
            ),
          ),
        ),
      );

      controller.activate();
      await tester.pumpAndSettle();

      expect(controller.isInspecting, isTrue);
      expect(scrollController.offset, equals(0.0));

      // Perform vertical drag to scroll
      final gesture = await tester.startGesture(const Offset(100.0, 300.0));
      await tester.pump();
      await gesture.moveBy(const Offset(0.0, -100.0)); // drag upward to scroll down
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // Scroll position must have moved down
      expect(scrollController.offset, greaterThan(0.0));
      // No widget should be selected because it was a scroll gesture
      expect(controller.selectedResult, isNull);
    });

    testWidgets('stationary tap selects widget even in a scrollable page',
        (tester) async {
      final controller = AgentationController();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: false,
            child: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: 100,
                itemBuilder: (context, index) => SizedBox(
                  height: 60.0,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Button $index'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      controller.activate();
      await tester.pumpAndSettle();

      // Direct tap without dragging
      await tester.tap(find.text('Button 0'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Widget should be selected
      expect(controller.selectedResult, isNotNull);
      expect(controller.selectedResult!.isAvailable, isTrue);
      expect(
        controller.selectedResult!.identity.widgetType,
        anyOf(equals('ElevatedButton'), equals('Text')),
      );
    });

    testWidgets('annotation marker moves along with page scroll',
        (tester) async {
      final controller = AgentationController();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: false,
            child: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: 50,
                itemBuilder: (context, index) => Container(
                  key: ValueKey('item_$index'),
                  height: 100.0,
                  alignment: Alignment.centerLeft,
                  child: Text('Item $index'),
                ),
              ),
            ),
          ),
        ),
      );

      controller.activate();
      await tester.pumpAndSettle();

      // Tap on Item 2 (at y = 200 initially)
      await tester.tap(find.text('Item 2'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(controller.selectedResult, isNotNull);

      // Create an annotation on Item 2
      await controller.createAnnotation(
        comment: 'Comment on Item 2',
        targetResult: controller.selectedResult,
      );
      await tester.pumpAndSettle();

      // Marker 1 should be visible
      expect(find.text('1'), findsOneWidget);
      final initialPos = tester.getTopLeft(find.text('1'));

      // Scroll down by 80px
      scrollController.jumpTo(80.0);
      await tester.pumpAndSettle();

      // Marker 1 MUST have moved up by 80px in lockstep with Item 2
      final scrolledPos = tester.getTopLeft(find.text('1'));
      expect(scrolledPos.dy, closeTo(initialPos.dy - 80.0, 2.0));
    });

    testWidgets('annotation marker on fixed element stays fixed when body scrolls',
        (tester) async {
      final controller = AgentationController();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: false,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Fixed Header'),
                actions: [
                  IconButton(
                    key: const ValueKey('appbar_action'),
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                ],
              ),
              body: ListView.builder(
                controller: scrollController,
                itemCount: 50,
                itemBuilder: (context, index) => SizedBox(
                  height: 100.0,
                  child: Text('Body Item $index'),
                ),
              ),
            ),
          ),
        ),
      );

      controller.activate();
      await tester.pumpAndSettle();

      // Tap AppBar settings button
      await tester.tap(find.byKey(const ValueKey('appbar_action')), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(controller.selectedResult, isNotNull);

      // Create annotation on the fixed header element
      await controller.createAnnotation(
        comment: 'Fixed AppBar comment',
        targetResult: controller.selectedResult,
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      final initialPos = tester.getTopLeft(find.text('1'));

      // Scroll body down by 150px
      scrollController.jumpTo(150.0);
      await tester.pumpAndSettle();

      // The marker on the fixed AppBar must remain at its exact position!
      final afterScrollPos = tester.getTopLeft(find.text('1'));
      expect(afterScrollPos.dy, equals(initialPos.dy));
    });

    testWidgets('annotation marker hides when target scrolls out of viewport and reappears when scrolled back',
        (tester) async {
      final controller = AgentationController();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: false,
            child: Scaffold(
              body: SizedBox(
                height: 400.0,
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 50,
                  itemBuilder: (context, index) => SizedBox(
                    key: ValueKey('scroll_item_$index'),
                    height: 100.0,
                    child: Text('Row $index'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      controller.activate();
      await tester.pumpAndSettle();

      // Inspect Row 0
      await tester.tap(find.byKey(const ValueKey('scroll_item_0')), warnIfMissed: false);
      await tester.pumpAndSettle();

      await controller.createAnnotation(
        comment: 'Comment on Row 0',
        targetResult: controller.selectedResult,
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);

      // Scroll far down so Row 0 is completely above the viewport (> 400px down)
      scrollController.jumpTo(500.0);
      await tester.pumpAndSettle();

      // Marker 1 should be hidden/scrolled out of view
      expect(find.text('1'), findsNothing);

      // Scroll back up to top
      scrollController.jumpTo(0.0);
      await tester.pumpAndSettle();

      // Marker 1 reappears
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('annotation on CupertinoActivityIndicator moves with SingleChildScrollView',
        (tester) async {
      final controller = AgentationController();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            controller: controller,
            showToolbar: false,
            child: Scaffold(
              body: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: const [
                    SizedBox(height: 100),
                    CupertinoActivityIndicator(radius: 12, animating: false),
                    SizedBox(height: 1000),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      controller.activate();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CupertinoActivityIndicator), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(controller.selectedResult, isNotNull);

      await controller.createAnnotation(
        comment: 'Comment on loader',
        targetResult: controller.selectedResult,
      );
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      final initialPos = tester.getTopLeft(find.text('1'));

      scrollController.jumpTo(50.0);
      await tester.pumpAndSettle();

      final scrolledPos = tester.getTopLeft(find.text('1'));
      expect(scrolledPos.dy, closeTo(initialPos.dy - 50.0, 2.0));
    });

    testWidgets('NotificationListener in MaterialApp.builder receives ScrollNotification from route',
        (tester) async {
      int notificationsReceived = 0;
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                notificationsReceived++;
                return false;
              },
              child: child!,
            );
          },
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: const [
                  SizedBox(height: 100),
                  Text('Target Item'),
                  SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      );

      expect(notificationsReceived, equals(0));

      scrollController.jumpTo(100.0);
      await tester.pumpAndSettle();

      debugPrint('TEST RESULT: notificationsReceived = $notificationsReceived');
      expect(notificationsReceived, greaterThan(0));
    });

    testWidgets('FlutterAgentation in MaterialApp.builder updates annotation position when page scrolls',
        (tester) async {
      final controller = AgentationController();
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return FlutterAgentation(
              controller: controller,
              showToolbar: false,
              child: child,
            );
          },
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: const [
                  SizedBox(height: 100),
                  CupertinoActivityIndicator(radius: 12, animating: false),
                  SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      );

      controller.activate();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CupertinoActivityIndicator), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(controller.selectedResult, isNotNull);

      await controller.createAnnotation(
        comment: 'Comment on loader',
        targetResult: controller.selectedResult,
      );
      await tester.pumpAndSettle();

      expect(find.byType(AnnotationMarker), findsOneWidget);
      final initialPos = tester.getTopLeft(find.byType(AnnotationMarker));
      debugPrint('TEST initialPos: $initialPos');

      scrollController.jumpTo(80.0);
      await tester.pumpAndSettle();

      final scrolledPos = tester.getTopLeft(find.byType(AnnotationMarker));
      debugPrint('TEST scrolledPos: $scrolledPos');
      expect(scrolledPos.dy, closeTo(initialPos.dy - 80.0, 2.0));
    });

    testWidgets('InspectionDemoApp: comment on Cupertino loader tracks scrolling',
        (tester) async {
      await tester.pumpWidget(const InspectionDemoApp());
      await tester.pump(const Duration(milliseconds: 100));

      final controller = AgentationScope.of(tester.element(find.byType(InspectionDemoScreen)));
      controller.activate();
      await tester.pump(const Duration(milliseconds: 100));

      final mainScrollable = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first;
      // Scroll down until CupertinoActivityIndicator is visible
      await tester.scrollUntilVisible(
        find.byType(CupertinoActivityIndicator),
        300.0,
        scrollable: mainScrollable,
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on CupertinoActivityIndicator
      await tester.tap(find.byType(CupertinoActivityIndicator), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.selectedResult, isNotNull);
      debugPrint('DEMO TEST selectedResult: ${controller.selectedResult!.identity}, isFixed=${controller.selectedResult!.context.isFixed}');

      await controller.createAnnotation(
        comment: 'Comment on loader in demo app',
        targetResult: controller.selectedResult,
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AnnotationMarker), findsOneWidget);
      final initialPos = tester.getTopLeft(find.byType(AnnotationMarker));
      debugPrint('DEMO TEST initial marker pos: $initialPos');

      final center = tester.getCenter(find.byType(CupertinoActivityIndicator));
      final scrollEvent = PointerScrollEvent(
        position: center,
        scrollDelta: const Offset(0.0, -100.0),
      );
      tester.binding.handlePointerEvent(scrollEvent);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 50));

      final afterPos = tester.getTopLeft(find.byType(AnnotationMarker));
      expect(afterPos.dy, closeTo(initialPos.dy + 100.0, 2.0));
    });

    testWidgets('InspectionDemoApp: comment on Cupertino loader tracks drag-to-scroll',
        (tester) async {
      await tester.pumpWidget(const InspectionDemoApp());
      await tester.pump(const Duration(milliseconds: 100));

      final controller = AgentationScope.of(tester.element(find.byType(InspectionDemoScreen)));
      controller.activate();
      await tester.pump(const Duration(milliseconds: 100));

      final mainScrollable = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first;
      // Scroll down until CupertinoActivityIndicator is visible
      await tester.scrollUntilVisible(
        find.byType(CupertinoActivityIndicator),
        300.0,
        scrollable: mainScrollable,
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on CupertinoActivityIndicator
      await tester.tap(find.byType(CupertinoActivityIndicator), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.selectedResult, isNotNull);

      await controller.createAnnotation(
        comment: 'Comment on loader during drag',
        targetResult: controller.selectedResult,
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AnnotationMarker), findsOneWidget);
      final initialPos = tester.getTopLeft(find.byType(AnnotationMarker));

      // Perform a drag-to-scroll gesture (drag down by 60px to scroll up)
      final gesture = await tester.startGesture(const Offset(100.0, 100.0));
      await tester.pump();
      await gesture.moveBy(const Offset(0.0, 60.0));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 50));

      final afterDragPos = tester.getTopLeft(find.byType(AnnotationMarker));
      expect(afterDragPos.dy, closeTo(initialPos.dy + 60.0, 2.0));
    });
  });
}


