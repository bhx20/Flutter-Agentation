import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/flutter_agentation.dart';

// ── Master Prompt Section 16 Test Sample ──
class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: const Text('Login'),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Welcome'),
          LoginButton(),
          const TextField(),
        ],
      ),
    );
  }
}

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

  group('Source Location Resolution & Master Prompt Section 16', () {
    testWidgets('identifies exact source location for custom LoginButton in LoginPage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      final loginButtonFinder = find.byType(LoginButton);
      expect(loginButtonFinder, findsOneWidget);

      final element = tester.element(loginButtonFinder);
      final resolver = FlutterSourceLocationResolver();
      final location = resolver.resolve(element);

      expect(location, isNotNull);
      expect(location!.isAvailable, isTrue);
      expect(location.fileName, equals('source_location_resolver_test.dart'));
      expect(location.filePath, contains('test/source_location/source_location_resolver_test.dart'));
      // Exactly line 28 where `LoginButton(),` constructor is invoked in LoginPage.build above
      expect(location.line, equals(28));
      expect(location.column, isNotNull);
    });

    testWidgets('resolves correct widget class name preferring custom widget over internal render objects', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      final engine = FlutterInspectionEngine();
      final element = tester.element(find.byType(LoginButton));
      final result = engine.inspectElement(element);

      expect(result.isAvailable, isTrue);
      expect(result.identity.widgetType, equals('LoginButton'));
      expect(result.identity.widgetType, isNot(equals('RenderFlex')));
      expect(result.identity.widgetType, isNot(equals('Semantics')));
      expect(result.sourceLocation, isNotNull);
      expect(result.sourceLocation!.line, equals(28));
    });

    testWidgets('resolves Material widget class name accurately', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      final engine = FlutterInspectionEngine();
      final element = tester.element(find.byType(ElevatedButton));
      final result = engine.inspectElement(element);

      expect(result.isAvailable, isTrue);
      expect(result.identity.widgetType, equals('ElevatedButton'));
    });

    testWidgets('end-to-end clipboard export creates exact token-efficient feedback output', (tester) async {
      final storage = MemoryAnnotationStorage();
      final controller = AgentationController(storage: storage);

      await tester.pumpWidget(
        MaterialApp(
          home: AgentationScope(
            controller: controller,
            child: const LoginPage(),
          ),
        ),
      );

      final engine = controller.engine;
      final element = tester.element(find.byType(LoginButton));
      final result = engine.inspectElement(element);

      await controller.createAnnotation(
        comment: 'Make this button taller.',
        targetResult: result,
      );

      expect(controller.annotations.length, equals(1));

      final exported = await controller.exportAnnotations();
      expect(exported, isNotNull);

      // Verify exact clipboard structure matching Section 11 & Section 16
      final lines = exported!.split('\n');
      expect(lines[0], equals('[Flutter UI Feedback]'));
      expect(lines[1], equals('Widget: LoginButton'));
      expect(lines[2], equals('File: source_location_resolver_test.dart'));
      expect(lines[3], contains('Location: test/source_location/source_location_resolver_test.dart'));
      expect(lines[4], equals('Line: 28'));
      expect(lines[5], equals('Comment: Make this button taller.'));

      // Ensure NO unnecessary context, dumps, JSON, or framework internals
      expect(exported, isNot(contains('{')));
      expect(exported, isNot(contains('RenderObject')));
      expect(exported, isNot(contains('Diagnostics')));
      expect(exported, isNot(contains('bounds')));

      // Verify actual clipboard data received
      final clipData = await Clipboard.getData(Clipboard.kTextPlain);
      expect(clipData?.text, equals(exported));
    });

    testWidgets('multiple comments export sequentially numbered items per Section 12', (tester) async {
      final storage = MemoryAnnotationStorage();
      final controller = AgentationController(storage: storage);

      await tester.pumpWidget(
        MaterialApp(
          home: AgentationScope(
            controller: controller,
            child: const LoginPage(),
          ),
        ),
      );

      final engine = controller.engine;

      // 1. First target: LoginButton
      final btnResult = engine.inspectElement(tester.element(find.byType(LoginButton)));
      await controller.createAnnotation(
        comment: 'Increase the button height to 48px.',
        targetResult: btnResult,
      );

      // 2. Second target: TextField
      final fieldResult = engine.inspectElement(tester.element(find.byType(TextField)));
      await controller.createAnnotation(
        comment: 'Add more spacing above this field.',
        targetResult: fieldResult,
      );

      expect(controller.annotations.length, equals(2));

      final exported = await controller.exportAnnotations();
      expect(exported, isNotNull);

      expect(exported, startsWith('[Flutter UI Feedback]\n\n1.\nWidget: LoginButton'));
      expect(exported, contains('Comment: Increase the button height to 48px.'));
      expect(exported, contains('2.\nWidget: TextField'));
      expect(exported, contains('Comment: Add more spacing above this field.'));

      final clipData = await Clipboard.getData(Clipboard.kTextPlain);
      expect(clipData?.text, equals(exported));
    });
  });
}
