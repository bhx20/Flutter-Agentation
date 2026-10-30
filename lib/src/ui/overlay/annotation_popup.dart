import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/agentation_controller.dart';
import '../../core/agentation_scope.dart';
import '../../core/agentation_state.dart';
import '../../domain/annotation_intent.dart';
import '../../domain/annotation_severity.dart';
import '../../domain/marker_color.dart';
import '../../domain/widget_inspection_result.dart';
import '../../source_location/widget_code_resolver.dart';
import '../../theme/agentation_colors.dart';
import '../../theme/agentation_radii.dart';
import '../../theme/agentation_theme.dart';
import '../../theme/agentation_typography.dart';
import '../toolbar/agentation_icons.dart';

/// Annotation creation popup matching the Agentation design system.
///
/// Prominently displays the exact or canonical Flutter Dart widget code snippet
/// of the selected widget, allowing users to reference and copy the code while commenting.
class AnnotationPopup extends StatefulWidget {
  const AnnotationPopup({
    super.key,
    required this.result,
    required this.onClose,
    this.initialComment = '',
    this.onDelete,
    this.onSave,
    this.submitLabel,
    this.initialIntent = AnnotationIntent.suggestion,
    this.initialSeverity = AnnotationSeverity.suggestion,
    this.showHierarchy = false,
    this.showWidgetCode = true,
    this.showIntentSelector = false,
    this.initialCodeExpanded = false,
    this.accentColor,
  });

  /// Optional initial comment text (e.g. when editing an existing annotation).
  final String initialComment;

  /// Optional callback invoked when the delete button is clicked.
  /// The trash/delete icon is ONLY shown when this callback is provided (edit mode).
  final VoidCallback? onDelete;

  /// Optional custom callback invoked when saving/submitting.
  final FutureOr<void> Function(String comment)? onSave;

  /// Optional custom label for the primary action button.
  final String? submitLabel;

  /// The inspected target widget snapshot.
  final WidgetInspectionResult result;

  /// Callback when closed or cancelled.
  final VoidCallback onClose;

  /// Default intent.
  final AnnotationIntent initialIntent;

  /// Default severity.
  final AnnotationSeverity initialSeverity;

  /// Whether to display the top widget hierarchy breadcrumb trail. Defaults to false.
  final bool showHierarchy;

  /// Whether to display the selected widget code snippet. Defaults to true.
  final bool showWidgetCode;

  /// Whether to display the intent chips (Change, Bug, Suggestion). Defaults to false.
  final bool showIntentSelector;

  /// Whether the widget code review box is expanded initially. Defaults to false (collapsed).
  final bool initialCodeExpanded;

  /// Optional accent theme color override (e.g. green for Area Selection or group multi-select).
  final Color? accentColor;

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
  final ValueNotifier<bool> _isCodeCopiedNotifier = ValueNotifier<bool>(false);
  final GlobalKey _cardKey = GlobalKey();
  late final ValueNotifier<bool> _isCodeExpandedNotifier;
  final ValueNotifier<String?> _asyncLoadedCodeNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<Offset> _dragOffsetNotifier = ValueNotifier<Offset>(Offset.zero);
  AgentationController? _controller;
  Timer? _copyTimer;

  String get _displayCode {
    final asyncCode = _asyncLoadedCodeNotifier.value;
    if (asyncCode != null && asyncCode.isNotEmpty) {
      return asyncCode;
    }
    if (widget.result.widgetCode != null && widget.result.widgetCode!.isNotEmpty) {
      return widget.result.widgetCode!;
    }
    return WidgetCodeResolver.resolveWidgetCode(
      result: widget.result,
      sourceLocation: widget.result.sourceLocation,
    );
  }

  @override
  void initState() {
    super.initState();
    _isCodeExpandedNotifier = ValueNotifier<bool>(widget.initialCodeExpanded);
    _commentController = TextEditingController(text: widget.initialComment);
    if (widget.initialComment.isNotEmpty) {
      _commentController.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.initialComment.length),
      );
    }
    _focusNode = FocusNode();
    _selectedIntentNotifier = ValueNotifier<AnnotationIntent>(widget.initialIntent);
    _hasTextNotifier.value = widget.initialComment.trim().isNotEmpty;
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
    _loadAsyncSource();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = AgentationScope.maybeOf(context);
    _updatePopupBounds();
  }

  @override
  void didUpdateWidget(covariant AnnotationPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.result.bounds != widget.result.bounds) {
      _updatePopupBounds();
    }
  }

  void _updatePopupBounds() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final origin = renderBox.localToGlobal(Offset.zero);
        final bounds = Rect.fromLTWH(
          origin.dx,
          origin.dy,
          renderBox.size.width,
          renderBox.size.height,
        );
        _controller?.updatePopupBounds(bounds);
      }
    });
  }

  void _toggleCodeExpanded() {
    _isCodeExpandedNotifier.value = !_isCodeExpandedNotifier.value;
    _updatePopupBounds();
  }

  Future<void> _loadAsyncSource() async {
    final loc = widget.result.sourceLocation;
    if (loc == null || !loc.isAvailable) return;
    final path = loc.rawPath ?? loc.filePath;
    final line = loc.line;
    if (path == null || line == null) return;

    final asyncCode = await WidgetCodeResolver.resolveAsyncWidgetCode(
      filePath: path,
      line: line,
      widgetType: widget.result.identity.widgetType,
    );
    if (asyncCode != null && asyncCode.trim().isNotEmpty && mounted) {
      _asyncLoadedCodeNotifier.value = asyncCode;
    }
  }

  @override
  void dispose() {
    _controller?.updatePopupBounds(null);
    _focusNode.dispose();
    _commentController.dispose();
    _selectedIntentNotifier.dispose();
    _isSavingNotifier.dispose();
    _showHierarchyNotifier.dispose();
    _hasTextNotifier.dispose();
    _isCodeCopiedNotifier.dispose();
    _isCodeExpandedNotifier.dispose();
    _asyncLoadedCodeNotifier.dispose();
    _dragOffsetNotifier.dispose();
    _copyTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSavingNotifier.value) return;
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    _isSavingNotifier.value = true;
    final controller = AgentationScope.of(context);

    try {
      if (widget.onSave != null) {
        await widget.onSave!(comment);
      } else {
        await controller.createAnnotation(
          comment: comment,
          intent: _selectedIntentNotifier.value,
          severity: widget.initialSeverity,
          targetResult: widget.result,
        );
      }
      widget.onClose();
    } finally {
      if (mounted) {
        _isSavingNotifier.value = false;
      }
    }
  }

  Color _resolveActionColor(AnnotationIntent? intent, {AgentationController? controller}) {
    // 1. Explicit accent color override takes highest precedence
    if (widget.accentColor != null) {
      return widget.accentColor!;
    }

    final widgetType = widget.result.identity.widgetType;
    final isArea = widgetType == 'AreaSelection' ||
        (controller?.toolMode == AnnotationToolMode.area);
    if (isArea) {
      // Area selection always uses green matching agentation-main
      return AgentationColors.success;
    }

    final isMulti = widgetType == 'MultiSelect' ||
        (controller != null && controller.multiSelection.length > 1) ||
        (controller?.toolMode == AnnotationToolMode.multiSelect);
    if (isMulti) {
      // Multi-element selection always uses green matching agentation-main
      return AgentationColors.success;
    }

    final isRearrange = widgetType == 'Rearrange' ||
        (controller?.toolMode == AnnotationToolMode.design);
    if (isRearrange) {
      // Layout rearrange / move uses amber
      return AgentationColors.amber;
    }

    if (widgetType == 'Placement') {
      // Component placement uses indigo
      return AgentationColors.indigo;
    }

    // 2. Action / Intent color (when intent is selected via chips or passed)
    if (intent != null && (widget.showIntentSelector || widget.initialIntent != AnnotationIntent.suggestion)) {
      switch (intent) {
        case AnnotationIntent.change:
          return AgentationColors.amber;
        case AnnotationIntent.bug:
          return AgentationColors.destructive;
        case AnnotationIntent.suggestion:
          return AgentationColors.success;
        case AnnotationIntent.question:
          return AgentationColors.cyan;
        case AnnotationIntent.note:
          break;
      }
    }

    // 3. User configured marker color from settings panel
    if (controller != null) {
      final colorId = controller.settings.markerColorId;
      return MarkerColor.findById(colorId).color;
    }

    return AgentationColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    _updatePopupBounds();
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;
    final bounds = widget.result.bounds;
    final isMobile = screenSize.width < 600.0;

    // Exact card width matching agentation-main (280px, clamped to screen - 24px)
    final cardWidth = math.min(280.0, screenSize.width - 24.0);
    final estimatedCardHeight = _isCodeExpandedNotifier.value ? 210.0 : 95.0;

    final controller = AgentationScope.maybeOf(context);
    final isDark = controller?.settings.isDarkMode ?? true;

    // Calculate usable screen height accounting for virtual software keyboard (iOS/Android)
    final usableHeight = screenSize.height - viewInsets.bottom - padding.bottom;
    final minTop = padding.top + 8.0;
    final maxTop = math.max(minTop, usableHeight - estimatedCardHeight - 8.0);

    // Anchor coordinates: use tapPosition (clientX, clientY) when available,
    // otherwise fallback to widget center/bottom matching agentation-main
    final anchorX = widget.result.tapPosition?.dx ?? (bounds.x + bounds.width / 2.0);
    final anchorY = widget.result.tapPosition?.dy ?? (bounds.y + bounds.height);

    // Calculate dynamic popup placement: on mobile screens, center cleanly in the viewport;
    // on desktop/wide screens, center horizontally on tapPosition clamped within screen boundaries
    final preferredLeft = anchorX - cardWidth / 2.0;
    final baseLeft = isMobile
        ? ((screenSize.width - cardWidth) / 2.0).roundToDouble()
        : preferredLeft.clamp(12.0, math.max(12.0, screenSize.width - cardWidth - 12.0)).toDouble();

    // Position popup vertically: on mobile, center in the available upper viewport above the bottom toolbar/keyboard;
    // on desktop, position nearby the client click (below or above depending on viewport space)
    final double computedTop;
    if (isMobile) {
      final mobileCenter = (usableHeight - 64.0 - estimatedCardHeight) / 2.0;
      computedTop = math.max(minTop, mobileCenter);
    } else if (anchorY + 16.0 + estimatedCardHeight < usableHeight - 12.0) {
      computedTop = anchorY + 16.0;
    } else if (anchorY - estimatedCardHeight - 16.0 > minTop) {
      computedTop = anchorY - estimatedCardHeight - 16.0;
    } else {
      computedTop = math.max(minTop, (usableHeight - estimatedCardHeight) / 2.0);
    }
    final baseTop = computedTop.clamp(minTop, maxTop).toDouble();

    final theme = AgentationThemeData.resolve(isDark: isDark);
    final cardBg = theme.cardBackground;
    final inputBg = theme.inputBackground;
    final textColor = theme.textPrimary;
    final subtextColor = theme.textSecondary;
    final borderColor = theme.borderTranslucentColor;

    // Action awareness matching agentation-main
    final isArea = widget.result.identity.widgetType == 'AreaSelection' ||
        (controller?.toolMode == AnnotationToolMode.area);
    final isMulti = widget.result.identity.widgetType == 'MultiSelect' ||
        (controller != null && controller.multiSelection.length > 1) ||
        (controller?.toolMode == AnnotationToolMode.multiSelect);
    final isRearrange = widget.result.identity.widgetType == 'Rearrange' ||
        (controller?.toolMode == AnnotationToolMode.design);
    final isPlacement = widget.result.identity.widgetType == 'Placement';

    // Dynamic placeholder matching agentation-main line 4627-4632
    final String placeholder;
    if (isArea) {
      placeholder = 'What should change in this area?';
    } else if (isMulti) {
      placeholder = 'Feedback for this group of elements...';
    } else if (isRearrange) {
      placeholder = 'What should change about this position?';
    } else if (isPlacement) {
      placeholder = 'Notes for this component...';
    } else {
      placeholder = 'What should change?';
    }

    final String elementLabel;
    if (isArea) {
      elementLabel = 'Area selection';
    } else if (isMulti) {
      elementLabel = 'Multi-selection (${controller?.multiSelection.length ?? 0} elements)';
    } else if (isRearrange) {
      elementLabel = 'Rearrange ${widget.result.identity.widgetType}';
    } else {
      elementLabel = widget.result.identity.widgetType;
    }

    final hasCode = !isArea && !isMulti && _displayCode.trim().isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Pinned '+' badge anchored at client tap position (matching agentation-main) ──
        ValueListenableBuilder<AnnotationIntent>(
          valueListenable: _selectedIntentNotifier,
          builder: (context, selectedIntent, _) {
            final activeColor = _resolveActionColor(selectedIntent, controller: controller);
            return Positioned(
              left: (anchorX - 11.0).clamp(4.0, screenSize.width - 26.0),
              top: (anchorY - 11.0).clamp(4.0, screenSize.height - 26.0),
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
            );
          },
        ),

        // ── Floating Annotation Input Card (Screenshot 5) ──
        ValueListenableBuilder<Offset>(
          valueListenable: _dragOffsetNotifier,
          builder: (context, dragOffset, cardChild) {
            final left = (baseLeft + dragOffset.dx).clamp(8.0, math.max(8.0, screenSize.width - cardWidth - 8.0)).toDouble();
            final top = (baseTop + dragOffset.dy).clamp(minTop, math.max(minTop, screenSize.height - 100.0)).toDouble();
            return Positioned(
              left: left,
              top: top,
              width: cardWidth,
              child: cardChild!,
            );
          },
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerSignal: (_) {}, // Absorb pointer signals to isolate from background page scrolling
            child: MouseRegion(
              key: const ValueKey('annotation_popup_card_mouse_region'),
              cursor: SystemMouseCursors.basic, // Restore standard cursor over interactive card
              child: Material(
                key: _cardKey,
                color: Colors.transparent,
                elevation: 16.0,
                borderRadius: AgentationRadii.br16,
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AgentationRadii.br16,
                  border: Border.all(color: borderColor, width: 1.0),
                  boxShadow: theme.cardShadows,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header line: draggable titlebar with expandable chevron toggle, widget type, text preview, key, and source location tag ──
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        _dragOffsetNotifier.value += details.delta;
                      },
                      child: InkWell(
                        onTap: (widget.showWidgetCode && hasCode) ? _toggleCodeExpanded : null,
                        borderRadius: AgentationRadii.br6,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                          child: Row(
                            children: [
                              if (isArea) ...[
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 15.0,
                                  color: subtextColor,
                                ),
                                const SizedBox(width: 2.0),
                                Text(
                                  elementLabel,
                                  style: AgentationTypography.italicLabel.copyWith(color: subtextColor),
                                ),
                              ] else ...[
                                if (widget.showWidgetCode && hasCode) ...[
                                  ValueListenableBuilder<bool>(
                                    valueListenable: _isCodeExpandedNotifier,
                                    builder: (context, isCodeExpanded, _) => AnimatedRotation(
                                      turns: isCodeExpanded ? 0.25 : 0.0,
                                      duration: const Duration(milliseconds: 150),
                                      child: Icon(
                                        Icons.chevron_right_rounded,
                                        size: 16.0,
                                        color: subtextColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                ],
                                ValueListenableBuilder<AnnotationIntent>(
                                  valueListenable: _selectedIntentNotifier,
                                  builder: (context, selectedIntent, _) {
                                    final activeColor = _resolveActionColor(selectedIntent, controller: controller);
                                    return Icon(
                                      Icons.code_rounded,
                                      size: 13.0,
                                      color: activeColor,
                                    );
                                  },
                                ),
                                const SizedBox(width: 5.0),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          elementLabel,
                                          style: AgentationTypography.elementLabel.copyWith(color: textColor),
                                        ),
                                        if (widget.result.sourceLocation?.isAvailable == true) ...[
                                          const SizedBox(width: 6.0),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: isDark ? AgentationColors.darkCodeTagBg : AgentationColors.lightBorderSlate,
                                              borderRadius: AgentationRadii.br4,
                                            ),
                                            child: Text(
                                              '${widget.result.sourceLocation!.fileString}:${widget.result.sourceLocation!.lineString}',
                                              style: AgentationTypography.codeLocation.copyWith(color: subtextColor),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Hierarchy breadcrumb trail & ActionChips (when showHierarchy is explicitly enabled) ──
                    if (widget.showHierarchy && (controller?.activeHierarchy != null || widget.result.ancestors.where((a) => a != widget.result.identity.widgetType).isNotEmpty))
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (controller?.activeHierarchy != null) ...[
                                for (final ancestor in controller!.activeHierarchy!.ancestors) ...[
                                  ActionChip(
                                    label: Text(ancestor.identity.widgetType, style: AgentationTypography.chip),
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
                                      style: AgentationTypography.chip,
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
                                    label: Text(ancestorName, style: AgentationTypography.chip),
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

                    // ── Expandable Widget Code Review Box (collapsed by default) ──
                    ValueListenableBuilder<bool>(
                      valueListenable: _isCodeExpandedNotifier,
                      builder: (context, isCodeExpanded, _) {
                        if (!widget.showWidgetCode || !hasCode || !isCodeExpanded) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8.0),
                            NotificationListener<ScrollNotification>(
                              onNotification: (notification) => true, // Absorb scroll notifications so underlying screen doesn't scroll!
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AgentationColors.darkCodeBg : AgentationColors.lightCodeBg,
                                  borderRadius: AgentationRadii.br8,
                                  border: Border.all(
                                    color: isDark ? AgentationColors.darkCodeBorder : AgentationColors.lightBorderSlate,
                                    width: 1.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: AgentationRadii.br7,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Code block header: label & Copy button
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
                                        decoration: BoxDecoration(
                                          color: isDark ? AgentationColors.darkCodeHeaderBg : AgentationColors.lightCodeHeaderBg,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: isDark ? AgentationColors.darkCodeTagBg : AgentationColors.lightBorderSlate,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              'WIDGET CODE',
                                              style: AgentationTypography.codeHeader.copyWith(color: subtextColor),
                                            ),
                                            const Spacer(),
                                            ValueListenableBuilder<bool>(
                                              valueListenable: _isCodeCopiedNotifier,
                                              builder: (context, isCopied, _) {
                                                return InkWell(
                                                  onTap: () {
                                                    Clipboard.setData(ClipboardData(text: _displayCode));
                                                    _isCodeCopiedNotifier.value = true;
                                                    _copyTimer?.cancel();
                                                    _copyTimer = Timer(const Duration(seconds: 2), () {
                                                      if (mounted) _isCodeCopiedNotifier.value = false;
                                                    });
                                                  },
                                                  borderRadius: AgentationRadii.br4,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.5),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          isCopied ? Icons.check_rounded : Icons.copy_rounded,
                                                          size: 11.0,
                                                          color: isCopied ? AgentationColors.emerald : subtextColor,
                                                        ),
                                                        const SizedBox(width: 3.0),
                                                        Text(
                                                          isCopied ? 'Copied' : 'Copy',
                                                          style: AgentationTypography.shortcut.copyWith(color: isCopied ? AgentationColors.emerald : subtextColor),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Code content area with syntax highlighting
                                      Container(
                                        constraints: const BoxConstraints(maxHeight: 120.0),
                                        padding: const EdgeInsets.all(7.0),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: ValueListenableBuilder<String?>(
                                              valueListenable: _asyncLoadedCodeNotifier,
                                              builder: (context, _, _) => SelectableText.rich(
                                                _buildSyntaxHighlightedSpan(_displayCode, isDark),
                                                style: AgentationTypography.codeCompact,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  const SizedBox(height: 10.0),

                  // ── Textarea with dynamic action border & placeholder (matches agentation-main) ──
                  ValueListenableBuilder<AnnotationIntent>(
                    valueListenable: _selectedIntentNotifier,
                    builder: (context, selectedIntent, _) {
                      final activeColor = _resolveActionColor(selectedIntent, controller: controller);
                      return Container(
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: AgentationRadii.br8,
                          border: Border.all(
                            color: activeColor,
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
                                // Enter or Ctrl/Cmd + Enter triggers Add/Save Comment
                                if (_hasTextNotifier.value && !_isSavingNotifier.value) {
                                  _handleSave();
                                }
                                return KeyEventResult.handled;
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
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            style: AgentationTypography.input.copyWith(color: textColor),
                            cursorColor: activeColor,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                              isDense: true,
                              hintText: placeholder,
                              hintStyle: AgentationTypography.inputHint.copyWith(color: subtextColor),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) {
                              if (_hasTextNotifier.value && !_isSavingNotifier.value) {
                                _handleSave();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  // ── Intent Selector Pills (Change, Bug, Suggestion) (hidden by default) ──
                  if (widget.showIntentSelector)
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

                  const SizedBox(height: 12.0),

                  // ── Bottom Actions Row: Cancel & Add/Save ──
                  Row(
                    mainAxisAlignment: widget.onDelete != null
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.end,
                    children: [
                      // Delete (Trash icon) - only shown when editing an annotation
                      if (widget.onDelete != null)
                        _CardDeleteIconButton(
                          onDelete: widget.onDelete!,
                          defaultColor: subtextColor,
                          hoverColor: AgentationColors.destructive,
                        ),

                      // Cancel & Add/Save
                      Row(
                        children: [
                          InkWell(
                            onTap: widget.onClose,
                            borderRadius: AgentationRadii.br4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Text(
                                'Cancel',
                                style: AgentationTypography.button.copyWith(color: isDark ? AgentationColors.darkTextSubtle : AgentationColors.lightTextSecondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          ListenableBuilder(
                            listenable: Listenable.merge([_hasTextNotifier, _isSavingNotifier, _selectedIntentNotifier]),
                            builder: (context, _) {
                              final hasText = _hasTextNotifier.value;
                              final isSaving = _isSavingNotifier.value;
                              final activeColor = _resolveActionColor(_selectedIntentNotifier.value, controller: controller);

                              return ElevatedButton(
                                onPressed: hasText && !isSaving ? _handleSave : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: activeColor,
                                  disabledBackgroundColor: activeColor.withValues(alpha: 0.35),
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white70,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AgentationRadii.br20,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  fixedSize: const Size.fromHeight(32.0),
                                  minimumSize: const Size(54.0, 32.0),
                                  visualDensity: VisualDensity.standard,
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
                                    : Text(
                                        widget.submitLabel ??
                                            (isArea || widget.onDelete != null ? 'Save' : 'Add'),
                                        style: AgentationTypography.body,
                                      ),
                              );
                            },
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
      ),
    ),
  ],
);
}

  Widget _buildIntentChip(String label, AnnotationIntent intent, AnnotationIntent selectedIntent, bool isDark) {
    final isSelected = selectedIntent == intent;
    final Color intentColor;
    switch (intent) {
      case AnnotationIntent.change:
        intentColor = AgentationColors.amber; // Yellow / Amber
        break;
      case AnnotationIntent.bug:
        intentColor = AgentationColors.destructive; // Red / Rose
        break;
      case AnnotationIntent.suggestion:
        intentColor = AgentationColors.success; // Green / Emerald
        break;
      case AnnotationIntent.question:
        intentColor = AgentationColors.cyan; // Cyan
        break;
      case AnnotationIntent.note:
        intentColor = AgentationColors.accent; // Blue
        break;
    }

    return InkWell(
      onTap: () => _selectedIntentNotifier.value = intent,
      borderRadius: AgentationRadii.br6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? intentColor.withValues(alpha: 0.25)
                  : intentColor.withValues(alpha: 0.15))
              : Colors.transparent,
          borderRadius: AgentationRadii.br6,
          border: Border.all(
            color: isSelected
                ? intentColor
                : (isDark ? AgentationColors.darkBorderTranslucent : AgentationColors.shadowMedium),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: (isSelected ? AgentationTypography.captionSemiBold : AgentationTypography.caption).copyWith(color: isSelected ? intentColor : (isDark ? AgentationColors.darkTextMuted : AgentationColors.darkIconInactive)),
        ),
      ),
    );
  }

  TextSpan _buildSyntaxHighlightedSpan(String code, bool isDark) {
    final spans = <TextSpan>[];

    final syntax = AgentationThemeData.resolve(isDark: isDark).syntaxColors;
    final defaultColor = syntax.defaultColor;
    final keywordColor = syntax.keywordColor;
    final typeColor = syntax.typeColor;
    final stringColor = syntax.stringColor;
    final propertyColor = syntax.propertyColor;
    final numberColor = syntax.numberColor;
    final commentColor = syntax.commentColor;
    final punctuationColor = syntax.punctuationColor;

    final pattern = RegExp(
      r'(//[^\n]*)'
      r"|('(?:\\.|[^'\\])*'|"
      r'"(?:\\.|[^"\\])*")'
      r'|(\b(?:const|final|var|void|return|true|false|null|required|new|async|await|class|extends|with|implements|static|super|import|export)\b)'
      r'|([a-zA-Z_][a-zA-Z0-9_]*(?=\s*:))'
      r'|(\b[A-Z][a-zA-Z0-9_]*\b)'
      r'|(\b\d+(?:\.\d+)?\b)'
      r'|([()[\]{},;:])',
    );

    int lastEnd = 0;
    for (final match in pattern.allMatches(code)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: code.substring(lastEnd, match.start),
          style: AgentationTypography.codeCompact.copyWith(color: defaultColor),
        ));
      }

      final matchText = match.group(0)!;
      if (match.group(1) != null) {
        spans.add(TextSpan(text: matchText, style: AgentationTypography.codeCompact.copyWith(color: commentColor, fontStyle: FontStyle.italic)));
      } else if (match.group(2) != null) {
        spans.add(TextSpan(text: matchText, style: AgentationTypography.codeCompact.copyWith(color: stringColor)));
      } else if (match.group(3) != null) {
        spans.add(TextSpan(text: matchText, style: AgentationTypography.codeCompact.copyWith(color: keywordColor, fontWeight: FontWeight.w600)));
      } else if (match.group(4) != null) {
        spans.add(TextSpan(text: matchText, style: AgentationTypography.codeCompact.copyWith(color: propertyColor)));
      } else if (match.group(5) != null) {
        spans.add(TextSpan(text: matchText, style: AgentationTypography.codeCompact.copyWith(color: typeColor, fontWeight: FontWeight.w600)));
      } else if (match.group(6) != null) {
        spans.add(TextSpan(text: matchText, style: AgentationTypography.codeCompact.copyWith(color: numberColor)));
      } else if (match.group(7) != null) {
        spans.add(TextSpan(text: matchText, style: AgentationTypography.codeCompact.copyWith(color: punctuationColor)));
      } else {
        spans.add(TextSpan(text: matchText, style: AgentationTypography.codeCompact.copyWith(color: defaultColor)));
      }

      lastEnd = match.end;
    }

    if (lastEnd < code.length) {
      spans.add(TextSpan(
        text: code.substring(lastEnd),
        style: AgentationTypography.codeCompact.copyWith(color: defaultColor),
      ));
    }

    return TextSpan(children: spans);
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
              borderRadius: AgentationRadii.br6,
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


