import 'package:flutter/material.dart';
import 'package:flutter_agentation/src/ui/toolbar/toolbar_toggle_icon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ToolbarToggleIcon & Morphing Transition', () {
    testWidgets('renders CustomPaint with active=false and active=true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolbarToggleIcon(
              active: false,
              size: 24.0,
              color: Colors.white,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ToolbarToggleIcon), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ToolbarToggleIcon),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolbarToggleIcon(
              active: true,
              size: 24.0,
              color: Colors.white,
            ),
          ),
        ),
      );

      // Animation starts over 300ms
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(ToolbarToggleIcon), findsOneWidget);

      // Settle full 300ms duration
      await tester.pumpAndSettle();
      expect(find.byType(ToolbarToggleIcon), findsOneWidget);
    });

    testWidgets('animates smoothly when active switches back and forth', (tester) async {
      final active = ValueNotifier<bool>(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: active,
              builder: (context, isActive, _) {
                return GestureDetector(
                  onTap: () => active.value = !active.value,
                  child: ToolbarToggleIcon(
                    active: isActive,
                    size: 24.0,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to expand (morph to close '✕')
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(ToolbarToggleIcon), findsOneWidget);

      await tester.pumpAndSettle();

      // Tap to collapse (morph to listSparkle)
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(ToolbarToggleIcon), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
