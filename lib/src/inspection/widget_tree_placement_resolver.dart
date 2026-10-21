import 'package:flutter/widgets.dart';

import '../domain/widget_identity.dart';
import '../source_location/source_location_resolver.dart';
import '../source_location/widget_source_location.dart';
import 'element_inspector.dart';
import 'hit_test_engine.dart';
import 'text_resolver.dart';
import 'widget_path_resolver.dart';

/// Represents the precise placement location of a widget within the Flutter widget tree.
class WidgetTreePlacement {
  const WidgetTreePlacement({
    required this.parentWidget,
    this.parentBreadcrumb,
    required this.direction,
    this.relativeTarget,
    this.siblingBefore,
    this.siblingAfter,
    this.childIndex,
    this.totalChildren,
    required this.description,
    this.sourceLocation,
  });

  /// The parent container in the widget tree (e.g. 'Column', 'Row', 'ListView', 'Card', 'Stack').
  final String parentWidget;

  /// Breadcrumb path of the parent container (e.g. 'HomeScreen > Scaffold > Column').
  final String? parentBreadcrumb;

  /// Relative direction: 'after', 'before', 'first', 'last', or 'inside'.
  final String direction;

  /// The relative target widget (e.g. "Text ('Basic & Boxes')", "TextField ('Search')").
  final String? relativeTarget;

  /// Sibling element immediately before the placement point, if any.
  final String? siblingBefore;

  /// Sibling element immediately after the placement point, if any.
  final String? siblingAfter;

  /// The 0-based insertion child index in the parent container, if applicable.
  final int? childIndex;

  /// Total number of children in the parent container.
  final int? totalChildren;

  /// Concise natural placement description (e.g. "after Text ('Basic & Boxes') in Column").
  final String description;

  /// Exact source code location of the resolved target element or parent container, if available.
  final WidgetSourceLocation? sourceLocation;

  /// Fallback empty placement when no container or target could be resolved.
  static const fallback = WidgetTreePlacement(
    parentWidget: 'WidgetTree',
    direction: 'inside',
    description: 'in widget tree',
  );
}

/// Helper item storing inspected sibling info within a parent layout container.
class _SiblingInfo {
  final Element element;
  final String label;
  final Rect bounds;

  _SiblingInfo({
    required this.element,
    required this.label,
    required this.bounds,
  });
}

/// Specialized resolver that determines the exact Flutter widget tree placement
/// (parent container, siblings, and relative tree position) for a dropped or moved widget.
class WidgetTreePlacementResolver {
  WidgetTreePlacementResolver({
    HitTestEngine? hitTestEngine,
    ElementInspector? elementInspector,
    TextResolver? textResolver,
    WidgetPathResolver? pathResolver,
    SourceLocationResolver? sourceLocationResolver,
  })  : hitTestEngine = hitTestEngine ?? HitTestEngine(),
        elementInspector = elementInspector ?? ElementInspector(),
        textResolver = textResolver ?? TextResolver(),
        pathResolver = pathResolver ?? WidgetPathResolver(),
        sourceLocationResolver = sourceLocationResolver ?? FlutterSourceLocationResolver();

  final HitTestEngine hitTestEngine;
  final ElementInspector elementInspector;
  final TextResolver textResolver;
  final WidgetPathResolver pathResolver;
  final SourceLocationResolver sourceLocationResolver;

  /// Resolves the widget tree placement at [dropPosition].
  WidgetTreePlacement resolvePlacement({
    required Offset dropPosition,
    Element? draggedElement,
    WidgetIdentity? draggedIdentity,
    Element? rootElement,
    RenderObject? rootRenderObject,
    Set<RenderObject>? ignoredRenderObjects,
  }) {
    try {
      final hitBoxes = hitTestEngine.hitTest(
        dropPosition,
        rootRenderObject: rootRenderObject,
        ignoredRenderObjects: ignoredRenderObjects,
      );

      Element? targetElement;
      for (final box in hitBoxes) {
        final el = elementInspector.findElementForRenderObject(box, rootElement: rootElement);
        if (el != null && el.mounted) {
          final meaningful = elementInspector.findMeaningfulElement(el, rootElement: rootElement);
          // Skip if this candidate is the widget being dragged
          if (draggedElement != null && (meaningful == draggedElement || el == draggedElement)) {
            continue;
          }
          if (draggedIdentity != null && meaningful.widget.runtimeType.toString() == draggedIdentity.widgetType) {
            final keyMatches = draggedIdentity.keyString != null &&
                meaningful.widget.key?.toString() == draggedIdentity.keyString;
            if (keyMatches) continue;
          }
          targetElement = meaningful;
          break;
        }
      }

      if (targetElement == null) {
        return WidgetTreePlacement.fallback;
      }

      // 1. Locate enclosing layout container
      final container = _findParentContainer(targetElement);
      final containerElement = container ?? targetElement;
      final containerName = containerElement.widget.runtimeType.toString();
      final breadcrumb = pathResolver.resolvePathString(containerElement);

      WidgetSourceLocation? sourceLoc;
      try {
        sourceLoc = sourceLocationResolver.resolve(targetElement) ??
            sourceLocationResolver.resolve(containerElement);
      } catch (_) {}

      // 2. Inspect container's meaningful children
      final siblings = _resolveContainerSiblings(
        containerElement,
        draggedElement: draggedElement,
        draggedIdentity: draggedIdentity,
        rootElement: rootElement,
      );

      // 3. If container has multiple children, resolve child order relative to dropPosition
      if (siblings.isNotEmpty) {
        return _resolveSiblingPlacement(
          containerName: containerName,
          breadcrumb: breadcrumb,
          siblings: siblings,
          dropPosition: dropPosition,
          sourceLocation: sourceLoc,
        );
      }

      // 4. Single-child container, or dropped directly over targetElement
      if (container != null && container != targetElement) {
        final targetLabel = formatWidgetLabel(targetElement);
        final dropCenter = _getBounds(targetElement)?.center;
        final isAfter = dropCenter == null || dropPosition.dy >= dropCenter.dy;
        final dir = isAfter ? 'after' : 'before';
        return WidgetTreePlacement(
          parentWidget: containerName,
          parentBreadcrumb: breadcrumb,
          direction: dir,
          relativeTarget: targetLabel,
          description: '$dir $targetLabel in $containerName',
          sourceLocation: sourceLoc,
        );
      }

      final targetLabel = formatWidgetLabel(targetElement);
      return WidgetTreePlacement(
        parentWidget: targetLabel,
        parentBreadcrumb: breadcrumb,
        direction: 'inside',
        relativeTarget: targetLabel,
        description: 'inside $targetLabel',
        sourceLocation: sourceLoc,
      );
    } catch (_) {
      return WidgetTreePlacement.fallback;
    }
  }

  /// Formats a human- and AI-readable placement comment for annotations.
  ///
  /// Examples:
  /// - `Move ElevatedButton after Text ('Basic & Boxes') in Column`
  /// - `Move ElevatedButton as first child of Column`
  /// - `Move ElevatedButton as last child of Column`
  /// - `Move ElevatedButton inside Card`
  /// - `Place ElevatedButton inside Column after Text ('Basic & Boxes')`
  String formatComment({
    required String action, // 'Move' or 'Place'
    required String targetLabel,
    required WidgetTreePlacement placement,
  }) {
    final cleanAction = action.trim();
    final cleanTarget = targetLabel.trim();

    if (placement.direction == 'first') {
      return '$cleanAction $cleanTarget as first child of ${placement.parentWidget}';
    }

    if (placement.direction == 'last') {
      return '$cleanAction $cleanTarget as last child of ${placement.parentWidget}';
    }

    if (placement.direction == 'inside') {
      return '$cleanAction $cleanTarget inside ${placement.parentWidget}';
    }

    if (placement.direction == 'before' && placement.relativeTarget != null) {
      return '$cleanAction $cleanTarget before ${placement.relativeTarget} in ${placement.parentWidget}';
    }

    if (placement.direction == 'after' && placement.relativeTarget != null) {
      if (cleanAction == 'Place') {
        return '$cleanAction $cleanTarget inside ${placement.parentWidget} after ${placement.relativeTarget}';
      }
      return '$cleanAction $cleanTarget after ${placement.relativeTarget} in ${placement.parentWidget}';
    }

    return '$cleanAction $cleanTarget ${placement.description}';
  }

  /// Extracts a human-readable widget label (including visible text or key).
  String formatWidgetLabel(Element element) {
    final widget = element.widget;
    final typeName = widget.runtimeType.toString();

    final text = textResolver.extractText(element);
    if (text != null && text.trim().isNotEmpty) {
      final cleanText = text.trim().replaceAll(RegExp(r'\s+'), ' ');
      final truncated = cleanText.length > 25 ? '${cleanText.substring(0, 22)}...' : cleanText;
      return "$typeName ('$truncated')";
    }

    if (widget.key != null) {
      final keyStr = widget.key.toString();
      if (!keyStr.contains('GlobalKey#') && !keyStr.startsWith('[_')) {
        return '$typeName (key: ${widget.key})';
      }
    }

    return typeName;
  }

  /// Walks up ancestor elements to locate the nearest layout container.
  Element? _findParentContainer(Element element) {
    Element? container;
    element.visitAncestorElements((ancestor) {
      final typeName = ancestor.widget.runtimeType.toString();
      if (_isMultiChildLayout(typeName, ancestor)) {
        container = ancestor;
        return false;
      }
      if (container == null && _isSingleChildLayout(typeName)) {
        container = ancestor;
      }
      return true;
    });
    return container;
  }

  bool _isMultiChildLayout(String typeName, Element element) {
    if (element is MultiChildRenderObjectElement) return true;
    const multiChild = {
      'Column',
      'Row',
      'Flex',
      'Wrap',
      'Stack',
      'Flow',
      'Table',
      'ListView',
      'GridView',
      'CustomScrollView',
      'PageView',
      'ListBody',
    };
    return multiChild.contains(typeName);
  }

  bool _isSingleChildLayout(String typeName) {
    const singleChild = {
      'Card',
      'ListTile',
      'Container',
      'Padding',
      'Center',
      'Align',
      'SizedBox',
      'Form',
      'Scaffold',
      'AppBar',
      'Drawer',
      'BottomAppBar',
      'NavigationBar',
      'BottomNavigationBar',
      'Expanded',
      'Flexible',
    };
    return singleChild.contains(typeName);
  }

  List<_SiblingInfo> _resolveContainerSiblings(
    Element container, {
    Element? draggedElement,
    WidgetIdentity? draggedIdentity,
    Element? rootElement,
  }) {
    final siblings = <_SiblingInfo>[];
    final seen = <Element>{};

    container.visitChildren((child) {
      final meaningful = elementInspector.findMeaningfulElement(child, rootElement: rootElement);
      if (!meaningful.mounted || !seen.add(meaningful)) return;

      // Skip dragged element from sibling inspection
      if (draggedElement != null && (meaningful == draggedElement || child == draggedElement)) {
        return;
      }
      if (draggedIdentity != null && meaningful.widget.runtimeType.toString() == draggedIdentity.widgetType) {
        if (draggedIdentity.keyString != null && meaningful.widget.key?.toString() == draggedIdentity.keyString) {
          return;
        }
      }

      final rect = _getBounds(meaningful) ?? _getBounds(child);
      if (rect != null) {
        siblings.add(_SiblingInfo(
          element: meaningful,
          label: formatWidgetLabel(meaningful),
          bounds: rect,
        ));
      }
    });

    return siblings;
  }

  WidgetTreePlacement _resolveSiblingPlacement({
    required String containerName,
    required String? breadcrumb,
    required List<_SiblingInfo> siblings,
    required Offset dropPosition,
    WidgetSourceLocation? sourceLocation,
  }) {
    final isVertical = containerName != 'Row';

    if (isVertical) {
      siblings.sort((a, b) => a.bounds.top.compareTo(b.bounds.top));

      // Before first sibling
      if (dropPosition.dy < siblings.first.bounds.top + siblings.first.bounds.height * 0.4) {
        return WidgetTreePlacement(
          parentWidget: containerName,
          parentBreadcrumb: breadcrumb,
          direction: 'first',
          relativeTarget: siblings.first.label,
          siblingAfter: siblings.first.label,
          childIndex: 0,
          totalChildren: siblings.length,
          description: 'as first child of $containerName',
          sourceLocation: sourceLocation,
        );
      }

      // After last sibling
      if (dropPosition.dy > siblings.last.bounds.bottom - siblings.last.bounds.height * 0.4) {
        return WidgetTreePlacement(
          parentWidget: containerName,
          parentBreadcrumb: breadcrumb,
          direction: 'last',
          relativeTarget: siblings.last.label,
          siblingBefore: siblings.last.label,
          childIndex: siblings.length,
          totalChildren: siblings.length,
          description: 'as last child of $containerName',
          sourceLocation: sourceLocation,
        );
      }

      // Between siblings
      for (int i = 0; i < siblings.length - 1; i++) {
        final current = siblings[i];
        final next = siblings[i + 1];
        if (dropPosition.dy >= current.bounds.top && dropPosition.dy < next.bounds.bottom) {
          final mid = (current.bounds.center.dy + next.bounds.center.dy) / 2.0;
          if (dropPosition.dy <= mid) {
            return WidgetTreePlacement(
              parentWidget: containerName,
              parentBreadcrumb: breadcrumb,
              direction: 'after',
              relativeTarget: current.label,
              siblingBefore: current.label,
              siblingAfter: next.label,
              childIndex: i + 1,
              totalChildren: siblings.length,
              description: 'after ${current.label} in $containerName',
              sourceLocation: sourceLocation,
            );
          } else {
            return WidgetTreePlacement(
              parentWidget: containerName,
              parentBreadcrumb: breadcrumb,
              direction: 'before',
              relativeTarget: next.label,
              siblingBefore: current.label,
              siblingAfter: next.label,
              childIndex: i + 1,
              totalChildren: siblings.length,
              description: 'before ${next.label} in $containerName',
              sourceLocation: sourceLocation,
            );
          }
        }
      }

      // Fallback to nearest sibling
      _SiblingInfo closest = siblings.first;
      double minDist = double.infinity;
      for (final s in siblings) {
        final dist = (dropPosition.dy - s.bounds.center.dy).abs();
        if (dist < minDist) {
          minDist = dist;
          closest = s;
        }
      }
      final dir = dropPosition.dy >= closest.bounds.center.dy ? 'after' : 'before';
      return WidgetTreePlacement(
        parentWidget: containerName,
        parentBreadcrumb: breadcrumb,
        direction: dir,
        relativeTarget: closest.label,
        description: '$dir ${closest.label} in $containerName',
        sourceLocation: sourceLocation,
      );
    } else {
      // Horizontal (Row)
      siblings.sort((a, b) => a.bounds.left.compareTo(b.bounds.left));

      if (dropPosition.dx < siblings.first.bounds.left + siblings.first.bounds.width * 0.4) {
        return WidgetTreePlacement(
          parentWidget: containerName,
          parentBreadcrumb: breadcrumb,
          direction: 'first',
          relativeTarget: siblings.first.label,
          siblingAfter: siblings.first.label,
          childIndex: 0,
          totalChildren: siblings.length,
          description: 'as first child of $containerName',
          sourceLocation: sourceLocation,
        );
      }

      if (dropPosition.dx > siblings.last.bounds.right - siblings.last.bounds.width * 0.4) {
        return WidgetTreePlacement(
          parentWidget: containerName,
          parentBreadcrumb: breadcrumb,
          direction: 'last',
          relativeTarget: siblings.last.label,
          siblingBefore: siblings.last.label,
          childIndex: siblings.length,
          totalChildren: siblings.length,
          description: 'as last child of $containerName',
          sourceLocation: sourceLocation,
        );
      }

      for (int i = 0; i < siblings.length - 1; i++) {
        final current = siblings[i];
        final next = siblings[i + 1];
        if (dropPosition.dx >= current.bounds.left && dropPosition.dx < next.bounds.right) {
          final mid = (current.bounds.center.dx + next.bounds.center.dx) / 2.0;
          if (dropPosition.dx <= mid) {
            return WidgetTreePlacement(
              parentWidget: containerName,
              parentBreadcrumb: breadcrumb,
              direction: 'after',
              relativeTarget: current.label,
              siblingBefore: current.label,
              siblingAfter: next.label,
              childIndex: i + 1,
              totalChildren: siblings.length,
              description: 'after ${current.label} in $containerName',
              sourceLocation: sourceLocation,
            );
          } else {
            return WidgetTreePlacement(
              parentWidget: containerName,
              parentBreadcrumb: breadcrumb,
              direction: 'before',
              relativeTarget: next.label,
              siblingBefore: current.label,
              siblingAfter: next.label,
              childIndex: i + 1,
              totalChildren: siblings.length,
              description: 'before ${next.label} in $containerName',
              sourceLocation: sourceLocation,
            );
          }
        }
      }

      _SiblingInfo closest = siblings.first;
      double minDist = double.infinity;
      for (final s in siblings) {
        final dist = (dropPosition.dx - s.bounds.center.dx).abs();
        if (dist < minDist) {
          minDist = dist;
          closest = s;
        }
      }
      final dir = dropPosition.dx >= closest.bounds.center.dx ? 'after' : 'before';
      return WidgetTreePlacement(
        parentWidget: containerName,
        parentBreadcrumb: breadcrumb,
        direction: dir,
        relativeTarget: closest.label,
        description: '$dir ${closest.label} in $containerName',
        sourceLocation: sourceLocation,
      );
    }
  }

  Rect? _getBounds(Element element) {
    if (!element.mounted) return null;
    final ro = element.renderObject;
    if (ro is RenderBox && ro.attached && ro.hasSize) {
      try {
        final origin = ro.localToGlobal(Offset.zero);
        return origin & ro.size;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
