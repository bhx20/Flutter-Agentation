import 'package:flutter/foundation.dart';
import 'widget_inspection_result.dart';

/// Comprehensive inspection result encompassing a target widget, its ancestor hierarchy,
/// its visual children, and all hit candidates under the interaction coordinate.
@immutable
class HierarchicalInspectionResult {
  /// The primary inspected target widget.
  final WidgetInspectionResult primaryTarget;

  /// Ordered chain of ancestor widgets from outermost root/scaffold down to primary target.
  final List<WidgetInspectionResult> ancestors;

  /// Immediate meaningful child widgets discovered directly contained within primary target.
  final List<WidgetInspectionResult> children;

  /// All candidate widgets along the hit test path at the interaction point.
  final List<WidgetInspectionResult> hitCandidates;

  /// Whether hierarchical inspection resolved an available target.
  final bool isAvailable;

  const HierarchicalInspectionResult({
    required this.primaryTarget,
    this.ancestors = const [],
    this.children = const [],
    this.hitCandidates = const [],
    this.isAvailable = true,
  });

  /// Defensive fallback constructor when inspection is unavailable.
  const HierarchicalInspectionResult.unavailable()
      : primaryTarget = const WidgetInspectionResult.unavailable(),
        ancestors = const [],
        children = const [],
        hitCandidates = const [],
        isAvailable = false;

  /// Returns a full list of all selectable widgets (ancestors + primary + children + hit candidates) deduplicated.
  List<WidgetInspectionResult> get allSelectableWidgets {
    final seen = <String>{};
    final list = <WidgetInspectionResult>[];

    void addIfNew(WidgetInspectionResult item) {
      if (!item.isAvailable) return;
      final key = '${item.identity.widgetType}_${item.identity.id}_${item.bounds.x}_${item.bounds.y}';
      if (seen.add(key)) {
        list.add(item);
      }
    }

    addIfNew(primaryTarget);
    for (final a in ancestors) {
      addIfNew(a);
    }
    for (final c in children) {
      addIfNew(c);
    }
    for (final h in hitCandidates) {
      addIfNew(h);
    }

    return list;
  }

  /// Serializes this result to a JSON map.
  Map<String, dynamic> toJson() => {
        'primaryTarget': primaryTarget.toJson(),
        if (ancestors.isNotEmpty)
          'ancestors': ancestors.map((a) => a.toJson()).toList(),
        if (children.isNotEmpty)
          'children': children.map((c) => c.toJson()).toList(),
        if (hitCandidates.isNotEmpty)
          'hitCandidates': hitCandidates.map((h) => h.toJson()).toList(),
        'isAvailable': isAvailable,
      };

  /// Deserializes a hierarchical inspection result from a JSON map.
  factory HierarchicalInspectionResult.fromJson(Map<String, dynamic> json) {
    return HierarchicalInspectionResult(
      primaryTarget: WidgetInspectionResult.fromJson(
        Map<String, dynamic>.from(json['primaryTarget'] as Map),
      ),
      ancestors: (json['ancestors'] as List<dynamic>?)
              ?.map((item) => WidgetInspectionResult.fromJson(
                  Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const [],
      children: (json['children'] as List<dynamic>?)
              ?.map((item) => WidgetInspectionResult.fromJson(
                  Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const [],
      hitCandidates: (json['hitCandidates'] as List<dynamic>?)
              ?.map((item) => WidgetInspectionResult.fromJson(
                  Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const [],
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HierarchicalInspectionResult &&
          runtimeType == other.runtimeType &&
          primaryTarget == other.primaryTarget &&
          listEquals(ancestors, other.ancestors) &&
          listEquals(children, other.children) &&
          listEquals(hitCandidates, other.hitCandidates) &&
          isAvailable == other.isAvailable;

  @override
  int get hashCode => Object.hash(
        primaryTarget,
        Object.hashAll(ancestors),
        Object.hashAll(children),
        Object.hashAll(hitCandidates),
        isAvailable,
      );

  @override
  String toString() =>
      'HierarchicalInspectionResult(target: ${primaryTarget.identity.widgetType}, ancestors: ${ancestors.length}, children: ${children.length})';
}
