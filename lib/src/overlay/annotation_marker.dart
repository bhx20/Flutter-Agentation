import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/agentation_scope.dart';
import '../models/annotation.dart';
import '../models/widget_bounds.dart';

/// Formats a Flutter widget type name into a clean, human-readable label
/// (e.g. 'ListTile' -> 'list item', 'ElevatedButton' -> 'button').
String formatWidgetLabel(String widgetType) {
  if (widgetType.isEmpty) return 'element';
  final lower = widgetType.toLowerCase();
  if (lower.contains('listtile') || lower == 'item') return 'list item';
  if (lower.contains('button')) return 'button';
  if (lower.contains('text') && !lower.contains('field')) return 'text';
  if (lower.contains('image')) return 'image';
  if (lower.contains('icon')) return 'icon';
  if (lower.contains('card')) return 'card';
  // Split CamelCase into lower case words
  final words = widgetType
      .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
      .trim()
      .toLowerCase();
  return words.isNotEmpty ? words : widgetType.toLowerCase();
}

/// Numbered circular visual badge rendered on the overlay over an annotated widget.
///
/// When hovered, smoothly transforms from the sequential index number to an edit
/// pencil icon (matching upstream Agentation and Screenshot 1).
class AnnotationMarker extends StatefulWidget {
  const AnnotationMarker({
    super.key,
    required this.index,
    required this.annotation,
    required this.onTap,
    this.isSelected = false,
    this.isHovered = false,
    this.onHoverChanged,
    this.accentColor,
    this.boundsOverride,
  });

  /// The 1-based sequential display number (1, 2, 3...).
  final int index;

  /// The associated annotation.
  final Annotation annotation;

  /// Callback when the marker is tapped.
  final VoidCallback onTap;

  /// Whether this marker is currently selected.
  final bool isSelected;

  /// Whether this marker is actively hovered.
  final bool isHovered;

  /// Optional callback invoked when hover status changes.
  final ValueChanged<bool>? onHoverChanged;

  /// Optional accent theme color (defaults to vibrant blue #0088FF).
  final Color? accentColor;

  /// Optional live bounding box override when dynamic scrolling reprojection is active.
  final WidgetBounds? boundsOverride;

  @override
  State<AnnotationMarker> createState() => _AnnotationMarkerState();
}

class _AnnotationMarkerState extends State<AnnotationMarker> {
  bool _localHover = false;

  bool get _effectiveHover => widget.isHovered || _localHover;

  @override
  Widget build(BuildContext context) {
    final bounds = widget.boundsOverride ?? widget.annotation.bounds;
    final left = widget.boundsOverride != null ? (bounds.x - 10.0) : math.max(4.0, bounds.x - 10.0);
    final top = widget.boundsOverride != null ? (bounds.y - 10.0) : math.max(4.0, bounds.y - 10.0);

    final baseColor = widget.accentColor ?? const Color(0xFF0088FF);

    return Positioned(
      left: left,
      top: top,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _localHover = true);
          widget.onHoverChanged?.call(true);
        },
        onExit: (_) {
          setState(() => _localHover = false);
          widget.onHoverChanged?.call(false);
        },
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('annotation_marker_${widget.index}'),
            onTap: widget.onTap,
            canRequestFocus: true,
            autofocus: widget.isSelected,
            borderRadius: BorderRadius.circular(14.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              transform: _effectiveHover
                  ? (Matrix4.identity()..scale(1.1, 1.1))
                  : Matrix4.identity(),
              transformAlignment: Alignment.center,
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.4),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: _effectiveHover
                    ? const Icon(
                        Icons.edit,
                        size: 13.0,
                        color: Colors.white,
                      )
                    : Text(
                        '${widget.index}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sleek floating hover preview card displayed when an [AnnotationMarker] is hovered
/// (matching Screenshot 1: element label in italic gray, feedback text below, white card).
class AnnotationHoverPreviewCard extends StatelessWidget {
  const AnnotationHoverPreviewCard({
    super.key,
    required this.annotation,
    required this.bounds,
    required this.onTap,
    this.isDark = false,
  });

  final Annotation annotation;
  final WidgetBounds bounds;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const cardMaxWidth = 240.0;
    const cardMinWidth = 120.0;

    // Position directly below or near the marker / element
    final left = bounds.x.clamp(8.0, math.max(8.0, screenSize.width - cardMaxWidth - 8.0)).toDouble();
    final preferredTop = bounds.y + bounds.height + 6.0;
    final top = (preferredTop + 70.0 < screenSize.height)
        ? preferredTop
        : math.max(16.0, bounds.y - 65.0);

    final cardBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF8E8E93);
    final commentColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          elevation: 8.0,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: cardMinWidth,
              maxWidth: cardMaxWidth,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isDark ? const Color(0x33FFFFFF) : const Color(0x14000000),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? const Color(0x7F000000) : const Color(0x26000000),
                  blurRadius: 14.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatWidgetLabel(annotation.targetWidget.widgetType),
                  style: TextStyle(
                    color: labelColor,
                    fontStyle: FontStyle.italic,
                    fontSize: 12.0,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  annotation.comment,
                  style: TextStyle(
                    color: commentColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating edit card / dialog displayed when an [AnnotationMarker] is tapped
/// (matching Screenshot 2: `> list item`, blue border input field, Delete / Cancel / Save).
class AnnotationDetailCard extends StatefulWidget {
  const AnnotationDetailCard({
    super.key,
    required this.index,
    required this.annotation,
    required this.onClose,
    required this.onDelete,
    this.accentColor,
    this.isDark = false,
    this.boundsOverride,
  });

  final int index;
  final Annotation annotation;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  final Color? accentColor;
  final bool isDark;
  final WidgetBounds? boundsOverride;

  @override
  State<AnnotationDetailCard> createState() => _AnnotationDetailCardState();
}

class _AnnotationDetailCardState extends State<AnnotationDetailCard> {
  late final TextEditingController _commentController;
  late final TextEditingController _replyController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.annotation.comment);
    _replyController = TextEditingController();
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _sendReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    final controller = AgentationScope.maybeOf(context);
    controller?.addThreadMessage(widget.annotation.id, text);
    _replyController.clear();
  }

  Future<void> _handleSave() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      final controller = AgentationScope.maybeOf(context);
      await controller?.updateAnnotation(widget.annotation.id, comment: text);
    } catch (_) {}

    if (mounted) {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bounds = widget.boundsOverride ?? widget.annotation.bounds;
    const cardWidth = 320.0;
    final active = widget.accentColor ?? const Color(0xFF0088FF);
    final isDark = widget.isDark;

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF8E8E93);
    final cardBg = isDark ? const Color(0xFF181825) : Colors.white;

    final left = bounds.x.clamp(8.0, math.max(8.0, screenSize.width - cardWidth - 8.0)).toDouble();
    final preferredTop = bounds.y - 140.0;
    final top = preferredTop >= 16.0
        ? preferredTop
        : math.min(screenSize.height - 180.0, bounds.y + bounds.height + 8.0);

    return Positioned(
      left: left,
      top: top,
      width: cardWidth,
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              widget.onClose();
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.enter &&
                (HardwareKeyboard.instance.isControlPressed ||
                 HardwareKeyboard.instance.isMetaPressed)) {
              _handleSave();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Material(
          color: Colors.transparent,
          elevation: 16.0,
          borderRadius: BorderRadius.circular(14.0),
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isDark ? const Color(0x33FFFFFF) : const Color(0x1F000000),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? const Color(0x7F000000) : const Color(0x26000000),
                  blurRadius: 20.0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: "> list item"
                Row(
                  children: [
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 15.0,
                      color: subtextColor,
                    ),
                    const SizedBox(width: 2.0),
                    Text(
                      formatWidgetLabel(widget.annotation.targetWidget.widgetType),
                      style: TextStyle(
                        color: subtextColor,
                        fontStyle: FontStyle.italic,
                        fontSize: 12.5,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                if (widget.annotation.thread.isEmpty)
                  // Editable text box with light blue border (matching Screenshot 2)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF232336) : Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: active,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _commentController,
                      autofocus: true,
                      maxLines: 4,
                      minLines: 2,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(10.0),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  )
                else
                  // Comment text display when in active conversational thread
                  Text(
                    widget.annotation.comment,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),

                // Conversational Thread Messages (if thread active)
                if (widget.annotation.thread.isNotEmpty) ...[
                  const SizedBox(height: 10.0),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 120.0),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: widget.annotation.thread.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6.0),
                      itemBuilder: (context, i) {
                        final msg = widget.annotation.thread[i];
                        final isAgent = msg.role == 'agent';

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: isAgent ? active.withValues(alpha: 0.15) : (isDark ? const Color(0xFF232336) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: isAgent ? active.withValues(alpha: 0.4) : Colors.transparent,
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isAgent ? 'AI Agent' : 'You',
                                    style: TextStyle(
                                      color: isAgent ? active : subtextColor,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(color: subtextColor, fontSize: 9.0),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                msg.content,
                                style: TextStyle(color: textColor, fontSize: 12.0),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32.0,
                          child: TextField(
                            controller: _replyController,
                            style: TextStyle(color: textColor, fontSize: 12.0),
                            onSubmitted: (_) => _sendReply(),
                            decoration: InputDecoration(
                              hintText: 'Reply to thread...',
                              hintStyle: TextStyle(color: subtextColor, fontSize: 11.0),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF232336) : const Color(0xFFF1F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      IconButton(
                        icon: Icon(Icons.send_rounded, size: 16.0, color: active),
                        tooltip: 'Send reply',
                        onPressed: _sendReply,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32.0, minHeight: 32.0),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12.0),

                // Footer: Delete (left), Cancel & Save (right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Delete
                    InkWell(
                      onTap: widget.onDelete,
                      borderRadius: BorderRadius.circular(4.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),

                    // Cancel & Save
                    Row(
                      children: [
                        InkWell(
                          onTap: widget.onClose,
                          borderRadius: BorderRadius.circular(4.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleSave,
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: active,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                _isSaving ? '...' : 'Save',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
