import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'agentation_controller.dart';
import 'agentation_scope.dart';

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

/// Intent to toggle visibility of comments and markers on the page.
class ToggleCommentsVisibilityIntent extends Intent {
  const ToggleCommentsVisibilityIntent();
}

/// Intent to undo the last annotation created.
class UndoAnnotationIntent extends Intent {
  const UndoAnnotationIntent();
}

/// Intent to redo the last undone annotation.
class RedoAnnotationIntent extends Intent {
  const RedoAnnotationIntent();
}

/// Configurable keyboard shortcut mapping for Agentation overlay actions.
class AgentationKeymap {
  const AgentationKeymap({
    this.deleteKeys = const [
      SingleActivator(LogicalKeyboardKey.delete),
      SingleActivator(LogicalKeyboardKey.backspace),
    ],
    this.closeKeys = const [
      SingleActivator(LogicalKeyboardKey.escape),
    ],
    this.submitKeys = const [
      SingleActivator(LogicalKeyboardKey.enter, control: true),
      SingleActivator(LogicalKeyboardKey.enter, meta: true),
    ],
    this.toggleInspectKeys = const [
      SingleActivator(LogicalKeyboardKey.keyI, alt: true),
    ],
    this.toggleCommentsKeys = const [
      SingleActivator(LogicalKeyboardKey.keyV, alt: true),
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

  /// Shortcuts to delete the selected annotation.
  final List<ShortcutActivator> deleteKeys;

  /// Shortcuts to close/cancel active popup or detail card.
  final List<ShortcutActivator> closeKeys;

  /// Shortcuts to submit active note or reply.
  final List<ShortcutActivator> submitKeys;

  /// Shortcuts to toggle inspect mode.
  final List<ShortcutActivator> toggleInspectKeys;

  /// Shortcuts to toggle comments visibility on page.
  final List<ShortcutActivator> toggleCommentsKeys;

  /// Shortcuts to undo last annotation.
  final List<ShortcutActivator> undoKeys;

  /// Shortcuts to redo undone annotation.
  final List<ShortcutActivator> redoKeys;

  /// Converts this keymap into a standard Flutter [Map<ShortcutActivator, Intent>].
  Map<ShortcutActivator, Intent> toShortcutsMap() {
    final map = <ShortcutActivator, Intent>{};
    for (final k in deleteKeys) {
      map[k] = const DeleteAnnotationIntent();
    }
    for (final k in closeKeys) {
      map[k] = const CloseAnnotationIntent();
    }
    for (final k in submitKeys) {
      map[k] = const SubmitAnnotationIntent();
    }
    for (final k in toggleInspectKeys) {
      map[k] = const ToggleInspectIntent();
    }
    for (final k in toggleCommentsKeys) {
      map[k] = const ToggleCommentsVisibilityIntent();
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
/// Handles:
/// - **Delete / Backspace**: Deletes the currently selected comment on the page (when not editing text).
/// - **Escape**: Closes active popup, dismisses detail card, or deselects comment.
/// - **Ctrl+Enter / Cmd+Enter**: Submits the open annotation popup note or reply.
/// - **Alt+I**: Toggles inspection mode.
/// - **Alt+V**: Toggles comment markers visibility.
/// - **Ctrl+Z / Cmd+Z**: Undoes last annotation.
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
    return context.widget is EditableText ||
        context.findAncestorWidgetOfExactType<EditableText>() != null;
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

    // Do not intercept if user is actively typing in a text field
    if (AgentationShortcuts.isEditingText()) {
      // Allow Ctrl+Enter or Cmd+Enter to submit even inside a text field
      if (event.logicalKey == LogicalKeyboardKey.enter &&
          (HardwareKeyboard.instance.isControlPressed ||
           HardwareKeyboard.instance.isMetaPressed)) {
        if (widget.onSubmit != null) {
          widget.onSubmit!();
          return true;
        }
      }
      // Allow Escape to dismiss even inside a text field
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _handleClose();
        return true;
      }
      return false;
    }

    final key = event.logicalKey;

    // 1. Delete / Backspace -> Delete selected comment
    if (key == LogicalKeyboardKey.delete || key == LogicalKeyboardKey.backspace) {
      return _handleDelete();
    }

    // 2. Escape -> Close popup / deselect comment
    if (key == LogicalKeyboardKey.escape) {
      return _handleClose();
    }

    // 3. Alt+I -> Toggle inspect / toolbar minimize
    if (key == LogicalKeyboardKey.keyI && HardwareKeyboard.instance.isAltPressed) {
      _ctrl.toggleToolbarMinimized();
      return true;
    }

    // 4. Alt+V -> Toggle comments visibility
    if (key == LogicalKeyboardKey.keyV && HardwareKeyboard.instance.isAltPressed) {
      _ctrl.toggleCommentsVisibility();
      return true;
    }

    // 5. Ctrl+Z / Cmd+Z -> Undo / Redo
    if (key == LogicalKeyboardKey.keyZ &&
        (HardwareKeyboard.instance.isControlPressed ||
         HardwareKeyboard.instance.isMetaPressed)) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        _ctrl.redo();
      } else {
        _ctrl.undo();
      }
      return true;
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
    if (widget.onClose != null) {
      widget.onClose!();
      return true;
    }

    final ctrl = _ctrl;
    if (ctrl.selectedResult != null) {
      ctrl.clearSelection();
      return true;
    }

    if (ctrl.activeAnnotation != null) {
      ctrl.viewAnnotation(null);
      return true;
    }

    if (ctrl.isInspecting) {
      ctrl.deactivate();
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
          DeleteAnnotationIntent: CallbackAction<DeleteAnnotationIntent>(
            onInvoke: (_) => _handleDelete(),
          ),
          CloseAnnotationIntent: CallbackAction<CloseAnnotationIntent>(
            onInvoke: (_) => _handleClose(),
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
          ToggleCommentsVisibilityIntent: CallbackAction<ToggleCommentsVisibilityIntent>(
            onInvoke: (_) {
              _ctrl.toggleCommentsVisibility();
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
