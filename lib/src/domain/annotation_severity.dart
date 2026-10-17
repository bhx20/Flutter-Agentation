import 'package:flutter/material.dart';

/// Indicates the urgency, priority, or impact level of an annotation.
enum AnnotationSeverity {
  /// Minor observation or low priority suggestion.
  low,

  /// Design recommendation or enhancement idea.
  suggestion,

  /// Standard feedback or regular defect.
  medium,

  /// High priority issue requiring immediate review.
  high,

  /// Severe defect blocking release or critical user flow.
  critical;

  /// Serializes the enum to a string.
  String toJson() => name;

  /// Deserializes a string into an [AnnotationSeverity].
  static AnnotationSeverity fromJson(String value) {
    return AnnotationSeverity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AnnotationSeverity.suggestion,
    );
  }

  /// Visual theme color representing this severity level.
  Color get color {
    switch (this) {
      case AnnotationSeverity.low:
        return const Color(0xFF64748B); // Slate
      case AnnotationSeverity.suggestion:
        return const Color(0xFF3B82F6); // Blue
      case AnnotationSeverity.medium:
        return const Color(0xFFEAB308); // Yellow
      case AnnotationSeverity.high:
        return const Color(0xFFF97316); // Orange
      case AnnotationSeverity.critical:
        return const Color(0xFFEF4444); // Red
    }
  }
}
