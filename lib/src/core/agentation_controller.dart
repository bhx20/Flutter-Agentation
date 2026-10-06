import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../inspection/flutter_inspection_engine.dart';
import '../models/annotation.dart';
import '../models/annotation_intent.dart';
import '../models/annotation_severity.dart';
import '../models/annotation_status.dart';
import '../models/drawing_stroke.dart';
import '../models/hierarchical_inspection_result.dart';
import '../models/placement_data.dart';
import '../models/rearrange_data.dart';
import '../models/thread_message.dart';
import '../models/toolbar_settings.dart';
import '../models/widget_bounds.dart';
import '../models/widget_context.dart';
import '../models/widget_identity.dart';
import '../models/widget_inspection_result.dart';
import '../storage/annotation_storage.dart';
import '../storage/memory_annotation_storage.dart';
import '../output/clipboard_exporter.dart';
import '../networking/agent_sync_client.dart';
import '../source_location/widget_source_location.dart';
import 'agentation_logger.dart';
import 'agentation_state.dart';

/// Programmatic controller for the FlutterAgentation inspection overlay, toolbar, and annotations.
class AgentationController extends ChangeNotifier {
  AgentationController({
    FlutterInspectionEngine? engine,
    AnnotationStorage? storage,
    AgentSyncClient? syncClient,
    InspectionMode initialMode = InspectionMode.inactive,
    String? appName,
    this.onAnnotationAdd,
    this.onAnnotationDelete,
    this.onAnnotationUpdate,
    this.onAnnotationsClear,
    this.onCopy,
    this.onSubmit,
    this.onSessionCreated,
    this.onOpenSource,
    bool copyToClipboard = true,
    this.enableKeyboardShortcuts = true,
  })  : _engine = engine ?? FlutterInspectionEngine(),
        _storage = storage ?? MemoryAnnotationStorage(),
        _state = AgentationState(mode: initialMode),
        shouldCopyToClipboard = copyToClipboard {
    _appName = appName;
    if (syncClient != null) {
      _syncClient = syncClient;
    }
  }

  /// Callback fired when an annotation is created.
  void Function(Annotation annotation)? onAnnotationAdd;

  /// Callback fired when an annotation is deleted.
  void Function(Annotation annotation)? onAnnotationDelete;

  /// Callback fired when an annotation is updated or receives a thread message.
  void Function(Annotation annotation)? onAnnotationUpdate;

  /// Callback fired when all annotations are cleared.
  void Function(List<Annotation> annotations)? onAnnotationsClear;

  /// Callback fired after a Copy attempt with formatted output.
  void Function(String output)? onCopy;

  /// Callback fired when "Send Annotations" is clicked.
  FutureOr<void> Function(String output, List<Annotation> annotations)? onSubmit;

  /// Callback fired when a new session is created.
  void Function(String sessionId)? onSessionCreated;

  /// Callback fired when "Open in editor" is clicked for source code navigation.
  void Function(String sourceFile)? onOpenSource;

  /// Whether to write output to the system clipboard on copy. Defaults to true.
  bool shouldCopyToClipboard;

  /// Whether global keyboard shortcuts are enabled. Defaults to true.
  bool enableKeyboardShortcuts;

  final FlutterInspectionEngine _engine;
  final AnnotationStorage _storage;
  AgentSyncClient? _syncClient;
  AgentationState _state;

  List<Annotation> _annotations = [];
  Annotation? _activeAnnotation;

  List<WidgetInspectionResult> _multiSelection = [];
  final List<Annotation> _redoStack = [];

  /// ValueNotifier indicating whether a copy feedback action was recently completed.
  final ValueNotifier<bool> isCopiedNotifier = ValueNotifier<bool>(false);

  /// The underlying inspection engine.
  FlutterInspectionEngine get engine => _engine;

  /// The storage repository.
  AnnotationStorage get storage => _storage;

  /// Current immutable state snapshot.
  AgentationState get state => _state;

  /// Active inspection mode.
  InspectionMode get mode => _state.mode;

  /// Active interaction tool mode (pointer, area, multiSelect, draw, design).
  AnnotationToolMode get toolMode => _state.toolMode;

  /// User preferences and configuration state.
  ToolbarSettings get settings => _state.settings;

  /// The optional MCP synchronization client.
  AgentSyncClient? get syncClient => _syncClient;

  /// Sets or updates the active [AgentSyncClient].
  void setSyncClient(AgentSyncClient? client) {
    _syncClient = client;
    notifyListeners();
  }

  String? _appName;

  /// The active application name for session branding and markdown export.
  String? get appName => _appName;

  /// Sets or updates the application name.
  void setAppName(String? name) {
    _appName = name;
  }

  /// Whether an annotation creation can be undone.
  bool get canUndo => _annotations.isNotEmpty;

  /// Whether an undone annotation can be restored.
  bool get canRedo => _redoStack.isNotEmpty;

  /// All recorded annotations in memory, ordered chronologically.
  List<Annotation> get annotations => List.unmodifiable(_annotations);

  /// The annotation currently being viewed in detail, if any.
  Annotation? get activeAnnotation => _activeAnnotation;

  /// Currently accumulated multi-selected candidate widgets.
  List<WidgetInspectionResult> get multiSelection =>
      List.unmodifiable(_multiSelection);

  /// Whether inspection is actively intercepting events.
  bool get isInspecting => _state.isInspecting;

  /// Whether inspection is paused.
  bool get isPaused => _state.isPaused;

  /// Whether animations and tickers in the host tree are frozen.
  bool get isFrozen => _state.isFrozen;

  /// Whether inspection is completely inactive.
  bool get isInactive => _state.isInactive;

  /// Whether comments and annotation pins are displayed on the page.
  bool get areCommentsVisible => _state.areCommentsVisible;

  /// Currently selected inspection result.
  WidgetInspectionResult? get selectedResult => _state.selectedResult;

  /// Candidate inspection result currently hovered.
  WidgetInspectionResult? get hoveredResult => _state.hoveredResult;

  /// The active multi-level widget hierarchy for the currently selected target.
  HierarchicalInspectionResult? get activeHierarchy => _state.activeHierarchy;

  /// Floating toolbar position offset.
  Offset get toolbarOffset => _state.toolbarOffset;

  /// Current bounding box of the floating toolbar on screen.
  Rect? get toolbarBounds => _state.toolbarBounds;

  /// Whether the floating toolbar is collapsed.
  bool get isToolbarMinimized => _state.isToolbarMinimized;

  /// Whether the settings panel is currently open.
  bool get isSettingsOpen => _state.isSettingsOpen;

  /// Whether layout mode / component palette is currently open.
  bool get isLayoutModeOpen => _state.isLayoutModeOpen;

  /// Sets the active interaction tool mode.
  void setToolMode(AnnotationToolMode mode) {
    if (_state.toolMode == mode) return;
    AgentationLogger.debug('Switched tool mode to: $mode');
    _state = _state.copyWith(toolMode: mode);
    if (mode != AnnotationToolMode.multiSelect) {
      _multiSelection = [];
    }
    notifyListeners();
  }

  /// Toggles selection of a widget within multi-select mode.
  void toggleMultiSelection(WidgetInspectionResult target) {
    final existingIndex = _multiSelection
        .indexWhere((item) => item.identity == target.identity);
    if (existingIndex >= 0) {
      _multiSelection.removeAt(existingIndex);
    } else {
      _multiSelection.add(target);
    }
    notifyListeners();
  }

  /// Clears multi-selection items.
  void clearMultiSelection() {
    if (_multiSelection.isEmpty) return;
    _multiSelection = [];
    notifyListeners();
  }

  /// Updates overlay and toolbar preferences.
  void updateSettings(ToolbarSettings settings) {
    if (_state.settings == settings) return;
    final oldMcp = _state.settings.mcpEndpoint;
    final oldWebhook = _state.settings.webhookUrl;
    _state = _state.copyWith(settings: settings);

    if (settings.mcpEndpoint != oldMcp || settings.webhookUrl != oldWebhook) {
      final endpoint = settings.mcpEndpoint?.trim();
      final webhook = settings.webhookUrl?.trim();
      final hasEndpoint = endpoint != null && endpoint.isNotEmpty;
      final hasWebhook = webhook != null && webhook.isNotEmpty;

      if (hasEndpoint || hasWebhook) {
        if (_syncClient != null) {
          _syncClient = _syncClient!.copyWith(
            endpoint: endpoint ?? _syncClient!.endpoint,
            webhookUrl: webhook,
          );
        } else {
          _syncClient = AgentSyncClient(
            endpoint: endpoint ?? '',
            webhookUrl: webhook,
          );
        }
        if (hasEndpoint) {
          ensureActiveSession();
        }
      } else {
        _syncClient = null;
      }
    }
    notifyListeners();
  }

  /// Ensures an active MCP session exists, generating or requesting one if needed.
  Future<String?> ensureActiveSession({String? customSessionId}) async {
    if (customSessionId != null && customSessionId.isNotEmpty) {
      _state = _state.copyWith(
        settings: _state.settings.copyWith(sessionId: customSessionId),
      );
      notifyListeners();
      return customSessionId;
    }

    if (_state.settings.sessionId != null && _state.settings.sessionId!.isNotEmpty) {
      return _state.settings.sessionId;
    }

    if (_syncClient != null && _syncClient!.endpoint.isNotEmpty) {
      try {
        final session = await _syncClient!.createSession();
        final id = (session['id'] ?? session['sessionId']) as String?;
        final effectiveId = (id != null && id.isNotEmpty)
            ? id
            : 'sess_${DateTime.now().millisecondsSinceEpoch}';
        _state = _state.copyWith(
          settings: _state.settings.copyWith(sessionId: effectiveId),
        );
        onSessionCreated?.call(effectiveId);
        notifyListeners();
        return effectiveId;
      } catch (_) {
        final fallbackId = 'sess_${DateTime.now().millisecondsSinceEpoch}';
        _state = _state.copyWith(
          settings: _state.settings.copyWith(sessionId: fallbackId),
        );
        onSessionCreated?.call(fallbackId);
        notifyListeners();
        return fallbackId;
      }
    }
    return null;
  }

  /// Dispatches an event to the configured webhook URL.
  Future<bool> notifyWebhook(String event, Map<String, dynamic> payload) async {
    final webhookUrl = _state.settings.webhookUrl ?? _syncClient?.webhookUrl;
    if (webhookUrl == null || webhookUrl.isEmpty) return false;

    if (_syncClient != null) {
      return _syncClient!.dispatchWebhook(webhookUrl, event: event, payload: payload);
    } else {
      final tempClient = AgentSyncClient(endpoint: '', webhookUrl: webhookUrl);
      return tempClient.dispatchWebhook(webhookUrl, event: event, payload: payload);
    }
  }

  /// Sets the active output detail level.
  void setDetailLevel(OutputDetailLevel level) {
    updateSettings(_state.settings.copyWith(outputDetail: level));
  }

  /// Sets the active clipboard export format.
  void setCopyFormat(CopyFormat format) {
    updateSettings(_state.settings.copyWith(copyFormat: format));
  }

  /// Toggles between dark and light themes.
  void toggleTheme() {
    updateSettings(_state.settings.copyWith(
      isDarkMode: !_state.settings.isDarkMode,
    ));
  }

  /// Cycles through output detail levels: compact -> standard -> detailed -> forensic.
  void cycleDetailLevel() {
    final nextIndex = (_state.settings.outputDetail.index + 1) %
        OutputDetailLevel.values.length;
    updateSettings(_state.settings.copyWith(
      outputDetail: OutputDetailLevel.values[nextIndex],
    ));
  }

  /// Updates the active marker color ID.
  void setMarkerColorId(String id) {
    updateSettings(_state.settings.copyWith(
      markerColorId: id,
    ));
  }

  /// Undoes the creation of the most recent annotation.
  Future<void> undo() async {
    if (_annotations.isEmpty) return;
    final last = _annotations.last;
    final success = await _storage.delete(last.id);
    if (success) {
      _annotations = await _storage.getAll();
      _redoStack.add(last);
      if (_activeAnnotation?.id == last.id) {
        _activeAnnotation = null;
      }
      if (_syncClient != null) {
        _syncClient!.deleteAnnotation(last.id);
      }
      notifyWebhook('annotation.deleted', {
        'annotationId': last.id,
      });
      AgentationLogger.debug('Undid annotation: ${last.id}');
      notifyListeners();
    }
  }

  /// Restores the most recently undone annotation.
  Future<void> redo() async {
    if (_redoStack.isEmpty) return;
    final annotation = _redoStack.removeLast();
    await _storage.save(annotation);
    _annotations = await _storage.getAll();
    AgentationLogger.debug('Redid annotation: ${annotation.id}');
    notifyListeners();
  }

  /// Freezes active animations and tickers across the inspected application.
  void freeze() {
    if (_state.isFrozen) return;
    AgentationLogger.debug('Animations frozen');
    _state = _state.copyWith(isFrozen: true);
    notifyListeners();
  }

  /// Resumes active animations and tickers across the inspected application.
  void unfreeze() {
    if (!_state.isFrozen) return;
    AgentationLogger.debug('Animations unfrozen');
    _state = _state.copyWith(isFrozen: false);
    notifyListeners();
  }

  /// Toggles animation freeze state.
  void toggleFreeze() {
    if (_state.isFrozen) {
      unfreeze();
    } else {
      freeze();
    }
  }

  /// Activates inspection mode, optionally freezing animations atomically.
  void activate({bool freeze = false}) {
    if (_state.mode == InspectionMode.inspecting && (!freeze || _state.isFrozen)) return;
    AgentationLogger.debug('Inspection mode activated (freeze: $freeze)');
    _state = _state.copyWith(
      mode: InspectionMode.inspecting,
      isFrozen: freeze ? true : _state.isFrozen,
    );
    notifyListeners();
  }

  /// Deactivates inspection mode and clears highlights, unfreezing animations by default.
  void deactivate({bool unfreeze = true}) {
    if (_state.mode == InspectionMode.inactive && (!unfreeze || !_state.isFrozen)) return;
    AgentationLogger.debug('Inspection mode deactivated (unfreeze: $unfreeze)');
    _state = _state.copyWith(
      mode: InspectionMode.inactive,
      isFrozen: unfreeze ? false : _state.isFrozen,
      selectedResult: () => null,
      hoveredResult: () => null,
      activeHierarchy: () => null,
    );
    _multiSelection = [];
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

  /// Atomically selects a target and updates its active hierarchy in a single notification pass.
  void selectTargetHierarchy(WidgetInspectionResult result, HierarchicalInspectionResult hierarchy) {
    if (_state.selectedResult == result && _state.activeHierarchy == hierarchy) return;
    _state = _state.copyWith(
      selectedResult: () => result,
      activeHierarchy: () => hierarchy,
      hoveredResult: () => null,
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
        _state.activeHierarchy == null &&
        _multiSelection.isEmpty) {
      return;
    }
    _multiSelection = [];
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
    AnnotationKind kind = AnnotationKind.feedback,
    bool? isMultiSelect,
    List<WidgetBounds>? elementBoundingBoxes,
    List<DrawingStroke>? strokes,
    PlacementData? placement,
    RearrangeData? rearrange,
    String? sourceFile,
    WidgetSourceLocation? sourceLocation,
    String? sessionId,
    List<ThreadMessage>? thread,
    bool? isFixed,
    double? scrollY,
    double? scrollX,
    Map<String, dynamic> metadata = const {},
  }) async {
    final result = targetResult ?? _state.selectedResult;
    final identity = result?.identity ?? const WidgetIdentity.empty();
    final bounds = result?.bounds ?? const WidgetBounds.zero();

    final isMulti = isMultiSelect ?? (_multiSelection.length > 1);
    final boxes = elementBoundingBoxes ??
        (_multiSelection.isNotEmpty
            ? _multiSelection.map((m) => m.bounds).toList()
            : (result != null ? [result.bounds] : const <WidgetBounds>[]));

    final resolvedSource = sourceLocation ?? result?.sourceLocation;
    final resolvedSourceFile = sourceFile ??
        (resolvedSource?.filePath != null
            ? (resolvedSource!.line != null
                ? '${resolvedSource.filePath}:${resolvedSource.line}'
                : resolvedSource.filePath)
            : null);

    final resolvedIsFixed = isFixed ?? (result?.context.isFixed ?? (result == null));
    final resolvedScrollY = scrollY ?? (result?.context.scrollOffset ?? 0.0);
    final resolvedScrollX = scrollX ?? 0.0;

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
      kind: kind,
      isMultiSelect: isMulti,
      elementBoundingBoxes: boxes,
      strokes: strokes ?? const [],
      placement: placement,
      rearrange: rearrange,
      sourceFile: resolvedSourceFile,
      sourceLocation: resolvedSource,
      sessionId: sessionId ?? (_state.settings.sessionId?.isNotEmpty == true ? _state.settings.sessionId : null),
      thread: thread ?? const [],
      isFixed: resolvedIsFixed,
      scrollY: resolvedScrollY,
      scrollX: resolvedScrollX,
      metadata: {
        if (result?.pathString != null) 'path': result!.pathString,
        ...metadata,
      },
    );

    await _storage.save(annotation);
    _annotations = await _storage.getAll();
    _redoStack.clear();
    AgentationLogger.debug('Created annotation: ${annotation.id}');

    final activeSessionId = annotation.sessionId ?? _state.settings.sessionId;
    if (_syncClient != null && activeSessionId != null && activeSessionId.isNotEmpty) {
      _syncClient!.syncAnnotation(activeSessionId, annotation);
    }
    notifyWebhook('annotation.created', {
      'sessionId': ?activeSessionId,
      'annotation': annotation.toJson(),
    });

    onAnnotationAdd?.call(annotation);

    notifyListeners();
    return annotation;
  }

  /// Creates a structured visual [AnnotationKind.placement] annotation for a wireframe skeleton.
  Future<Annotation> createPlacementAnnotation({
    required PlacementData placement,
    required Offset position,
    required String comment,
    AnnotationSeverity severity = AnnotationSeverity.suggestion,
    bool? isFixed,
    double? scrollY,
    double? scrollX,
    Map<String, dynamic> metadata = const {},
  }) async {
    final bounds = WidgetBounds(
      x: position.dx,
      y: position.dy,
      width: placement.width,
      height: placement.height,
    );

    return createAnnotation(
      comment: comment,
      kind: AnnotationKind.placement,
      placement: placement,
      severity: severity,
      isFixed: isFixed,
      scrollY: scrollY,
      scrollX: scrollX,
      targetResult: WidgetInspectionResult(
        identity: WidgetIdentity(
          id: 'placement_${DateTime.now().millisecondsSinceEpoch}',
          widgetType: placement.componentType,
        ),
        bounds: bounds,
        context: const WidgetContext.empty(),
        ancestors: const [],
      ),
      elementBoundingBoxes: [bounds],
      metadata: metadata,
    );
  }

  /// Creates a structured visual [AnnotationKind.rearrange] annotation for a reordered widget.
  Future<Annotation> createRearrangeAnnotation({
    required RearrangeData rearrange,
    required WidgetIdentity targetIdentity,
    required String comment,
    AnnotationSeverity severity = AnnotationSeverity.suggestion,
    bool? isFixed,
    double? scrollY,
    double? scrollX,
    Map<String, dynamic> metadata = const {},
  }) async {
    return createAnnotation(
      comment: comment,
      kind: AnnotationKind.rearrange,
      rearrange: rearrange,
      severity: severity,
      isFixed: isFixed,
      scrollY: scrollY,
      scrollX: scrollX,
      targetResult: WidgetInspectionResult(
        identity: targetIdentity,
        bounds: rearrange.newBounds,
        context: const WidgetContext.empty(),
        ancestors: const [],
      ),
      elementBoundingBoxes: [rearrange.originalBounds, rearrange.newBounds],
      metadata: metadata,
    );
  }

  /// Exports all collected annotations to the system clipboard in the requested [format].
  /// If [format] is omitted, defaults to the current [ToolbarSettings.copyFormat].
  /// If [detailLevel] is omitted, defaults to the current [ToolbarSettings.outputDetail].
  /// Returns the formatted string if copied, or null if empty or failed.
  Future<String?> exportAnnotations({
    ExportFormat? format,
    OutputDetailLevel? detailLevel,
    bool prettyJson = true,
    String? appName,
    ClipboardExporter exporter = const ClipboardExporter(),
  }) async {
    final activeFormat = format ?? _mapCopyFormatToExportFormat(_state.settings.copyFormat);
    final activeDetail = detailLevel ?? _state.settings.outputDetail;
    final activeAppName = appName ?? _appName;

    final output = exporter.formatAnnotations(
      _annotations,
      format: activeFormat,
      detailLevel: activeDetail,
      prettyJson: prettyJson,
      appName: activeAppName,
    );

    if (output.isEmpty && _annotations.isNotEmpty) {
      return null;
    }

    if (shouldCopyToClipboard && output.isNotEmpty) {
      await exporter.copyToClipboard(
        _annotations,
        format: activeFormat,
        detailLevel: activeDetail,
        prettyJson: prettyJson,
        appName: activeAppName,
      );
    }

    if (output.isNotEmpty) {
      onCopy?.call(output);
    }

    if (output.isNotEmpty && _state.settings.autoClearAfterCopy) {
      await clearAnnotations();
    }
    return output.isNotEmpty ? output : null;
  }

  static ExportFormat _mapCopyFormatToExportFormat(CopyFormat copyFormat) {
    switch (copyFormat) {
      case CopyFormat.feedback:
        return ExportFormat.feedback;
      case CopyFormat.markdown:
        return ExportFormat.markdown;
      case CopyFormat.json:
        return ExportFormat.json;
      case CopyFormat.agentationJson:
        return ExportFormat.agentationJson;
      case CopyFormat.source:
        return ExportFormat.source;
      case CopyFormat.attributes:
        return ExportFormat.attributes;
    }
  }

  /// Partially updates an existing annotation's comment, intent, severity, or status.
  Future<Annotation?> updateAnnotation(
    String id, {
    String? comment,
    AnnotationIntent? intent,
    AnnotationSeverity? severity,
    AnnotationStatus? status,
    Map<String, dynamic>? metadata,
  }) async {
    final index = _annotations.indexWhere((a) => a.id == id);
    final Annotation target;
    if (index == -1) {
      final fromStorage = await _storage.getById(id);
      if (fromStorage == null) return null;
      target = fromStorage;
    } else {
      target = _annotations[index];
    }

    final updated = target.copyWith(
      comment: comment ?? target.comment,
      intent: intent ?? target.intent,
      severity: severity ?? target.severity,
      status: status ?? target.status,
      metadata: metadata != null ? {...target.metadata, ...metadata} : target.metadata,
    );

    await _storage.save(updated);
    _annotations = await _storage.getAll();
    if (_activeAnnotation?.id == id) {
      _activeAnnotation = updated;
    }

    final activeSessionId = target.sessionId ?? _state.settings.sessionId;
    if (_syncClient != null && activeSessionId != null && activeSessionId.isNotEmpty) {
      _syncClient!.updateAnnotation(id, {
        'comment': ?comment,
        'status': ?status?.name,
        'intent': ?intent?.name,
        'severity': ?severity?.name,
      });
    }

    notifyWebhook('annotation.updated', {
      'sessionId': ?activeSessionId,
      'annotation': updated.toJson(),
    });

    onAnnotationUpdate?.call(updated);
    notifyListeners();
    return updated;
  }

  /// Deletes an annotation by its unique [id].
  Future<bool> deleteAnnotation(String id) async {
    final target = _annotations.where((a) => a.id == id).firstOrNull;
    final success = await _storage.delete(id);
    if (success) {
      _annotations = await _storage.getAll();
      if (_activeAnnotation?.id == id) {
        _activeAnnotation = null;
      }
      if (_syncClient != null) {
        _syncClient!.deleteAnnotation(id);
      }
      AgentationLogger.debug('Deleted annotation: $id');
      if (target != null) {
        onAnnotationDelete?.call(target);
      }
      notifyListeners();
    }
    return success;
  }

  /// Reloads all annotations from persistent storage into memory.
  Future<List<Annotation>> loadAnnotations() async {
    _annotations = await _storage.getAll();
    notifyListeners();
    return _annotations;
  }

  /// Adds a conversational [ThreadMessage] reply to an existing annotation.
  Future<Annotation?> addThreadMessage(
    String annotationId,
    String content, {
    String role = 'human',
  }) async {
    final index = _annotations.indexWhere((a) => a.id == annotationId);
    final Annotation target;
    if (index == -1) {
      final fromStorage = await _storage.getById(annotationId);
      if (fromStorage == null) return null;
      target = fromStorage;
    } else {
      target = _annotations[index];
    }

    final newMessage = ThreadMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      role: role,
      content: content,
      timestamp: DateTime.now(),
    );

    final updated = target.copyWith(
      thread: [...target.thread, newMessage],
    );

    await _storage.save(updated);
    _annotations = await _storage.getAll();
    if (_activeAnnotation?.id == annotationId) {
      _activeAnnotation = updated;
    }

    final activeSessionId = target.sessionId ?? _state.settings.sessionId;
    if (_syncClient != null && activeSessionId != null && activeSessionId.isNotEmpty) {
      _syncClient!.syncAnnotation(activeSessionId, updated);
    }
    notifyWebhook('thread.message_added', {
      'sessionId': ?activeSessionId,
      'annotationId': annotationId,
      'message': newMessage.toJson(),
    });

    onAnnotationUpdate?.call(updated);
    notifyListeners();
    return updated;
  }

  /// Requests the connected AI agent to act on active annotations via MCP /action endpoint.
  Future<Map<String, dynamic>?> sendToAgent() async {
    final sessionId = _state.settings.sessionId;
    if (_syncClient == null || sessionId == null || sessionId.isEmpty) return null;
    final markdown = await exportAnnotations(format: ExportFormat.markdown);
    if (markdown == null) return null;
    final result = await _syncClient!.requestAction(sessionId, markdown);
    notifyWebhook('agent.action_requested', {
      'sessionId': sessionId,
      'result': result,
    });
    return result;
  }

  /// Whether the "Send Annotations" button should be visible/active.
  bool get canSend =>
      onSubmit != null ||
      _hasWebhookTarget ||
      (_syncClient != null && _syncClient!.endpoint.isNotEmpty);

  bool get _hasWebhookTarget {
    final webhook = _state.settings.webhookUrl ?? _syncClient?.webhookUrl;
    return webhook != null && webhook.isNotEmpty;
  }

  /// Sends formatted annotations to configured `onSubmit` callback, agent MCP, or webhooks.
  Future<bool> submitAnnotations() async {
    if (_annotations.isEmpty && !canSend) return false;

    final output = await exportAnnotations(format: ExportFormat.markdown);
    if (output == null) return false;

    bool callbackSuccess = true;
    if (onSubmit != null) {
      try {
        await onSubmit!(output, List.unmodifiable(_annotations));
      } catch (e, stack) {
        AgentationLogger.error('onSubmit callback failed', e, stack);
        callbackSuccess = false;
      }
    }

    bool syncSuccess = true;
    if (_syncClient != null && (_state.settings.sessionId?.isNotEmpty == true)) {
      try {
        await _syncClient!.requestAction(_state.settings.sessionId!, output);
      } catch (e, stack) {
        AgentationLogger.error('MCP requestAction failed', e, stack);
        syncSuccess = false;
      }
    }

    bool webhookSuccess = true;
    if (_hasWebhookTarget) {
      try {
        webhookSuccess = await notifyWebhook('submit', {
          'output': output,
          'annotations': _annotations.map((a) => a.toJson()).toList(),
          'sessionId': _state.settings.sessionId,
        });
      } catch (e, stack) {
        AgentationLogger.error('Webhook submit failed', e, stack);
        webhookSuccess = false;
      }
    }

    final overallSuccess = callbackSuccess && (syncSuccess || onSubmit != null || webhookSuccess);

    if (overallSuccess && _state.settings.autoClearAfterCopy) {
      await clearAnnotations();
    }

    return overallSuccess;
  }

  /// Clears all annotations from memory.
  Future<void> clearAnnotations() async {
    final cleared = List<Annotation>.from(_annotations);
    final count = cleared.length;
    await _storage.clear();
    _annotations = [];
    _activeAnnotation = null;
    notifyWebhook('annotations.cleared', {
      'count': count,
    });
    if (cleared.isNotEmpty) {
      onAnnotationsClear?.call(cleared);
    }
    notifyListeners();
  }

  /// Copies all collected annotations to the system clipboard.
  Future<String?> copyToClipboard({
    dynamic format,
    OutputDetailLevel? detailLevel,
    bool prettyJson = true,
  }) {
    final ExportFormat? exportFmt;
    if (format is CopyFormat) {
      exportFmt = _mapCopyFormatToExportFormat(format);
    } else if (format is ExportFormat) {
      exportFmt = format;
    } else {
      exportFmt = null;
    }
    return exportAnnotations(
      format: exportFmt,
      detailLevel: detailLevel,
      prettyJson: prettyJson,
    );
  }

  /// Updates toolbar offset position.
  void updateToolbarOffset(Offset newOffset) {
    if (_state.toolbarOffset == newOffset) return;
    _state = _state.copyWith(
      toolbarOffset: newOffset,
    );
    notifyListeners();
  }

  /// Updates toolbar bounding box on screen.
  void updateToolbarBounds(Rect? newBounds) {
    if (_state.toolbarBounds == newBounds) return;
    _state = _state.copyWith(
      toolbarBounds: () => newBounds,
    );
    notifyListeners();
  }

  /// Sets toolbar minimized state. When minimized/collapsed, inspection is paused/inactive.
  /// When expanded, inspection is activated/enabled.
  void setToolbarMinimized(bool minimized) {
    if (_state.isToolbarMinimized == minimized &&
        (minimized ? _state.isInactive : _state.isInspecting)) {
      return;
    }
    if (minimized) {
      _state = _state.copyWith(
        isToolbarMinimized: true,
        mode: InspectionMode.inactive,
        isFrozen: false,
        isSettingsOpen: false,
        isLayoutModeOpen: false,
        selectedResult: () => null,
        hoveredResult: () => null,
        activeHierarchy: () => null,
      );
      _multiSelection = [];
      _activeAnnotation = null;
    } else {
      _state = _state.copyWith(
        isToolbarMinimized: false,
        mode: InspectionMode.inspecting,
      );
    }
    notifyListeners();
  }

  /// Toggles toolbar minimized state.
  void toggleToolbarMinimized() {
    setToolbarMinimized(!_state.isToolbarMinimized);
  }

  /// Toggles visibility of comments and annotation pins on the page.
  void toggleCommentsVisibility() {
    _state = _state.copyWith(
      areCommentsVisible: !_state.areCommentsVisible,
    );
    notifyListeners();
  }

  /// Sets visibility of comments and annotation pins on the page.
  void setCommentsVisibility(bool visible) {
    if (_state.areCommentsVisible == visible) return;
    _state = _state.copyWith(
      areCommentsVisible: visible,
    );
    notifyListeners();
  }

  /// Sets settings panel open state.
  void setSettingsOpen(bool open) {
    if (_state.isSettingsOpen == open) return;
    _state = _state.copyWith(
      isSettingsOpen: open,
      isLayoutModeOpen: open ? false : _state.isLayoutModeOpen,
    );
    notifyListeners();
  }

  /// Opens the settings panel.
  void openSettings() => setSettingsOpen(true);

  /// Closes the settings panel.
  void closeSettings() => setSettingsOpen(false);

  /// Toggles settings panel open state.
  void toggleSettings() => setSettingsOpen(!_state.isSettingsOpen);

  /// Sets layout mode / component palette open state.
  void setLayoutModeOpen(bool open) {
    if (_state.isLayoutModeOpen == open) return;
    _state = _state.copyWith(
      isLayoutModeOpen: open,
      isSettingsOpen: open ? false : _state.isSettingsOpen,
      toolMode: open ? AnnotationToolMode.design : AnnotationToolMode.pointer,
    );
    if (open) {
      clearSelection();
      if (!_state.isInspecting) {
        activate();
      }
    }
    notifyListeners();
  }

  /// Opens layout mode.
  void openLayoutMode() => setLayoutModeOpen(true);

  /// Closes layout mode.
  void closeLayoutMode() => setLayoutModeOpen(false);

  /// Toggles layout mode open state.
  void toggleLayoutMode() => setLayoutModeOpen(!_state.isLayoutModeOpen);

  Timer? _copyTimer;

  /// Copies formatted annotations output to clipboard and triggers [onCopy].
  Future<String> copyFeedback() async {
    isCopiedNotifier.value = true;
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(milliseconds: 1500), () {
      isCopiedNotifier.value = false;
    });

    final markdown = await exportAnnotations(format: ExportFormat.markdown) ?? '';
    if (shouldCopyToClipboard && markdown.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: markdown));
    }
    onCopy?.call(markdown);
    if (settings.autoClearAfterCopy) {
      await clearAnnotations();
    }
    return markdown;
  }

  @override
  void dispose() {
    _copyTimer?.cancel();
    isCopiedNotifier.dispose();
    super.dispose();
  }
}
