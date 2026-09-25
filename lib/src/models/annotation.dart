import 'package:flutter/foundation.dart';
import 'annotation_intent.dart';
import 'annotation_severity.dart';
import 'annotation_status.dart';
import 'widget_bounds.dart';
import 'widget_identity.dart';

/// Immutable model representing user feedback attached to a visual Flutter widget.
@immutable
class Annotation {
  const Annotation({
    required this.id,
    required this.comment,
    required this.timestamp,
    required this.targetWidget,
    required this.bounds,
    this.route,
    this.text,
    this.intent = AnnotationIntent.suggestion,
    this.severity = AnnotationSeverity.suggestion,
    this.status = AnnotationStatus.pending,
    this.selectedText,
    this.selectedWidgets = const [],
    this.metadata = const {},
  });

  /// Unique identifier for this annotation.
  final String id;

  /// User-authored feedback note or description.
  final String comment;

  /// When this annotation was created.
  final DateTime timestamp;

  /// Target widget identification metadata.
  final WidgetIdentity targetWidget;

  /// Pixel-accurate global bounding box coordinates of the widget.
  final WidgetBounds bounds;

  /// Active route/page identity if detected.
  final String? route;

  /// Display text extracted from the target widget.
  final String? text;

  /// Categorical intent (e.g. bug, change, suggestion).
  final AnnotationIntent intent;

  /// Priority and urgency level.
  final AnnotationSeverity severity;

  /// Lifecycle status (e.g. pending, inProgress, resolved).
  final AnnotationStatus status;

  /// Specific text selection range if applicable.
  final String? selectedText;

  /// Additional multi-selected widgets if part of a group annotation.
  final List<WidgetIdentity> selectedWidgets;

  /// Extensible custom metadata attributes.
  final Map<String, dynamic> metadata;

  /// Serializes this annotation to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
      'targetWidget': targetWidget.toJson(),
      'bounds': bounds.toJson(),
      if (route != null) 'route': route,
      if (text != null) 'text': text,
      'intent': intent.toJson(),
      'severity': severity.toJson(),
      'status': status.toJson(),
      if (selectedText != null) 'selectedText': selectedText,
      if (selectedWidgets.isNotEmpty)
        'selectedWidgets': selectedWidgets.map((w) => w.toJson()).toList(),
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }

  /// Deserializes an annotation from a JSON map.
  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'] as String,
      comment: json['comment'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      targetWidget: WidgetIdentity.fromJson(
        Map<String, dynamic>.from(json['targetWidget'] as Map),
      ),
      bounds: WidgetBounds.fromJson(
        Map<String, dynamic>.from(json['bounds'] as Map),
      ),
      route: json['route'] as String?,
      text: json['text'] as String?,
      intent: AnnotationIntent.fromJson(json['intent'] as String? ?? ''),
      severity: AnnotationSeverity.fromJson(json['severity'] as String? ?? ''),
      status: AnnotationStatus.fromJson(json['status'] as String? ?? ''),
      selectedText: json['selectedText'] as String?,
      selectedWidgets: (json['selectedWidgets'] as List<dynamic>?)
              ?.map<WidgetIdentity>((item) =>
                  WidgetIdentity.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const <WidgetIdentity>[],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
    );
  }

  /// Returns a copy of this annotation with specified fields replaced.
  Annotation copyWith({
    String? id,
    String? comment,
    DateTime? timestamp,
    WidgetIdentity? targetWidget,
    WidgetBounds? bounds,
    String? route,
    String? text,
    AnnotationIntent? intent,
    AnnotationSeverity? severity,
    AnnotationStatus? status,
    String? selectedText,
    List<WidgetIdentity>? selectedWidgets,
    Map<String, dynamic>? metadata,
  }) {
    return Annotation(
      id: id ?? this.id,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
      targetWidget: targetWidget ?? this.targetWidget,
      bounds: bounds ?? this.bounds,
      route: route ?? this.route,
      text: text ?? this.text,
      intent: intent ?? this.intent,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      selectedText: selectedText ?? this.selectedText,
      selectedWidgets: selectedWidgets ?? this.selectedWidgets,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Annotation &&
        other.id == id &&
        other.comment == comment &&
        other.timestamp == timestamp &&
        other.targetWidget == targetWidget &&
        other.bounds == bounds &&
        other.route == route &&
        other.text == text &&
        other.intent == intent &&
        other.severity == severity &&
        other.status == status &&
        other.selectedText == selectedText &&
        listEquals(other.selectedWidgets, selectedWidgets) &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
        id,
        comment,
        timestamp,
        targetWidget,
        bounds,
        route,
        text,
        intent,
        severity,
        status,
        selectedText,
      );

  @override
  String toString() {
    return 'Annotation(id: $id, target: ${targetWidget.widgetType}, comment: "$comment", severity: ${severity.name})';
  }
}
