import 'package:flutter/foundation.dart';
import 'annotation_intent.dart';
import 'annotation_severity.dart';
import 'annotation_status.dart';
import 'drawing_stroke.dart';
import 'placement_data.dart';
import 'rearrange_data.dart';
import 'thread_message.dart';
import 'widget_bounds.dart';
import 'widget_identity.dart';

/// The categorical kind of visual annotation.
enum AnnotationKind {
  /// Standard user feedback note on a widget or region.
  feedback,

  /// Wireframe placement of a new suggested component.
  placement,

  /// Visual rearrangement and reordering of an existing widget.
  rearrange;

  String toJson() => name;

  static AnnotationKind fromJson(String? value) {
    return AnnotationKind.values.firstWhere(
      (k) => k.name == value,
      orElse: () => AnnotationKind.feedback,
    );
  }
}

/// Immutable model representing user feedback attached to a visual Flutter widget or area.
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
    // Parity fields:
    this.kind = AnnotationKind.feedback,
    this.isMultiSelect = false,
    this.elementBoundingBoxes = const [],
    this.strokes = const [],
    this.placement,
    this.rearrange,
    this.sourceFile,
    this.sessionId,
    this.thread = const [],
    this.resolvedBy,
    this.resolvedAt,
    this.authorId,
  });

  /// Unique identifier for this annotation.
  final String id;

  /// User-authored feedback note or description.
  final String comment;

  /// When this annotation was created.
  final DateTime timestamp;

  /// Target widget identification metadata.
  final WidgetIdentity targetWidget;

  /// Pixel-accurate global bounding box coordinates of the widget or area.
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

  /// The structural kind of annotation (feedback, placement, rearrange).
  final AnnotationKind kind;

  /// Whether this annotation represents a multi-widget selection.
  final bool isMultiSelect;

  /// Individual bounding boxes when multiple elements are selected.
  final List<WidgetBounds> elementBoundingBoxes;

  /// Freehand sketch strokes linked to this annotation.
  final List<DrawingStroke> strokes;

  /// Placement data for new component wireframes.
  final PlacementData? placement;

  /// Rearrange data for visual element repositioning.
  final RearrangeData? rearrange;

  /// Source file and line location if available (e.g. "lib/views/home.dart:42").
  final String? sourceFile;

  /// MCP session ID this annotation is associated with.
  final String? sessionId;

  /// Conversational message thread between human and AI coding agent.
  final List<ThreadMessage> thread;

  /// Who resolved this annotation ("human" or "agent").
  final String? resolvedBy;

  /// When this annotation was marked resolved.
  final DateTime? resolvedAt;

  /// Author identifier.
  final String? authorId;

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
      'kind': kind.toJson(),
      if (isMultiSelect) 'isMultiSelect': isMultiSelect,
      if (elementBoundingBoxes.isNotEmpty)
        'elementBoundingBoxes':
            elementBoundingBoxes.map((b) => b.toJson()).toList(),
      if (strokes.isNotEmpty)
        'strokes': strokes.map((s) => s.toJson()).toList(),
      if (placement != null) 'placement': placement!.toJson(),
      if (rearrange != null) 'rearrange': rearrange!.toJson(),
      if (sourceFile != null) 'sourceFile': sourceFile,
      if (sessionId != null) 'sessionId': sessionId,
      if (thread.isNotEmpty) 'thread': thread.map((m) => m.toJson()).toList(),
      if (resolvedBy != null) 'resolvedBy': resolvedBy,
      if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
      if (authorId != null) 'authorId': authorId,
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
      kind: AnnotationKind.fromJson(json['kind'] as String?),
      isMultiSelect: json['isMultiSelect'] as bool? ?? false,
      elementBoundingBoxes: (json['elementBoundingBoxes'] as List<dynamic>?)
              ?.map<WidgetBounds>((item) =>
                  WidgetBounds.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const <WidgetBounds>[],
      strokes: (json['strokes'] as List<dynamic>?)
              ?.map<DrawingStroke>((item) =>
                  DrawingStroke.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const <DrawingStroke>[],
      placement: json['placement'] != null
          ? PlacementData.fromJson(
              Map<String, dynamic>.from(json['placement'] as Map))
          : null,
      rearrange: json['rearrange'] != null
          ? RearrangeData.fromJson(
              Map<String, dynamic>.from(json['rearrange'] as Map))
          : null,
      sourceFile: json['sourceFile'] as String?,
      sessionId: json['sessionId'] as String?,
      thread: (json['thread'] as List<dynamic>?)
              ?.map<ThreadMessage>((item) =>
                  ThreadMessage.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const <ThreadMessage>[],
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'] as String)
          : null,
      authorId: json['authorId'] as String?,
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
    AnnotationKind? kind,
    bool? isMultiSelect,
    List<WidgetBounds>? elementBoundingBoxes,
    List<DrawingStroke>? strokes,
    PlacementData? placement,
    RearrangeData? rearrange,
    String? sourceFile,
    String? sessionId,
    List<ThreadMessage>? thread,
    String? resolvedBy,
    DateTime? resolvedAt,
    String? authorId,
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
      kind: kind ?? this.kind,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      elementBoundingBoxes: elementBoundingBoxes ?? this.elementBoundingBoxes,
      strokes: strokes ?? this.strokes,
      placement: placement ?? this.placement,
      rearrange: rearrange ?? this.rearrange,
      sourceFile: sourceFile ?? this.sourceFile,
      sessionId: sessionId ?? this.sessionId,
      thread: thread ?? this.thread,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      authorId: authorId ?? this.authorId,
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
        other.kind == kind &&
        other.isMultiSelect == isMultiSelect &&
        other.sourceFile == sourceFile &&
        other.sessionId == sessionId &&
        listEquals(other.selectedWidgets, selectedWidgets) &&
        listEquals(other.elementBoundingBoxes, elementBoundingBoxes) &&
        listEquals(other.strokes, strokes) &&
        other.placement == placement &&
        other.rearrange == rearrange &&
        listEquals(other.thread, thread) &&
        other.resolvedBy == resolvedBy &&
        other.resolvedAt == resolvedAt &&
        other.authorId == authorId &&
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
        kind,
        isMultiSelect,
      );

  @override
  String toString() {
    return 'Annotation(id: $id, target: ${targetWidget.widgetType}, kind: ${kind.name}, comment: "$comment")';
  }
}
