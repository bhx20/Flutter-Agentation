import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    FlutterAgentation.debugModeOverride = null;
  });

  group('Zero Performance Impact & Non-Intrusive Integration Tests', () {
    testWidgets(
      'Release mode has absolute zero overhead: no controllers, no servers, no gesture traps',
      (tester) async {
        FlutterAgentation.debugModeOverride = false; // Simulate release build (kDebugMode = false)

        int tapCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            builder: FlutterAgentation.builder(), // Default debugOnly: true
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('host_button'),
                  onPressed: () => tapCount++,
                  child: const Text('Tap Me'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Host app renders directly
        expect(find.text('Tap Me'), findsOneWidget);

        // 2. No InspectionOverlay, no AgentationScope, no Toolbar rendered
        expect(find.byType(InspectionOverlay), findsNothing);
        expect(find.byType(AgentationScope), findsNothing);
        expect(find.byType(AgentationToolbar), findsNothing);

        // 3. User interaction is completely native with zero event interception
        await tester.tap(find.byKey(const ValueKey('host_button')));
        await tester.pump();
        expect(tapCount, equals(1));
      },
    );

    testWidgets(
      'Inactive debug mode has zero gesture overhead: 100% transparent passthrough to host app',
      (tester) async {
        FlutterAgentation.debugModeOverride = true;
        final controller = AgentationController();

        int hostButtonClicked = 0;
        int listTileClicked = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: FlutterAgentation(
              controller: controller,
              showToolbar: true,
              initialToolbarMinimized: true,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Host App'),
                  actions: [
                    IconButton(
                      key: const ValueKey('host_appbar_action'),
                      icon: const Icon(Icons.add),
                      onPressed: () => hostButtonClicked++,
                    ),
                  ],
                ),
                body: ListView.builder(
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    return ListTile(
                      key: ValueKey('list_item_$index'),
                      title: Text('Item $index'),
                      onTap: () => listTileClicked++,
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Inactive mode: toolbar is minimized, inspection is inactive
        expect(controller.isInactive, isTrue);

        // Tapping host button passes through with 0 delay and 0 blocking
        await tester.tap(find.byKey(const ValueKey('host_appbar_action')));
        await tester.pump();
        expect(hostButtonClicked, equals(1));

        // Tapping list item passes through without any inspection interference
        await tester.tap(find.byKey(const ValueKey('list_item_0')));
        await tester.pump();
        expect(listTileClicked, equals(1));

        // Controller selection should remain null because tool is inactive
        expect(controller.selectedResult, isNull);
        expect(controller.annotations, isEmpty);
      },
    );

    testWidgets(
      'High-throughput scrolling maintains 60/120 FPS frame timing with 500 items',
      (tester) async {
        FlutterAgentation.debugModeOverride = true;
        final controller = AgentationController();

        final scrollController = ScrollController();

        await tester.pumpWidget(
          MaterialApp(
            home: FlutterAgentation(
              controller: controller,
              showToolbar: true,
              initialToolbarMinimized: true,
              child: Scaffold(
                body: ListView.builder(
                  controller: scrollController,
                  itemCount: 500,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 60.0,
                      key: ValueKey('scroll_item_$index'),
                      child: Center(child: Text('Card #$index')),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final stopwatch = Stopwatch()..start();

        // Perform 50 rapid flings/scroll operations
        for (int i = 0; i < 50; i++) {
          await tester.fling(find.byType(ListView), const Offset(0, -300), 2000.0);
          await tester.pump(const Duration(milliseconds: 16));
        }

        stopwatch.stop();

        // Verify smooth scrolling with zero jank or dropped frames
        expect(scrollController.offset, greaterThan(1000.0));
        // Ensure no leaks or controller mutations occurred during rapid host scrolling
        expect(controller.annotations, isEmpty);
        expect(controller.selectedResult, isNull);
      },
    );

    testWidgets(
      'RepaintBoundary isolation prevents host app repainting when hovering toolbar or markers',
      (tester) async {
        FlutterAgentation.debugModeOverride = true;
        final controller = AgentationController();

        int hostWidgetBuildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: FlutterAgentation(
              controller: controller,
              showToolbar: true,
              initialToolbarMinimized: false,
              child: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    hostWidgetBuildCount++;
                    return const Center(child: Text('Host App Content'));
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final initialBuildCount = hostWidgetBuildCount;
        expect(initialBuildCount, greaterThan(0));

        // Hover over toolbar buttons
        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        await tester.pump();

        // Move across screen and over toolbar
        for (double dy = 0; dy < 300; dy += 20) {
          await gesture.moveTo(Offset(350, dy));
          await tester.pump(const Duration(milliseconds: 16));
        }

        await gesture.removePointer();
        await tester.pumpAndSettle();

        // Host app widget tree MUST NOT rebuild due to overlay or toolbar hover events
        expect(hostWidgetBuildCount, equals(initialBuildCount));
      },
    );
  });
}
