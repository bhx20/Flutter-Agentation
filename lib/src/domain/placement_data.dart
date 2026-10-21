import 'package:flutter/foundation.dart';

/// Structured metadata for a newly placed component wireframe in Design Mode.
@immutable
class PlacementData {
  const PlacementData({
    required this.componentType,
    required this.width,
    required this.height,
    this.label,
    this.text,
    this.prompt,
    this.parentWidget,
    this.relativeTarget,
    this.direction,
    this.treePlacement,
    this.childIndex,
    this.totalChildren,
    this.parentBreadcrumb,
    this.siblingBefore,
    this.siblingAfter,
    this.source,
    this.variant,
    this.properties = const {},
  });

  /// The component or widget type to be created (e.g. 'ElevatedButton', 'Card', 'TextField').
  final String componentType;

  /// User-friendly display label (e.g. 'Button', 'Text Block', 'Icon Button').
  final String? label;

  /// The desired component width in pixels.
  final double width;

  /// The desired component height in pixels.
  final double height;

  /// Optional placeholder or preview text.
  final String? text;

  /// Optional developer/designer instructions for the AI coding agent.
  final String? prompt;

  /// Enclosing layout container in the widget tree (e.g. 'Column', 'Row', 'Card').
  final String? parentWidget;

  /// Target sibling element in the container.
  final String? relativeTarget;

  /// Relative direction ('after', 'before', 'first', 'last', 'inside').
  final String? direction;

  /// Human- and AI-readable placement phrase (e.g. "inside Column after Text ('Header')").
  final String? treePlacement;

  /// 0-based insertion child index in parent container, if applicable.
  final int? childIndex;

  /// Total number of children in parent container.
  final int? totalChildren;

  /// Full breadcrumb path to parent container (e.g. 'HomeScreen > Scaffold > Column').
  final String? parentBreadcrumb;

  /// Sibling element immediately before insertion point.
  final String? siblingBefore;

  /// Sibling element immediately after insertion point.
  final String? siblingAfter;

  /// Optional asset path or network URL (e.g. for Image, Video, Avatar, Audio).
  final String? source;

  /// Optional component variant or styling mode (e.g. 'Filled', 'Outlined', 'H1 Headline').
  final String? variant;

  /// Optional key-value properties or configuration chosen by user.
  final Map<String, dynamic> properties;

  PlacementData copyWith({
    String? componentType,
    String? label,
    double? width,
    double? height,
    String? text,
    String? prompt,
    String? parentWidget,
    String? relativeTarget,
    String? direction,
    String? treePlacement,
    int? childIndex,
    int? totalChildren,
    String? parentBreadcrumb,
    String? siblingBefore,
    String? siblingAfter,
    String? source,
    String? variant,
    Map<String, dynamic>? properties,
  }) {
    return PlacementData(
      componentType: componentType ?? this.componentType,
      label: label ?? this.label,
      width: width ?? this.width,
      height: height ?? this.height,
      text: text ?? this.text,
      prompt: prompt ?? this.prompt,
      parentWidget: parentWidget ?? this.parentWidget,
      relativeTarget: relativeTarget ?? this.relativeTarget,
      direction: direction ?? this.direction,
      treePlacement: treePlacement ?? this.treePlacement,
      childIndex: childIndex ?? this.childIndex,
      totalChildren: totalChildren ?? this.totalChildren,
      parentBreadcrumb: parentBreadcrumb ?? this.parentBreadcrumb,
      siblingBefore: siblingBefore ?? this.siblingBefore,
      siblingAfter: siblingAfter ?? this.siblingAfter,
      source: source ?? this.source,
      variant: variant ?? this.variant,
      properties: properties ?? this.properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'componentType': componentType,
      if (label != null) 'label': label,
      'width': width,
      'height': height,
      if (text != null) 'text': text,
      if (prompt != null) 'prompt': prompt,
      if (parentWidget != null) 'parentWidget': parentWidget,
      if (relativeTarget != null) 'relativeTarget': relativeTarget,
      if (direction != null) 'direction': direction,
      if (treePlacement != null) 'treePlacement': treePlacement,
      if (childIndex != null) 'childIndex': childIndex,
      if (totalChildren != null) 'totalChildren': totalChildren,
      if (parentBreadcrumb != null) 'parentBreadcrumb': parentBreadcrumb,
      if (siblingBefore != null) 'siblingBefore': siblingBefore,
      if (siblingAfter != null) 'siblingAfter': siblingAfter,
      if (source != null) 'source': source,
      if (variant != null) 'variant': variant,
      if (properties.isNotEmpty) 'properties': properties,
    };
  }

  factory PlacementData.fromJson(Map<String, dynamic> json) {
    return PlacementData(
      componentType: json['componentType'] as String? ?? 'Widget',
      label: json['label'] as String?,
      width: (json['width'] as num?)?.toDouble() ?? 100.0,
      height: (json['height'] as num?)?.toDouble() ?? 40.0,
      text: json['text'] as String?,
      prompt: json['prompt'] as String?,
      parentWidget: json['parentWidget'] as String?,
      relativeTarget: json['relativeTarget'] as String?,
      direction: json['direction'] as String?,
      treePlacement: json['treePlacement'] as String?,
      childIndex: json['childIndex'] as int?,
      totalChildren: json['totalChildren'] as int?,
      parentBreadcrumb: json['parentBreadcrumb'] as String?,
      siblingBefore: json['siblingBefore'] as String?,
      siblingAfter: json['siblingAfter'] as String?,
      source: json['source'] as String?,
      variant: json['variant'] as String?,
      properties: (json['properties'] as Map<String, dynamic>?) ?? const {},
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlacementData &&
        other.componentType == componentType &&
        other.label == label &&
        other.width == width &&
        other.height == height &&
        other.text == text &&
        other.prompt == prompt &&
        other.parentWidget == parentWidget &&
        other.relativeTarget == relativeTarget &&
        other.direction == direction &&
        other.treePlacement == treePlacement &&
        other.childIndex == childIndex &&
        other.totalChildren == totalChildren &&
        other.parentBreadcrumb == parentBreadcrumb &&
        other.siblingBefore == siblingBefore &&
        other.siblingAfter == siblingAfter &&
        other.source == source &&
        other.variant == variant &&
        mapEquals(other.properties, properties);
  }

  @override
  int get hashCode => Object.hash(
        componentType,
        label,
        width,
        height,
        text,
        prompt,
        parentWidget,
        relativeTarget,
        direction,
        treePlacement,
        childIndex,
        totalChildren,
        parentBreadcrumb,
        siblingBefore,
        siblingAfter,
        source,
        variant,
        Object.hashAll(properties.entries.map((e) => Object.hash(e.key, e.value))),
      );
}
