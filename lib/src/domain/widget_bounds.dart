import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Immutable model representing the global rectangular coordinates and dimensions
/// of an inspected widget.
@immutable
class WidgetBounds {
  /// The global horizontal offset (X coordinate).
  final double x;

  /// The global vertical offset (Y coordinate).
  final double y;

  /// The physical width of the widget.
  final double width;

  /// The physical height of the widget.
  final double height;

  /// Left boundary coordinate.
  double get left => x;

  /// Top boundary coordinate.
  double get top => y;

  /// Right boundary coordinate.
  double get right => x + width;

  /// Bottom boundary coordinate.
  double get bottom => y + height;

  /// Center point offset.
  Offset get center => Offset(x + width / 2, y + height / 2);

  /// Rect representation.
  Rect get rect => Rect.fromLTWH(x, y, width, height);

  /// Helper converting bounds to Flutter Rect.
  Rect toRect() => rect;

  /// Size representation.
  Size get size => Size(width, height);

  const WidgetBounds({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Constructs an empty/zero bounding box.
  const WidgetBounds.zero()
      : x = 0.0,
        y = 0.0,
        width = 0.0,
        height = 0.0;

  /// Factory creating [WidgetBounds] from a Flutter [Rect].
  factory WidgetBounds.fromRect(Rect rect) {
    return WidgetBounds(
      x: rect.left,
      y: rect.top,
      width: rect.width,
      height: rect.height,
    );
  }

  /// Converts this bounds model into a serializable JSON map.
  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
      };

  /// Factory creating [WidgetBounds] from a JSON map.
  factory WidgetBounds.fromJson(Map<String, dynamic> json) {
    return WidgetBounds(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetBounds &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() =>
      'WidgetBounds(x: ${x.toStringAsFixed(1)}, y: ${y.toStringAsFixed(1)}, w: ${width.toStringAsFixed(1)}, h: ${height.toStringAsFixed(1)})';
}
