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

  Map<String, dynamic> toJson() {
    return {
      'componentType': componentType,
      'width': width,
      'height': height,
      if (text != null) 'text': text,
      if (prompt != null) 'prompt': prompt,
    };
  }

  factory PlacementData.fromJson(Map<String, dynamic> json) {
    return PlacementData(
      componentType: json['componentType'] as String? ?? 'Widget',
      width: (json['width'] as num?)?.toDouble() ?? 100.0,
      height: (json['height'] as num?)?.toDouble() ?? 40.0,
      text: json['text'] as String?,
      prompt: json['prompt'] as String?,
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
        other.prompt == prompt;
  }

  @override
  int get hashCode => Object.hash(componentType, width, height, text, prompt);
}
