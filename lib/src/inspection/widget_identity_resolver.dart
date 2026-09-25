import 'package:flutter/widgets.dart';

import '../models/widget_identity.dart';

/// Optional explicit target widget that developers can wrap around widgets
/// to provide deterministic identity in complex or dynamic applications.
class AgentationTarget extends StatelessWidget {
  /// The explicit identifier assigned to this target.
  final String id;

  /// The child widget.
  final Widget child;

  const AgentationTarget({
    super.key,
    required this.id,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => child;
}

/// Specialized resolver responsible for determining the identity of an inspected widget
/// according to strict priority order.
class WidgetIdentityResolver {
  /// Resolves the [WidgetIdentity] for [element].
  ///
  /// Priority:
  /// 1. Explicit `AgentationTarget` ancestor or self
  /// 2. Explicit `Key` or `ValueKey`
  /// 3. Widget runtime class name
  /// 4. Positional hierarchy index
  WidgetIdentity resolveIdentity(Element element, {RenderObject? renderObject}) {
    final widget = element.widget;

    // 1. Check for AgentationTarget on widget or immediate ancestors
    String? explicitTargetId;
    if (widget is AgentationTarget) {
      explicitTargetId = widget.id;
    } else {
      element.visitAncestorElements((ancestor) {
        if (ancestor.widget is AgentationTarget) {
          explicitTargetId = (ancestor.widget as AgentationTarget).id;
          return false;
        }
        return true;
      });
    }

    if (explicitTargetId != null) {
      return WidgetIdentity(
        id: explicitTargetId!,
        keyString: widget.key?.toString(),
        widgetType: widget.runtimeType.toString(),
        isExplicitTarget: true,
      );
    }

    // 2. Check for explicit Key on widget
    final key = widget.key;
    final keyString = key?.toString();
    final typeName = widget.runtimeType.toString();

    if (keyString != null && !_isInternalKey(key!)) {
      return WidgetIdentity(
        id: keyString,
        keyString: keyString,
        widgetType: typeName,
        isExplicitTarget: false,
      );
    }

    // 3. Fallback: Type name with stable positional or element hash
    final id = '${typeName}_${element.hashCode}';
    return WidgetIdentity(
      id: id,
      keyString: keyString,
      widgetType: typeName,
      isExplicitTarget: false,
    );
  }

  static bool _isInternalKey(Key key) {
    final str = key.toString();
    return str.contains('ink renderer') ||
        str.contains('GlobalKey#') ||
        str.startsWith('[_');
  }
}
