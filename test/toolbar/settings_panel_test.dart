import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/core/package_version.dart';
import 'package:flutter_agentation/src/models/marker_color.dart';
import 'package:flutter_agentation/src/storage/memory_annotation_storage.dart';
import 'package:flutter_agentation/src/toolbar/settings_panel.dart';

void main() {
  group('SettingsPanel Widget & Parity Theming', () {
    late MemoryAnnotationStorage storage;
    late AgentationController controller;

    setUp(() {
      storage = MemoryAnnotationStorage();
      controller = AgentationController(storage: storage);
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders theme toggle, all 7 marker color swatches, and behavior switches',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: SettingsPanel(
                onClose: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & version dynamically from pubspec.yaml
      expect(find.textContaining('Agentation'), findsOneWidget);
      expect(find.textContaining('v${PackageVersion.current}'), findsOneWidget);
      expect(find.byKey(const ValueKey('theme_toggle_button')), findsOneWidget);

      // Verify all 7 color swatches exist by tooltip or label
      for (final color in MarkerColor.values) {
        expect(find.byTooltip(color.label), findsOneWidget);
      }

      // Verify behavior toggles exist
      expect(find.text('Clear on copy/send'), findsOneWidget);
      expect(find.text('Block page interactions'), findsOneWidget);
    });

    testWidgets('selecting marker color swatch updates controller settings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: SettingsPanel(onClose: () {}),
            ),
          ),
        ),
      );

      expect(controller.settings.markerColorId, equals('indigo'));

      // Tap Emerald swatch
      final emeraldFinder = find.byTooltip('Emerald');
      expect(emeraldFinder, findsOneWidget);
      await tester.tap(emeraldFinder);
      await tester.pumpAndSettle();

      expect(controller.settings.markerColorId, equals('emerald'));

      // Tap Rose swatch
      final roseFinder = find.byTooltip('Rose');
      expect(roseFinder, findsOneWidget);
      await tester.tap(roseFinder);
      await tester.pumpAndSettle();

      expect(controller.settings.markerColorId, equals('rose'));
    });

    testWidgets('toggling theme updates controller dark mode setting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: SettingsPanel(onClose: () {}),
            ),
          ),
        ),
      );

      expect(controller.settings.isDarkMode, isTrue);

      // Tap Theme toggle button (Sun/Moon icon)
      await tester.tap(find.byKey(const ValueKey('theme_toggle_button')));
      await tester.pumpAndSettle();

      expect(controller.settings.isDarkMode, isFalse);

      // Tap Theme toggle button again
      await tester.tap(find.byKey(const ValueKey('theme_toggle_button')));
      await tester.pumpAndSettle();

      expect(controller.settings.isDarkMode, isTrue);
    });

    testWidgets('toggling behavior options updates controller settings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: SettingsPanel(onClose: () {}),
            ),
          ),
        ),
      );

      expect(controller.settings.autoClearAfterCopy, isFalse);
      expect(controller.settings.blockInteractions, isTrue);

      // Toggle auto-clear checkbox
      final autoClearFinder = find.byKey(const ValueKey('toggle_auto_clear'));
      expect(autoClearFinder, findsOneWidget);
      await tester.tap(autoClearFinder);
      await tester.pumpAndSettle();

      expect(controller.settings.autoClearAfterCopy, isTrue);

      // Toggle block interactions
      final blockFinder = find.byKey(const ValueKey('toggle_block_interactions'));
      expect(blockFinder, findsOneWidget);
      await tester.tap(blockFinder);
      await tester.pumpAndSettle();

      expect(controller.settings.blockInteractions, isFalse);
    });

    testWidgets('verifies clean Agentation settings layout, React components removed, and version matching pubspec.yaml',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: SettingsPanel(onClose: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header displays dynamic version
      expect(find.textContaining('Agentation'), findsOneWidget);
      expect(find.textContaining('v${PackageVersion.current}'), findsOneWidget);
      expect(find.byKey(const ValueKey('theme_toggle_button')), findsOneWidget);

      // Rows match specification
      expect(find.text('Output Detail'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Hide Until Restart'), findsOneWidget);
      expect(find.text('Marker Color'), findsOneWidget);
      expect(find.text('Clear on copy/send'), findsOneWidget);
      expect(find.text('Block page interactions'), findsOneWidget);

      // Verify React Components is removed (Flutter widgets always inspected by default)
      expect(find.text('React Components'), findsNothing);

      // Verify MCP & Webhook controls are completely removed
      expect(find.text('Manage MCP & Webhooks'), findsNothing);
      expect(find.text('Automations & MCP Sync'), findsNothing);
      expect(find.byKey(const ValueKey('manage_mcp_webhooks_tile')), findsNothing);
      expect(find.byKey(const ValueKey('mcp_endpoint_input')), findsNothing);
    });

    testWidgets('displays help popup tooltip on "?" icon tap or hover', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: SettingsPanel(onClose: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tooltip is initially not visible
      expect(find.text('Controls how much detail is included in the copied output'), findsNothing);

      // Tap on Output Detail help icon
      final outputDetailRow = find.ancestor(
        of: find.text('Output Detail'),
        matching: find.byType(Row),
      ).first;

      final helpIconFinder = find.descendant(
        of: outputDetailRow,
        matching: find.byType(GestureDetector),
      ).first;

      await tester.tap(helpIconFinder);
      await tester.pumpAndSettle();

      // Tooltip popup is visible
      expect(find.text('Controls how much detail is included in the copied output'), findsOneWidget);

      // Tapping again hides it
      await tester.tap(helpIconFinder);
      await tester.pumpAndSettle();
      expect(find.text('Controls how much detail is included in the copied output'), findsNothing);
    });
  });
}
