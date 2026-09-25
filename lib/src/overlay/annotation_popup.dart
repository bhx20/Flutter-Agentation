import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_scope.dart';
import '../models/annotation_intent.dart';
import '../models/annotation_severity.dart';
import '../models/widget_inspection_result.dart';

/// Interactive popup card for creating an annotation attached to an inspected widget.
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
  late AnnotationIntent _selectedIntent;
  late AnnotationSeverity _selectedSeverity;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _selectedIntent = widget.initialIntent;
    _selectedSeverity = widget.initialSeverity;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    setState(() => _isSaving = true);
    final controller = AgentationScope.of(context);

    try {
      await controller.createAnnotation(
        comment: comment,
        intent: _selectedIntent,
        severity: _selectedSeverity,
        targetResult: widget.result,
      );
      widget.onClose();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bounds = widget.result.bounds;
    const cardWidth = 340.0;
    const estimatedHeight = 380.0;

    final controller = AgentationScope.maybeOf(context);
    final hierarchy = controller?.activeHierarchy;

    final breadcrumbList = <WidgetInspectionResult>[
      if (hierarchy != null) ...hierarchy.ancestors,
      if (hierarchy != null &&
          !hierarchy.ancestors.any((a) => a.identity == hierarchy.primaryTarget.identity))
        hierarchy.primaryTarget,
      if (hierarchy != null &&
          !hierarchy.ancestors.any((a) => a.identity == widget.result.identity) &&
          hierarchy.primaryTarget.identity != widget.result.identity &&
          !hierarchy.children.any((c) => c.identity == widget.result.identity))
        widget.result,
    ];

    // Position calculation with viewport clamping
    final left = bounds.x.clamp(8.0, math.max(8.0, screenSize.width - cardWidth - 8.0)).toDouble();
    final double top;
    if (bounds.y + bounds.height + 12.0 + estimatedHeight < screenSize.height - 20.0) {
      top = bounds.y + bounds.height + 12.0;
    } else if (bounds.y - estimatedHeight - 12.0 > 40.0) {
      top = bounds.y - estimatedHeight - 12.0;
    } else {
      top = math.max(16.0, (screenSize.height - estimatedHeight) / 2.0);
    }

    final keyString = widget.result.identity.keyString;

    return Positioned(
      left: left,
      top: top,
      width: cardWidth,
      child: Material(
        color: Colors.transparent,
        elevation: 16.0,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xF0181825), // Catppuccin / Slate 950 glass
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0x336366F1), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x7F000000),
                blurRadius: 24.0,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: const Color(0x266366F1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(
                      Icons.widgets_outlined,
                      size: 16.0,
                      color: Color(0xFF818CF8),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.result.identity.widgetType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (keyString != null)
                          Text(
                            keyString,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16.0, color: Colors.white60),
                    onPressed: widget.onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              // Multi-level hierarchy breadcrumbs (Ancestors -> Primary Target)
              if (hierarchy != null && breadcrumbList.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      Icons.account_tree_outlined,
                      size: 12.0,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Hierarchy',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < breadcrumbList.length; i++) ...[
                        if (i > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Icon(
                              Icons.chevron_right,
                              size: 14.0,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        _buildHierarchyChip(
                          breadcrumbList[i],
                          isSelected: breadcrumbList[i].identity == widget.result.identity,
                          controller: controller,
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Child widgets explorer
              if (hierarchy != null && hierarchy.children.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right,
                      size: 12.0,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Child Elements',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final child in hierarchy.children)
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: _buildHierarchyChip(
                            child,
                            isSelected: child.identity == widget.result.identity,
                            controller: controller,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12.0),

              // Comment text field
              TextField(
                controller: _commentController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 13.0),
                decoration: InputDecoration(
                  hintText: 'Add feedback, bug notes, or design suggestions...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12.0),
                  filled: true,
                  fillColor: const Color(0xFF1E1E2E),
                  contentPadding: const EdgeInsets.all(10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),

              // Intent Chips
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: [
                  _buildIntentChip('Change', AnnotationIntent.change),
                  _buildIntentChip('Bug', AnnotationIntent.bug),
                  _buildIntentChip('Suggestion', AnnotationIntent.suggestion),
                  _buildIntentChip('Question', AnnotationIntent.question),
                ],
              ),
              const SizedBox(height: 8.0),

              // Severity Dots
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      'Severity: ',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11.0),
                    ),
                    const SizedBox(width: 4.0),
                    ...AnnotationSeverity.values.map((sev) {
                      final isSelected = _selectedSeverity == sev;
                      return InkWell(
                        onTap: () => setState(() => _selectedSeverity = sev),
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3.0),
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: isSelected ? sev.color.withValues(alpha: 0.25) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.0),
                            border: isSelected ? Border.all(color: sev.color, width: 1.0) : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.0,
                                height: 6.0,
                                decoration: BoxDecoration(color: sev.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                sev.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white60,
                                  fontSize: 10.0,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onClose,
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.0),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _handleSave,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check, size: 14.0),
                    label: const Text('Save Note', style: TextStyle(fontSize: 12.0)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntentChip(String label, AnnotationIntent intent) {
    final isSelected = _selectedIntent == intent;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedIntent = intent),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontSize: 10.0,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: const Color(0xFF4F46E5),
      backgroundColor: const Color(0xFF1E1E2E),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildHierarchyChip(
    WidgetInspectionResult candidate, {
    required bool isSelected,
    required AgentationController? controller,
  }) {
    return ActionChip(
      onPressed: () {
        controller?.selectTarget(candidate);
      },
      label: Text(candidate.identity.widgetType),
      backgroundColor: isSelected
          ? const Color(0xFF4F46E5)
          : const Color(0xFF1E1E2E),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF818CF8)
            : Colors.white.withValues(alpha: 0.12),
        width: 1.0,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontSize: 10.0,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
