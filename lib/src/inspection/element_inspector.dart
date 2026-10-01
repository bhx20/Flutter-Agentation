import 'package:flutter/widgets.dart';

import '../core/agentation_logger.dart';

/// Helper responsible for mapping Flutter [RenderObject]s to their owning [Element]s
/// and identifying meaningful developer widgets.
class ElementInspector {
  static final Expando<Element> _roToElementCache = Expando<Element>();
  static final Expando<Element> _meaningfulCache = Expando<Element>();

  /// Locates the owning [Element] for [renderObject].
  Element? findElementForRenderObject(
    RenderObject renderObject, {
    Element? rootElement,
  }) {
    // 1. Try debugCreator in debug/profile builds
    final creator = renderObject.debugCreator;
    if (creator is DebugCreator) {
      final el = creator.element;
      if (el != null) {
        _roToElementCache[renderObject] = el;
      }
      return el;
    }

    // 2. Fast Expando cache lookup
    final cached = _roToElementCache[renderObject];
    if (cached != null && cached.mounted) {
      return cached;
    }

    // 3. Fallback: tree walk from rootElement with batch cache population
    final root = rootElement ?? WidgetsBinding.instance.rootElement;
    if (root == null) return null;

    Element? foundElement;
    void visitor(Element element) {
      final ro = element.renderObject;
      if (ro != null) {
        _roToElementCache[ro] = element;
      }
      if (foundElement != null) return;
      if (ro == renderObject) {
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
    final cached = _meaningfulCache[element];
    if (cached != null && cached.mounted) {
      return cached;
    }

    Element current = element;
    Element? publicCandidate;
    bool isLeafPrimitive = false;

    int steps = 0;
    while (steps < 60) {
      steps++;
      if (rootElement != null && current == rootElement) {
        return publicCandidate ?? current;
      }
      final widget = current.widget;
      final typeName = widget.runtimeType.toString();

      final isPublic = !typeName.startsWith('_') &&
          !_isFrameworkBoilerplate(typeName) &&
          !_isStrictFrameworkPlumbing(typeName);

      if (isPublic) {
        if (widget.key != null && !_isInternalKey(widget.key!)) {
          // If this keyed widget is a compound layout container (e.g. ListTile, Card, Scaffold, ListView)
          // and we already have a specific child candidate (e.g. Text, Icon, Button),
          // preserve the child candidate instead of jumping out to the container.
          if (publicCandidate != null && _isCompoundContainer(typeName)) {
            return publicCandidate;
          }
          return current;
        }

        if (publicCandidate == null) {
          publicCandidate = current;
          isLeafPrimitive = _isFrameworkLeafPrimitive(typeName);
        } else if (isLeafPrimitive) {
          // If we started on a primitive leaf (like Text or Icon),
          // and we encounter an enclosing custom developer widget (like AppHeadingText)
          // before reaching a compound layout container, promote to the custom widget!
          if (!_isFrameworkWidget(typeName) && !_isCompoundContainer(typeName)) {
            publicCandidate = current;
            isLeafPrimitive = false;
          } else if (_isCompoundContainer(typeName)) {
            return publicCandidate;
          }
        } else if (_isCompoundContainer(typeName)) {
          return publicCandidate;
        }
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

    final resolved = publicCandidate ?? element;
    _meaningfulCache[element] = resolved;
    return resolved;
  }

  static bool _isFrameworkLeafPrimitive(String typeName) {
    const primitives = {
      'Text',
      'RichText',
      'Icon',
      'Image',
      'Placeholder',
      'CircleAvatar',
    };
    return primitives.contains(typeName);
  }

  /// Checks if [typeName] is a standard Flutter framework widget.
  static bool _isFrameworkWidget(String typeName) {
    if (_isFrameworkBoilerplate(typeName) ||
        _isStrictFrameworkPlumbing(typeName) ||
        _isCompoundContainer(typeName)) {
      return true;
    }
    const standardFramework = {
      'Text',
      'RichText',
      'Icon',
      'Image',
      'Placeholder',
      'CircleAvatar',
      'MaterialApp',
      'CupertinoApp',
      'WidgetsApp',
      'ElevatedButton',
      'FilledButton',
      'OutlinedButton',
      'TextButton',
      'IconButton',
      'FloatingActionButton',
      'SegmentedButton',
      'PopupMenuButton',
      'DropdownButton',
      'BackButton',
      'CloseButton',
      'MenuAnchor',
      'SubmenuButton',
      'MenuItemButton',
      'TextField',
      'TextFormField',
      'Checkbox',
      'Radio',
      'Switch',
      'Slider',
      'RangeSlider',
      'CircularProgressIndicator',
      'LinearProgressIndicator',
      'Badge',
      'Chip',
      'ActionChip',
      'FilterChip',
      'ChoiceChip',
      'InputChip',
      'Tooltip',
      'Divider',
      'VerticalDivider',
      'Container',
      'Material',
      'CupertinoButton',
      'CupertinoTextField',
      'CupertinoSwitch',
      'CupertinoSlider',
      'CupertinoActivityIndicator',
      'CupertinoSegmentedControl',
      'CupertinoSlidingSegmentedControl',
      'CupertinoListTile',
    };
    return standardFramework.contains(typeName);
  }

  static bool _isCompoundContainer(String typeName) {
    const containers = {
      'MaterialApp',
      'CupertinoApp',
      'WidgetsApp',
      'ListTile',
      'RadioListTile',
      'CheckboxListTile',
      'SwitchListTile',
      'ExpansionTile',
      'Card',
      'Scaffold',
      'ListView',
      'GridView',
      'SingleChildScrollView',
      'CustomScrollView',
      'NestedScrollView',
      'PageView',
      'Column',
      'Row',
      'Stack',
      'Wrap',
      'Flex',
      'Flow',
      'Table',
      'AppBar',
      'Drawer',
      'NavigationRail',
      'BottomAppBar',
      'NavigationBar',
      'NavigationDrawer',
      'BottomNavigationBar',
      'TabBarView',
      'Form',
    };
    return containers.contains(typeName);
  }

  /// Collects the chain of public, meaningful ancestor elements from root down to [element].
  List<Element> findAncestorHierarchy(Element element, {int maxDepth = 40}) {
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
    int maxDepth = 50,
    int maxCount = 30,
  }) {
    final results = <Element>[];
    final seen = <Element>{};

    void visit(Element current, int depth) {
      if (results.length >= maxCount || depth > maxDepth) return;

      current.visitChildren((child) {
        if (results.length >= maxCount || !seen.add(child)) return;

        final typeName = child.widget.runtimeType.toString();
        final hasDevKey = child.widget.key != null && !_isInternalKey(child.widget.key!);
        final isPublic = !typeName.startsWith('_');
        final isBoilerplate = _isFrameworkBoilerplate(typeName) || _isStrictFrameworkPlumbing(typeName);

        if (hasDevKey || (isPublic && !isBoilerplate)) {
          results.add(child);
          // Do not recurse into terminal leaf widgets like Text, Icon, Image
          if (typeName != 'Text' && typeName != 'Icon' && typeName != 'Image') {
            visit(child, depth + 1);
          }
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
      'FocusScope',
      'DefaultTextStyle',
      'AnimatedDefaultTextStyle',
      'DefaultSelectionStyle',
      'IconTheme',
      'IconButtonTheme',
      'Theme',
      'AnimatedTheme',
      'CupertinoTheme',
      'Semantics',
      'ExcludeSemantics',
      'Offstage',
      'TickerMode',
      'SafeArea',
      'MediaQuery',
      'Ink',
      'InkWell',
      'InkResponse',
      'MouseRegion',
      'InheritedWidget',
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
      'ExcludeSemantics',
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
      'FocusScope',
      'Actions',
      'Shortcuts',
      'InkWell',
      'InkResponse',
      'Ink',
      'Material',
      'IconTheme',
      'IconButtonTheme',
      'CupertinoTheme',
      'Theme',
      'AnimatedTheme',
      'DefaultTextStyle',
      'AnimatedDefaultTextStyle',
      'DefaultSelectionStyle',
      'RichText',
      'Overlay',
      'OverlayEntry',
      'Navigator',
      'SafeArea',
      'MediaQuery',
    };
    return ignored.contains(typeName);
  }
}
