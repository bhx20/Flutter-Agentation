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

  /// True if element has fixed/sticky positioning (e.g. AppBar, bottom bar) and stays fixed on screen.
  final bool isFixed;

  /// Scroll offset of the enclosing scrollable at the time of inspection.
  final double? scrollOffset;

  /// Scroll axis direction of the enclosing scrollable.
  final String? scrollAxis;

  /// Global rectangular bounds of the enclosing scrollable's viewport.
  final Map<String, dynamic>? viewportBounds;

  const WidgetContext({
    this.route,
    this.semanticsLabel,
    this.semanticsHint,
    this.packageSource,
    this.depth = 0,
    this.isFixed = false,
    this.scrollOffset,
    this.scrollAxis,
    this.viewportBounds,
  });

  /// Constructs an empty context fallback.
  const WidgetContext.empty()
      : route = null,
        semanticsLabel = null,
        semanticsHint = null,
        packageSource = null,
        depth = 0,
        isFixed = true,
        scrollOffset = null,
        scrollAxis = null,
        viewportBounds = null;

  /// Converts this context model into a serializable JSON map.
  Map<String, dynamic> toJson() => {
        'route': route,
        'semanticsLabel': semanticsLabel,
        'semanticsHint': semanticsHint,
        'packageSource': packageSource,
        'depth': depth,
        'isFixed': isFixed,
        if (scrollOffset != null) 'scrollOffset': scrollOffset,
        if (scrollAxis != null) 'scrollAxis': scrollAxis,
        if (viewportBounds != null) 'viewportBounds': viewportBounds,
      };

  /// Factory creating [WidgetContext] from a JSON map.
  factory WidgetContext.fromJson(Map<String, dynamic> json) {
    return WidgetContext(
      route: json['route'] as String?,
      semanticsLabel: json['semanticsLabel'] as String?,
      semanticsHint: json['semanticsHint'] as String?,
      packageSource: json['packageSource'] as String?,
      depth: json['depth'] as int? ?? 0,
      isFixed: json['isFixed'] as bool? ?? false,
      scrollOffset: (json['scrollOffset'] as num?)?.toDouble(),
      scrollAxis: json['scrollAxis'] as String?,
      viewportBounds: json['viewportBounds'] != null
          ? Map<String, dynamic>.from(json['viewportBounds'] as Map)
          : null,
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
          depth == other.depth &&
          isFixed == other.isFixed &&
          scrollOffset == other.scrollOffset &&
          scrollAxis == other.scrollAxis;

  @override
  int get hashCode => Object.hash(
        route,
        semanticsLabel,
        semanticsHint,
        packageSource,
        depth,
        isFixed,
        scrollOffset,
        scrollAxis,
      );

  @override
  String toString() =>
      'WidgetContext(route: $route, semantics: $semanticsLabel, depth: $depth, isFixed: $isFixed, scrollOffset: $scrollOffset)';
}
