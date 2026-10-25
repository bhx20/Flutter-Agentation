import 'package:flutter_agentation/flutter_agentation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WidgetCodeResolver', () {
    test('resolves canonical code for Text widget', () {
      const result = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'text_1',
          widgetType: 'Text',
        ),
        bounds: WidgetBounds(x: 10, y: 10, width: 80, height: 20),
        context: WidgetContext.empty(),
        ancestors: ['Text'],
        text: 'Hello World',
      );

      final code = WidgetCodeResolver.resolveWidgetCode(result: result);
      expect(code, equals("Text('Hello World')"));
    });

    test('resolves canonical code for ElevatedButton with key and text', () {
      const result = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'btn_1',
          keyString: 'submit_btn',
          widgetType: 'ElevatedButton',
        ),
        bounds: WidgetBounds(x: 10, y: 10, width: 120, height: 40),
        context: WidgetContext.empty(),
        ancestors: ['ElevatedButton'],
        text: 'Submit Form',
      );

      final code = WidgetCodeResolver.resolveWidgetCode(result: result);
      expect(code, contains('ElevatedButton('));
      expect(code, contains("key: const Key('submit_btn')"));
      expect(code, contains("child: Text('Submit Form')"));
      expect(code, contains('onPressed: () {}'));
    });

    test('resolves canonical code for Container with dimensions', () {
      const result = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'container_1',
          widgetType: 'Container',
        ),
        bounds: WidgetBounds(x: 0, y: 0, width: 150, height: 75),
        context: WidgetContext.empty(),
        ancestors: ['Container'],
      );

      final code = WidgetCodeResolver.resolveWidgetCode(result: result);
      expect(code, contains('Container('));
      expect(code, contains('width: 150.0'));
      expect(code, contains('height: 75.0'));
    });

    test('resolves canonical code for Card with child text', () {
      const result = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'card_1',
          widgetType: 'Card',
        ),
        bounds: WidgetBounds(x: 0, y: 0, width: 200, height: 100),
        context: WidgetContext.empty(),
        ancestors: ['Card'],
        text: 'Card Content',
      );

      final code = WidgetCodeResolver.resolveWidgetCode(result: result);
      expect(code, contains('Card('));
      expect(code, contains("Text('Card Content')"));
    });

    test('extracts exact source code from file when sourceLocation is available', () {
      const location = WidgetSourceLocation(
        fileName: 'test_button.dart',
        filePath: 'test/fixtures/test_button.dart',
        line: 4,
      );

      const result = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'btn_section',
          widgetType: 'ElevatedButton',
        ),
        bounds: WidgetBounds(x: 20, y: 50, width: 160, height: 48),
        context: WidgetContext.empty(),
        ancestors: ['ElevatedButton'],
        sourceLocation: location,
      );

      final code = WidgetCodeResolver.resolveWidgetCode(result: result);
      expect(code, isNotEmpty);
      expect(code, contains('ElevatedButton('));
      expect(code, contains('Primary Action'));
    });

    test('prefers pre-computed widgetCode on WidgetInspectionResult', () {
      const result = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'custom_1',
          widgetType: 'CustomWidget',
        ),
        bounds: WidgetBounds.zero(),
        context: WidgetContext.empty(),
        ancestors: ['CustomWidget'],
        widgetCode: 'CustomWidget(\n  customProperty: 42,\n)',
      );

      final code = WidgetCodeResolver.resolveWidgetCode(result: result);
      expect(code, equals('CustomWidget(\n  customProperty: 42,\n)'));
    });

    test('extracts multi-line WidgetCard declaration with nested children from layout_section.dart', () {
      const location = WidgetSourceLocation(
        fileName: 'test_button.dart',
        filePath: 'test/fixtures/test_button.dart',
        line: 29,
      );

      const result = WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'widget_card_layout',
          widgetType: 'WidgetCard',
        ),
        bounds: WidgetBounds(x: 16, y: 100, width: 340, height: 180),
        context: WidgetContext.empty(),
        ancestors: ['WidgetCard', 'Column', 'LayoutSection'],
        sourceLocation: location,
      );

      final code = WidgetCodeResolver.resolveWidgetCode(result: result);
      expect(code, startsWith('const WidgetCard('));
      expect(code, contains("title: 'Row, Expanded, Flexible & Spacer'"));
      expect(code, contains("subtitle: 'Horizontal linear layout distribution'"));
      expect(code, contains('badgeColor: Color(0xFF3B82F6)'));
      expect(code, contains('child: Row('));
      expect(code, contains('Expanded('));
      expect(code, contains('flex: 2'));
      expect(code, contains('Flexible('));
      expect(code, contains('Spacer(flex: 1)'));
      expect(code, endsWith(')'));
    });
  });
}

