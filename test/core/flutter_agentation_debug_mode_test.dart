import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

void main() {
  tearDown(() {
    FlutterAgentation.debugModeOverride = null;
  });

  group('FlutterAgentation debugOnly & release mode behavior', () {
    testWidgets('defaults to debugOnly = true', (tester) async {
      const widget = FlutterAgentation(child: SizedBox());
      expect(widget.debugOnly, isTrue);
    });

    testWidgets('renders full overlay in debug mode by default', (tester) async {
      FlutterAgentation.debugModeOverride = true;

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            child: const Text('App Content'),
          ),
        ),
      );

      expect(find.text('App Content'), findsOneWidget);
      expect(find.byType(InspectionOverlay), findsOneWidget);
      expect(find.byType(AgentationScope), findsOneWidget);
    });

    testWidgets('completely hides and renders pure child in release mode when debugOnly is true', (tester) async {
      // Simulate release mode (kDebugMode = false)
      FlutterAgentation.debugModeOverride = false;

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            debugOnly: true,
            child: const Text('App Content'),
          ),
        ),
      );

      // Child is rendered
      expect(find.text('App Content'), findsOneWidget);
      // Tooling overlay and scope are completely bypassed
      expect(find.byType(InspectionOverlay), findsNothing);
      expect(find.byType(AgentationScope), findsNothing);
    });

    testWidgets('renders overlay even in release mode when debugOnly is set to false', (tester) async {
      // Simulate release mode
      FlutterAgentation.debugModeOverride = false;

      await tester.pumpWidget(
        MaterialApp(
          home: FlutterAgentation(
            debugOnly: false,
            child: const Text('App Content'),
          ),
        ),
      );

      // Since debugOnly is explicitly false, it stays active
      expect(find.text('App Content'), findsOneWidget);
      expect(find.byType(InspectionOverlay), findsOneWidget);
      expect(find.byType(AgentationScope), findsOneWidget);
    });

    testWidgets('FlutterAgentation.builder defaults to debugOnly = true and respects release mode', (tester) async {
      FlutterAgentation.debugModeOverride = false;

      await tester.pumpWidget(
        MaterialApp(
          builder: FlutterAgentation.builder(),
          home: const Scaffold(
            body: Text('Home Screen'),
          ),
        ),
      );

      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.byType(InspectionOverlay), findsNothing);
      expect(find.byType(AgentationScope), findsNothing);
    });
  });
}
