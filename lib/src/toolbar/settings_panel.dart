import 'package:flutter/material.dart';
import '../core/agentation_controller.dart';
import '../core/agentation_scope.dart';
import '../models/marker_color.dart';

/// Frosted-glass settings panel allowing customization of theme, marker color,
/// interaction behaviors, and automations / MCP synchronization.
class SettingsPanel extends StatefulWidget {
  const SettingsPanel({
    super.key,
    required this.onClose,
    this.controller,
  });

  /// Callback to dismiss the settings panel.
  final VoidCallback onClose;

  /// Optional controller; defaults to closest [AgentationScope].
  final AgentationController? controller;

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late final TextEditingController _mcpController;

  @override
  void initState() {
    super.initState();
    _mcpController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ctrl = widget.controller ?? AgentationScope.of(context);
    if (_mcpController.text.isEmpty && ctrl.settings.mcpEndpoint != null) {
      _mcpController.text = ctrl.settings.mcpEndpoint!;
    }
  }

  @override
  void dispose() {
    _mcpController.dispose();
    super.dispose();
  }

  AgentationController get _ctrl =>
      widget.controller ?? AgentationScope.of(context);

  @override
  Widget build(BuildContext context) {
    final controller = _ctrl;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final settings = controller.settings;
        final isDark = settings.isDarkMode;
        final activeColor = MarkerColor.findById(settings.markerColorId).color;

        final bg = isDark ? const Color(0xF2181825) : const Color(0xF7FFFFFF);
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final borderColor = isDark ? const Color(0x33FFFFFF) : const Color(0x1F000000);

        return Material(
          color: Colors.transparent,
          child: Container(
            width: 320.0,
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: isDark ? const Color(0x7F000000) : const Color(0x26000000),
                  blurRadius: 24.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.settings, size: 20.0, color: activeColor),
                          const SizedBox(width: 8.0),
                          Text(
                            'Settings',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 18.0, color: subtextColor),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Section 1: Visual Theme
                  Text(
                    'Theme',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeButton(
                          label: 'Dark',
                          icon: Icons.dark_mode_outlined,
                          isSelected: isDark,
                          activeColor: activeColor,
                          isDark: isDark,
                          onTap: () => controller.updateSettings(
                            settings.copyWith(isDarkMode: true),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: _buildThemeButton(
                          label: 'Light',
                          icon: Icons.light_mode_outlined,
                          isSelected: !isDark,
                          activeColor: activeColor,
                          isDark: isDark,
                          onTap: () => controller.updateSettings(
                            settings.copyWith(isDarkMode: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18.0),

                  // Section 2: Marker Color Swatches
                  Text(
                    'Marker Color',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: MarkerColor.values.map((item) {
                      final isSelected = item.id == settings.markerColorId;
                      return Tooltip(
                        message: item.label,
                        child: InkWell(
                          onTap: () => controller.updateSettings(
                            settings.copyWith(markerColorId: item.id),
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 32.0,
                            height: 32.0,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: item.color.withValues(alpha: 0.6),
                                    blurRadius: 8.0,
                                    spreadRadius: 1.0,
                                  ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16.0,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18.0),

                  // Section 3: Behavior Checkboxes
                  Text(
                    'Behavior',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  _buildToggleRow(
                    key: const ValueKey('toggle_auto_clear'),
                    label: 'Clear after copy',
                    value: settings.autoClearAfterCopy,
                    activeColor: activeColor,
                    textColor: textColor,
                    onChanged: (val) => controller.updateSettings(
                      settings.copyWith(autoClearAfterCopy: val),
                    ),
                  ),
                  _buildToggleRow(
                    key: const ValueKey('toggle_block_interactions'),
                    label: 'Block page interactions',
                    value: settings.blockInteractions,
                    activeColor: activeColor,
                    textColor: textColor,
                    onChanged: (val) => controller.updateSettings(
                      settings.copyWith(blockInteractions: val),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Section 4: Automations & MCP Sync
                  Text(
                    'Automations & MCP Sync',
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: settings.mcpEndpoint != null
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              settings.mcpEndpoint != null ? 'Connected' : 'Local Standby',
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: _mcpController,
                          style: TextStyle(color: textColor, fontSize: 12.0),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'http://localhost:4747',
                            hintStyle: TextStyle(color: subtextColor, fontSize: 12.0),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(color: activeColor),
                            ),
                          ),
                          onSubmitted: (val) {
                            controller.updateSettings(
                              settings.copyWith(mcpEndpoint: val.trim().isEmpty ? null : val.trim()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.2)
              : (isDark ? const Color(0x1AFFFFFF) : const Color(0x0A000000)),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.0,
              color: isSelected ? activeColor : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 12.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required Key key,
    required String label,
    required bool value,
    required Color activeColor,
    required Color textColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: textColor, fontSize: 13.0),
          ),
        ),
        Switch.adaptive(
          key: key,
          value: value,
          activeTrackColor: activeColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
