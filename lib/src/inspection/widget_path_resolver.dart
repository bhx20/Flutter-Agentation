import 'package:flutter/widgets.dart';

/// Specialized resolver responsible for determining the hierarchical ancestry path
/// of an inspected widget.
class WidgetPathResolver {
  /// Resolves the list of ancestor widget names leading from the root element
  /// down to [element].
  List<String> resolveAncestors(Element element) {
    final ancestors = <String>[];
    Element? current = element;

    while (current != null) {
      final typeName = current.widget.runtimeType.toString();
      if (!_shouldOmitFromBreadcrumbs(typeName)) {
        ancestors.add(typeName);
      }

      Element? parent;
      current.visitAncestorElements((ancestor) {
        parent = ancestor;
        return false;
      });
      current = parent;
    }

    return ancestors.reversed.toList();
  }

  /// Formats the resolved ancestry into a human-readable breadcrumb path string.
  /// Example: `LoginPage > LoginForm > ElevatedButton`.
  String resolvePathString(Element element) {
    final ancestors = resolveAncestors(element);
    if (ancestors.isEmpty) {
      return element.widget.runtimeType.toString();
    }
    return ancestors.join(' > ');
  }

  /// Determines whether a widget type name is internal noise that should be omitted
  /// from human-readable breadcrumbs.
  static bool _shouldOmitFromBreadcrumbs(String name) {
    if (name.startsWith('_')) return true;
    if (name.startsWith('NotificationListener')) return true;
    if (name.startsWith('ValueListenableBuilder')) return true;
    if (name.startsWith('Animated')) return true;
    if (name.contains('Focus')) return true;
    if (name.contains('Inherited')) return true;
    if (name.endsWith('Scope')) return true;
    if (name.endsWith('Builder')) return true;
    if (name.endsWith('Transition')) return true;
    if (name.endsWith('Observer')) return true;

    const omitted = {
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
      'RootWidget',
      'View',
      'RawView',
      'MediaQuery',
      'WidgetsApp',
      'SharedAppData',
      'DefaultTextEditingShortcuts',
      'TapRegionSurface',
      'ShortcutRegistrar',
      'Localizations',
      'Directionality',
      'Title',
      'CheckedModeBanner',
      'Banner',
      'ScaffoldMessenger',
      'Navigator',
      'Overlay',
      'TickerMode',
      'PageStorage',
      'PrimaryScrollController',
      'IgnorePointer',
      'AbsorbPointer',
      'CustomMultiChildLayout',
      'LayoutId',
      'ScrollConfiguration',
    };

    return omitted.contains(name);
  }
}
