import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'agentation_controller.dart';
import 'agentation_scope.dart';
import 'agentation_state.dart';

/// Intent to delete the currently active / selected annotation or comment.
class DeleteAnnotationIntent extends Intent {
  const DeleteAnnotationIntent();
}

/// Intent to close or dismiss the active annotation popup, detail card, or selection.
class CloseAnnotationIntent extends Intent {
  const CloseAnnotationIntent();
}

/// Intent to submit and save the active annotation popup or thread reply.
class SubmitAnnotationIntent extends Intent {
  const SubmitAnnotationIntent();
}

/// Intent to toggle inspection mode / animation freeze.
class ToggleInspectIntent extends Intent {
  const ToggleInspectIntent();
}

/// Intent to toggle visibility of comments and markers on the page ('H').
class ToggleCommentsVisibilityIntent extends Intent {
  const ToggleCommentsVisibilityIntent();
}

/// Intent to toggle feedback mode ('Cmd+Shift+F' / 'Ctrl+Shift+F').
class ToggleFeedbackModeIntent extends Intent {
  const ToggleFeedbackModeIntent();
}

/// Intent to toggle animation pause/freeze ('P').
class PauseAnimationsIntent extends Intent {
  const PauseAnimationsIntent();
}

/// Intent to toggle layout / design mode ('L').
class ToggleLayoutModeIntent extends Intent {
  const ToggleLayoutModeIntent();
}

/// Intent to copy feedback markdown output ('C').
class CopyFeedbackIntent extends Intent {
  const CopyFeedbackIntent();
}

/// Intent to clear all annotations on page ('X').
class ClearAllAnnotationsIntent extends Intent {
  const ClearAllAnnotationsIntent();
}

/// Intent to send annotations to webhook ('S').
class SendAnnotationsIntent extends Intent {
  const SendAnnotationsIntent();
}

/// Intent to undo the last annotation created ('Cmd+Z' / 'Ctrl+Z').
class UndoAnnotationIntent extends Intent {
  const UndoAnnotationIntent();
}

/// Intent to redo the last undone annotation ('Cmd+Shift+Z' / 'Ctrl+Shift+Z' / 'Ctrl+Y').
class RedoAnnotationIntent extends Intent {
  const RedoAnnotationIntent();
}

/// Configurable keyboard shortcut mapping for Agentation overlay actions matching official upstream specs.
class AgentationKeymap {
  const AgentationKeymap({
    this.toggleFeedbackKeys = const [
      SingleActivator(LogicalKeyboardKey.keyF, meta: true, shift: true),
      SingleActivator(LogicalKeyboardKey.keyF, control: true, shift: true),
    ],
    this.closeKeys = const [
      SingleActivator(LogicalKeyboardKey.escape),
    ],
    this.pauseKeys = const [
      SingleActivator(LogicalKeyboardKey.keyP),
    ],
    this.layoutKeys = const [
      SingleActivator(LogicalKeyboardKey.keyL),
    ],
    this.toggleCommentsKeys = const [
      SingleActivator(LogicalKeyboardKey.keyH),
      SingleActivator(LogicalKeyboardKey.keyV, alt: true),
    ],
    this.copyKeys = const [
      SingleActivator(LogicalKeyboardKey.keyC),
    ],
    this.sendKeys = const [
      SingleActivator(LogicalKeyboardKey.keyS),
    ],
    this.clearKeys = const [
      SingleActivator(LogicalKeyboardKey.keyX),
    ],
    this.deleteKeys = const [
      SingleActivator(LogicalKeyboardKey.delete),
      SingleActivator(LogicalKeyboardKey.backspace),
    ],
    this.submitKeys = const [
      SingleActivator(LogicalKeyboardKey.enter, control: true),
      SingleActivator(LogicalKeyboardKey.enter, meta: true),
    ],
    this.toggleInspectKeys = const [
      SingleActivator(LogicalKeyboardKey.keyI, alt: true),
    ],
    this.undoKeys = const [
      SingleActivator(LogicalKeyboardKey.keyZ, control: true),
      SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
    ],
    this.redoKeys = const [
      SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true),
      SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true),
      SingleActivator(LogicalKeyboardKey.keyY, control: true),
      SingleActivator(LogicalKeyboardKey.keyY, meta: true),
    ],
  });

  /// Shortcuts to toggle feedback mode (minimize/expand toolbar).
  final List<ShortcutActivator> toggleFeedbackKeys;

  /// Shortcuts to close/cancel active menu, modal, or toolbar (Escape).
  final List<ShortcutActivator> closeKeys;

  /// Shortcuts to pause/resume animations (P).
  final List<ShortcutActivator> pauseKeys;

  /// Shortcuts to toggle layout mode (L).
  final List<ShortcutActivator> layoutKeys;

  /// Shortcuts to toggle comments/markers visibility (H).
  final List<ShortcutActivator> toggleCommentsKeys;

  /// Shortcuts to copy feedback (C).
  final List<ShortcutActivator> copyKeys;

  /// Shortcuts to send annotations (S).
  final List<ShortcutActivator> sendKeys;

  /// Shortcuts to clear all annotations (X).
  final List<ShortcutActivator> clearKeys;

  /// Shortcuts to delete the selected annotation.
  final List<ShortcutActivator> deleteKeys;

  /// Shortcuts to submit active note or reply.
  final List<ShortcutActivator> submitKeys;

  /// Shortcuts to toggle inspect mode (legacy Alt+I).
  final List<ShortcutActivator> toggleInspectKeys;

  /// Shortcuts to undo last annotation.
  final List<ShortcutActivator> undoKeys;

  /// Shortcuts to redo undone annotation.
  final List<ShortcutActivator> redoKeys;

  /// Converts this keymap into a standard Flutter [Map<ShortcutActivator, Intent>].
  Map<ShortcutActivator, Intent> toShortcutsMap() {
    final map = <ShortcutActivator, Intent>{};
    for (final k in toggleFeedbackKeys) {
      map[k] = const ToggleFeedbackModeIntent();
    }
    for (final k in closeKeys) {
      map[k] = const CloseAnnotationIntent();
    }
    for (final k in pauseKeys) {
      map[k] = const PauseAnimationsIntent();
    }
    for (final k in layoutKeys) {
      map[k] = const ToggleLayoutModeIntent();
    }
    for (final k in toggleCommentsKeys) {
      map[k] = const ToggleCommentsVisibilityIntent();
    }
    for (final k in copyKeys) {
      map[k] = const CopyFeedbackIntent();
    }
    for (final k in sendKeys) {
      map[k] = const SendAnnotationsIntent();
    }
    for (final k in clearKeys) {
      map[k] = const ClearAllAnnotationsIntent();
    }
    for (final k in deleteKeys) {
      map[k] = const DeleteAnnotationIntent();
    }
    for (final k in submitKeys) {
      map[k] = const SubmitAnnotationIntent();
    }
    for (final k in toggleInspectKeys) {
      map[k] = const ToggleInspectIntent();
    }
    for (final k in undoKeys) {
      map[k] = const UndoAnnotationIntent();
    }
    for (final k in redoKeys) {
      map[k] = const RedoAnnotationIntent();
    }
    return map;
  }
}

/// Widget providing keyboard shortcut handling and keymap routing for Agentation.
///
/// Implements full parity with the official Agentation keyboard specifications:
/// - **Cmd+Shift+F / Ctrl+Shift+F**: Toggle feedback mode (works when closed or open).
/// - **Escape**: Closes topmost open layer (Settings panel -> Layout mode -> Draw mode -> Selection -> Toolbar).
/// - **P**: Pause / resume animations (single-key, while toolbar is open).
/// - **L**: Toggle layout mode (single-key, while toolbar is open).
/// - **H**: Hide / show markers (single-key, while annotations exist).
/// - **C**: Copy feedback (single-key, while annotations exist).
/// - **X**: Clear all annotations (single-key, while annotations exist).
/// - **S**: Send annotations (single-key, when canSend is true).
/// - **Delete / Backspace**: Deletes the currently selected comment on the page.
/// - **Ctrl+Enter / Cmd+Enter**: Submits the open annotation popup note or reply.
/// - **Ctrl+Z / Cmd+Z**: Undoes last annotation.
/// - **Ctrl+Shift+Z / Cmd+Shift+Z / Ctrl+Y**: Redoes annotation.
class AgentationShortcuts extends StatefulWidget {
  const AgentationShortcuts({
    super.key,
    required this.child,
    this.controller,
    this.keymap = const AgentationKeymap(),
    this.onDeleteSelected,
    this.onClose,
    this.onSubmit,
  });

  final Widget child;
  final AgentationController? controller;
  final AgentationKeymap keymap;
  final VoidCallback? onDeleteSelected;
  final VoidCallback? onClose;
  final VoidCallback? onSubmit;

  /// Checks if primary keyboard focus currently resides in an editable text field.
  static bool isEditingText() {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return false;
    final context = primaryFocus.context;
    if (context == null) return false;
    if (context.widget is EditableText) return true;
    if (context.findAncestorWidgetOfExactType<EditableText>() != null) return true;
    if (context.findAncestorWidgetOfExactType<TextField>() != null) return true;
    if (context.findAncestorStateOfType<EditableTextState>() != null) return true;

    // Check if the focused element has an EditableText in its descendant subtree
    Element? editableElement;
    void visitor(Element element) {
      if (editableElement != null) return;
      if (element.widget is EditableText) {
        editableElement = element;
        return;
      }
      element.visitChildren(visitor);
    }
    context.visitChildElements(visitor);
    return editableElement != null;
  }

  @override
  State<AgentationShortcuts> createState() => _AgentationShortcutsState();
}

class _AgentationShortcutsState extends State<AgentationShortcuts> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'AgentationShortcutsFocus');
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    _focusNode.dispose();
    super.dispose();
  }

  AgentationController get _ctrl =>
      widget.controller ?? AgentationScope.of(context);

  bool _handleHardwareKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final ctrl = _ctrl;
    if (!ctrl.enableKeyboardShortcuts) return false;

    final key = event.logicalKey;
    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    final isMeta = HardwareKeyboard.instance.isMetaPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    final isAlt = HardwareKeyboard.instance.isAltPressed;

    // ── 1. Escape: Close topmost layer matching upstream Agentation ──
    if (key == LogicalKeyboardKey.escape) {
      return _handleClose();
    }

    // ── 2. Cmd+Shift+F / Ctrl+Shift+F: Toggle feedback mode (expanded vs collapsed) ──
    if ((isCtrl || isMeta) && isShift && key == LogicalKeyboardKey.keyF) {
      ctrl.toggleToolbarMinimized();
      return true;
    }

    // ── 3. Ctrl+Enter / Cmd+Enter: Submit active note or reply ──
    if ((isCtrl || isMeta) && key == LogicalKeyboardKey.enter) {
      if (widget.onSubmit != null) {
        widget.onSubmit!();
        return true;
      }
    }

    // ── 4. Undo / Redo: Cmd+Z / Ctrl+Z / Ctrl+Y ──
    if ((isCtrl || isMeta) && key == LogicalKeyboardKey.keyZ) {
      if (isShift) {
        ctrl.redo();
      } else {
        ctrl.undo();
      }
      return true;
    }
    if ((isCtrl || isMeta) && key == LogicalKeyboardKey.keyY) {
      ctrl.redo();
      return true;
    }

    // ── 5. Alt+I / Alt+V (legacy shortcuts) ──
    if (isAlt && key == LogicalKeyboardKey.keyI) {
      ctrl.toggleToolbarMinimized();
      return true;
    }
    if (isAlt && key == LogicalKeyboardKey.keyV) {
      ctrl.toggleCommentsVisibility();
      return true;
    }

    // ── 6. Single-key shortcuts belong to the expanded toolbar ──
    // In upstream: Skip when collapsed, when typing in an input field, or when modifier keys are held.
    final isTyping = AgentationShortcuts.isEditingText();
    if (ctrl.isToolbarMinimized || isTyping || isCtrl || isMeta || isAlt) {
      return false;
    }

    if (event.synthesized) return false;

    // "P" -> Toggle pause / resume animations
    if (key == LogicalKeyboardKey.keyP) {
      ctrl.toggleFreeze();
      return true;
    }

    // "L" -> Toggle layout mode
    if (key == LogicalKeyboardKey.keyL) {
      ctrl.toggleLayoutMode();
      return true;
    }

    // "H" -> Toggle markers visibility
    if (key == LogicalKeyboardKey.keyH) {
      if (ctrl.annotations.isNotEmpty) {
        ctrl.toggleCommentsVisibility();
        return true;
      }
      return false;
    }

    // "C" -> Copy feedback
    if (key == LogicalKeyboardKey.keyC) {
      if (ctrl.annotations.isNotEmpty) {
        ctrl.copyFeedback();
        return true;
      }
      return false;
    }

    // "X" -> Clear all annotations
    if (key == LogicalKeyboardKey.keyX) {
      if (ctrl.annotations.isNotEmpty) {
        ctrl.clearAnnotations();
        return true;
      }
      return false;
    }

    // "S" -> Send annotations
    if (key == LogicalKeyboardKey.keyS) {
      if (ctrl.annotations.isNotEmpty && ctrl.canSend) {
        ctrl.submitAnnotations();
        return true;
      }
      return false;
    }

    // Delete / Backspace -> Delete selected comment
    if (key == LogicalKeyboardKey.delete || key == LogicalKeyboardKey.backspace) {
      return _handleDelete();
    }

    return false;
  }

  bool _handleDelete() {
    if (widget.onDeleteSelected != null) {
      widget.onDeleteSelected!();
      return true;
    }

    final ctrl = _ctrl;
    if (ctrl.activeAnnotation != null) {
      final id = ctrl.activeAnnotation!.id;
      ctrl.deleteAnnotation(id);
      return true;
    }

    if (ctrl.selectedResult != null) {
      ctrl.clearSelection();
      return true;
    }

    return false;
  }

  bool _handleClose() {
    final ctrl = _ctrl;

    // 1. If Settings panel is open -> close settings panel (toolbar stays open)
    if (ctrl.isSettingsOpen) {
      ctrl.closeSettings();
      return true;
    }

    // 2. If Layout mode is open -> close layout mode (toolbar stays open)
    if (ctrl.isLayoutModeOpen) {
      ctrl.closeLayoutMode();
      return true;
    }

    // 3. If Draw mode is active -> exit draw mode
    if (ctrl.toolMode == AnnotationToolMode.draw) {
      ctrl.setToolMode(AnnotationToolMode.pointer);
      return true;
    }

    // 4. If multi-selection is active -> clear multi-selection
    if (ctrl.multiSelection.isNotEmpty) {
      ctrl.clearMultiSelection();
      return true;
    }

    // 5. If active annotation is open for viewing -> dismiss detail card
    if (ctrl.activeAnnotation != null) {
      ctrl.viewAnnotation(null);
      return true;
    }

    // 6. If selected result / inspector selection is active -> clear selection
    if (ctrl.selectedResult != null) {
      ctrl.clearSelection();
      return true;
    }

    // 7. If custom onClose callback provided -> execute it
    if (widget.onClose != null) {
      widget.onClose!();
      return true;
    }

    // 8. Otherwise, if toolbar is open -> close / minimize toolbar
    if (!ctrl.isToolbarMinimized) {
      ctrl.setToolbarMinimized(true);
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = widget.keymap.toShortcutsMap();

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: {
          ToggleFeedbackModeIntent: CallbackAction<ToggleFeedbackModeIntent>(
            onInvoke: (_) {
              _ctrl.toggleToolbarMinimized();
              return null;
            },
          ),
          CloseAnnotationIntent: CallbackAction<CloseAnnotationIntent>(
            onInvoke: (_) => _handleClose(),
          ),
          PauseAnimationsIntent: CallbackAction<PauseAnimationsIntent>(
            onInvoke: (_) {
              if (AgentationShortcuts.isEditingText() || _ctrl.isToolbarMinimized) return null;
              _ctrl.toggleFreeze();
              return null;
            },
          ),
          ToggleLayoutModeIntent: CallbackAction<ToggleLayoutModeIntent>(
            onInvoke: (_) {
              if (AgentationShortcuts.isEditingText() || _ctrl.isToolbarMinimized) return null;
              _ctrl.toggleLayoutMode();
              return null;
            },
          ),
          ToggleCommentsVisibilityIntent: CallbackAction<ToggleCommentsVisibilityIntent>(
            onInvoke: (_) {
              if (AgentationShortcuts.isEditingText() || _ctrl.isToolbarMinimized) return null;
              if (_ctrl.annotations.isNotEmpty) {
                _ctrl.toggleCommentsVisibility();
              }
              return null;
            },
          ),
          CopyFeedbackIntent: CallbackAction<CopyFeedbackIntent>(
            onInvoke: (_) {
              if (AgentationShortcuts.isEditingText() || _ctrl.isToolbarMinimized) return null;
              if (_ctrl.annotations.isNotEmpty) {
                _ctrl.copyFeedback();
              }
              return null;
            },
          ),
          ClearAllAnnotationsIntent: CallbackAction<ClearAllAnnotationsIntent>(
            onInvoke: (_) {
              if (AgentationShortcuts.isEditingText() || _ctrl.isToolbarMinimized) return null;
              if (_ctrl.annotations.isNotEmpty) {
                _ctrl.clearAnnotations();
              }
              return null;
            },
          ),
          SendAnnotationsIntent: CallbackAction<SendAnnotationsIntent>(
            onInvoke: (_) {
              if (AgentationShortcuts.isEditingText() || _ctrl.isToolbarMinimized) return null;
              if (_ctrl.annotations.isNotEmpty && _ctrl.canSend) {
                _ctrl.submitAnnotations();
              }
              return null;
            },
          ),
          DeleteAnnotationIntent: CallbackAction<DeleteAnnotationIntent>(
            onInvoke: (_) {
              if (AgentationShortcuts.isEditingText()) return null;
              return _handleDelete();
            },
          ),
          SubmitAnnotationIntent: CallbackAction<SubmitAnnotationIntent>(
            onInvoke: (_) {
              widget.onSubmit?.call();
              return null;
            },
          ),
          ToggleInspectIntent: CallbackAction<ToggleInspectIntent>(
            onInvoke: (_) {
              _ctrl.toggleToolbarMinimized();
              return null;
            },
          ),
          UndoAnnotationIntent: CallbackAction<UndoAnnotationIntent>(
            onInvoke: (_) {
              _ctrl.undo();
              return null;
            },
          ),
          RedoAnnotationIntent: CallbackAction<RedoAnnotationIntent>(
            onInvoke: (_) {
              _ctrl.redo();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          canRequestFocus: true,
          child: widget.child,
        ),
      ),
    );
  }
}
