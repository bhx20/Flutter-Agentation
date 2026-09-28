import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/core/agentation_scope.dart';
import 'package:flutter_agentation/src/core/agentation_state.dart';
import 'package:flutter_agentation/src/overlay/freeze_overlay.dart';
import 'package:flutter_agentation/src/toolbar/agentation_toolbar.dart';

void main() {
  group('Animation Freeze Controller (User Story 4)', () {
    late AgentationController controller;

    setUp(() {
      controller = AgentationController(
        initialMode: InspectionMode.inspecting,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('controller supports freezing, unfreezing, and deactivation unfreeze', () {
      expect(controller.isFrozen, isFalse);

      controller.freeze();
      expect(controller.isFrozen, isTrue);

      controller.unfreeze();
      expect(controller.isFrozen, isFalse);

      controller.toggleFreeze();
      expect(controller.isFrozen, isTrue);

      controller.deactivate();
      expect(controller.isFrozen, isFalse);
    });

    testWidgets('FreezeOverlay halts animations when frozen and resumes when unfrozen',
        (tester) async {
      late AnimationController animController;
      double lastValue = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FreezeOverlay(
              controller: controller,
              child: _TestAnimatedWidget(
                onInit: (ac) => animController = ac,
              ),
            ),
          ),
        ),
      );

      // Advance frames normally
      await tester.pump(const Duration(milliseconds: 100));
      lastValue = animController.value;
      expect(lastValue, greaterThan(0.0));

      // Freeze animations
      controller.freeze();
      await tester.pump();

      // Advance clock while frozen
      await tester.pump(const Duration(milliseconds: 200));
      // Ticker should be disabled; animation value must not change
      expect(animController.value, equals(lastValue));

      // Unfreeze animations
      controller.unfreeze();
      await tester.pump();

      // Advance clock after unfreezing
      await tester.pump(const Duration(milliseconds: 100));
      expect(animController.value, greaterThan(lastValue));
    });

    testWidgets('AgentationToolbar provides freeze button and toggles controller freeze state',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                AgentationScope(
                  controller: controller,
                  child: const AgentationToolbar(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(controller.isFrozen, isFalse);
      final freezeFinder = find.byKey(const ValueKey('toolbar_pause'));
      expect(freezeFinder, findsOneWidget);

      await tester.tap(freezeFinder);
      await tester.pumpAndSettle();

      expect(controller.isFrozen, isTrue);

      await tester.tap(freezeFinder);
      await tester.pumpAndSettle();

      expect(controller.isFrozen, isFalse);
    });
  });
}

class _TestAnimatedWidget extends StatefulWidget {
  const _TestAnimatedWidget({
    required this.onInit,
  });

  final ValueChanged<AnimationController> onInit;

  @override
  State<_TestAnimatedWidget> createState() => _TestAnimatedWidgetState();
}

class _TestAnimatedWidgetState extends State<_TestAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    widget.onInit(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Frame: ${_controller.value.toStringAsFixed(2)}'),
    );
  }
}
