import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/src/components/agentation_logo.dart';
import 'package:example/src/components/footer.dart';
import 'package:example/src/components/navbar.dart';
import 'package:example/src/pages/code_mapping_page.dart';
import 'package:example/src/pages/installation_page.dart';
import 'package:example/src/pages/interactive_preview_page.dart';
import 'package:example/src/pages/mcp_webhooks_page.dart';
import 'package:example/src/pages/overview_page.dart';
import 'package:example/src/pages/toolbar_platforms_page.dart';
import 'package:example/src/pages/workflow_page.dart';

void main() {
  group('Landing Page Sections Tests', () {
    testWidgets('NavbarSection renders navigation links and action buttons', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      String? navigatedTo;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavbarSection(
              onNavigate: (section) => navigatedTo = section,
            ),
          ),
        ),
      );

      expect(find.byType(AgentationLogo), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Installation'), findsOneWidget);
      expect(find.text('MCP & Webhooks'), findsOneWidget);
      expect(find.text('Toolbar & Platforms'), findsOneWidget);
      expect(find.text('GitHub'), findsOneWidget);

      await tester.tap(find.text('Overview'));
      expect(navigatedTo, 'overview');
    });

    testWidgets('HeroSection renders headline, subtitle, and CTAs', (tester) async {
      bool getStartedTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HeroSection(
                onGetStarted: () => getStartedTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('Visual UI Feedback & MCP Server Engine for Flutter and AI Coding Agents'),
        findsOneWidget,
      );
      expect(find.text('Get Started with pub.dev'), findsOneWidget);

      await tester.tap(find.text('Get Started with pub.dev'));
      expect(getStartedTapped, isTrue);
    });

    testWidgets('MetricsSection renders all 4 dynamic pub.dev metrics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricsSection(),
          ),
        ),
      );

      expect(find.textContaining('Pub Points'), findsOneWidget);
      expect(find.textContaining('Downloads'), findsOneWidget);
      expect(find.textContaining('Likes'), findsOneWidget);
      expect(find.textContaining('Platforms'), findsOneWidget);
    });

    testWidgets('InteractivePreviewSection renders mockup and toggles pin visibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: InteractivePreviewSection(),
            ),
          ),
        ),
      );

      expect(find.text('localhost:3000'), findsOneWidget);
      expect(find.text('Benji\'s dashboard'), findsOneWidget);
      expect(find.text('Change to primary style'), findsOneWidget);

      // Close the pin popup
      final closeIcon = find.byKey(const ValueKey('close_callout_button'));
      await tester.tap(closeIcon);
      await tester.pumpAndSettle();

      expect(find.text('Change to primary style'), findsNothing);
    });

    testWidgets('WorkflowSection renders 6 steps and direct MCP banner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WorkflowSection(),
            ),
          ),
        ),
      );

      expect(find.text('How you use it'), findsOneWidget);
      expect(find.text('Activate overlay'), findsOneWidget);
      expect(find.text('Hover & inspect'), findsOneWidget);
      expect(find.text('Target element'), findsOneWidget);
      expect(find.text('Submit note'), findsOneWidget);
      expect(find.text('Copy markdown'), findsOneWidget);
      expect(find.text('Paste to agent'), findsOneWidget);
      expect(find.text('Zero copy-paste required'), findsOneWidget);
    });

    testWidgets('CodeMappingSection renders before/after and agent loop', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CodeMappingSection(),
            ),
          ),
        ),
      );

      expect(find.text('Direct Widget-to-Code Mapping'), findsOneWidget);
      expect(find.text('WITHOUT FLUTTER AGENTATION'), findsOneWidget);
      expect(find.text('WITH FLUTTER AGENTATION'), findsOneWidget);
      expect(find.text('Agents talk back'), findsOneWidget);
      expect(find.text('“What annotations do I have?”'), findsOneWidget);
    });

    testWidgets('QuickstartSection renders 4 installation cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: QuickstartSection(),
            ),
          ),
        ),
      );

      expect(find.text('Installation & Setup'), findsOneWidget);
      expect(find.text('Add Dependency'), findsOneWidget);
      expect(find.text('Wrap Your App'), findsOneWidget);
      expect(find.text('Run the CLI Setup (setupmcp)'), findsOneWidget);
      expect(find.text('Run App & Inspect'), findsOneWidget);
    });

    testWidgets('McpWebhooksSection switches payload tabs and shows endpoints', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: McpWebhooksSection(),
            ),
          ),
        ),
      );

      expect(find.text('MCP & Webhooks'), findsOneWidget);
      expect(find.text('MCP Server & Endpoints'), findsOneWidget);
      expect(find.text('/health, /status'), findsOneWidget);
      expect(find.text('/sse, /events'), findsOneWidget);

      // Tap Slack Incoming tab
      await tester.tap(find.text('Slack Incoming'));
      await tester.pumpAndSettle();
      expect(find.textContaining('New visual feedback submitted on ElevatedButton'), findsOneWidget);

      // Tap Discord Webhook tab
      await tester.tap(find.text('Discord Webhook'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Flutter Agentation Feedback Event'), findsOneWidget);
    });

    testWidgets('ToolbarPlatformsSection renders wireframe palette and transport matrix', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ToolbarPlatformsSection(),
            ),
          ),
        ),
      );

      expect(find.text('Floating Toolbar & Platform Transports'), findsOneWidget);
      expect(find.text('Flutter Skeleton Wireframe Palette'), findsOneWidget);
      expect(find.text('Desktop'), findsOneWidget);
      expect(find.text('Android'), findsOneWidget);
      expect(find.text('iOS'), findsOneWidget);
    });

    testWidgets('FooterSection renders license and version tags', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FooterSection(),
          ),
        ),
      );

      expect(find.text('Flutter Agentation'), findsOneWidget);
      expect(find.text('Dart 3.x+'), findsOneWidget);
      expect(find.text('Flutter 3.22+'), findsOneWidget);
      expect(find.text('License: MIT'), findsOneWidget);
    });
  });
}
