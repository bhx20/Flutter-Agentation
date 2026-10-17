import 'package:flutter/widgets.dart';

/// Represents a freehand drawing stroke captured during sketch mode.
@immutable
class DrawingStroke {
  const DrawingStroke({
    required this.points,
    this.color = const Color(0xFF6366F1),
    this.strokeWidth = 3.0,
  });

  /// The list of sequential points comprising this stroke.
  final List<Offset> points;

  /// The stroke presentation color.
  final Color color;

  /// The stroke line thickness.
  final double strokeWidth;

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'color': color.toARGB32(),
      'strokeWidth': strokeWidth,
    };
  }

  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List<dynamic>? ?? [];
    final points = rawPoints.map((raw) {
      final map = raw as Map<String, dynamic>;
      final x = (map['x'] as num).toDouble();
      final y = (map['y'] as num).toDouble();
      return Offset(x, y);
    }).toList();

    final colorValue = json['color'] as int? ?? 0xFF6366F1;
    final strokeWidth = (json['strokeWidth'] as num?)?.toDouble() ?? 3.0;

    return DrawingStroke(
      points: points,
      color: Color(colorValue),
      strokeWidth: strokeWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrawingStroke &&
        other.color == color &&
        other.strokeWidth == strokeWidth &&
        _listEquals(other.points, points);
  }

  @override
  int get hashCode => Object.hash(color, strokeWidth, Object.hashAll(points));

  static bool _listEquals(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
