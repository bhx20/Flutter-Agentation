import 'package:flutter/widgets.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_scope.dart';

/// Wraps the host application widget subtree in a dynamic [TickerMode]
/// to halt and freeze in-flight animations, transitions, and tickers during inspection.
class FreezeOverlay extends StatelessWidget {
  const FreezeOverlay({
    super.key,
    required this.child,
    this.controller,
  });

  /// The host application widget subtree.
  final Widget child;

  /// Optional controller; defaults to closest [AgentationScope].
  final AgentationController? controller;

  @override
  Widget build(BuildContext context) {
    final effectiveController =
        controller ?? AgentationScope.of(context);

    return ListenableBuilder(
      listenable: effectiveController,
      builder: (context, _) {
        final isFrozen = effectiveController.isFrozen;
        return TickerMode(
          enabled: !isFrozen,
          child: child,
        );
      },
    );
  }
}
