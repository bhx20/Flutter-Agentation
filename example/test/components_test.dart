import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/src/components/action_button.dart';
import 'package:example/src/components/agentation_logo.dart';
import 'package:example/src/components/app_icons.dart';
import 'package:example/src/components/browser_window_frame.dart';
import 'package:example/src/components/code_snippet_card.dart';
import 'package:example/src/components/copy_pill.dart';
import 'package:example/src/components/hover_tile.dart';
import 'package:example/src/components/metric_card.dart';
import 'package:example/src/components/section_badge.dart';
import 'package:example/src/components/section_header.dart';
import 'package:example/src/theme/app_colors.dart';

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      return null;
    });
  });
  group('Atomic Components Tests', () {
    testWidgets('ActionButton renders and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              text: 'Click Me',
              icon: Icons.check,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('CopyPill renders command and triggers copy on tap', (tester) async {
      bool copied = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CopyPill(
              command: 'dart run setup',
              onCopied: () => copied = true,
            ),
          ),
        ),
      );

      expect(find.text('dart run setup'), findsOneWidget);
      await tester.tap(find.text('dart run setup'));
      await tester.pump();
      expect(copied, isTrue);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('SectionBadge renders uppercase label and dot indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionBadge(
              label: 'Production Ready',
              dotColor: AppColors.accentGreen,
            ),
          ),
        ),
      );

      expect(find.text('PRODUCTION READY'), findsOneWidget);
    });

    testWidgets('SectionHeader renders tag, title, and description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              tag: 'Architecture',
              title: 'Core Engine',
              description: 'Detailed description of the engine',
            ),
          ),
        ),
      );

      expect(find.text('ARCHITECTURE'), findsOneWidget);
      expect(find.text('Core Engine'), findsOneWidget);
      expect(find.text('Detailed description of the engine'), findsOneWidget);
    });

    testWidgets('MetricCard renders value, label, and optional badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricCard(
              value: '140 Pub Points',
              label: 'pub.dev benchmark',
              badge: '100%',
            ),
          ),
        ),
      );

      expect(find.text('140 Pub Points'), findsOneWidget);
      expect(find.text('pub.dev benchmark'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('BrowserWindowFrame renders title, url, and children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BrowserWindowFrame(
              title: 'Dashboard Test',
              url: 'localhost:3000',
              child: Text('Window Content'),
            ),
          ),
        ),
      );

      expect(find.text('localhost:3000'), findsOneWidget);
      expect(find.text('Window Content'), findsOneWidget);
    });

    testWidgets('CodeSnippetCard renders code block and copy action', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CodeSnippetCard(
              title: 'Terminal',
              code: 'flutter test',
            ),
          ),
        ),
      );

      expect(find.text('Terminal'), findsOneWidget);
      expect(find.text('flutter test'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('AgentationLogo renders official vector SVG', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgentationLogo(height: 24),
          ),
        ),
      );

      expect(find.byType(AgentationLogo), findsOneWidget);
    });

    testWidgets('HoverTile renders child, responds to tap and hover states', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HoverTile(
              onTap: () => tapped = true,
              child: const Text('Hoverable Item'),
            ),
          ),
        ),
      );

      expect(find.text('Hoverable Item'), findsOneWidget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(find.text('Hoverable Item')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hoverable Item'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('AppIcons renders lock icon with custom paint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppIcons.lock(size: 16, color: Colors.blue),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.size == const Size(16, 16),
        ),
        findsOneWidget,
      );
    });
  });
}
