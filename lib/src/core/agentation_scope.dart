import 'package:flutter/widgets.dart';
import 'agentation_controller.dart';

/// An [InheritedNotifier] providing descendant widgets access to [AgentationController].
class AgentationScope extends InheritedNotifier<AgentationController> {
  const AgentationScope({
    super.key,
    required AgentationController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Retrieves the [AgentationController] from the closest ancestor [AgentationScope].
  ///
  /// Throws an assertion error if no [AgentationScope] is found.
  static AgentationController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AgentationScope>();
    assert(scope != null, 'No AgentationScope found in context');
    return scope!.notifier!;
  }

  /// Retrieves the [AgentationController] from the closest ancestor [AgentationScope],
  /// or null if none exists.
  static AgentationController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AgentationScope>();
    return scope?.notifier;
  }
}
