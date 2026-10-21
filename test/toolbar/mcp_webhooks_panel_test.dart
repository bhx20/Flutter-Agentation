import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/ui/toolbar/mcp_webhooks_panel.dart';
import 'package:flutter_agentation/src/ui/toolbar/settings_panel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('McpWebhooksPanel & Settings Integration Tests', () {
    late AgentationController controller;

    setUp(() {
      controller = AgentationController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('SettingsPanel navigates to Manage MCP & Webhooks and back', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsPanel(
              controller: controller,
              onClose: () {},
            ),
          ),
        ),
      );

      // Verify "Manage MCP & Webhooks" nav link is present
      final navLinkFinder = find.byKey(const ValueKey('settings_nav_mcp_webhooks'));
      expect(navLinkFinder, findsOneWidget);
      expect(find.text('Manage MCP & Webhooks'), findsOneWidget);

      // Tap nav link
      await tester.tap(navLinkFinder);
      await tester.pumpAndSettle();

      // Should now render McpWebhooksPanel
      expect(find.byType(McpWebhooksPanel), findsOneWidget);
      expect(find.text('MCP Connection'), findsOneWidget);
      expect(find.text('Webhooks'), findsOneWidget);
      expect(find.text('Auto-Send'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Back in main settings
      expect(find.byType(McpWebhooksPanel), findsNothing);
      expect(find.byKey(const ValueKey('settings_nav_mcp_webhooks')), findsOneWidget);
    });

    testWidgets('McpWebhooksPanel updates webhook URL and autoSend toggle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: McpWebhooksPanel(
              controller: controller,
              onBack: () {},
            ),
          ),
        ),
      );

      // Enter Webhook URL
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'https://my-agent.ngrok.app/webhook');
      await tester.pump();

      expect(controller.settings.webhookUrl, equals('https://my-agent.ngrok.app/webhook'));

      // Toggle Auto-Send
      final autoSendToggle = find.byKey(const ValueKey('toggle_webhook_autosend'));
      expect(autoSendToggle, findsOneWidget);
      await tester.tap(autoSendToggle);
      await tester.pump();

      expect(controller.settings.autoSendWebhook, isTrue);

      // Test connection button renders
      expect(find.text('Test Connection'), findsOneWidget);
    });
  });
}
