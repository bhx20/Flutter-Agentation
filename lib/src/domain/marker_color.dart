import 'package:flutter/widgets.dart';
import '../theme/agentation_colors.dart';

/// Curated marker color options matching Agentation brand styling (Screenshot 3).
@immutable
class MarkerColor {
  const MarkerColor({
    required this.id,
    required this.label,
    required this.color,
  });

  /// Unique identifier (e.g. 'purple', 'blue', 'emerald').
  final String id;

  /// User-facing label (e.g. 'Purple', 'Blue', 'Emerald').
  final String label;

  /// Visual presentation color.
  final Color color;

  static const List<MarkerColor> values = [
    MarkerColor(id: 'purple', label: 'Purple', color: AgentationColors.indigo),
    MarkerColor(id: 'blue', label: 'Blue', color: AgentationColors.accent),
    MarkerColor(id: 'cyan', label: 'Cyan', color: AgentationColors.cyan),
    MarkerColor(id: 'emerald', label: 'Emerald', color: AgentationColors.success),
    MarkerColor(id: 'amber', label: 'Amber', color: AgentationColors.amber),
    MarkerColor(id: 'orange', label: 'Orange', color: AgentationColors.warningAmber),
    MarkerColor(id: 'rose', label: 'Rose', color: AgentationColors.destructive),
  ];

  /// Finds a color by ID, falling back to 'blue'.
  static MarkerColor findById(String? id) {
    if (id == 'indigo') return values.firstWhere((c) => c.id == 'purple');
    if (id == 'green') return values.firstWhere((c) => c.id == 'emerald');
    if (id == 'yellow') return values.firstWhere((c) => c.id == 'amber');
    if (id == 'red') return values.firstWhere((c) => c.id == 'rose');
    return values.firstWhere(
      (c) => c.id == id,
      orElse: () => values.firstWhere((c) => c.id == 'blue', orElse: () => values.first),
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
