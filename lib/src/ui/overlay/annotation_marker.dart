import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/agentation_scope.dart';
import '../../domain/annotation.dart';
import '../../domain/widget_bounds.dart';
import '../../theme/agentation_colors.dart';
import '../../theme/agentation_theme.dart';
import '../toolbar/agentation_icons.dart';

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
/// Features scale-up entrance and scale-down exit animations with staggered delays
/// (matching upstream Agentation and Screenshot 1), and hover transitions.
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
    this.isExiting = false,
    this.layerIndex = 0,
    this.layerSize = 1,
    this.animateEntrance = true,
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

  /// Whether this marker is currently animating its exit before unmounting.
  final bool isExiting;

  /// 0-based index of this marker in the visible layer, for stagger animation delay.
  final int layerIndex;

  /// Total count of markers in this layer, for calculating reverse stagger delays.
  final int layerSize;

  /// Whether to animate entrance when mounted.
  final bool animateEntrance;

  @override
  State<AnnotationMarker> createState() => _AnnotationMarkerState();
}

class _AnnotationMarkerState extends State<AnnotationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Timer? _staggerTimer;
  final ValueNotifier<bool> _localHoverNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      value: widget.animateEntrance ? 0.0 : 1.0,
    );

    if (widget.animateEntrance && !widget.isExiting) {
      _startEntranceAnimation();
    }
  }

  void _startEntranceAnimation() {
    _staggerTimer?.cancel();
    final delayMs = widget.layerIndex * 20;
    if (delayMs > 0) {
      _staggerTimer = Timer(Duration(milliseconds: delayMs), () {
        if (mounted && !widget.isExiting) {
          _animController.animateTo(
            1.0,
            duration: const Duration(milliseconds: 250),
            curve: const Cubic(0.22, 1.0, 0.36, 1.0),
          );
        }
      });
    } else {
      _animController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 250),
        curve: const Cubic(0.22, 1.0, 0.36, 1.0),
      );
    }
  }

  void _startExitAnimation() {
    _staggerTimer?.cancel();
    final reverseIndex = math.max(0, widget.layerSize - 1 - widget.layerIndex);
    final delayMs = reverseIndex * 20;
    if (delayMs > 0) {
      _staggerTimer = Timer(Duration(milliseconds: delayMs), () {
        if (mounted && widget.isExiting) {
          _animController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      _animController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void didUpdateWidget(AnnotationMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExiting && !oldWidget.isExiting) {
      _startExitAnimation();
    } else if (!widget.isExiting && oldWidget.isExiting) {
      _startEntranceAnimation();
    }
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _animController.dispose();
    _localHoverNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bounds = widget.boundsOverride ?? widget.annotation.bounds;
    final double left;
    final double top;
    if (widget.annotation.tapPosition != null) {
      final relX = widget.annotation.tapPosition!.dx - widget.annotation.bounds.x;
      final relY = widget.annotation.tapPosition!.dy - widget.annotation.bounds.y;
      final posX = bounds.x + relX - 12.0;
      final posY = bounds.y + relY - 12.0;
      left = widget.boundsOverride != null ? posX : math.max(0.0, posX);
      top = widget.boundsOverride != null ? posY : math.max(0.0, posY);
    } else {
      left = widget.boundsOverride != null ? (bounds.x - 10.0) : math.max(4.0, bounds.x - 10.0);
      top = widget.boundsOverride != null ? (bounds.y - 10.0) : math.max(4.0, bounds.y - 10.0);
    }

    final baseColor = widget.accentColor ?? AgentationColors.accent;

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        ignoring: widget.isExiting,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final scale = 0.3 + 0.7 * _animController.value;
            final opacity = _animController.value.clamp(0.0, 1.0);
            return Transform.scale(
              key: const ValueKey('annotation_marker_scale_transform'),
              scale: scale,
              alignment: Alignment.center,
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            );
          },
          child: MouseRegion(
            onEnter: (_) {
              if (widget.isExiting) return;
              _localHoverNotifier.value = true;
              widget.onHoverChanged?.call(true);
            },
            onExit: (_) {
              if (widget.isExiting) return;
              _localHoverNotifier.value = false;
              widget.onHoverChanged?.call(false);
            },
            cursor: widget.isExiting ? SystemMouseCursors.basic : SystemMouseCursors.click,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: ValueKey('annotation_marker_${widget.index}'),
                onTap: widget.isExiting ? null : widget.onTap,
                canRequestFocus: !widget.isExiting,
                autofocus: widget.isSelected && !widget.isExiting,
                borderRadius: BorderRadius.circular(14.0),
                child: ValueListenableBuilder<bool>(
                  valueListenable: _localHoverNotifier,
                  builder: (context, localHover, _) {
                    final effectiveHover = !widget.isExiting && (widget.isHovered || localHover);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      transform: effectiveHover
                          ? Matrix4.diagonal3Values(1.1, 1.1, 1.0)
                          : Matrix4.identity(),
                      transformAlignment: Alignment.center,
                      width: 24.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        color: baseColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: baseColor.withValues(alpha: 0.4),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: effectiveHover
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
                    );
                  },
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
    this.onHoverChanged,
    this.isDark = false,
  });

  final Annotation annotation;
  final WidgetBounds bounds;
  final VoidCallback onTap;
  final ValueChanged<bool>? onHoverChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const cardMaxWidth = 240.0;
    const cardMinWidth = 120.0;

    // Determine the marker's actual location on screen
    final double markerLeft;
    final double markerTop;
    if (annotation.tapPosition != null) {
      final relX = annotation.tapPosition!.dx - annotation.bounds.x;
      final relY = annotation.tapPosition!.dy - annotation.bounds.y;
      markerLeft = bounds.x + relX - 12.0;
      markerTop = bounds.y + relY - 12.0;
    } else {
      markerLeft = bounds.x - 10.0;
      markerTop = bounds.y - 10.0;
    }
    final markerCenterX = markerLeft + 12.0;
    final markerBottom = markerTop + 24.0;

    // Approximate card height based on comment text length so it never overlaps the hovered marker or widget
    final approxLines = (annotation.comment.length / 28.0).ceil().clamp(1, 14);
    final estimatedCardHeight = 48.0 + (approxLines * 18.0);

    // If the annotated widget is full-screen or excessively large (e.g. FreezeOverlay, Scaffold, root view),
    // anchoring to the widget's bounds would push the card off-screen and cause it to flip to top: 8.0.
    // In that case, anchor cleanly to the marker pin itself.
    final isHugeOrFullScreenWidget = bounds.height >= screenSize.height * 0.65 ||
        (bounds.y <= 0.0 && bounds.height >= screenSize.height - 80.0);

    final double anchorTop;
    final double anchorBottom;
    final double anchorCenterX;

    if (isHugeOrFullScreenWidget) {
      anchorTop = markerTop;
      anchorBottom = markerBottom;
      anchorCenterX = markerCenterX;
    } else {
      anchorTop = bounds.y;
      anchorBottom = bounds.y + bounds.height;
      anchorCenterX = bounds.x + (bounds.width / 2.0);
    }

    // Prefer positioning below the anchor; if not enough room at the bottom of the viewport, position above.
    final preferredTopBelow = anchorBottom + 8.0;
    final top = (preferredTopBelow + estimatedCardHeight < screenSize.height - 8.0)
        ? preferredTopBelow
        : math.max(8.0, anchorTop - estimatedCardHeight - 8.0);

    // Center horizontally aligned with the anchor
    final left = (anchorCenterX - (cardMaxWidth / 2.0))
        .clamp(8.0, math.max(8.0, screenSize.width - cardMaxWidth - 8.0))
        .toDouble();

    final theme = AgentationThemeData.resolve(isDark: isDark);
    final cardBg = theme.cardBackground;
    final labelColor = theme.textSecondary;
    final commentColor = theme.textPrimary;

    return Positioned(
      left: left,
      top: top,
      child: MouseRegion(
        onEnter: (_) => onHoverChanged?.call(true),
        onExit: (_) => onHoverChanged?.call(false),
        cursor: SystemMouseCursors.click,
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
                  color: theme.borderTranslucentColor,
                  width: 1.0,
                ),
                boxShadow: theme.cardShadows,
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
  late final FocusNode _commentFocusNode;
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<Offset> _dragOffsetNotifier = ValueNotifier<Offset>(Offset.zero);

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.annotation.comment);
    _replyController = TextEditingController();
    _commentFocusNode = FocusNode(debugLabel: 'AnnotationDetailCommentFocus');
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    _commentFocusNode.dispose();
    _isSavingNotifier.dispose();
    _dragOffsetNotifier.dispose();
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
    if (text.isEmpty || _isSavingNotifier.value) return;
    _isSavingNotifier.value = true;

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
    final cardWidth = math.min(280.0, screenSize.width - 24.0);
    final isDark = widget.isDark;
    final theme = AgentationThemeData.resolve(isDark: isDark);
    final active = widget.accentColor ?? theme.accentColor;
    final textColor = theme.textPrimary;
    final subtextColor = theme.textSecondary;
    final cardBg = theme.cardBackground;

    final double anchorX;
    final double anchorY;
    if (widget.annotation.tapPosition != null) {
      final relX = widget.annotation.tapPosition!.dx - widget.annotation.bounds.x;
      final relY = widget.annotation.tapPosition!.dy - widget.annotation.bounds.y;
      anchorX = bounds.x + relX;
      anchorY = bounds.y + relY;
    } else {
      anchorX = bounds.x;
      anchorY = bounds.y;
    }

    final isMobile = screenSize.width < 600.0;
    final baseLeft = isMobile
        ? ((screenSize.width - cardWidth) / 2.0).roundToDouble()
        : (anchorX - (cardWidth / 2)).clamp(8.0, math.max(8.0, screenSize.width - cardWidth - 8.0)).toDouble();
    final preferredTop = anchorY - 140.0;
    final baseTop = isMobile
        ? math.max(16.0, (screenSize.height - 70.0 - 180.0) / 2.0)
        : (preferredTop >= 16.0
            ? preferredTop
            : math.min(screenSize.height - 180.0, bounds.y + bounds.height + 8.0));

    return ValueListenableBuilder<Offset>(
      valueListenable: _dragOffsetNotifier,
      builder: (context, dragOffset, cardChild) {
        final left = (baseLeft + dragOffset.dx).clamp(8.0, math.max(8.0, screenSize.width - cardWidth - 8.0)).toDouble();
        final top = (baseTop + dragOffset.dy).clamp(16.0, math.max(16.0, screenSize.height - 100.0)).toDouble();

        return Positioned(
          left: left,
          top: top,
          width: cardWidth,
          child: cardChild!,
        );
      },
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              widget.onClose();
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.numpadEnter) {
              if (HardwareKeyboard.instance.isShiftPressed) {
                // Shift + Enter inserts a newline
                return KeyEventResult.ignored;
              }
              _handleSave();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Material(
          color: Colors.transparent,
          elevation: 16.0,
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: theme.borderTranslucentColor,
                width: 1.0,
              ),
              boxShadow: theme.cardShadows,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: draggable titlebar with widget type only
                Builder(
                  builder: (context) {
                    final widgetType = widget.annotation.targetWidget.widgetType;
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        _dragOffsetNotifier.value += details.delta;
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 15.0,
                            color: subtextColor,
                          ),
                          const SizedBox(width: 2.0),
                          Expanded(
                            child: Text(
                              formatWidgetLabel(widgetType),
                              style: TextStyle(
                                color: subtextColor,
                                fontStyle: FontStyle.italic,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10.0),

                if (widget.annotation.thread.isEmpty)
                  // Editable text box with light blue border (matching Screenshot 2)
                  Container(
                    decoration: BoxDecoration(
                      color: theme.inputBackground,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: active,
                        width: 1.5,
                      ),
                    ),
                    child: Focus(
                      onKeyEvent: (node, event) {
                        if (event is KeyDownEvent) {
                          if (event.logicalKey == LogicalKeyboardKey.escape) {
                            widget.onClose();
                            return KeyEventResult.handled;
                          }
                          if (event.logicalKey == LogicalKeyboardKey.enter ||
                              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
                            if (HardwareKeyboard.instance.isShiftPressed) {
                              // Shift + Enter inserts a newline
                              return KeyEventResult.ignored;
                            }
                            // Enter or Ctrl/Cmd + Enter triggers Save
                            if (!_isSavingNotifier.value) {
                              _handleSave();
                            }
                            return KeyEventResult.handled;
                          }
                        }
                        return KeyEventResult.ignored;
                      },
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        maxLines: 3,
                        minLines: 1,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                          border: InputBorder.none,
                          isDense: true,
                        ),
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
                            color: isAgent ? active.withValues(alpha: 0.15) : theme.inputBackground,
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
                          child: Focus(
                            onKeyEvent: (node, event) {
                              if (event is KeyDownEvent &&
                                  event.logicalKey == LogicalKeyboardKey.escape) {
                                widget.onClose();
                                return KeyEventResult.handled;
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
                                fillColor: theme.inputBackground,
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
                ],

                const SizedBox(height: 12.0),

                // Footer: Delete (left), Cancel & Save (right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Delete
                    _CardDeleteIconButton(
                      onDelete: widget.onDelete,
                      defaultColor: subtextColor,
                      hoverColor: AgentationColors.destructive,
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
                                color: subtextColor,
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
                              height: 32.0,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: active,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: ValueListenableBuilder<bool>(
                                valueListenable: _isSavingNotifier,
                                builder: (context, isSaving, _) => Text(
                                  isSaving ? '...' : 'Save',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none,
                                  ),
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

class _CardDeleteIconButton extends StatefulWidget {
  const _CardDeleteIconButton({
    required this.onDelete,
    required this.defaultColor,
    required this.hoverColor,
  });

  final VoidCallback onDelete;
  final Color defaultColor;
  final Color hoverColor;

  @override
  State<_CardDeleteIconButton> createState() => _CardDeleteIconButtonState();
}

class _CardDeleteIconButtonState extends State<_CardDeleteIconButton> {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isHovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Delete',
      triggerMode: TooltipTriggerMode.manual,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _isHovered.value = true,
        onExit: (_) => _isHovered.value = false,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isHovered,
          builder: (context, isHovered, _) {
            return InkWell(
              key: const ValueKey('agentation_card_delete_button'),
              onTap: widget.onDelete,
              borderRadius: BorderRadius.circular(6.0),
              hoverColor: widget.hoverColor.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: AgentationIcons.trash(
                  size: 21.5,
                  color: isHovered ? widget.hoverColor : widget.defaultColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

