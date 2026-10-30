import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/ui/toolbar/agentation_toolbar.dart';
import 'package:flutter_agentation/src/ui/toolbar/mcp_webhooks_panel.dart';
import 'package:flutter_agentation/src/ui/toolbar/settings_panel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('McpWebhooksPanel & Settings Integration Tests', () {
    late AgentationController controller;

    setUp(() {
      controller = AgentationController();
    });

    tearDown(() async {
      await controller.mcpServer.stop();
      controller.dispose();
    });

    testWidgets('SettingsPanel navigates to Manage MCP & Webhooks and back', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsPanel(controller: controller, onClose: () {}),
          ),
        ),
      );

      // Verify "Manage MCP & Webhooks" nav link is present
      final navLinkFinder = find.byKey(
        const ValueKey('settings_nav_mcp_webhooks'),
      );
      expect(navLinkFinder, findsOneWidget);
      expect(find.text('Manage MCP & Webhooks'), findsOneWidget);

      // Tap nav link
      await tester.tap(navLinkFinder);
      await tester.pumpAndSettle();

      // Should now render McpWebhooksPanel
      expect(find.byType(McpWebhooksPanel), findsOneWidget);
      expect(find.text('MCP Connection'), findsOneWidget);
      expect(find.text('Webhooks'), findsOneWidget);
      expect(find.text('Auto-Send'), findsNWidgets(2));

      // Tap back button
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Back in main settings
      expect(find.byType(McpWebhooksPanel), findsNothing);
      expect(
        find.byKey(const ValueKey('settings_nav_mcp_webhooks')),
        findsOneWidget,
      );
    });

    testWidgets('McpWebhooksPanel updates webhook URL and autoSend toggle', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: McpWebhooksPanel(controller: controller, onBack: () {}),
          ),
        ),
      );

      // Enter Webhook URL
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'https://my-agent.ngrok.app/webhook');
      await tester.pump();

      expect(
        controller.settings.webhookUrl,
        equals('https://my-agent.ngrok.app/webhook'),
      );

      // Toggle Auto-Send
      final autoSendToggle = find.byKey(
        const ValueKey('toggle_webhook_autosend'),
      );
      expect(autoSendToggle, findsOneWidget);
      await tester.tap(autoSendToggle);
      await tester.pump();

      expect(controller.settings.autoSendWebhook, isTrue);

      // Test connection button renders
      expect(find.text('Test Connection'), findsOneWidget);
    });

    testWidgets(
      'SettingsPanel maintains consistent height and w500 font on view navigation',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsPanel(controller: controller, onClose: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final initialBox =
            tester.renderObject(find.byType(SettingsPanel)) as RenderBox;
        final initialHeight = initialBox.size.height;

        // Tap nav link
        await tester.tap(
          find.byKey(const ValueKey('settings_nav_mcp_webhooks')),
        );
        await tester.pumpAndSettle();

        final mcpBox =
            tester.renderObject(find.byType(SettingsPanel)) as RenderBox;
        final mcpHeight = mcpBox.size.height;

        // Heights should match
        expect(mcpHeight, equals(initialHeight));

        // Header uses w500 font
        final headerText = tester.widget<Text>(
          find.text('Manage MCP & Webhooks'),
        );
        expect(headerText.style?.fontWeight, equals(FontWeight.w500));

        // Tooltips have multiline constraints
        final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip));
        for (final tooltip in tooltips) {
          expect(tooltip.constraints?.maxWidth, isNotNull);
          expect(tooltip.textStyle?.fontWeight, equals(FontWeight.normal));
        }

        // Tap back button
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();

        final backBox =
            tester.renderObject(find.byType(SettingsPanel)) as RenderBox;
        expect(backBox.size.height, equals(initialHeight));
      },
    );

    testWidgets(
      'Send Annotations button renders when canSend is true, displays badge and submits',
      (tester) async {
        bool submitCalled = false;
        String? submittedOutput;
        controller.onSubmit = (output, annotations) {
          submitCalled = true;
          submittedOutput = output;
        };

        // When canSend is true, button renders in AgentationToolbar
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [AgentationToolbar(controller: controller)],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find Send button
        final sendButtonFinder = find.byKey(const ValueKey('toolbar_send'));
        expect(sendButtonFinder, findsOneWidget);

        // Add an annotation to activate send button and badge
        await controller.createAnnotation(comment: 'Needs better contrast');
        await tester.pumpAndSettle();

        // Badge showing annotation count "1"
        expect(find.text('1'), findsOneWidget);

        // Tap Send button
        await tester.tap(sendButtonFinder);
        await tester.pump();

        expect(submitCalled, isTrue);
        expect(submittedOutput, isNotNull);
        expect(submittedOutput, contains('Needs better contrast'));

        // Advances timer past 2.5s to verify return to idle
        await tester.pump(const Duration(milliseconds: 3000));
      },
    );

    testWidgets(
      'McpWebhooksPanel renders clean MCP status and does not show Learn more or Web Bridge',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: McpWebhooksPanel(controller: controller, onBack: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // MCP Connection header and description render cleanly
        expect(find.text('MCP Connection'), findsOneWidget);
        expect(
          find.text(
            'MCP connection allows agents to receive and act on annotations.',
          ),
          findsOneWidget,
        );

        // "Learn more" and "Web Bridge Connected" are removed per design
        expect(find.text('Learn more'), findsNothing);
        expect(find.text('Web Bridge Connected'), findsNothing);
        expect(find.text('Web Browser MCP Bridge'), findsNothing);

        // Status indicator tooltip is present
        final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip));
        expect(tooltips, isNotEmpty);

        // Verify MCP on/off switch and Auto-Send switch are present
        final mcpToggleFinder = find.byKey(const ValueKey('toggle_mcp_server'));
        expect(mcpToggleFinder, findsOneWidget);

        final autoSendMcpFinder = find.byKey(
          const ValueKey('toggle_mcp_autosend'),
        );
        expect(autoSendMcpFinder, findsOneWidget);

        // Tap MCP switch to toggle
        await tester.tap(mcpToggleFinder);
        await tester.pump();
        expect(controller.settings.mcpEnabled, isTrue);

        // Tap Auto-Send switch to toggle
        await tester.tap(autoSendMcpFinder);
        await tester.pump();
        expect(controller.settings.autoSendMcp, isFalse);

        // Clean up server
        await controller.mcpServer.stop();
        await tester.pump();
      },
    );
  });
}
