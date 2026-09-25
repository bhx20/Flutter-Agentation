import 'package:flutter/widgets.dart';
import '../models/hierarchical_inspection_result.dart';
import '../models/widget_inspection_result.dart';

/// Interaction mode of the visual inspection overlay.
enum InspectionMode {
  /// The overlay is passive; 100% of gestures pass to the host application.
  inactive,

  /// The overlay intercepts gestures to inspect widgets under the pointer.
  inspecting,

  /// Inspection is paused; active selections remain locked on screen.
  paused,
}

/// Immutable state snapshot of the Agentation inspection system.
@immutable
class AgentationState {
  const AgentationState({
    this.mode = InspectionMode.inactive,
    this.selectedResult,
    this.hoveredResult,
    this.activeHierarchy,
    this.toolbarOffset = Offset.zero,
    this.isToolbarMinimized = false,
  });

  /// The current inspection mode.
  final InspectionMode mode;

  /// The currently selected widget inspection result.
  final WidgetInspectionResult? selectedResult;

  /// The candidate widget currently under the hover cursor (desktop/web).
  final WidgetInspectionResult? hoveredResult;

  /// The active multi-level hierarchy (ancestors, primary, children) for the current selection.
  final HierarchicalInspectionResult? activeHierarchy;

  /// Current coordinate offset of the floating toolbar.
  final Offset toolbarOffset;

  /// Whether the floating toolbar is collapsed.
  final bool isToolbarMinimized;

  /// Whether inspection is actively intercepting events.
  bool get isInspecting => mode == InspectionMode.inspecting;

  /// Whether inspection is paused.
  bool get isPaused => mode == InspectionMode.paused;

  /// Whether inspection is completely inactive (gesture passthrough).
  bool get isInactive => mode == InspectionMode.inactive;

  /// Creates a copy of this state with specified fields replaced.
  AgentationState copyWith({
    InspectionMode? mode,
    WidgetInspectionResult? Function()? selectedResult,
    WidgetInspectionResult? Function()? hoveredResult,
    HierarchicalInspectionResult? Function()? activeHierarchy,
    Offset? toolbarOffset,
    bool? isToolbarMinimized,
  }) {
    return AgentationState(
      mode: mode ?? this.mode,
      selectedResult:
          selectedResult != null ? selectedResult() : this.selectedResult,
      hoveredResult:
          hoveredResult != null ? hoveredResult() : this.hoveredResult,
      activeHierarchy:
          activeHierarchy != null ? activeHierarchy() : this.activeHierarchy,
      toolbarOffset: toolbarOffset ?? this.toolbarOffset,
      isToolbarMinimized: isToolbarMinimized ?? this.isToolbarMinimized,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgentationState &&
        other.mode == mode &&
        other.selectedResult == selectedResult &&
        other.hoveredResult == hoveredResult &&
        other.activeHierarchy == activeHierarchy &&
        other.toolbarOffset == toolbarOffset &&
        other.isToolbarMinimized == isToolbarMinimized;
  }

  @override
  int get hashCode => Object.hash(
        mode,
        selectedResult,
        hoveredResult,
        activeHierarchy,
        toolbarOffset,
        isToolbarMinimized,
      );
}
