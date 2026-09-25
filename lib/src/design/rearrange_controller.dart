import 'package:flutter/widgets.dart';
import '../models/rearrange_data.dart';
import '../models/widget_bounds.dart';

/// Manages visual drag-and-drop state when rearranging existing widgets on screen.
class RearrangeController extends ChangeNotifier {
  RearrangeController({
    this.initialBounds = const WidgetBounds.zero(),
  })  : _currentBounds = initialBounds;

  /// The original static bounding box of the target element.
  WidgetBounds initialBounds;

  WidgetBounds _currentBounds;
  Offset? _dragStart;
  bool _isDragging = false;

  /// Current instantaneous bounding box during drag.
  WidgetBounds get currentBounds => _currentBounds;

  /// Whether a drag gesture is actively in progress.
  bool get isDragging => _isDragging;

  /// Initiates drag operation from [startPosition] with optional target [bounds].
  void startDrag(Offset startPosition, {WidgetBounds? bounds}) {
    if (bounds != null) {
      initialBounds = bounds;
      _currentBounds = bounds;
    }
    _dragStart = startPosition;
    _isDragging = true;
    _currentBounds = initialBounds;
    notifyListeners();
  }

  /// Updates drag position, translating the bounding box.
  void updateDrag(Offset currentPosition) {
    if (!_isDragging || _dragStart == null) return;

    final dx = currentPosition.dx - _dragStart!.dx;
    final dy = currentPosition.dy - _dragStart!.dy;

    _currentBounds = WidgetBounds(
      x: initialBounds.x + dx,
      y: initialBounds.y + dy,
      width: initialBounds.width,
      height: initialBounds.height,
    );
    notifyListeners();
  }

  /// Concludes drag operation and compiles structured [RearrangeData].
  RearrangeData endDrag({
    String? relativeTarget,
    String? direction,
  }) {
    _isDragging = false;
    _dragStart = null;

    final computedDirection = direction ??
        (_currentBounds.y >= initialBounds.y ? 'after' : 'before');

    final data = RearrangeData(
      originalBounds: initialBounds,
      newBounds: _currentBounds,
      relativeTarget: relativeTarget,
      direction: computedDirection,
    );

    notifyListeners();
    return data;
  }
}
