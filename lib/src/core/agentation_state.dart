import 'package:flutter/widgets.dart';
import '../models/hierarchical_inspection_result.dart';
import '../models/toolbar_settings.dart';
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

/// Active interaction tool mode in the inspection overlay.
enum AnnotationToolMode {
  /// Single widget inspection and hierarchy targeting.
  pointer,

  /// Drag marquee bounding box across empty space or specific regions.
  area,

  /// Select multiple widgets concurrently.
  multiSelect,

  /// Freehand sketch and drawing canvas.
  draw,

  /// Visual wireframe skeletons and widget rearrangement.
  design,
}

/// Immutable state snapshot of the Agentation inspection system.
@immutable
class AgentationState {
  const AgentationState({
    this.mode = InspectionMode.inactive,
    this.toolMode = AnnotationToolMode.pointer,
    this.settings = const ToolbarSettings(),
    this.selectedResult,
    this.hoveredResult,
    this.activeHierarchy,
    this.toolbarOffset = Offset.zero,
    this.isToolbarMinimized = false,
    this.isFrozen = false,
  });

  /// The current inspection mode.
  final InspectionMode mode;

  /// The active interaction tool mode (pointer, area, multiSelect, draw, design).
  final AnnotationToolMode toolMode;

  /// User preferences and configuration state for the inspection overlay and toolbar.
  final ToolbarSettings settings;

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

  /// Whether in-flight animations and tickers in the host tree are paused.
  final bool isFrozen;

  /// Whether inspection is actively intercepting events.
  bool get isInspecting => mode == InspectionMode.inspecting;

  /// Whether inspection is paused.
  bool get isPaused => mode == InspectionMode.paused;

  /// Whether inspection is completely inactive (gesture passthrough).
  bool get isInactive => mode == InspectionMode.inactive;

  /// Creates a copy of this state with specified fields replaced.
  AgentationState copyWith({
    InspectionMode? mode,
    AnnotationToolMode? toolMode,
    ToolbarSettings? settings,
    WidgetInspectionResult? Function()? selectedResult,
    WidgetInspectionResult? Function()? hoveredResult,
    HierarchicalInspectionResult? Function()? activeHierarchy,
    Offset? toolbarOffset,
    bool? isToolbarMinimized,
    bool? isFrozen,
  }) {
    return AgentationState(
      mode: mode ?? this.mode,
      toolMode: toolMode ?? this.toolMode,
      settings: settings ?? this.settings,
      selectedResult:
          selectedResult != null ? selectedResult() : this.selectedResult,
      hoveredResult:
          hoveredResult != null ? hoveredResult() : this.hoveredResult,
      activeHierarchy:
          activeHierarchy != null ? activeHierarchy() : this.activeHierarchy,
      toolbarOffset: toolbarOffset ?? this.toolbarOffset,
      isToolbarMinimized: isToolbarMinimized ?? this.isToolbarMinimized,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgentationState &&
        other.mode == mode &&
        other.toolMode == toolMode &&
        other.settings == settings &&
        other.selectedResult == selectedResult &&
        other.hoveredResult == hoveredResult &&
        other.activeHierarchy == activeHierarchy &&
        other.toolbarOffset == toolbarOffset &&
        other.isToolbarMinimized == isToolbarMinimized &&
        other.isFrozen == isFrozen;
  }

  @override
  int get hashCode => Object.hash(
        mode,
        toolMode,
        settings,
        selectedResult,
        hoveredResult,
        activeHierarchy,
        toolbarOffset,
        isToolbarMinimized,
        isFrozen,
      );
}
