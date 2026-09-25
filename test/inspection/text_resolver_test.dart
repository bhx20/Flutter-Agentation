import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/text_resolver.dart';

void main() {
  group('TextResolver', () {
    final resolver = TextResolver();

    testWidgets('extracts direct text from Text widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Direct Text Content'),
            ),
          ),
        ),
      );

      final element = tester.element(find.text('Direct Text Content'));
      final text = resolver.extractText(element);

      expect(text, 'Direct Text Content');
    });

    testWidgets('extracts text from RichText widget with TextSpan', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text.rich(
                TextSpan(
                  text: 'Hello ',
                  children: [TextSpan(text: 'World')],
                ),
              ),
            ),
          ),
        ),
      );

      final element = tester.element(find.byType(RichText));
      final text = resolver.extractText(element);

      expect(text, 'Hello World');
    });

    testWidgets('extracts child text when inspecting an ElevatedButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Save Changes'),
              ),
            ),
          ),
        ),
      );

      final buttonElement = tester.element(find.byType(ElevatedButton));
      final text = resolver.extractText(buttonElement);

      expect(text, 'Save Changes');
    });
  });
}
