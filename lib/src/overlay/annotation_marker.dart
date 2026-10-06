import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/agentation_scope.dart';
import '../models/annotation.dart';
import '../models/widget_bounds.dart';

/// Numbered circular visual badge rendered on the overlay over an annotated widget.
class AnnotationMarker extends StatelessWidget {
  const AnnotationMarker({
    super.key,
    required this.index,
    required this.annotation,
    required this.onTap,
    this.isSelected = false,
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

  /// Optional accent theme color.
  final Color? accentColor;

  /// Optional live bounding box override when dynamic scrolling reprojection is active.
  final WidgetBounds? boundsOverride;

  @override
  Widget build(BuildContext context) {
    final bounds = boundsOverride ?? annotation.bounds;
    final left = boundsOverride != null ? (bounds.x - 10.0) : math.max(4.0, bounds.x - 10.0);
    final top = boundsOverride != null ? (bounds.y - 10.0) : math.max(4.0, bounds.y - 10.0);

    final borderColor = isSelected
        ? Colors.white
        : (accentColor ?? annotation.severity.color);

    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('annotation_marker_$index'),
          onTap: onTap,
          canRequestFocus: true,
          autofocus: isSelected,
          borderRadius: BorderRadius.circular(14.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: isSelected
                  ? (accentColor ?? const Color(0xFF6366F1))
                  : const Color(0xFF1E1E2E),
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: (accentColor ?? Colors.black).withValues(alpha: 0.4),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating details card displayed when an [AnnotationMarker] is tapped,
/// featuring conversational thread messaging between developers and AI agents.
class AnnotationDetailCard extends StatefulWidget {
  const AnnotationDetailCard({
    super.key,
    required this.index,
    required this.annotation,
    required this.onClose,
    required this.onDelete,
    this.accentColor,
    this.isDark = true,
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
  late final TextEditingController _replyController;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bounds = widget.boundsOverride ?? widget.annotation.bounds;
    const cardWidth = 310.0;
    final active = widget.accentColor ?? const Color(0xFF6366F1);
    final isDark = widget.isDark;

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xF2181825) : const Color(0xF7FFFFFF);
    final bubbleBg = isDark ? const Color(0xFF232336) : const Color(0xFFF1F5F9);

    final left = bounds.x.clamp(8.0, math.max(8.0, screenSize.width - cardWidth - 8.0)).toDouble();
    final top = math.max(
      16.0,
      bounds.y + bounds.height + 8.0 < screenSize.height - 260.0
          ? bounds.y + bounds.height + 8.0
          : math.max(16.0, bounds.y - 250.0),
    );

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
            if (event.logicalKey == LogicalKeyboardKey.delete ||
                event.logicalKey == LogicalKeyboardKey.backspace) {
              widget.onDelete();
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
            border: Border.all(color: active.withValues(alpha: 0.3), width: 1.0),
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
              // Header
              Row(
                children: [
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: widget.annotation.severity.color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      widget.annotation.targetWidget.widgetType,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 16.0, color: subtextColor),
                    onPressed: widget.onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Comment text
              Text(
                widget.annotation.comment,
                style: TextStyle(color: textColor, fontSize: 13.0, height: 1.3),
              ),

              // Kind metadata badge if placement or rearrange
              if (widget.annotation.placement != null) ...[
                const SizedBox(height: 6.0),
                Text(
                  'Placement: ${widget.annotation.placement!.componentType}',
                  style: TextStyle(color: active, fontSize: 11.0, fontWeight: FontWeight.w600),
                ),
              ],
              if (widget.annotation.rearrange != null) ...[
                const SizedBox(height: 6.0),
                Text(
                  'Rearrange: ${widget.annotation.rearrange!.direction ?? "reordered"}',
                  style: TextStyle(color: active, fontSize: 11.0, fontWeight: FontWeight.w600),
                ),
              ],

              // Source File location & Open in editor (matching upstream Agentation)
              if (widget.annotation.sourceFile != null &&
                  widget.annotation.sourceFile!.isNotEmpty) ...[
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    Icon(Icons.code_rounded, size: 12.0, color: subtextColor),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        widget.annotation.sourceFile!,
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 10.5,
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        final controller = AgentationScope.maybeOf(context);
                        controller?.onOpenSource?.call(widget.annotation.sourceFile!);
                      },
                      borderRadius: BorderRadius.circular(4.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                        child: Text(
                          'Open in editor',
                          style: TextStyle(
                            color: active,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Conversational Thread Messages
              if (widget.annotation.thread.isNotEmpty) ...[
                const SizedBox(height: 10.0),
                Container(
                  constraints: const BoxConstraints(maxHeight: 140.0),
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
                          color: isAgent ? active.withValues(alpha: 0.15) : bubbleBg,
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
              ],

              const SizedBox(height: 8.0),

              // Reply Input Row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 32.0,
                      child: Focus(
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent) {
                            if (event.logicalKey == LogicalKeyboardKey.escape) {
                              widget.onClose();
                              return KeyEventResult.handled;
                            }
                            if ((event.logicalKey == LogicalKeyboardKey.delete ||
                                 event.logicalKey == LogicalKeyboardKey.backspace) &&
                                _replyController.text.isEmpty) {
                              widget.onDelete();
                              return KeyEventResult.handled;
                            }
                            if (event.logicalKey == LogicalKeyboardKey.enter &&
                                (HardwareKeyboard.instance.isControlPressed ||
                                 HardwareKeyboard.instance.isMetaPressed)) {
                              _sendReply();
                              return KeyEventResult.handled;
                            }
                          }
                          return KeyEventResult.ignored;
                        },
                        child: TextField(
                          controller: _replyController,
                          style: TextStyle(color: textColor, fontSize: 12.0),
                          onSubmitted: (_) => _sendReply(),
                          decoration: InputDecoration(
                            hintText: 'Reply to thread...',
                            hintStyle: TextStyle(color: subtextColor, fontSize: 11.0),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                          filled: true,
                          fillColor: bubbleBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
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

              const SizedBox(height: 10.0),

              // Footer: severity & delete
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: widget.annotation.severity.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      '${widget.annotation.intent.name.toUpperCase()} • ${widget.annotation.severity.name.toUpperCase()}',
                      style: TextStyle(
                        color: widget.annotation.severity.color,
                        fontSize: 9.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16.0, color: Colors.redAccent),
                    tooltip: 'Delete Note',
                    onPressed: widget.onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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

