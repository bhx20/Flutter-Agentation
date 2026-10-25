import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/agentation_controller.dart';
import '../../theme/agentation_colors.dart';
import '../../theme/agentation_theme.dart';
import '../../theme/agentation_typography.dart';

/// Manage MCP & Webhooks settings panel matching the official Agentation design.
class McpWebhooksPanel extends StatefulWidget {
  const McpWebhooksPanel({
    super.key,
    required this.controller,
    required this.onBack,
    this.targetHeight,
  });

  final AgentationController controller;
  final VoidCallback onBack;
  final double? targetHeight;

  @override
  State<McpWebhooksPanel> createState() => _McpWebhooksPanelState();
}

class _McpWebhooksPanelState extends State<McpWebhooksPanel> {
  late final TextEditingController _webhookController;
  final ValueNotifier<bool> _isTestingWebhookNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _testResultNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _copiedConfigNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isTogglingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showMcpDetailsNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasWebhookNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final initialUrl = widget.controller.settings.webhookUrl ?? '';
    _webhookController = TextEditingController(text: initialUrl);
    _hasWebhookNotifier.value = initialUrl.trim().isNotEmpty;
    _webhookController.addListener(_onUrlChanged);

    // Auto-start MCP server if enabled in settings but not currently running
    if (widget.controller.settings.mcpEnabled &&
        !widget.controller.mcpServer.isRunning &&
        widget.controller.mcpServer.isSupported) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            widget.controller.settings.mcpEnabled &&
            !widget.controller.mcpServer.isRunning) {
          _handleToggleMcp(true);
        }
      });
    }
  }

  void _onUrlChanged() {
    final hasUrl = _webhookController.text.trim().isNotEmpty;
    if (_hasWebhookNotifier.value != hasUrl) {
      _hasWebhookNotifier.value = hasUrl;
    }
  }

  @override
  void didUpdateWidget(covariant McpWebhooksPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentSettingsUrl = widget.controller.settings.webhookUrl ?? '';
    if (currentSettingsUrl != _webhookController.text && currentSettingsUrl.isNotEmpty) {
      _webhookController.text = currentSettingsUrl;
    }
  }

  Timer? _copiedTimer;

  @override
  void dispose() {
    _copiedTimer?.cancel();
    _webhookController.removeListener(_onUrlChanged);
    _webhookController.dispose();
    _isTestingWebhookNotifier.dispose();
    _testResultNotifier.dispose();
    _copiedConfigNotifier.dispose();
    _isTogglingNotifier.dispose();
    _showMcpDetailsNotifier.dispose();
    _hasWebhookNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleToggleMcp(bool enabled) async {
    if (_isTogglingNotifier.value) return;
    _isTogglingNotifier.value = true;

    try {
      if (enabled) {
        widget.controller.updateSettings(
          widget.controller.settings.copyWith(mcpEnabled: true),
        );
      } else {
        widget.controller.updateSettings(
          widget.controller.settings.copyWith(mcpEnabled: false),
        );
        await widget.controller.mcpServer.stop();
      }
    } finally {
      if (mounted) {
        _isTogglingNotifier.value = false;
      }
    }
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
      _testResultNotifier.value = 'Enter a valid URL first';
      return;
    }

    _isTestingWebhookNotifier.value = true;
    _testResultNotifier.value = null;

    try {
      final success = await widget.controller.notifyWebhook('test.ping', {
        'message': 'Flutter Agentation webhook connectivity test',
        'timestamp': DateTime.now().toIso8601String(),
        'platform': widget.controller.currentPlatformName,
      }, force: true);

      if (!mounted) return;
      _isTestingWebhookNotifier.value = false;
      _testResultNotifier.value = success ? 'Success (200 OK)' : 'Failed to reach URL';
    } catch (e) {
      if (!mounted) return;
      _isTestingWebhookNotifier.value = false;
      _testResultNotifier.value = 'Error: $e';
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

    _copiedTimer?.cancel();
    _copiedConfigNotifier.value = true;

    _copiedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _copiedConfigNotifier.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.controller,
        _isTestingWebhookNotifier,
        _testResultNotifier,
        _copiedConfigNotifier,
        _isTogglingNotifier,
        _showMcpDetailsNotifier,
        _hasWebhookNotifier,
      ]),
      builder: (context, _) {
        final settings = widget.controller.settings;
        final isDark = settings.isDarkMode;
        final theme = AgentationThemeData.resolve(isDark: isDark);

        final textColor = theme.textPrimary;
        final subtextColor = theme.textSecondary;
        final dividerColor = theme.panelDividerColor;
        final mcpServer = widget.controller.mcpServer;
        final isMcpRunning = mcpServer.isRunning;
        final hasWebhook = _hasWebhookNotifier.value ||
            (settings.webhookUrl != null && settings.webhookUrl!.trim().isNotEmpty);
        final isTestingWebhook = _isTestingWebhookNotifier.value;
        final testResult = _testResultNotifier.value;
        final copiedConfig = _copiedConfigNotifier.value;
        final isToggling = _isTogglingNotifier.value;
        final showMcpDetails = _showMcpDetailsNotifier.value;
        final autoSendColor = theme.autoSendActiveColor;

    final inputWidget = Container(
      decoration: BoxDecoration(
        color: theme.panelInputBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: theme.panelInputBorder,
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: _webhookController,
        style: AgentationTypography.panelInput.copyWith(
          color: textColor,
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: 'Webhook URL',
          hintStyle: AgentationTypography.panelInputHint.copyWith(
            color: theme.panelInputHint,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: _saveWebhook,
      ),
    );

        final isSupported = mcpServer.isSupported;
        final hasClients = isMcpRunning && mcpServer.connectedClientsCount > 0;

        final String mcpStatusMessage;
        final Color mcpStatusColor;

        if (!isSupported) {
          mcpStatusMessage = 'Runs on Windows, Android, iOS, and Linux (on Web, use Webhooks below)';
          mcpStatusColor = theme.textMuted;
        } else if (hasClients) {
          mcpStatusMessage = 'Connected (${mcpServer.connectedClientsCount} AI agent active)';
          mcpStatusColor = theme.statusConnected;
        } else if (isMcpRunning) {
          mcpStatusMessage = 'Ready & listening on port ${mcpServer.port}';
          mcpStatusColor = theme.statusConnected;
        } else if (isToggling) {
          mcpStatusMessage = 'Starting...';
          mcpStatusColor = theme.statusConnecting;
        } else if (mcpServer.errorMessage != null) {
          mcpStatusMessage = 'Error: ${mcpServer.errorMessage}';
          mcpStatusColor = theme.statusDisconnected;
        } else {
          mcpStatusMessage = 'Offline / Stopped';
          mcpStatusColor = theme.textMuted;
        }

    final content = Column(
      mainAxisSize: widget.targetHeight != null ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: Back button + Manage MCP & Webhooks ──
        InkWell(
          onTap: widget.onBack,
          borderRadius: BorderRadius.circular(6.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 3.0),
            child: Row(
              children: [
                Icon(
                  Icons.chevron_left,
                  size: 19.0,
                  color: subtextColor,
                ),
                const SizedBox(width: 4.0),
                Expanded(
                  child: Text(
                    'Manage MCP & Webhooks',
                    style: AgentationTypography.panelHeader.copyWith(
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
        const SizedBox(height: 12.0),

        // ── Section 1: MCP Connection ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MCP Connection',
                  style: AgentationTypography.sectionHeader.copyWith(
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 4.0),
                _PanelTooltip(
                  message:
                      'Connect via Model Context Protocol to let AI agents like Claude Code receive annotations in real-time.',
                  child: Icon(
                    Icons.help_outline,
                    size: 13.0,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
            _PanelTooltip(
              message: mcpStatusMessage,
              child: Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mcpStatusColor,
                  boxShadow: [
                    BoxShadow(
                      color: mcpStatusColor.withValues(alpha: 0.4),
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4.0),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'MCP connection allows agents to receive and act on annotations. ',
              style: AgentationTypography.panelDescription.copyWith(
                color: subtextColor,
              ),
            ),
            InkWell(
              onTap: () {
                _showMcpDetailsNotifier.value = !_showMcpDetailsNotifier.value;
              },
              borderRadius: BorderRadius.circular(2.0),
              child: Text(
                'Learn more',
                style: AgentationTypography.panelLink.copyWith(
                  color: subtextColor,
                ),
              ),
            ),
          ],
        ),

        // Expandable technical details when user taps "Learn more"
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: showMcpDetails
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 6.0),
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
                                      color: isMcpRunning
                                          ? theme.statusConnected
                                          : (isToggling ||
                                                  (settings.mcpEnabled &&
                                                      !isMcpRunning)
                                              ? theme.statusConnecting
                                              : (mcpServer.errorMessage != null
                                                  ? theme.statusConnecting
                                                  : theme.textMuted)),
                                    ),
                                  ),
                                  const SizedBox(width: 6.0),
                                  Expanded(
                                    child: Text(
                                      isMcpRunning
                                          ? 'Port ${mcpServer.port}'
                                          : (isToggling ||
                                                  (settings.mcpEnabled &&
                                                      !isMcpRunning)
                                              ? 'Starting...'
                                              : (mcpServer.errorMessage ??
                                                  'Stopped')),
                                      style: AgentationTypography.panelDescription.copyWith(
                                        color: textColor,
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0, vertical: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      copiedConfig ? Icons.check : Icons.copy,
                                      size: 11.0,
                                      color: copiedConfig
                                          ? theme.statusConnected
                                          : subtextColor,
                                    ),
                                    const SizedBox(width: 3.0),
                                    Text(
                                      copiedConfig ? 'Copied' : 'Config',
                                      style: AgentationTypography.panelActionTag.copyWith(
                                        color: copiedConfig
                                            ? theme.statusConnected
                                            : subtextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            _PanelSwitch(
                              key: const ValueKey('toggle_mcp_server'),
                              value: settings.mcpEnabled,
                              isDark: isDark,
                              onChanged: isToggling ? null : _handleToggleMcp,
                            ),
                          ],
                        ),
                      ),
                      if (isMcpRunning) ...[
                        const SizedBox(height: 6.0),
                        SelectableText(
                          mcpServer.sseUrl,
                          style: AgentationTypography.panelCodeSnippet.copyWith(
                            color: theme.linkColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 12.0),
        Divider(height: 1.0, thickness: 1.0, color: dividerColor),
        const SizedBox(height: 12.0),

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
                      style: AgentationTypography.sectionHeader.copyWith(
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  _PanelTooltip(
                    message:
                        'Send annotation data to any URL endpoint when annotations change. Useful for custom integrations.',
                    child: Icon(
                      Icons.help_outline,
                      size: 13.0,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Auto-Send',
                  style: AgentationTypography.autoSendLabel.copyWith(
                    color: !hasWebhook
                        ? subtextColor.withValues(alpha: 0.5)
                        : (settings.autoSendWebhook ? autoSendColor : subtextColor),
                  ),
                ),
                const SizedBox(width: 6.0),
                _PanelSwitch(
                  key: const ValueKey('toggle_webhook_autosend'),
                  value: settings.autoSendWebhook,
                  isDark: isDark,
                  onChanged: hasWebhook
                      ? (val) {
                          widget.controller.updateSettings(
                            widget.controller.settings.copyWith(autoSendWebhook: val),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 4.0),
        Text(
          'The webhook URL will receive live annotation changes and annotation data.',
          style: AgentationTypography.panelDescription.copyWith(
            color: subtextColor,
          ),
        ),

        const SizedBox(height: 8.0),

        // Webhook URL Text Input (Expands to fill exact height when targetHeight is set)
        if (widget.targetHeight != null)
          Expanded(child: inputWidget)
        else
          SizedBox(height: 100.0, child: inputWidget),

        // Test connection & status (rendered when URL exists or test result available)
        if (hasWebhook || testResult != null) ...[
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (testResult != null)
                Expanded(
                  child: Text(
                    testResult,
                    style: AgentationTypography.panelTooltipText.copyWith(
                      color: testResult.startsWith('Success')
                          ? theme.statusConnected
                          : theme.statusConnecting,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const Spacer(),
              InkWell(
                onTap: isTestingWebhook ? null : _testWebhook,
                borderRadius: BorderRadius.circular(6.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTestingWebhook) ...[
                        const SizedBox(
                          width: 10.0,
                          height: 10.0,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                        const SizedBox(width: 4.0),
                      ],
                      Text(
                        isTestingWebhook ? 'Testing...' : 'Test Connection',
                        style: AgentationTypography.button.copyWith(
                          color: textColor,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );

    final result = widget.targetHeight != null
        ? SizedBox(
            height: widget.targetHeight,
            child: content,
          )
        : content;

    return result;
      },
    );
  }
}

/// Compact multiline tooltip with smaller normal-weight font matching user requirements.
class _PanelTooltip extends StatelessWidget {
  const _PanelTooltip({
    required this.message,
    required this.child,
  });

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      constraints: const BoxConstraints(maxWidth: 180.0),
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 6.0),
      textStyle: AgentationTypography.panelTooltipText.copyWith(
        color: AgentationColors.zinc100,
        height: 1.35,
      ),
      decoration: BoxDecoration(
        color: AgentationColors.zinc900,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: AgentationColors.shadowSubtle,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      preferBelow: false,
      child: child,
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
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    const trackWidth = 26.0;
    const trackHeight = 16.0;
    const thumbSize = 12.0;

    final isEnabled = onChanged != null;
    final activeColor =
        isDark ? AgentationColors.blue400 : AgentationColors.blue300;
    final trackColor = value
        ? activeColor
        : (isDark
            ? Colors.white.withValues(alpha: 0.15)
            : AgentationColors.gray200);

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: MouseRegion(
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: isEnabled ? () => onChanged!(!value) : null,
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
                      color: AgentationColors.shadowSubtle,
                      blurRadius: 2.0,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
