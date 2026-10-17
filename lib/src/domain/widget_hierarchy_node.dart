import 'package:flutter/foundation.dart';
import 'widget_bounds.dart';
import 'widget_identity.dart';

/// Immutable node representing a widget in the hierarchical inspection tree.
@immutable
class WidgetHierarchyNode {
  /// The resolved identity of this widget node.
  final WidgetIdentity identity;

  /// Global bounds of this widget on screen.
  final WidgetBounds bounds;

  /// Primary extracted text display content, if any.
  final String? text;

  /// Nesting depth from the root or parent.
  final int depth;

  /// Formatted hierarchical ancestry path string.
  final String pathString;

  /// Direct meaningful child nodes under this widget.
  final List<WidgetHierarchyNode> children;

  /// Whether this node represents the currently selected inspection target.
  final bool isSelected;

  const WidgetHierarchyNode({
    required this.identity,
    required this.bounds,
    this.text,
    this.depth = 0,
    required this.pathString,
    this.children = const [],
    this.isSelected = false,
  });

  /// Serializes this hierarchy node to a JSON map.
  Map<String, dynamic> toJson() => {
        'identity': identity.toJson(),
        'bounds': bounds.toJson(),
        if (text != null) 'text': text,
        'depth': depth,
        'pathString': pathString,
        if (children.isNotEmpty)
          'children': children.map((c) => c.toJson()).toList(),
        'isSelected': isSelected,
      };

  /// Deserializes a hierarchy node from a JSON map.
  factory WidgetHierarchyNode.fromJson(Map<String, dynamic> json) {
    return WidgetHierarchyNode(
      identity: WidgetIdentity.fromJson(
        Map<String, dynamic>.from(json['identity'] as Map),
      ),
      bounds: WidgetBounds.fromJson(
        Map<String, dynamic>.from(json['bounds'] as Map),
      ),
      text: json['text'] as String?,
      depth: json['depth'] as int? ?? 0,
      pathString: json['pathString'] as String? ?? '',
      children: (json['children'] as List<dynamic>?)
              ?.map((item) => WidgetHierarchyNode.fromJson(
                  Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const [],
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetHierarchyNode &&
          runtimeType == other.runtimeType &&
          identity == other.identity &&
          bounds == other.bounds &&
          text == other.text &&
          depth == other.depth &&
          pathString == other.pathString &&
          listEquals(children, other.children) &&
          isSelected == other.isSelected;

  @override
  int get hashCode => Object.hash(
        identity,
        bounds,
        text,
        depth,
        pathString,
        Object.hashAll(children),
        isSelected,
      );

  @override
  String toString() =>
      'WidgetHierarchyNode(type: ${identity.widgetType}, depth: $depth, children: ${children.length})';
}
