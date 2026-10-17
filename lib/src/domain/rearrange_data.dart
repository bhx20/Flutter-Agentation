import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'widget_bounds.dart';

/// Structured metadata for an element rearranged or repositioned during Design Mode.
@immutable
class RearrangeData {
  const RearrangeData({
    this.selector = '',
    this.label = '',
    WidgetBounds? originalRect,
    WidgetBounds? currentRect,
    WidgetBounds? originalBounds,
    WidgetBounds? newBounds,
    this.direction,
    this.relativeTarget,
    this.parentWidget,
    this.siblingBefore,
    this.siblingAfter,
    this.childIndex,
    this.totalChildren,
    this.treePlacement,
  })  : originalRect = originalBounds ?? originalRect ?? const WidgetBounds.zero(),
        currentRect = newBounds ?? currentRect ?? const WidgetBounds.zero();

  /// Widget identity selector or path string.
  final String selector;

  /// Readable widget label or title.
  final String label;

  /// Original bounding box coordinates before relocation.
  final WidgetBounds originalRect;

  /// New target bounding box coordinates after dragging.
  final WidgetBounds currentRect;

  /// Relative placement direction ('before', 'after', 'first', 'last', 'inside').
  final String? direction;

  /// Relative target identifier or label.
  final String? relativeTarget;

  /// Enclosing parent layout container in the widget tree (e.g. 'Column', 'Row', 'Card').
  final String? parentWidget;

  /// Sibling element immediately before this widget in the parent's children.
  final String? siblingBefore;

  /// Sibling element immediately after this widget in the parent's children.
  final String? siblingAfter;

  /// 0-based insertion index in the parent's children list.
  final int? childIndex;

  /// Total count of children in the parent layout container.
  final int? totalChildren;

  /// Human- and AI-readable placement phrase (e.g. "after Text ('Submit') in Column").
  final String? treePlacement;

  /// Alias for [originalRect].
  WidgetBounds get originalBounds => originalRect;

  /// Alias for [currentRect].
  WidgetBounds get newBounds => currentRect;

  /// Distance in pixels moved from original center to new center.
  double get distanceMoved {
    final originalCenterX = originalBounds.x + originalBounds.width / 2.0;
    final originalCenterY = originalBounds.y + originalBounds.height / 2.0;
    final newCenterX = newBounds.x + newBounds.width / 2.0;
    final newCenterY = newBounds.y + newBounds.height / 2.0;
    final dx = newCenterX - originalCenterX;
    final dy = newCenterY - originalCenterY;
    return math.sqrt(dx * dx + dy * dy);
  }

  Map<String, dynamic> toJson() {
    return {
      'selector': selector,
      'label': label,
      'originalRect': originalRect.toJson(),
      'currentRect': currentRect.toJson(),
      if (direction != null) 'direction': direction,
      if (relativeTarget != null) 'relativeTarget': relativeTarget,
      if (parentWidget != null) 'parentWidget': parentWidget,
      if (siblingBefore != null) 'siblingBefore': siblingBefore,
      if (siblingAfter != null) 'siblingAfter': siblingAfter,
      if (childIndex != null) 'childIndex': childIndex,
      if (totalChildren != null) 'totalChildren': totalChildren,
      if (treePlacement != null) 'treePlacement': treePlacement,
    };
  }

  factory RearrangeData.fromJson(Map<String, dynamic> json) {
    return RearrangeData(
      selector: json['selector'] as String? ?? '',
      label: json['label'] as String? ?? '',
      originalRect: json['originalRect'] != null
          ? WidgetBounds.fromJson(json['originalRect'] as Map<String, dynamic>)
          : (json['originalBounds'] != null
              ? WidgetBounds.fromJson(json['originalBounds'] as Map<String, dynamic>)
              : const WidgetBounds.zero()),
      currentRect: json['currentRect'] != null
          ? WidgetBounds.fromJson(json['currentRect'] as Map<String, dynamic>)
          : (json['newBounds'] != null
              ? WidgetBounds.fromJson(json['newBounds'] as Map<String, dynamic>)
              : const WidgetBounds.zero()),
      direction: json['direction'] as String?,
      relativeTarget: json['relativeTarget'] as String?,
      parentWidget: json['parentWidget'] as String?,
      siblingBefore: json['siblingBefore'] as String?,
      siblingAfter: json['siblingAfter'] as String?,
      childIndex: json['childIndex'] as int?,
      totalChildren: json['totalChildren'] as int?,
      treePlacement: json['treePlacement'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RearrangeData &&
        other.selector == selector &&
        other.label == label &&
        other.originalRect == originalRect &&
        other.currentRect == currentRect &&
        other.direction == direction &&
        other.relativeTarget == relativeTarget &&
        other.parentWidget == parentWidget &&
        other.siblingBefore == siblingBefore &&
        other.siblingAfter == siblingAfter &&
        other.childIndex == childIndex &&
        other.totalChildren == totalChildren &&
        other.treePlacement == treePlacement;
  }

  @override
  int get hashCode => Object.hash(
        selector,
        label,
        originalRect,
        currentRect,
        direction,
        relativeTarget,
        parentWidget,
        siblingBefore,
        siblingAfter,
        childIndex,
        totalChildren,
        treePlacement,
      );
}
