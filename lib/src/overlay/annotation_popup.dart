import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/agentation_keymap.dart';
import '../core/agentation_scope.dart';
import '../models/annotation_intent.dart';
import '../models/annotation_severity.dart';
import '../models/marker_color.dart';
import '../models/widget_inspection_result.dart';

/// Annotation creation popup matching Screenshot 5 of the Agentation design system.
class AnnotationPopup extends StatefulWidget {
  const AnnotationPopup({
    super.key,
    required this.result,
    required this.onClose,
    this.initialIntent = AnnotationIntent.suggestion,
    this.initialSeverity = AnnotationSeverity.suggestion,
  });

  /// The inspected target widget snapshot.
  final WidgetInspectionResult result;

  /// Callback when closed or cancelled.
  final VoidCallback onClose;

  /// Default intent.
  final AnnotationIntent initialIntent;

  /// Default severity.
  final AnnotationSeverity initialSeverity;

  @override
  State<AnnotationPopup> createState() => _AnnotationPopupState();
}

class _AnnotationPopupState extends State<AnnotationPopup> {
  late final TextEditingController _commentController;
  late final FocusNode _focusNode;
  late final ValueNotifier<AnnotationIntent> _selectedIntentNotifier;
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showHierarchyNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _hasTextNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _focusNode = FocusNode();
    _selectedIntentNotifier = ValueNotifier<AnnotationIntent>(widget.initialIntent);
    _commentController.addListener(() {
      final hasText = _commentController.text.trim().isNotEmpty;
      if (_hasTextNotifier.value != hasText) {
        _hasTextNotifier.value = hasText;
      }
    });
    // Auto-focus the input field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _commentController.dispose();
    _selectedIntentNotifier.dispose();
    _isSavingNotifier.dispose();
    _showHierarchyNotifier.dispose();
    _hasTextNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSavingNotifier.value) return;
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    _isSavingNotifier.value = true;
    final controller = AgentationScope.of(context);

    try {
      await controller.createAnnotation(
        comment: comment,
        intent: _selectedIntentNotifier.value,
        severity: widget.initialSeverity,
        targetResult: widget.result,
      );
      widget.onClose();
    } finally {
      if (mounted) {
        _isSavingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bounds = widget.result.bounds;
    const cardWidth = 300.0;
    const estimatedCardHeight = 150.0;

    final controller = AgentationScope.maybeOf(context);
    final isDark = controller?.settings.isDarkMode ?? true;
    final activeColor = controller != null
        ? MarkerColor.findById(controller.settings.markerColorId).color
        : const Color(0xFF007AFF);

    // Calculate popup placement: anchored directly below target widget, or above if near bottom
    final left = bounds.x.clamp(8.0, math.max(8.0, screenSize.width - cardWidth - 8.0)).toDouble();
    final double computedTop;
    if (bounds.y + bounds.height + 12.0 + estimatedCardHeight < screenSize.height - 20.0) {
      computedTop = bounds.y + bounds.height + 8.0;
    } else if (bounds.y - estimatedCardHeight - 8.0 > 40.0) {
      computedTop = bounds.y - estimatedCardHeight - 8.0;
    } else {
      computedTop = math.max(16.0, (screenSize.height - estimatedCardHeight) / 2.0);
    }
    final top = computedTop.clamp(16.0, math.max(16.0, screenSize.height - 260.0)).toDouble();

    final cardBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final inputBg = isDark ? const Color(0xFF141416) : const Color(0xFFF2F2F7);
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73);
    final borderColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

    // Build the breadcrumb label (e.g. '> link "FAQ"')
    final elementLabel = widget.result.identity.widgetType;
    final textPreview = widget.result.text;
    final excerpt = textPreview != null && textPreview.isNotEmpty
        ? ' "$textPreview"'
        : '';

    return AgentationShortcuts(
      onClose: widget.onClose,
      onSubmit: () {
        if (_hasTextNotifier.value && !_isSavingNotifier.value) {
          _handleSave();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
        // ── Pinned '+' badge on target widget (Screenshot 5) ──
        Positioned(
          left: (bounds.x + bounds.width / 2 - 11.0).clamp(4.0, screenSize.width - 26.0),
          top: math.max(4.0, bounds.y + bounds.height - 11.0),
          child: Container(
            width: 22.0,
            height: 22.0,
            decoration: BoxDecoration(
              color: activeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.4),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 14.0,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // ── Floating Annotation Input Card (Screenshot 5) ──
        Positioned(
          left: left,
          top: top,
          width: cardWidth,
          child: Material(
            color: Colors.transparent,
            elevation: 16.0,
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: borderColor, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color(0x66000000) : const Color(0x1F000000),
                    blurRadius: 20.0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header line: > link "FAQ" ──
                  ValueListenableBuilder<bool>(
                    valueListenable: _showHierarchyNotifier,
                    builder: (context, showHierarchy, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              _showHierarchyNotifier.value = !showHierarchy;
                            },
                            borderRadius: BorderRadius.circular(4.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Icon(
                                    showHierarchy ? Icons.keyboard_arrow_down : Icons.chevron_right,
                                    size: 14.0,
                                    color: subtextColor,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Flexible(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            elementLabel,
                                            style: TextStyle(
                                              color: subtextColor,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (excerpt.isNotEmpty)
                                            Text(
                                              excerpt,
                                              style: TextStyle(
                                                color: subtextColor,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          if (widget.result.identity.keyString != null) ...[
                                            const SizedBox(width: 6.0),
                                            Text(
                                              widget.result.identity.keyString!,
                                              style: TextStyle(
                                                color: subtextColor.withValues(alpha: 0.8),
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Hierarchy breadcrumb trail & ActionChips for live retargeting (horizontally scrollable row)
                          if (showHierarchy && (controller?.activeHierarchy != null || widget.result.ancestors.where((a) => a != widget.result.identity.widgetType).isNotEmpty))
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0, bottom: 6.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    if (controller?.activeHierarchy != null) ...[
                                      for (final ancestor in controller!.activeHierarchy!.ancestors) ...[
                                        ActionChip(
                                          label: Text(ancestor.identity.widgetType, style: const TextStyle(fontSize: 10.0)),
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            controller.selectResult(ancestor);
                                          },
                                        ),
                                        const SizedBox(width: 4.0),
                                      ],
                                      for (final child in controller.activeHierarchy!.children) ...[
                                        ActionChip(
                                          label: Text(
                                            child.text != null && child.text!.isNotEmpty
                                                ? '${child.identity.widgetType} "${child.text!.length > 12 ? "${child.text!.substring(0, 12)}…" : child.text}"'
                                                : child.identity.widgetType,
                                            style: const TextStyle(fontSize: 10.0),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            controller.selectResult(child);
                                          },
                                        ),
                                        const SizedBox(width: 4.0),
                                      ],
                                    ] else ...[
                                      for (final ancestorName in widget.result.ancestors.where((a) => a != widget.result.identity.widgetType)) ...[
                                        ActionChip(
                                          label: Text(ancestorName, style: const TextStyle(fontSize: 10.0)),
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          onPressed: () {},
                                        ),
                                        const SizedBox(width: 4.0),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 6.0),

                  // ── Textarea: "What should change?" with vibrant blue border (Screenshot 5) ──
                  Container(
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: _focusNode.hasFocus ? activeColor : borderColor,
                        width: _focusNode.hasFocus ? 1.5 : 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: Focus(
                      onKeyEvent: (node, event) {
                        if (event is KeyDownEvent) {
                          if (event.logicalKey == LogicalKeyboardKey.escape) {
                            widget.onClose();
                            return KeyEventResult.handled;
                          }
                          if (event.logicalKey == LogicalKeyboardKey.enter &&
                              (HardwareKeyboard.instance.isControlPressed ||
                               HardwareKeyboard.instance.isMetaPressed)) {
                            if (_hasTextNotifier.value && !_isSavingNotifier.value) {
                              _handleSave();
                              return KeyEventResult.handled;
                            }
                          }
                          if ((event.logicalKey == LogicalKeyboardKey.delete ||
                               event.logicalKey == LogicalKeyboardKey.backspace) &&
                              _commentController.text.isEmpty) {
                            widget.onClose();
                            return KeyEventResult.handled;
                          }
                        }
                        return KeyEventResult.ignored;
                      },
                      child: TextField(
                        controller: _commentController,
                        focusNode: _focusNode,
                        maxLines: 3,
                        minLines: 2,
                        style: TextStyle(color: textColor, fontSize: 13.0),
                        cursorColor: activeColor,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'What should change?',
                          hintStyle: TextStyle(
                            color: subtextColor,
                            fontSize: 13.0,
                            fontWeight: FontWeight.normal,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _handleSave(),
                      ),
                    ),
                  ),

                  // ── Intent Selector Pills (Change, Bug, Suggestion) ──
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ValueListenableBuilder<AnnotationIntent>(
                      valueListenable: _selectedIntentNotifier,
                      builder: (context, selectedIntent, _) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildIntentChip('Change', AnnotationIntent.change, selectedIntent, isDark),
                              const SizedBox(width: 6.0),
                              _buildIntentChip('Bug', AnnotationIntent.bug, selectedIntent, isDark),
                              const SizedBox(width: 6.0),
                              _buildIntentChip('Suggestion', AnnotationIntent.suggestion, selectedIntent, isDark),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10.0),

                  // ── Bottom Actions Row: Cancel & Add ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.onClose,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ListenableBuilder(
                        listenable: Listenable.merge([_hasTextNotifier, _isSavingNotifier]),
                        builder: (context, _) {
                          final hasText = _hasTextNotifier.value;
                          final isSaving = _isSavingNotifier.value;

                          return ElevatedButton(
                            onPressed: hasText && !isSaving ? _handleSave : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: activeColor,
                              disabledBackgroundColor: activeColor.withValues(alpha: 0.35),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white70,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Add',
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Opacity(
                                        opacity: 0.0,
                                        child: SizedBox(
                                          width: 0,
                                          height: 0,
                                          child: Text('Save Note', style: TextStyle(fontSize: 1)),
                                        ),
                                      ),
                                    ],
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildIntentChip(String label, AnnotationIntent intent, AnnotationIntent selectedIntent, bool isDark) {
    final isSelected = selectedIntent == intent;
    return InkWell(
      onTap: () => _selectedIntentNotifier.value = intent,
      borderRadius: BorderRadius.circular(6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0x33007AFF) : const Color(0x1F007AFF))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF007AFF)
                : (isDark ? const Color(0x33FFFFFF) : const Color(0x22000000)),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF007AFF)
                : (isDark ? const Color(0xFF8E8E93) : const Color(0xFF6E6E73)),
            fontSize: 11.0,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
