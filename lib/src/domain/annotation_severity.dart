import 'package:flutter/material.dart';
import '../theme/agentation_colors.dart';

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
        return AgentationColors.lightTextSlate;
      case AnnotationSeverity.suggestion:
        return AgentationColors.blue500;
      case AnnotationSeverity.medium:
        return AgentationColors.yellow500;
      case AnnotationSeverity.high:
        return AgentationColors.orange;
      case AnnotationSeverity.critical:
        return AgentationColors.red500;
    }
  }
}
