import 'package:flutter/foundation.dart';

/// Immutable model representing contextual environment metadata associated with
/// an inspected widget.
@immutable
class WidgetContext {
  /// The active navigation route name, if available.
  final String? route;

  /// The accessibility semantics label, if defined.
  final String? semanticsLabel;

  /// The accessibility semantics hint, if defined.
  final String? semanticsHint;

  /// Package or library source origin, if detectable.
  final String? packageSource;

  /// Depth of the widget within the active element hierarchy.
  final int depth;

  const WidgetContext({
    this.route,
    this.semanticsLabel,
    this.semanticsHint,
    this.packageSource,
    this.depth = 0,
  });

  /// Constructs an empty context fallback.
  const WidgetContext.empty()
      : route = null,
        semanticsLabel = null,
        semanticsHint = null,
        packageSource = null,
        depth = 0;

  /// Converts this context model into a serializable JSON map.
  Map<String, dynamic> toJson() => {
        'route': route,
        'semanticsLabel': semanticsLabel,
        'semanticsHint': semanticsHint,
        'packageSource': packageSource,
        'depth': depth,
      };

  /// Factory creating [WidgetContext] from a JSON map.
  factory WidgetContext.fromJson(Map<String, dynamic> json) {
    return WidgetContext(
      route: json['route'] as String?,
      semanticsLabel: json['semanticsLabel'] as String?,
      semanticsHint: json['semanticsHint'] as String?,
      packageSource: json['packageSource'] as String?,
      depth: json['depth'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetContext &&
          runtimeType == other.runtimeType &&
          route == other.route &&
          semanticsLabel == other.semanticsLabel &&
          semanticsHint == other.semanticsHint &&
          packageSource == other.packageSource &&
          depth == other.depth;

  @override
  int get hashCode => Object.hash(
        route,
        semanticsLabel,
        semanticsHint,
        packageSource,
        depth,
      );

  @override
  String toString() =>
      'WidgetContext(route: $route, semantics: $semanticsLabel, depth: $depth)';
}
