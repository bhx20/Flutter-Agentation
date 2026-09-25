import 'package:flutter/widgets.dart';

/// Curated marker color options matching Agentation brand styling.
@immutable
class MarkerColor {
  const MarkerColor({
    required this.id,
    required this.label,
    required this.color,
  });

  /// Unique identifier (e.g. 'indigo', 'emerald').
  final String id;

  /// User-facing label (e.g. 'Indigo', 'Emerald').
  final String label;

  /// Visual presentation color.
  final Color color;

  static const List<MarkerColor> values = [
    MarkerColor(id: 'indigo', label: 'Indigo', color: Color(0xFF6366F1)),
    MarkerColor(id: 'emerald', label: 'Emerald', color: Color(0xFF10B981)),
    MarkerColor(id: 'amber', label: 'Amber', color: Color(0xFFF59E0B)),
    MarkerColor(id: 'rose', label: 'Rose', color: Color(0xFFF43F5E)),
    MarkerColor(id: 'cyan', label: 'Cyan', color: Color(0xFF06B6D4)),
    MarkerColor(id: 'purple', label: 'Purple', color: Color(0xFFA855F7)),
  ];

  /// Finds a color by ID, falling back to 'indigo'.
  static MarkerColor findById(String? id) {
    return values.firstWhere(
      (c) => c.id == id,
      orElse: () => values.first,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarkerColor && other.id == id && other.color == color;
  }

  @override
  int get hashCode => Object.hash(id, color);
}
