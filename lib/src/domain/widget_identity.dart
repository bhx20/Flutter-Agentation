import 'package:flutter/foundation.dart';

/// Immutable model representing the identity and type classification
/// of an inspected widget.
@immutable
class WidgetIdentity {
  /// The primary identifier for the widget (resolved from target id, key, or type).
  final String id;

  /// String representation of the widget's [Key] if present.
  final String? keyString;

  /// The concrete Dart class name of the widget (e.g. 'ElevatedButton').
  final String widgetType;

  /// Whether this widget was explicitly instrumented with an explicit target identifier.
  final bool isExplicitTarget;

  const WidgetIdentity({
    required this.id,
    this.keyString,
    required this.widgetType,
    this.isExplicitTarget = false,
  });

  /// Constructs an empty/unknown identity fallback.
  const WidgetIdentity.empty()
      : id = '',
        keyString = null,
        widgetType = 'Unknown',
        isExplicitTarget = false;

  /// Converts this identity model into a serializable JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'keyString': keyString,
        'widgetType': widgetType,
        'isExplicitTarget': isExplicitTarget,
      };

  /// Factory creating [WidgetIdentity] from a JSON map.
  factory WidgetIdentity.fromJson(Map<String, dynamic> json) {
    return WidgetIdentity(
      id: json['id'] as String? ?? '',
      keyString: json['keyString'] as String?,
      widgetType: json['widgetType'] as String? ?? 'Unknown',
      isExplicitTarget: json['isExplicitTarget'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetIdentity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          keyString == other.keyString &&
          widgetType == other.widgetType &&
          isExplicitTarget == other.isExplicitTarget;

  @override
  int get hashCode => Object.hash(id, keyString, widgetType, isExplicitTarget);

  @override
  String toString() =>
      'WidgetIdentity(id: $id, type: $widgetType, key: $keyString, explicit: $isExplicitTarget)';
}
