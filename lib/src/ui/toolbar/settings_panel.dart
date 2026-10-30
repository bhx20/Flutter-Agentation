import 'package:flutter/material.dart';
import '../../core/agentation_controller.dart';
import '../../core/agentation_scope.dart';
import '../../core/package_version.dart';
import '../../domain/marker_color.dart';
import '../../domain/toolbar_settings.dart';
import '../../theme/agentation_colors.dart';
import '../../theme/agentation_theme.dart';
import '../../theme/agentation_typography.dart';
import 'agentation_icons.dart';
import 'agentation_tooltip.dart';
import 'mcp_webhooks_panel.dart';

/// Settings panel matching the official Agentation design system without MCP.
class SettingsPanel extends StatefulWidget {
  const SettingsPanel({
    super.key,
    required this.onClose,
    this.controller,
  });

  final VoidCallback onClose;
  final AgentationController? controller;

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final GlobalKey _panelKey = GlobalKey();
  final GlobalKey _mainViewKey = GlobalKey();
  AgentationController? _controller;
  final ValueNotifier<bool> _showMcpWebhooksNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isNavigatingForwardNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<double?> _mainPanelHeightNotifier = ValueNotifier<double?>(null);

  AgentationController get _ctrl =>
      widget.controller ?? AgentationScope.of(context);

  @override
  void initState() {
    super.initState();
    PackageVersion.loadFromYaml();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= widget.controller ?? AgentationScope.maybeOf(context);
    _updateFlyoutBounds();
  }

  void _updateFlyoutBounds() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderBox = _panelKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final origin = renderBox.localToGlobal(Offset.zero);
        final bounds = Rect.fromLTWH(origin.dx, origin.dy, renderBox.size.width, renderBox.size.height);
        _controller?.updateFlyoutBounds(bounds);
      }
      final mainBox = _mainViewKey.currentContext?.findRenderObject() as RenderBox?;
      if (mainBox != null && mainBox.hasSize && mainBox.size.height > 100) {
        if (_mainPanelHeightNotifier.value != mainBox.size.height) {
          _mainPanelHeightNotifier.value = mainBox.size.height;
        }
      }
    });
  }

  @override
  void dispose() {
    _showMcpWebhooksNotifier.dispose();
    _isNavigatingForwardNotifier.dispose();
    _mainPanelHeightNotifier.dispose();
    _controller?.updateFlyoutBounds(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _updateFlyoutBounds();
    final controller = _ctrl;

    return ListenableBuilder(
      listenable: Listenable.merge([
        controller,
        _showMcpWebhooksNotifier,
        _isNavigatingForwardNotifier,
        _mainPanelHeightNotifier,
      ]),
      builder: (context, _) {
        final showMcpWebhooks = _showMcpWebhooksNotifier.value;
        final isNavigatingForward = _isNavigatingForwardNotifier.value;
        final mainPanelHeight = _mainPanelHeightNotifier.value;
        final settings = controller.settings;
        final isDark = settings.isDarkMode;
        final theme = AgentationThemeData.resolve(isDark: isDark);

        final textColor = theme.textPrimary;
        final subtextColor = theme.textSecondary;
        final dividerColor = theme.dividerColor;

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerSignal: (_) {},
          child: Material(
            key: _panelKey,
            color: Colors.transparent,
            child: Container(
              width: 260.0,
              decoration: BoxDecoration(
                color: theme.panelBackground,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: theme.panelBorderColor, width: 1.0),
                boxShadow: theme.panelShadows,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          ...previousChildren,
                          ?currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final isIncoming = (child.key == const ValueKey('settings_mcp_webhooks_view')) == showMcpWebhooks;
                      final begin = isIncoming
                          ? (isNavigatingForward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0))
                          : (isNavigatingForward ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0));
                      return SlideTransition(
                        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: isIncoming ? Curves.easeOutCubic : Curves.easeInCubic,
                          ),
                        ),
                        child: child,
                      );
                    },
                    child: showMcpWebhooks
                        ? KeyedSubtree(
                            key: const ValueKey('settings_mcp_webhooks_view'),
                            child: SizedBox(
                              width: double.infinity,
                              child: McpWebhooksPanel(
                                controller: controller,
                                targetHeight: mainPanelHeight,
                                onBack: () {
                                  _isNavigatingForwardNotifier.value = false;
                                  _showMcpWebhooksNotifier.value = false;
                                },
                              ),
                            ),
                          )
                        : KeyedSubtree(
                            key: const ValueKey('settings_main_view'),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                key: _mainViewKey,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                    // ── Header: Agentation v0.0.1 + Moon/Sun Theme Toggle ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  'Flutter Agentation',
                                  style: AgentationTypography.title.copyWith(
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                ValueListenableBuilder<String>(
                                  valueListenable: PackageVersion.versionNotifier,
                                  builder: (context, version, _) => Text(
                                    'v$version',
                                    style: AgentationTypography.subtext.copyWith(
                                      color: subtextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _ThemeToggleButton(
                          key: const ValueKey('theme_toggle_button'),
                          isDark: isDark,
                          onToggle: controller.toggleTheme,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10.0),
                    Divider(height: 1.0, thickness: 1.0, color: dividerColor),
                    const SizedBox(height: 12.0),

                    // ── Row 1: Output Detail ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Output Detail',
                                  style: AgentationTypography.body.copyWith(
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              const _HelpTooltip(
                                content: 'Controls how much detail is included in the copied output',
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: controller.cycleDetailLevel,
                          borderRadius: BorderRadius.circular(4.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeOut,
                                  layoutBuilder: (currentChild, previousChildren) {
                                    return Stack(
                                      alignment: Alignment.centerLeft,
                                      children: <Widget>[
                                        ...previousChildren,
                                        ?currentChild,
                                      ],
                                    );
                                  },
                                  transitionBuilder: (child, animation) {
                                    final isIncoming = (child.key as ValueKey<OutputDetailLevel>?)?.value ==
                                        settings.outputDetail;
                                    if (!isIncoming) {
                                      // Existing text cuts out immediately as next text slides in,
                                      // matching React mounting a new span with animation: cycleTextIn 0.2s
                                      return const SizedBox.shrink();
                                    }
                                    final slideAnimation = Tween<Offset>(
                                      begin: const Offset(0.0, -0.4),
                                      end: Offset.zero,
                                    ).animate(animation);
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: slideAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    _getDetailLabel(settings.outputDetail),
                                    key: ValueKey(settings.outputDetail),
                                    style: AgentationTypography.body.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                _DetailLevelIndicator(
                                  currentLevel: settings.outputDetail,
                                  activeColor: textColor,
                                  inactiveColor: isDark
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : textColor.withValues(alpha: 0.25),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10.0),

                    // ── Row 2: Hide Until Restart ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Hide Until Restart',
                                  style: AgentationTypography.body.copyWith(
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              const _HelpTooltip(
                                content: 'Hides the toolbar until restart',
                              ),
                            ],
                          ),
                        ),
                        _AgentationSwitch(
                          key: const ValueKey('toggle_hide_until_restart'),
                          value: settings.hideUntilRestart,
                          isDark: isDark,
                          onChanged: (val) {
                            widget.onClose();
                            controller.setHideUntilRestart(val);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12.0),
                    Divider(height: 1.0, thickness: 1.0, color: dividerColor),
                    const SizedBox(height: 10.0),

                    // ── Marker Color ──
                    Text(
                      'Marker Color',
                      style: AgentationTypography.sectionHeader.copyWith(
                        color: subtextColor,
                        fontSize: 12.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // ── 7 Swatches with Concentric Ring Selection ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: MarkerColor.values.map((swatch) {
                        final selectedColorId = MarkerColor.findById(settings.markerColorId).id;
                        final isSelected = selectedColorId == swatch.id;
                        return Tooltip(
                          message: swatch.label,
                          triggerMode: TooltipTriggerMode.manual,
                          child: GestureDetector(
                            key: ValueKey('swatch_${swatch.id}'),
                            onTap: () => controller.setMarkerColorId(swatch.id),
                            behavior: HitTestBehavior.opaque,
                            child: SizedBox(
                              width: 24.0,
                              height: 24.0,
                              child: Center(
                                child: isSelected
                                    ? Container(
                                        width: 24.0,
                                        height: 24.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: swatch.color, width: 2.0),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 14.0,
                                            height: 14.0,
                                            decoration: BoxDecoration(
                                              color: swatch.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 20.0,
                                        height: 20.0,
                                        decoration: BoxDecoration(
                                          color: swatch.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12.0),
                    Divider(height: 1.0, thickness: 1.0, color: dividerColor),
                    const SizedBox(height: 10.0),

                    // ── Checkbox 1: Clear on copy/send ──
                    InkWell(
                      key: const ValueKey('toggle_auto_clear'),
                      onTap: () {
                        controller.updateSettings(
                          settings.copyWith(
                            autoClearAfterCopy: !settings.autoClearAfterCopy,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(4.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            _buildCustomCheckbox(
                              checked: settings.autoClearAfterCopy,
                              theme: theme,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Clear on copy/send',
                                      style: AgentationTypography.body.copyWith(
                                        color: textColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  const _HelpTooltip(
                                    content: 'Automatically clear annotations after copying',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 4.0),

                    // ── Checkbox 2: Block page interactions ──
                    InkWell(
                      key: const ValueKey('toggle_block_interactions'),
                      onTap: () {
                        controller.updateSettings(
                          settings.copyWith(
                            blockInteractions: !settings.blockInteractions,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(4.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            _buildCustomCheckbox(
                              checked: settings.blockInteractions,
                              theme: theme,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                'Block page interactions',
                                style: AgentationTypography.body.copyWith(
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10.0),
                    Divider(height: 1.0, thickness: 1.0, color: dividerColor),
                    const SizedBox(height: 8.0),

                    // ── Nav Link: Manage MCP & Webhooks (matching official Agentation) ──
                    InkWell(
                      key: const ValueKey('settings_nav_mcp_webhooks'),
                      onTap: () {
                        _isNavigatingForwardNotifier.value = true;
                        _showMcpWebhooksNotifier.value = true;
                      },
                      borderRadius: BorderRadius.circular(6.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Manage MCP & Webhooks',
                                style: AgentationTypography.body.copyWith(
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (controller.mcpServer.isRunning || controller.syncClient?.endpoint.isNotEmpty == true)
                                  Container(
                                    width: 6.0,
                                    height: 6.0,
                                    margin: const EdgeInsets.only(right: 6.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.statusConnected,
                                    ),
                                  )
                                else if (controller.settings.mcpEnabled)
                                  Container(
                                    width: 6.0,
                                    height: 6.0,
                                    margin: const EdgeInsets.only(right: 6.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.statusConnecting,
                                    ),
                                  ),
                                _PanelHoverIconButton(
                                  key: const ValueKey('settings_forward_mcp_webhooks'),
                                  icon: Icons.chevron_right,
                                  size: 22.0,
                                  iconSize: 16.0,
                                  isDark: isDark,
                                  onTap: () {
                                    _isNavigatingForwardNotifier.value = true;
                                    _showMcpWebhooksNotifier.value = true;
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
                    ),
                  ),
                ),
              ),
            ),
        );
      },
    );
  }

  Widget _buildCustomCheckbox({required bool checked, required AgentationThemeData theme}) {
    return Container(
      width: 16.0,
      height: 16.0,
      decoration: BoxDecoration(
        color: checked ? theme.textPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(4.5),
        border: Border.all(
          color: checked
              ? theme.textPrimary
              : (theme.isDark ? AgentationColors.darkCheckboxBorder : AgentationColors.lightBorderGray),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: checked
          ? Icon(
              Icons.check,
              size: 11.0,
              color: theme.isDark ? Colors.black : Colors.white,
            )
          : null,
    );
  }

  String _getDetailLabel(OutputDetailLevel level) {
    switch (level) {
      case OutputDetailLevel.compact:
        return 'Compact';
      case OutputDetailLevel.standard:
        return 'Standard';
      case OutputDetailLevel.detailed:
        return 'Detailed';
      case OutputDetailLevel.forensic:
        return 'Forensic';
    }
  }
}

class _HelpTooltip extends StatelessWidget {
  const _HelpTooltip({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    return AgentationTooltip.help(content: content);
  }
}

/// Compact miniature toggle switch matching upstream Agentation (24px x 16px).
class _AgentationSwitch extends StatelessWidget {
  const _AgentationSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const trackWidth = 24.0;
    const trackHeight = 16.0;
    const thumbSize = 12.0;

    final trackColor = value
        ? AgentationColors.platformBlue
        : (isDark ? AgentationColors.darkBorderMuted : AgentationColors.lightBorderSubtle);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          width: trackWidth,
          height: trackHeight,
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Align(
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: thumbSize,
              height: thumbSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AgentationColors.shadowHeavy,
                    blurRadius: 2.0,
                    offset: Offset(0, 1),
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

/// A 4-dot vertical indicator showing the active [OutputDetailLevel].
///
/// Each dot represents one level (Compact, Standard, Detailed, Forensic) from top to bottom.
/// The dot corresponding to the active level is highlighted with [activeColor], while
/// inactive dots use [inactiveColor].
class _DetailLevelIndicator extends StatelessWidget {
  const _DetailLevelIndicator({
    required this.currentLevel,
    required this.activeColor,
    required this.inactiveColor,
  });

  final OutputDetailLevel currentLevel;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    const levels = OutputDetailLevel.values;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(levels.length, (index) {
        final isActive = levels[index] == currentLevel;
        final dotSize = isActive ? 3.0 : 2.0;
        return Padding(
          padding: EdgeInsets.only(bottom: index < levels.length - 1 ? 2.5 : 0.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

/// A theme toggle button matching the exact dimensions, hover effects, and
/// rotation/scale entrance animation from the reference Agentation codebase:
/// - Size: 22x22, border-radius: 6px
/// - Hover background: rgba(255, 255, 255, 0.1) in dark, rgba(0, 0, 0, 0.06) in light
/// - Normal icon color: rgba(255, 255, 255, 0.4) in dark, rgba(0, 0, 0, 0.4) in light
/// - Hover icon color: rgba(255, 255, 255, 0.8) in dark, rgba(0, 0, 0, 0.7) in light
/// - Animation: 0.35s scale(0.8) rotate(-30deg) to scale(1) rotate(0deg)
class _ThemeToggleButton extends StatefulWidget {
  const _ThemeToggleButton({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  final bool isDark;
  final VoidCallback onToggle;

  @override
  State<_ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<_ThemeToggleButton> {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isHovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalColor = widget.isDark
        ? const Color.fromRGBO(255, 255, 255, 0.4)
        : const Color.fromRGBO(0, 0, 0, 0.4);
    final hoverColor = widget.isDark
        ? const Color.fromRGBO(255, 255, 255, 0.8)
        : const Color.fromRGBO(0, 0, 0, 0.7);

    final hoverBg = widget.isDark
        ? const Color.fromRGBO(255, 255, 255, 0.1)
        : const Color.fromRGBO(0, 0, 0, 0.06);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _isHovered.value = true,
      onExit: (_) => _isHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isHovered,
        builder: (context, isHovered, _) {
          final backgroundColor = isHovered ? hoverBg : Colors.transparent;
          final iconColor = isHovered ? hoverColor : normalColor;

          return GestureDetector(
            onTap: widget.onToggle,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.ease,
          width: 22.0,
          height: 22.0,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: const Cubic(0.34, 1.56, 0.64, 1.0),
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) {
                  final isIncoming = (child.key as ValueKey<bool>?)?.value == widget.isDark;
                  if (!isIncoming) {
                    return const SizedBox.shrink();
                  }
                  final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(animation);
                  final rotateAnimation = Tween<double>(begin: -30.0 * 3.141592653589793 / 180.0, end: 0.0)
                      .animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: AnimatedBuilder(
                        animation: rotateAnimation,
                        builder: (context, c) => Transform.rotate(
                          angle: rotateAnimation.value,
                          child: c,
                        ),
                        child: child,
                      ),
                    ),
                  );
                },
                child: Center(
                  key: ValueKey(widget.isDark),
                  child: widget.isDark
                      ? AgentationIcons.sun(size: 16.0, color: iconColor)
                      : AgentationIcons.moon(size: 16.0, color: iconColor),
                ),
              ),
            ),
          ),
        ),
      );
    },
  ),
);
}
}

class _PanelHoverIconButton extends StatefulWidget {
  const _PanelHoverIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.size = 22.0,
    this.iconSize = 16.0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final double size;
  final double iconSize;

  @override
  State<_PanelHoverIconButton> createState() => _PanelHoverIconButtonState();
}

class _PanelHoverIconButtonState extends State<_PanelHoverIconButton> {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isHovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalColor = widget.isDark
        ? AgentationColors.darkTextSecondary
        : AgentationColors.lightTextSecondary;
    final hoverColor = widget.isDark
        ? AgentationColors.darkTextPrimary
        : AgentationColors.lightTextPrimary;
    final hoverBg = widget.isDark
        ? AgentationColors.darkHoverBg
        : AgentationColors.lightHoverBg;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _isHovered.value = true,
      onExit: (_) => _isHovered.value = false,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isHovered,
          builder: (context, isHovered, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: isHovered ? hoverBg : Colors.transparent,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: isHovered ? hoverColor : normalColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


