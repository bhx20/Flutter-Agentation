import 'package:flutter/foundation.dart';
import 'widget_source_location.dart';

/// Target model encapsulating an inspected widget's name and its exact source code location.
@immutable
class FeedbackTarget {
  /// The meaningful Dart widget class name (e.g. 'LoginButton' or 'ElevatedButton').
  final String widgetName;

  /// The exact resolved source code file, line, and column location.
  final WidgetSourceLocation source;

  const FeedbackTarget({
    required this.widgetName,
    required this.source,
  });

  /// Factory creating an unavailable fallback target.
  const FeedbackTarget.unavailable()
      : widgetName = 'Unknown',
        source = const WidgetSourceLocation.unavailable();

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
        'widgetName': widgetName,
        'source': source.toJson(),
      };

  /// Deserializes from a JSON map.
  factory FeedbackTarget.fromJson(Map<String, dynamic> json) {
    return FeedbackTarget(
      widgetName: json['widgetName'] as String? ?? 'Unknown',
      source: json['source'] != null
          ? WidgetSourceLocation.fromJson(
              Map<String, dynamic>.from(json['source'] as Map))
          : const WidgetSourceLocation.unavailable(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackTarget &&
          runtimeType == other.runtimeType &&
          widgetName == other.widgetName &&
          source == other.source;

  @override
  int get hashCode => Object.hash(widgetName, source);

  @override
  String toString() => 'FeedbackTarget($widgetName @ $source)';
}
