import 'package:flutter/widgets.dart';

import '../core/agentation_logger.dart';

/// Helper responsible for mapping Flutter [RenderObject]s to their owning [Element]s
/// and identifying meaningful developer widgets.
class ElementInspector {
  /// Locates the owning [Element] for [renderObject].
  Element? findElementForRenderObject(
    RenderObject renderObject, {
    Element? rootElement,
  }) {
    // 1. Try debugCreator in debug/profile builds
    final creator = renderObject.debugCreator;
    if (creator is DebugCreator) {
      return creator.element;
    }

    // 2. Fallback: tree walk from rootElement
    final root = rootElement ?? WidgetsBinding.instance.rootElement;
    if (root == null) return null;

    Element? foundElement;
    void visitor(Element element) {
      if (foundElement != null) return;
      if (element.renderObject == renderObject) {
        foundElement = element;
        return;
      }
      element.visitChildren(visitor);
    }

    try {
      root.visitChildren(visitor);
    } catch (e, st) {
      AgentationLogger.warning('Element tree walk encountered error: $e');
      AgentationLogger.verbose(st.toString());
    }

    return foundElement;
  }

  /// Traverses up from [element] to find the nearest meaningful developer widget.
  ///
  /// Filters out low-level rendering or internal framework composition nodes
  /// (e.g. private `_RawGestureDetector`, internal `Focus`, internal `Semantics`, internal ink keys).
  Element findMeaningfulElement(Element element, {Element? rootElement}) {
    Element current = element;
    Element? publicCandidate;

    int steps = 0;
    while (steps < 60) {
      steps++;
      if (rootElement != null && current == rootElement) {
        return current;
      }
      final widget = current.widget;
      final typeName = widget.runtimeType.toString();
      final isPublic = !typeName.startsWith('_') && !_isFrameworkBoilerplate(typeName);

      if (isPublic) {
        if (widget.key != null && !_isInternalKey(widget.key!)) {
          return current; // Best possible: public developer widget with an explicit key
        }
        publicCandidate ??= current;
      }

      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false;
      });

      if (parent == null || parent == current) {
        break;
      }
      current = parent!;
    }

    return publicCandidate ?? element;
  }

  /// Collects the chain of public, meaningful ancestor elements from root down to [element].
  List<Element> findAncestorHierarchy(Element element, {int maxDepth = 30}) {
    final ancestors = <Element>[];
    int steps = 0;

    element.visitAncestorElements((ancestor) {
      steps++;
      if (steps > maxDepth) return false;

      final typeName = ancestor.widget.runtimeType.toString();
      if (!typeName.startsWith('_') && !_isStrictFrameworkPlumbing(typeName) && !_isFrameworkBoilerplate(typeName)) {
        ancestors.add(ancestor);
      }
      return true;
    });

    return ancestors.reversed.toList();
  }

  /// Traverses down from [element] to find immediate and nested meaningful child elements.
  List<Element> findMeaningfulChildren(
    Element element, {
    int maxDepth = 25,
    int maxCount = 25,
  }) {
    final results = <Element>[];
    final seen = <Element>{};

    void visit(Element current, int depth) {
      if (results.length >= maxCount || depth > maxDepth) return;

      current.visitChildren((child) {
        if (results.length >= maxCount || !seen.add(child)) return;

        final typeName = child.widget.runtimeType.toString();
        final isPublic = !typeName.startsWith('_');
        final isBoilerplate = _isFrameworkBoilerplate(typeName) || _isStrictFrameworkPlumbing(typeName);

        if (isPublic && !isBoilerplate) {
          results.add(child);
          visit(child, depth + 1);
        } else {
          visit(child, depth + 1);
        }
      });
    }

    visit(element, 1);
    return results;
  }

  static bool _isStrictFrameworkPlumbing(String typeName) {
    const plumbing = {
      'RepaintBoundary',
      'CustomPaint',
      'FractionalTranslation',
      'KeyedSubtree',
      'Builder',
      'StatefulBuilder',
      'StatelessElement',
      'StatefulElement',
      'LayoutId',
      'CustomMultiChildLayout',
      'Listener',
      'RawGestureDetector',
      'Actions',
      'Shortcuts',
      'Focus',
      'DefaultTextStyle',
      'DefaultSelectionStyle',
      'IconTheme',
      'Theme',
      'AnimatedTheme',
      'CupertinoTheme',
      'Semantics',
      'Offstage',
      'TickerMode',
    };
    return plumbing.contains(typeName);
  }

  static bool _isInternalKey(Key key) {
    final str = key.toString();
    return str.contains('ink renderer') ||
        str.contains('GlobalKey#') ||
        str.contains('_ScaffoldSlot') ||
        str.startsWith('[_');
  }

  /// Identifies whether a widget type is internal framework boilerplate.
  static bool _isFrameworkBoilerplate(String typeName) {
    const ignored = {
      'RepaintBoundary',
      'CustomPaint',
      'FractionalTranslation',
      'Transform',
      'Opacity',
      'ClipRect',
      'ClipRRect',
      'PhysicalModel',
      'PhysicalShape',
      'DecoratedBox',
      'ColoredBox',
      'ConstrainedBox',
      'UnconstrainedBox',
      'SizedBox',
      'Padding',
      'Align',
      'Center',
      'FittedBox',
      'LimitedBox',
      'AspectRatio',
      'IntrinsicWidth',
      'IntrinsicHeight',
      'Offstage',
      'Semantics',
      'KeyedSubtree',
      'Builder',
      'StatefulBuilder',
      'LayoutId',
      'CustomMultiChildLayout',
      'StatelessElement',
      'StatefulElement',
      'Listener',
      'RawGestureDetector',
      'GestureDetector',
      'MouseRegion',
      'Focus',
      'Actions',
      'Shortcuts',
      'InkWell',
      'InkResponse',
      'Material',
      'IconTheme',
      'CupertinoTheme',
      'Theme',
      'AnimatedTheme',
      'DefaultTextStyle',
      'DefaultSelectionStyle',
      'RichText',
      'Overlay',
      'OverlayEntry',
      'Navigator',
    };
    return ignored.contains(typeName);
  }
}
