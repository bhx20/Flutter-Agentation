import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/source_location/feedback_context_builder.dart';
import 'package:flutter_agentation/src/source_location/feedback_target.dart';
import 'package:flutter_agentation/src/source_location/widget_source_location.dart';

void main() {
  group('FeedbackContextBuilder', () {
    const builder = FeedbackContextBuilder();

    test('builds single feedback item strictly matching Section 11', () {
      const target = FeedbackTarget(
        widgetName: 'LoginButton',
        source: WidgetSourceLocation(
          fileName: 'login_page.dart',
          filePath: 'lib/features/auth/login_page.dart',
          line: 87,
          column: 15,
        ),
      );

      final output = builder.build(target, 'Increase the button height to 48px.');

      const expected = '''[Flutter UI Feedback]
Widget: LoginButton
File: login_page.dart
Location: lib/features/auth/login_page.dart
Line: 87
Comment: Increase the button height to 48px.''';

      expect(output, equals(expected));
    });

    test('builds multiple feedback items strictly matching Section 12', () {
      final items = [
        (
          target: const FeedbackTarget(
            widgetName: 'LoginButton',
            source: WidgetSourceLocation(
              fileName: 'login_page.dart',
              filePath: 'lib/features/auth/login_page.dart',
              line: 87,
            ),
          ),
          comment: 'Increase the button height to 48px.',
        ),
        (
          target: const FeedbackTarget(
            widgetName: 'EmailField',
            source: WidgetSourceLocation(
              fileName: 'login_page.dart',
              filePath: 'lib/features/auth/login_page.dart',
              line: 63,
            ),
          ),
          comment: 'Add more spacing above this field.',
        ),
      ];

      final output = builder.buildMultiple(items);

      const expected = '''[Flutter UI Feedback]

1.
Widget: LoginButton
File: login_page.dart
Location: lib/features/auth/login_page.dart
Line: 87
Comment: Increase the button height to 48px.

2.
Widget: EmailField
File: login_page.dart
Location: lib/features/auth/login_page.dart
Line: 63
Comment: Add more spacing above this field.''';

      expect(output, equals(expected));
    });

    test('handles single item in buildMultiple by returning single format', () {
      final items = [
        (
          target: const FeedbackTarget(
            widgetName: 'LoginButton',
            source: WidgetSourceLocation(
              fileName: 'login_page.dart',
              filePath: 'lib/features/auth/login_page.dart',
              line: 87,
            ),
          ),
          comment: 'Increase the button height to 48px.',
        ),
      ];

      final output = builder.buildMultiple(items);

      const expected = '''[Flutter UI Feedback]
Widget: LoginButton
File: login_page.dart
Location: lib/features/auth/login_page.dart
Line: 87
Comment: Increase the button height to 48px.''';

      expect(output, equals(expected));
    });

    test('handles fallback when line or file is unavailable', () {
      const target = FeedbackTarget(
        widgetName: 'CustomCard',
        source: WidgetSourceLocation.unavailable(),
      );

      final output = builder.build(target, 'Change border color.');

      const expected = '''[Flutter UI Feedback]
Widget: CustomCard
File: unavailable
Location: unavailable
Line: unavailable
Comment: Change border color.''';

      expect(output, equals(expected));
    });

    test('empty list returns empty string', () {
      expect(builder.buildMultiple([]), equals(''));
    });
  });
}
