import 'package:flutter/widgets.dart';

import '../core/agentation_logger.dart';

/// Specialized resolver responsible for determining the active navigation route name
/// containing the inspected element.
class RouteResolver {
  /// Resolves the route name of the active [ModalRoute] containing [element].
  ///
  /// Returns null safely if the element is not inside a routed navigation hierarchy.
  String? resolveRoute(Element element) {
    try {
      final modalRoute = ModalRoute.of(element);
      if (modalRoute == null) return null;

      final settings = modalRoute.settings;
      if (settings.name != null && settings.name!.isNotEmpty) {
        return settings.name;
      }

      // Fallback: Check if it's the root/initial route or use route runtime type
      return modalRoute.runtimeType.toString();
    } catch (e, st) {
      AgentationLogger.debug('Route resolution skipped: $e');
      AgentationLogger.verbose(st.toString());
      return null;
    }
  }
}
