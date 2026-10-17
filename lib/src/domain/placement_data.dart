import 'package:flutter/foundation.dart';

/// Structured metadata for a newly placed component wireframe in Design Mode.
@immutable
class PlacementData {
  const PlacementData({
    required this.componentType,
    required this.width,
    required this.height,
    this.text,
    this.prompt,
    this.parentWidget,
    this.relativeTarget,
    this.direction,
    this.treePlacement,
  });

  /// The component or widget type to be created (e.g. 'ElevatedButton', 'Card', 'TextField').
  final String componentType;

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

  Map<String, dynamic> toJson() {
    return {
      'componentType': componentType,
      'width': width,
      'height': height,
      if (text != null) 'text': text,
      if (prompt != null) 'prompt': prompt,
      if (parentWidget != null) 'parentWidget': parentWidget,
      if (relativeTarget != null) 'relativeTarget': relativeTarget,
      if (direction != null) 'direction': direction,
      if (treePlacement != null) 'treePlacement': treePlacement,
    };
  }

  factory PlacementData.fromJson(Map<String, dynamic> json) {
    return PlacementData(
      componentType: json['componentType'] as String? ?? 'Widget',
      width: (json['width'] as num?)?.toDouble() ?? 100.0,
      height: (json['height'] as num?)?.toDouble() ?? 40.0,
      text: json['text'] as String?,
      prompt: json['prompt'] as String?,
      parentWidget: json['parentWidget'] as String?,
      relativeTarget: json['relativeTarget'] as String?,
      direction: json['direction'] as String?,
      treePlacement: json['treePlacement'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlacementData &&
        other.componentType == componentType &&
        other.width == width &&
        other.height == height &&
        other.text == text &&
        other.prompt == prompt &&
        other.parentWidget == parentWidget &&
        other.relativeTarget == relativeTarget &&
        other.direction == direction &&
        other.treePlacement == treePlacement;
  }

  @override
  int get hashCode => Object.hash(
        componentType,
        width,
        height,
        text,
        prompt,
        parentWidget,
        relativeTarget,
        direction,
        treePlacement,
      );
}
