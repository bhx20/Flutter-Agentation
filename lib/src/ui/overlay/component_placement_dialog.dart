import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/pending_placement.dart';
import '../../domain/placement_data.dart';
import '../../theme/agentation_colors.dart';
import '../../theme/agentation_radii.dart';
import '../../theme/agentation_theme.dart';
import '../../theme/agentation_typography.dart';
import '../design/component_question_config.dart';
import '../design/skeleton_templates.dart';

/// Interactive configuration dialog / box displayed when dropping or placing any component.
///
/// Prompts the user with tailored counter-questions (e.g. Image URL vs Asset Path,
/// Button label & variant, Input placeholder & type), provides ready-to-click option presets,
/// and comes prefilled with sensible defaults so it is immediately ready to use.
class ComponentPlacementDialog extends StatefulWidget {
  const ComponentPlacementDialog({
    super.key,
    required this.pendingPlacement,
    required this.onConfirm,
    required this.onCancel,
    this.isDark = true,
    this.accentColor,
  });

  /// The pending drop event containing the skeleton template and resolved tree coordinates.
  final PendingPlacement pendingPlacement;

  /// Callback when user confirms placement with the populated details.
  final void Function(
    PlacementData placement,
    String comment,
    Map<String, dynamic> metadata,
  ) onConfirm;

  /// Callback when user cancels or dismisses the placement.
  final VoidCallback onCancel;

  /// Current dark/light theme mode.
  final bool isDark;

  /// Active accent color for highlights and primary buttons.
  final Color? accentColor;

  @override
  State<ComponentPlacementDialog> createState() => _ComponentPlacementDialogState();
}

class _ComponentPlacementDialogState extends State<ComponentPlacementDialog> {
  late ComponentQuestionConfig _config;
  late final TextEditingController _primaryController;
  late final TextEditingController _secondaryController;
  late final TextEditingController _notesController;
  late final FocusNode _primaryFocusNode;

  final ValueNotifier<Map<String, dynamic>> _selectedOptionsNotifier =
      ValueNotifier<Map<String, dynamic>>({});
  final ValueNotifier<Map<String, bool>> _behaviorValuesNotifier =
      ValueNotifier<Map<String, bool>>({});
  final ValueNotifier<double> _sliderValueNotifier = ValueNotifier<double>(50.0);
  final ValueNotifier<Offset> _dragOffsetNotifier = ValueNotifier<Offset>(Offset.zero);

  Map<String, dynamic> get _selectedOptions => _selectedOptionsNotifier.value;
  Map<String, bool> get _behaviorValues => _behaviorValuesNotifier.value;
  double get _sliderValue => _sliderValueNotifier.value;

  @override
  void initState() {
    super.initState();
    _primaryController = TextEditingController();
    _secondaryController = TextEditingController();
    _notesController = TextEditingController();
    _primaryFocusNode = FocusNode();

    _initializeForTemplate(widget.pendingPlacement.template);

    // Select text on first frame so user can easily overwrite or hit Enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _primaryFocusNode.requestFocus();
      _primaryController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _primaryController.text.length,
      );
    });
  }

  void _initializeForTemplate(SkeletonTemplate template) {
    _config = ComponentQuestionConfig.forTemplate(template);
    _primaryController.text = _config.defaultPrimaryValue;
    _secondaryController.text = _config.defaultSecondaryValue ?? '';
    _notesController.text = template.defaultPrompt;

    final initialSelected = <String, dynamic>{};
    for (final group in _config.optionGroups) {
      if (group.choices.isNotEmpty) {
        final defaultChoice = group.choices[group.defaultSelectedIndex.clamp(0, group.choices.length - 1)];
        initialSelected[group.title.replaceAll(':', '').trim()] = defaultChoice.effectiveValue;
      }
    }
    _selectedOptionsNotifier.value = initialSelected;

    final initialBehaviors = <String, bool>{};
    for (final toggle in _config.behaviorToggles) {
      initialBehaviors[toggle.key] = toggle.defaultValue;
    }
    _behaviorValuesNotifier.value = initialBehaviors;
  }

  @override
  void didUpdateWidget(ComponentPlacementDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pendingPlacement.template != widget.pendingPlacement.template) {
      _initializeForTemplate(widget.pendingPlacement.template);
    }
  }

  @override
  void dispose() {
    _primaryFocusNode.unfocus();
    _primaryController.dispose();
    _secondaryController.dispose();
    _notesController.dispose();
    _primaryFocusNode.dispose();
    _selectedOptionsNotifier.dispose();
    _behaviorValuesNotifier.dispose();
    _sliderValueNotifier.dispose();
    _dragOffsetNotifier.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final template = widget.pendingPlacement.template;
    final tree = widget.pendingPlacement.treePlacement;
    final primaryText = _primaryController.text.trim();
    final secondaryText = _secondaryController.text.trim();
    final notes = _notesController.text.trim();

    // Determine variant and source from choices or primary input
    String? source;
    if (_config.componentType == 'Image' ||
        _config.componentType == 'Avatar' ||
        _config.componentType == 'VideoPlayer' ||
        _config.componentType == 'AudioPlayer') {
      source = primaryText.isNotEmpty ? primaryText : _config.defaultPrimaryValue;
    }

    String? variant;
    for (final entry in _selectedOptions.entries) {
      if (entry.key.toLowerCase().contains('variant') ||
          entry.key.toLowerCase().contains('style') ||
          entry.key.toLowerCase().contains('preset') ||
          entry.key.toLowerCase().contains('type')) {
        variant = entry.value?.toString();
        break;
      }
    }

    final comment = _config.formatPlacementComment(
      targetLabel: template.label,
      treePlacementDescription: tree.description,
      primaryText: primaryText,
      secondaryText: secondaryText.isNotEmpty ? secondaryText : null,
      selectedOptions: _selectedOptions,
      behaviorStates: _behaviorValues,
      additionalNotes: notes.isNotEmpty ? notes : null,
    );

    final mergedProperties = <String, dynamic>{
      ..._selectedOptions,
      ..._behaviorValues,
      if (_config.behaviorCategory == ComponentBehaviorCategory.slider)
        'sliderValue': _sliderValue,
    };

    final placement = PlacementData(
      componentType: template.componentType,
      label: template.label,
      width: template.defaultWidth,
      height: template.defaultHeight,
      text: primaryText.isNotEmpty ? primaryText : _config.defaultPrimaryValue,
      prompt: notes.isNotEmpty ? notes : template.defaultPrompt,
      source: source,
      variant: variant,
      parentWidget: tree.parentWidget,
      relativeTarget: tree.relativeTarget,
      direction: tree.direction,
      treePlacement: tree.description,
      childIndex: tree.childIndex,
      totalChildren: tree.totalChildren,
      parentBreadcrumb: tree.parentBreadcrumb,
      siblingBefore: tree.siblingBefore,
      siblingAfter: tree.siblingAfter,
      properties: mergedProperties,
    );

    final metadata = <String, dynamic>{
      'path': tree.parentBreadcrumb != null
          ? '${tree.parentBreadcrumb} (${tree.description})'
          : tree.description,
      'parentWidget': tree.parentWidget,
      'direction': tree.direction,
      if (tree.relativeTarget != null) 'relativeTarget': tree.relativeTarget,
      if (tree.siblingBefore != null) 'siblingBefore': tree.siblingBefore,
      if (tree.siblingAfter != null) 'siblingAfter': tree.siblingAfter,
      if (tree.childIndex != null) 'childIndex': tree.childIndex,
      if (tree.parentBreadcrumb != null) 'parentBreadcrumb': tree.parentBreadcrumb,
      'treePlacement': tree.description,
      'source': ?source,
      'variant': ?variant,
      'behaviorCategory': _config.behaviorCategory.name,
      'styleInstruction': 'Understand the project theme and decoration style from the codebase, and develop this component based on existing project patterns.',
      if (mergedProperties.isNotEmpty) 'options': mergedProperties,
      if (tree.sourceLocation?.fileString != null)
        'sourceFile': tree.sourceLocation!.fileString,
    };

    widget.onConfirm(placement, comment, metadata);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final theme = AgentationThemeData.resolve(isDark: widget.isDark);
    final accent = widget.accentColor ?? AgentationColors.indigo;

    final template = widget.pendingPlacement.template;
    final tree = widget.pendingPlacement.treePlacement;

    final isMobile = screenSize.width < 600.0;
    final hasOptions = _config.behaviorToggles.isNotEmpty || _config.optionGroups.isNotEmpty;
    final isHorizontal = !isMobile && hasOptions;

    final cardWidth = isHorizontal
        ? math.min(620.0, screenSize.width - 24.0)
        : math.min(340.0, screenSize.width - 24.0);
    final maxCardHeight = math.min(isMobile ? 520.0 : 440.0, screenSize.height - 32.0);

    return FocusScope(
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              widget.onCancel();
            } else if (event.logicalKey == LogicalKeyboardKey.enter &&
                HardwareKeyboard.instance.isMetaPressed) {
              _submit();
            }
          }
        },
        child: Stack(
          children: [
            // Scrim to dismiss
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onCancel,
                child: Container(color: Colors.black.withValues(alpha: 0.15)),
              ),
            ),

            // Dialog Card
            ValueListenableBuilder<Offset>(
              valueListenable: _dragOffsetNotifier,
              builder: (context, dragOffset, _) {
                // Calculate clamped bounds: top + maxCardHeight will never exceed screen bounds
                final maxTop = math.max(12.0, screenSize.height - maxCardHeight - 12.0);
                final preferredTop = isMobile
                    ? (screenSize.height - maxCardHeight) / 2.0
                    : (widget.pendingPlacement.position.dy - (maxCardHeight / 2.5) + dragOffset.dy);

                final top = preferredTop.clamp(12.0, maxTop).toDouble();
                final left = (widget.pendingPlacement.position.dx - (cardWidth / 2.0) + dragOffset.dx)
                    .clamp(12.0, math.max(12.0, screenSize.width - cardWidth - 12.0))
                    .toDouble();

                final availableCardHeight = (screenSize.height - top - 12.0).clamp(180.0, maxCardHeight);

                return Positioned(
                  left: left,
                  top: top,
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerSignal: (_) {}, // Absorb pointer signals to isolate from background page scrolling
                    child: MouseRegion(
                      cursor: SystemMouseCursors.basic,
                      child: Material(
                        color: Colors.transparent,
                        elevation: 16.0,
                        borderRadius: AgentationRadii.br16,
                        child: Container(
                          width: cardWidth,
                          constraints: BoxConstraints(
                            maxHeight: availableCardHeight,
                          ),
                          decoration: BoxDecoration(
                            color: theme.cardBackground,
                            borderRadius: AgentationRadii.br16,
                            boxShadow: theme.cardShadows,
                          ),
                          child: ListenableBuilder(
                            listenable: Listenable.merge([
                              _selectedOptionsNotifier,
                              _behaviorValuesNotifier,
                              _sliderValueNotifier,
                            ]),
                            builder: (context, _) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Header & drag handle
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onPanUpdate: (details) {
                                      _dragOffsetNotifier.value += details.delta;
                                    },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? Colors.white.withValues(alpha: 0.03)
                                    : Colors.black.withValues(alpha: 0.02),
                                borderRadius: AgentationRadii.brTop16,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.15),
                                      borderRadius: AgentationRadii.br6,
                                    ),
                                    child: Icon(
                                      template.icon,
                                      size: 14.0,
                                      color: accent,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Configure ${template.label}',
                                          style: AgentationTypography.dialogItemTitle.copyWith(color: theme.textPrimary),
                                        ),
                                        Text(
                                          tree.parentWidget.isNotEmpty
                                              ? 'Target: ${tree.parentWidget} • ${tree.description}'
                                              : tree.description,
                                          style: AgentationTypography.dialogItemSubtitle.copyWith(color: theme.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: 15.0,
                                      color: theme.textSecondary,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 22.0, minHeight: 22.0),
                                    splashRadius: 12.0,
                                    onPressed: widget.onCancel,
                                    tooltip: 'Cancel (Esc)',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Scrollable content body with scroll event isolation
                          Flexible(
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (_) => true,
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                                child: isHorizontal
                                    ? Row(
                                        key: const ValueKey('agentation_placement_horizontal_row'),
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Left Column: Live Card, Inputs & Instructions
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (_config.behaviorCategory == ComponentBehaviorCategory.toggle) ...[
                                                  _buildLiveToggleCard(theme, accent, template),
                                                  const SizedBox(height: 10.0),
                                                ] else if (_config.behaviorCategory == ComponentBehaviorCategory.slider) ...[
                                                  _buildLiveSliderCard(theme, accent),
                                                  const SizedBox(height: 10.0),
                                                ],
                                                _buildPrimaryInputSection(theme, accent),
                                                if (_config.secondaryInputLabel != null) ...[
                                                  const SizedBox(height: 8.0),
                                                  _buildSecondaryInputSection(theme, accent)!,
                                                ],
                                                const SizedBox(height: 8.0),
                                                _buildNotesSection(theme, accent),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 18.0),
                                          // Right Column: Behavior Toggles & Option Groups
                                          Expanded(
                                            child: _buildOptionsSection(theme, accent),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        key: const ValueKey('agentation_placement_vertical_column'),
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_config.behaviorCategory == ComponentBehaviorCategory.toggle) ...[
                                            _buildLiveToggleCard(theme, accent, template),
                                            const SizedBox(height: 10.0),
                                          ] else if (_config.behaviorCategory == ComponentBehaviorCategory.slider) ...[
                                            _buildLiveSliderCard(theme, accent),
                                            const SizedBox(height: 10.0),
                                          ],
                                          _buildPrimaryInputSection(theme, accent),
                                          if (_config.secondaryInputLabel != null) ...[
                                            const SizedBox(height: 8.0),
                                            _buildSecondaryInputSection(theme, accent)!,
                                          ],
                                          if (hasOptions) ...[
                                            const SizedBox(height: 10.0),
                                            _buildOptionsSection(theme, accent),
                                          ],
                                          const SizedBox(height: 8.0),
                                          _buildNotesSection(theme, accent),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          // Footer actions with clean borderless transition
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? Colors.white.withValues(alpha: 0.02)
                                  : Colors.black.withValues(alpha: 0.015),
                              borderRadius: AgentationRadii.brBottom16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: widget.onCancel,
                                  borderRadius: AgentationRadii.br6,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Text(
                                      'Cancel',
                                      style: AgentationTypography.panelDescription.copyWith(color: theme.textSecondary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Flexible(
                                  child: ElevatedButton(
                                    onPressed: _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      foregroundColor: Colors.white,
                                      elevation: 0.0,
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      fixedSize: const Size.fromHeight(26.0),
                                      minimumSize: const Size(40.0, 26.0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AgentationRadii.br13,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check, size: 12.0),
                                        SizedBox(width: 4.0),
                                        Text(
                                          'Place Component',
                                          style: AgentationTypography.dialogAction,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  ],
),
),
);
  }

  Widget _buildPrimaryInputSection(AgentationThemeData theme, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _config.primaryInputLabel,
          style: AgentationTypography.dialogSectionTitle.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 5.0),
        TextField(
          controller: _primaryController,
          focusNode: _primaryFocusNode,
          style: AgentationTypography.panelInput.copyWith(color: theme.textPrimary),
          cursorColor: accent,
          decoration: InputDecoration(
            hintText: _config.primaryInputPlaceholder,
            hintStyle: AgentationTypography.panelInputHint.copyWith(color: theme.textMuted),
            isDense: true,
            filled: true,
            fillColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            border: OutlineInputBorder(
              borderRadius: AgentationRadii.br8,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AgentationRadii.br8,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AgentationRadii.br8,
              borderSide: BorderSide.none,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _primaryController,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.clear, size: 14.0),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24.0, minHeight: 24.0),
                  onPressed: () {
                    _primaryController.clear();
                  },
                );
              },
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
      ],
    );
  }

  Widget? _buildSecondaryInputSection(AgentationThemeData theme, Color accent) {
    if (_config.secondaryInputLabel == null) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _config.secondaryInputLabel!,
          style: AgentationTypography.dialogSectionTitle.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 5.0),
        TextField(
          controller: _secondaryController,
          style: AgentationTypography.panelInput.copyWith(color: theme.textPrimary),
          cursorColor: accent,
          decoration: InputDecoration(
            hintText: _config.secondaryInputPlaceholder,
            hintStyle: AgentationTypography.panelInputHint.copyWith(color: theme.textMuted),
            isDense: true,
            filled: true,
            fillColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            border: OutlineInputBorder(
              borderRadius: AgentationRadii.br8,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AgentationRadii.br8,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AgentationRadii.br8,
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
      ],
    );
  }

  Widget _buildNotesSection(AgentationThemeData theme, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Instructions for AI Coding Agent:',
          style: AgentationTypography.dialogSectionTitle.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: 5.0),
        TextField(
          controller: _notesController,
          minLines: 1,
          maxLines: 2,
          style: AgentationTypography.panelInput.copyWith(color: theme.textPrimary, fontSize: 11.5),
          cursorColor: accent,
          decoration: InputDecoration(
            hintText: _config.notesPlaceholder,
            hintStyle: AgentationTypography.panelInputHint.copyWith(color: theme.textMuted, fontSize: 11.5),
            isDense: true,
            filled: true,
            fillColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            border: OutlineInputBorder(
              borderRadius: AgentationRadii.br8,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AgentationRadii.br8,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AgentationRadii.br8,
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection(AgentationThemeData theme, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Component Behavior & State Toggles
        if (_config.behaviorToggles.isNotEmpty) ...[
          Text(
            'Behavior & State:',
            style: AgentationTypography.dialogSectionTitle.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: 5.0),
          Wrap(
            spacing: 6.0,
            runSpacing: 5.0,
            children: [
              for (final toggle in _config.behaviorToggles)
                _buildBehaviorToggleChip(toggle, theme, accent),
            ],
          ),
          const SizedBox(height: 8.0),
        ],

        // Component Option Groups (Variant, Intent, Fit, Alignment)
        for (final group in _config.optionGroups) ...[
          if (group.title == 'Alignment:') ...[
            Text(
              group.title,
              style: AgentationTypography.dialogSectionTitle.copyWith(color: theme.textSecondary),
            ),
            const SizedBox(height: 5.0),
            Row(
              children: [
                for (final choice in group.choices) ...[
                  _buildAlignmentChip(group, choice, theme, accent),
                  const SizedBox(width: 6.0),
                ],
              ],
            ),
            const SizedBox(height: 8.0),
          ] else ...[
            Text(
              group.title,
              style: AgentationTypography.dialogSectionTitle.copyWith(color: theme.textSecondary),
            ),
            const SizedBox(height: 5.0),
            Wrap(
              spacing: 6.0,
              runSpacing: 5.0,
              children: [
                for (int i = 0; i < group.choices.length; i++)
                  _buildOptionChip(group, group.choices[i], theme, accent),
              ],
            ),
            const SizedBox(height: 8.0),
          ],
        ],
      ],
    );
  }

  /// Live interactive preview card for toggle switches and checkboxes
  Widget _buildLiveToggleCard(AgentationThemeData theme, Color accent, dynamic template) {
    final isChecked = _behaviorValues['checked'] ?? true;
    final isSwitch = template.componentType.toString().contains('Switch');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: AgentationRadii.br10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _primaryController.text.isNotEmpty ? _primaryController.text : 'Setting Label',
                  style: AgentationTypography.dialogItemTitle.copyWith(color: theme.textPrimary, fontWeight: FontWeight.normal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isChecked ? 'Active state: ON (true)' : 'Inactive state: OFF (false)',
                  style: AgentationTypography.dialogItemSubtitle.copyWith(color: isChecked ? accent : theme.textSecondary),
                ),
              ],
            ),
          ),
          if (isSwitch)
            Switch.adaptive(
              value: isChecked,
              onChanged: (val) {
                _behaviorValuesNotifier.value = {
                  ..._behaviorValuesNotifier.value,
                  'checked': val,
                };
              },
              activeThumbColor: accent,
            )
          else
            Checkbox(
              value: isChecked,
              onChanged: (val) {
                _behaviorValuesNotifier.value = {
                  ..._behaviorValuesNotifier.value,
                  'checked': val ?? false,
                };
              },
              activeColor: accent,
            ),
        ],
      ),
    );
  }

  /// Live interactive preview card for slider widgets
  Widget _buildLiveSliderCard(AgentationThemeData theme, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: AgentationRadii.br10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Slider Position:',
                style: AgentationTypography.dialogSectionTitle.copyWith(color: theme.textSecondary),
              ),
              Text(
                '${_sliderValue.round()}%',
                style: AgentationTypography.captionSemiBold.copyWith(color: accent, fontSize: 11.5),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accent,
              thumbColor: accent,
              overlayColor: accent.withValues(alpha: 0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              trackHeight: 3.0,
            ),
            child: Slider(
              value: _sliderValue,
              min: 0.0,
              max: 100.0,
              divisions: (_behaviorValues['divisions'] ?? false) ? 5 : null,
              onChanged: (v) {
                _sliderValueNotifier.value = v;
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Chip for boolean behavioral flags (e.g. Loading State, Clearable, With Icon)
  Widget _buildBehaviorToggleChip(
    ComponentBehaviorToggle toggle,
    AgentationThemeData theme,
    Color accent,
  ) {
    final isActive = _behaviorValues[toggle.key] ?? toggle.defaultValue;
    final unselectedBg = widget.isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.05);

    return InkWell(
      onTap: () {
        _behaviorValuesNotifier.value = {
          ..._behaviorValuesNotifier.value,
          toggle.key: !isActive,
        };
      },
      borderRadius: AgentationRadii.br8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isActive ? accent : unselectedBg,
          borderRadius: AgentationRadii.br8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive
                  ? (toggle.activeIcon ?? toggle.icon ?? Icons.check)
                  : (toggle.icon ?? Icons.radio_button_unchecked),
              size: 12.0,
              color: isActive
                  ? Colors.white
                  : (widget.isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.6)),
            ),
            const SizedBox(width: 5.0),
            Flexible(
              child: Text(
                toggle.label,
                style: AgentationTypography.dialogAction.copyWith(color: isActive ? Colors.white : (widget.isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.85))),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chip for alignment selection with icons (Left, Center, Right)
  Widget _buildAlignmentChip(
    ComponentOptionGroup group,
    ComponentOptionChoice choice,
    AgentationThemeData theme,
    Color accent,
  ) {
    final groupKey = group.title.replaceAll(':', '').trim();
    final isSelected = _selectedOptions[groupKey] == choice.effectiveValue;
    final unselectedBg = widget.isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.05);

    return InkWell(
      onTap: () {
        _selectedOptionsNotifier.value = {
          ..._selectedOptionsNotifier.value,
          groupKey: choice.effectiveValue,
        };
      },
      borderRadius: AgentationRadii.br8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? accent : unselectedBg,
          borderRadius: AgentationRadii.br8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (choice.icon != null) ...[
              Icon(
                choice.icon,
                size: 13.0,
                color: isSelected
                    ? Colors.white
                    : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.6)),
              ),
              const SizedBox(width: 5.0),
            ],
            Flexible(
              child: Text(
                choice.label,
                style: AgentationTypography.dialogAction.copyWith(color: isSelected ? Colors.white : (widget.isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.85))),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionChip(
    ComponentOptionGroup group,
    ComponentOptionChoice choice,
    AgentationThemeData theme,
    Color accent,
  ) {
    final groupKey = group.title.replaceAll(':', '').trim();
    final isSelected = _selectedOptions[groupKey] == choice.effectiveValue;
    final unselectedBg = widget.isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.05);

    return InkWell(
      onTap: () {
        _selectedOptionsNotifier.value = {
          ..._selectedOptionsNotifier.value,
          groupKey: choice.effectiveValue,
        };
        // If this choice provides a preset text, immediately populate the primary text field!
        if (choice.presetText != null) {
          _primaryController.text = choice.presetText!;
          _primaryController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _primaryController.text.length,
          );
        }
      },
      borderRadius: AgentationRadii.br8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? accent : unselectedBg,
          borderRadius: AgentationRadii.br8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (choice.icon != null) ...[
              Icon(
                choice.icon,
                size: 12.0,
                color: isSelected
                    ? Colors.white
                    : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.6)),
              ),
              const SizedBox(width: 4.0),
            ],
            Flexible(
              child: Text(
                choice.label,
                style: AgentationTypography.dialogAction.copyWith(color: isSelected ? Colors.white : (widget.isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.85))),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

