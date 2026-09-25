import 'package:flutter/widgets.dart';
import '../inspection/flutter_inspection_engine.dart';
import '../models/annotation.dart';
import '../models/annotation_intent.dart';
import '../models/annotation_severity.dart';
import '../models/annotation_status.dart';
import '../models/hierarchical_inspection_result.dart';
import '../models/widget_bounds.dart';
import '../models/widget_identity.dart';
import '../models/widget_inspection_result.dart';
import '../storage/annotation_storage.dart';
import '../storage/memory_annotation_storage.dart';
import '../output/clipboard_exporter.dart';
import 'agentation_logger.dart';
import 'agentation_state.dart';

/// Programmatic controller for the FlutterAgentation inspection overlay, toolbar, and annotations.
class AgentationController extends ChangeNotifier {
  AgentationController({
    FlutterInspectionEngine? engine,
    AnnotationStorage? storage,
    InspectionMode initialMode = InspectionMode.inactive,
  })  : _engine = engine ?? FlutterInspectionEngine(),
        _storage = storage ?? MemoryAnnotationStorage(),
        _state = AgentationState(mode: initialMode);

  final FlutterInspectionEngine _engine;
  final AnnotationStorage _storage;
  AgentationState _state;

  List<Annotation> _annotations = [];
  Annotation? _activeAnnotation;

  /// The underlying inspection engine.
  FlutterInspectionEngine get engine => _engine;

  /// The storage repository.
  AnnotationStorage get storage => _storage;

  /// Current immutable state snapshot.
  AgentationState get state => _state;

  /// Active inspection mode.
  InspectionMode get mode => _state.mode;

  /// All recorded annotations in memory, ordered chronologically.
  List<Annotation> get annotations => List.unmodifiable(_annotations);

  /// The annotation currently being viewed in detail, if any.
  Annotation? get activeAnnotation => _activeAnnotation;

  /// Whether inspection is actively intercepting events.
  bool get isInspecting => _state.isInspecting;

  /// Whether inspection is paused.
  bool get isPaused => _state.isPaused;

  /// Whether inspection is completely inactive.
  bool get isInactive => _state.isInactive;

  /// Currently selected inspection result.
  WidgetInspectionResult? get selectedResult => _state.selectedResult;

  /// Candidate inspection result currently hovered.
  WidgetInspectionResult? get hoveredResult => _state.hoveredResult;

  /// The active multi-level widget hierarchy for the currently selected target.
  HierarchicalInspectionResult? get activeHierarchy => _state.activeHierarchy;

  /// Floating toolbar position offset.
  Offset get toolbarOffset => _state.toolbarOffset;

  /// Whether the floating toolbar is collapsed.
  bool get isToolbarMinimized => _state.isToolbarMinimized;

  /// Activates inspection mode.
  void activate() {
    if (_state.mode == InspectionMode.inspecting) return;
    AgentationLogger.debug('Inspection mode activated');
    _state = _state.copyWith(
      mode: InspectionMode.inspecting,
    );
    notifyListeners();
  }

  /// Deactivates inspection mode and clears highlights.
  void deactivate() {
    if (_state.mode == InspectionMode.inactive) return;
    AgentationLogger.debug('Inspection mode deactivated');
    _state = _state.copyWith(
      mode: InspectionMode.inactive,
      selectedResult: () => null,
      hoveredResult: () => null,
      activeHierarchy: () => null,
    );
    _activeAnnotation = null;
    notifyListeners();
  }

  /// Toggles between inactive and inspecting modes.
  void toggleInspect() {
    if (_state.isInspecting) {
      deactivate();
    } else {
      activate();
    }
  }

  /// Pauses active inspection while keeping the current selection highlight.
  void pause() {
    if (_state.mode == InspectionMode.paused) return;
    AgentationLogger.debug('Inspection paused');
    _state = _state.copyWith(
      mode: InspectionMode.paused,
      hoveredResult: () => null,
    );
    notifyListeners();
  }

  /// Resumes active inspection from paused state.
  void resume() {
    if (_state.mode == InspectionMode.inspecting) return;
    AgentationLogger.debug('Inspection resumed');
    _state = _state.copyWith(
      mode: InspectionMode.inspecting,
    );
    notifyListeners();
  }

  /// Sets the active multi-level hierarchy.
  void setActiveHierarchy(HierarchicalInspectionResult? hierarchy) {
    if (_state.activeHierarchy == hierarchy) return;
    _state = _state.copyWith(
      activeHierarchy: () => hierarchy,
    );
    notifyListeners();
  }

  /// Retargets the active selection to a specific [target] candidate (e.g. from breadcrumb or child chips),
  /// updating the highlight and notifying listeners.
  void selectTarget(WidgetInspectionResult target) {
    if (_state.selectedResult == target) return;
    AgentationLogger.debug('Retargeted selection to: ${target.identity.widgetType}');
    _state = _state.copyWith(
      selectedResult: () => target,
    );
    notifyListeners();
  }

  /// Selects a specific inspection result.
  void selectResult(WidgetInspectionResult? result) {
    if (_state.selectedResult == result) return;
    _state = _state.copyWith(
      selectedResult: () => result,
    );
    notifyListeners();
  }

  /// Sets candidate hovered result.
  void setHoveredResult(WidgetInspectionResult? result) {
    if (_state.hoveredResult == result) return;
    _state = _state.copyWith(
      hoveredResult: () => result,
    );
    notifyListeners();
  }

  /// Clears active selection and hover highlights.
  void clearSelection() {
    if (_state.selectedResult == null &&
        _state.hoveredResult == null &&
        _activeAnnotation == null &&
        _state.activeHierarchy == null) {
      return;
    }
    _state = _state.copyWith(
      selectedResult: () => null,
      hoveredResult: () => null,
      activeHierarchy: () => null,
    );
    _activeAnnotation = null;
    notifyListeners();
  }

  /// Sets the currently active annotation for detail viewing.
  void viewAnnotation(Annotation? annotation) {
    if (_activeAnnotation == annotation) return;
    _activeAnnotation = annotation;
    notifyListeners();
  }

  /// Creates and persists an [Annotation] attached to the currently selected widget.
  Future<Annotation> createAnnotation({
    required String comment,
    AnnotationIntent intent = AnnotationIntent.suggestion,
    AnnotationSeverity severity = AnnotationSeverity.suggestion,
    AnnotationStatus status = AnnotationStatus.pending,
    WidgetInspectionResult? targetResult,
    Map<String, dynamic> metadata = const {},
  }) async {
    final result = targetResult ?? _state.selectedResult;
    final identity = result?.identity ?? const WidgetIdentity.empty();
    final bounds = result?.bounds ?? const WidgetBounds.zero();

    final annotation = Annotation(
      id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
      comment: comment,
      timestamp: DateTime.now(),
      targetWidget: identity,
      bounds: bounds,
      route: result?.route,
      text: result?.text,
      intent: intent,
      severity: severity,
      status: status,
      metadata: {
        if (result?.pathString != null) 'path': result!.pathString,
        ...metadata,
      },
    );

    await _storage.save(annotation);
    _annotations = await _storage.getAll();
    AgentationLogger.debug('Created annotation: ${annotation.id}');
    notifyListeners();
    return annotation;
  }

  /// Exports all collected annotations to the system clipboard in the requested [format].
  /// Returns the formatted string if copied, or null if empty or failed.
  Future<String?> exportAnnotations({
    ExportFormat format = ExportFormat.markdown,
    bool prettyJson = true,
    ClipboardExporter exporter = const ClipboardExporter(),
  }) async {
    return exporter.copyToClipboard(
      _annotations,
      format: format,
      prettyJson: prettyJson,
    );
  }

  /// Deletes an annotation by its unique [id].
  Future<bool> deleteAnnotation(String id) async {
    final success = await _storage.delete(id);
    if (success) {
      _annotations = await _storage.getAll();
      if (_activeAnnotation?.id == id) {
        _activeAnnotation = null;
      }
      AgentationLogger.debug('Deleted annotation: $id');
      notifyListeners();
    }
    return success;
  }

  /// Clears all annotations from memory.
  Future<void> clearAnnotations() async {
    await _storage.clear();
    _annotations = [];
    _activeAnnotation = null;
    notifyListeners();
  }

  /// Updates toolbar offset position.
  void updateToolbarOffset(Offset newOffset) {
    if (_state.toolbarOffset == newOffset) return;
    _state = _state.copyWith(
      toolbarOffset: newOffset,
    );
    notifyListeners();
  }

  /// Toggles toolbar minimized state.
  void toggleToolbarMinimized() {
    _state = _state.copyWith(
      isToolbarMinimized: !_state.isToolbarMinimized,
    );
    notifyListeners();
  }
}
