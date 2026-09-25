import 'dart:math' as math;
import '../models/widget_bounds.dart';
import '../models/widget_inspection_result.dart';

/// Manages multiple selected widgets for concurrent multi-widget feedback annotations.
class MultiSelectHandler {
  final List<WidgetInspectionResult> _selected = [];

  /// All currently selected candidate results in order of selection.
  List<WidgetInspectionResult> get selectedWidgets =>
      List.unmodifiable(_selected);

  /// Number of currently selected widgets.
  int get selectedCount => _selected.length;

  /// Whether a specific [target] is currently included in the multi-selection.
  bool isSelected(WidgetInspectionResult target) {
    return _selected.any((item) => item.identity == target.identity);
  }

  /// Toggles selection of [target]; adds if absent, removes if present.
  void toggleSelection(WidgetInspectionResult target) {
    final index =
        _selected.indexWhere((item) => item.identity == target.identity);
    if (index >= 0) {
      _selected.removeAt(index);
    } else {
      _selected.add(target);
    }
  }

  /// Adds a target to the selection if not already present.
  void addSelection(WidgetInspectionResult target) {
    if (!isSelected(target)) {
      _selected.add(target);
    }
  }

  /// Removes a target from the selection if present.
  void removeSelection(WidgetInspectionResult target) {
    _selected.removeWhere((item) => item.identity == target.identity);
  }

  /// Clears all active multi-selected items.
  void clear() {
    _selected.clear();
  }

  /// Computes the union bounding box enclosing all selected widgets.
  WidgetBounds get combinedBounds {
    if (_selected.isEmpty) return const WidgetBounds.zero();

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final item in _selected) {
      final b = item.bounds;
      minX = math.min(minX, b.x);
      minY = math.min(minY, b.y);
      maxX = math.max(maxX, b.x + b.width);
      maxY = math.max(maxY, b.y + b.height);
    }

    return WidgetBounds(
      x: minX,
      y: minY,
      width: maxX - minX,
      height: maxY - minY,
    );
  }
}
