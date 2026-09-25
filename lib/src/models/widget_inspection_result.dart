import 'package:flutter/foundation.dart';

import 'widget_bounds.dart';
import 'widget_context.dart';
import 'widget_identity.dart';

/// Primary immutable result object encapsulating a complete widget inspection snapshot.
///
/// Guaranteed to retain ZERO live framework references (`BuildContext`, `Element`,
/// `RenderObject`, `Widget`), completely isolating the inspection snapshot in memory.
@immutable
class WidgetInspectionResult {
  /// The resolved identity and type classification of the inspected widget.
  final WidgetIdentity identity;

  /// Global physical coordinates and rectangular dimensions.
  final WidgetBounds bounds;

  /// Contextual environment metadata.
  final WidgetContext context;

  /// Active navigation route name, if present.
  final String? route;

  /// Primary extracted text display content, if available.
  final String? text;

  /// Ordered breadcrumb list of ancestor widget names leading to this widget.
  final List<String> ancestors;

  /// Additional arbitrary inspection metadata.
  final Map<String, dynamic> metadata;

  /// Whether inspection successfully resolved a target widget.
  final bool isAvailable;

  /// Formatted hierarchical ancestry path string (e.g. "LoginPage > LoginForm > ElevatedButton").
  String get pathString => ancestors.isEmpty ? identity.widgetType : ancestors.join(' > ');

  const WidgetInspectionResult({
    required this.identity,
    required this.bounds,
    required this.context,
    this.route,
    this.text,
    required this.ancestors,
    this.metadata = const {},
    this.isAvailable = true,
  });

  /// Defensive fallback constructor for when hit testing fails or encounters an unhandled node.
  const WidgetInspectionResult.unavailable()
      : identity = const WidgetIdentity.empty(),
        bounds = const WidgetBounds.zero(),
        context = const WidgetContext.empty(),
        route = null,
        text = null,
        ancestors = const [],
        metadata = const {},
        isAvailable = false;

  /// Converts this inspection result into a serializable JSON map.
  Map<String, dynamic> toJson() => {
        'identity': identity.toJson(),
        'bounds': bounds.toJson(),
        'context': context.toJson(),
        'route': route,
        'text': text,
        'ancestors': ancestors,
        'pathString': pathString,
        'metadata': metadata,
        'isAvailable': isAvailable,
      };

  /// Factory creating [WidgetInspectionResult] from a JSON map.
  factory WidgetInspectionResult.fromJson(Map<String, dynamic> json) {
    return WidgetInspectionResult(
      identity: WidgetIdentity.fromJson(
        Map<String, dynamic>.from(json['identity'] as Map),
      ),
      bounds: WidgetBounds.fromJson(
        Map<String, dynamic>.from(json['bounds'] as Map),
      ),
      context: json['context'] != null
          ? WidgetContext.fromJson(Map<String, dynamic>.from(json['context'] as Map))
          : const WidgetContext.empty(),
      route: json['route'] as String?,
      text: json['text'] as String?,
      ancestors: (json['ancestors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetInspectionResult &&
          runtimeType == other.runtimeType &&
          identity == other.identity &&
          bounds == other.bounds &&
          context == other.context &&
          route == other.route &&
          text == other.text &&
          listEquals(ancestors, other.ancestors) &&
          mapEquals(metadata, other.metadata) &&
          isAvailable == other.isAvailable;

  @override
  int get hashCode => Object.hash(
        identity,
        bounds,
        context,
        route,
        text,
        Object.hashAll(ancestors),
        isAvailable,
      );

  @override
  String toString() =>
      'WidgetInspectionResult(available: $isAvailable, type: ${identity.widgetType}, path: $pathString, text: $text)';
}
