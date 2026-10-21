import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/agentation_controller.dart';
import '../../theme/agentation_colors.dart';
import '../../theme/agentation_theme.dart';

/// Manage MCP & Webhooks settings panel matching the official Agentation design.
class McpWebhooksPanel extends StatefulWidget {
  const McpWebhooksPanel({
    super.key,
    required this.controller,
    required this.onBack,
  });

  final AgentationController controller;
  final VoidCallback onBack;

  @override
  State<McpWebhooksPanel> createState() => _McpWebhooksPanelState();
}

class _McpWebhooksPanelState extends State<McpWebhooksPanel> {
  late final TextEditingController _webhookController;
  bool _isTestingWebhook = false;
  String? _testResult;
  bool _copiedConfig = false;

  @override
  void initState() {
    super.initState();
    _webhookController = TextEditingController(
      text: widget.controller.settings.webhookUrl ?? '',
    );
  }

  @override
  void dispose() {
    _webhookController.dispose();
    super.dispose();
  }

  void _saveWebhook(String value) {
    final trimmed = value.trim();
    widget.controller.updateSettings(
      widget.controller.settings.copyWith(
        webhookUrl: trimmed.isNotEmpty ? trimmed : null,
      ),
    );
  }

  Future<void> _testWebhook() async {
    final url = _webhookController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _testResult = 'Enter a valid URL first';
      });
      return;
    }

    setState(() {
      _isTestingWebhook = true;
      _testResult = null;
    });

    try {
      final success = await widget.controller.notifyWebhook('test.ping', {
        'message': 'Flutter Agentation webhook connectivity test',
        'timestamp': DateTime.now().toIso8601String(),
        'platform': widget.controller.currentPlatformName,
      });

      if (!mounted) return;
      setState(() {
        _isTestingWebhook = false;
        _testResult = success ? 'Success (200 OK)' : 'Failed to reach URL';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTestingWebhook = false;
        _testResult = 'Error: $e';
      });
    }
  }

  void _copyMcpConfig() {
    final port = widget.controller.settings.mcpPort;
    final config = {
      'mcpServers': {
        'flutter-agentation': {
          'url': 'http://127.0.0.1:$port/sse',
        },
      },
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(config);
    Clipboard.setData(ClipboardData(text: jsonStr));

    setState(() {
      _copiedConfig = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedConfig = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.controller.settings;
    final isDark = settings.isDarkMode;
    final theme = AgentationThemeData.resolve(isDark: isDark);

    final textColor = theme.textPrimary;
    final subtextColor = theme.textSecondary;
    final dividerColor = theme.dividerColor;
    final mcpServer = widget.controller.mcpServer;
    final isMcpRunning = mcpServer.isRunning;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: Back button + Manage MCP & Webhooks ──
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: widget.onBack,
                borderRadius: BorderRadius.circular(6.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chevron_left,
                        size: 18.0,
                        color: textColor,
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          'Manage MCP & Webhooks',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10.0),
        Divider(height: 1.0, thickness: 1.0, color: dividerColor),
        const SizedBox(height: 10.0),

        // ── Section 1: MCP Connection ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MCP Connection',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4.0),
                Tooltip(
                  message: 'Model Context Protocol allows AI agents (Antigravity, Claude, Cursor) to inspect UI and act on annotations.',
                  child: Icon(
                    Icons.help_outline,
                    size: 13.0,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
            // MCP Enable / Disable toggle
            _PanelSwitch(
              key: const ValueKey('toggle_mcp_enabled'),
              value: settings.mcpEnabled && isMcpRunning,
              isDark: isDark,
              onChanged: (val) {
                widget.controller.updateSettings(
                  settings.copyWith(mcpEnabled: val),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 4.0),
        Text(
          'MCP connection allows agents to receive and act on annotations. Learn more',
          style: TextStyle(
            color: subtextColor,
            fontSize: 11.5,
            height: 1.35,
          ),
        ),

        const SizedBox(height: 8.0),

        // Status pill & port
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.0,
                      height: 7.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isMcpRunning ? Colors.greenAccent[400] : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child: Text(
                        isMcpRunning ? 'Active on port ${mcpServer.port}' : 'MCP Server Stopped',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _copyMcpConfig,
                borderRadius: BorderRadius.circular(4.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _copiedConfig ? Icons.check : Icons.copy,
                        size: 11.0,
                        color: _copiedConfig ? Colors.greenAccent[400] : subtextColor,
                      ),
                      const SizedBox(width: 3.0),
                      Text(
                        _copiedConfig ? 'Copied!' : 'Copy Config',
                        style: TextStyle(
                          color: _copiedConfig ? Colors.greenAccent[400] : subtextColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12.0),
        Divider(height: 1.0, thickness: 1.0, color: dividerColor),
        const SizedBox(height: 10.0),

        // ── Section 2: Webhooks ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Webhooks',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Tooltip(
                    message: 'Streams live annotations to external webhook endpoints as JSON.',
                    child: Icon(
                      Icons.help_outline,
                      size: 13.0,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Auto-Send',
                  style: TextStyle(
                    color: settings.autoSendWebhook ? AgentationColors.indigo : subtextColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6.0),
                _PanelSwitch(
                  key: const ValueKey('toggle_webhook_autosend'),
                  value: settings.autoSendWebhook,
                  isDark: isDark,
                  onChanged: (val) {
                    widget.controller.updateSettings(
                      settings.copyWith(autoSendWebhook: val),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 3.0),
        Text(
          'The webhook URL will receive live annotation changes and annotation data.',
          style: TextStyle(
            color: subtextColor,
            fontSize: 11.5,
            height: 1.35,
          ),
        ),

        const SizedBox(height: 8.0),

        // Webhook URL Text Input matching screenshot
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextField(
            controller: _webhookController,
            style: TextStyle(
              color: textColor,
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
            ),
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Webhook URL (https://...)',
              hintStyle: TextStyle(
                color: theme.textMuted,
                fontSize: 12.0,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            onChanged: _saveWebhook,
          ),
        ),

        const SizedBox(height: 8.0),

        // Test connection & status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_testResult != null)
              Expanded(
                child: Text(
                  _testResult!,
                  style: TextStyle(
                    color: _testResult!.startsWith('Success')
                        ? Colors.greenAccent[400]
                        : Colors.orangeAccent,
                    fontSize: 10.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Spacer(),
            InkWell(
              onTap: _isTestingWebhook ? null : _testWebhook,
              borderRadius: BorderRadius.circular(6.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isTestingWebhook) ...[
                      const SizedBox(
                        width: 10.0,
                        height: 10.0,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                      const SizedBox(width: 4.0),
                    ],
                    Text(
                      _isTestingWebhook ? 'Testing...' : 'Test Connection',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 11.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PanelSwitch extends StatelessWidget {
  const _PanelSwitch({
    super.key,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const trackWidth = 26.0;
    const trackHeight = 16.0;
    const thumbSize = 12.0;

    final trackColor = value
        ? AgentationColors.indigo
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
