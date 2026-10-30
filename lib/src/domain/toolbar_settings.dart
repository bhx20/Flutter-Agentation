import 'package:flutter/foundation.dart';

/// Output detail levels matching the official Agentation protocol.
enum OutputDetailLevel {
  /// Minimal single-line format: "1. Button (lib/...): Comment"
  compact,

  /// Default: Location path, source file, context, and feedback.
  standard,

  /// Detailed: Adds widget classes, exact bounding box dimensions, and full text context.
  detailed,

  /// Forensic: Adds full environment (viewport, platform, DPR, timestamp) and deep tree path.
  forensic,
}

/// Formats supported for copying annotations to system clipboard.
enum CopyFormat {
  /// Compact AI-friendly Flutter UI Feedback format ([Flutter UI Feedback]).
  feedback,

  /// Structured Markdown documentation.
  markdown,

  /// Standard JSON array.
  json,

  /// Official Agentation Protocol JSON envelope.
  agentationJson,

  /// Plain list of source file locations (e.g. "lib/views/home.dart:42").
  source,

  /// Plain list of developer Keys and identifying attributes.
  attributes,
}

/// User preferences and configuration state for the inspection overlay and toolbar.
@immutable
class ToolbarSettings {
  const ToolbarSettings({
    this.outputDetail = OutputDetailLevel.standard,
    this.copyFormat = CopyFormat.feedback,
    this.isDarkMode = true,
    this.markerColorId = 'blue',
    this.autoClearAfterCopy = false,
    this.blockInteractions = true,
    this.flutterComponentsEnabled = true,
    this.hideUntilRestart = false,
    this.mcpEndpoint,
    this.sessionId,
    this.webhookUrl,
    this.mcpEnabled = false,
    this.mcpPort = 4747,
    this.autoSendWebhook = false,
    this.autoSendMcp = true,
  });

  /// The active output detail level.
  final OutputDetailLevel outputDetail;

  /// Default format when copying to clipboard.
  final CopyFormat copyFormat;

  /// Whether the toolbar and overlay cards render in dark theme.
  final bool isDarkMode;

  /// The active marker accent color ID (matches MarkerColor.values).
  final String markerColorId;

  /// Whether annotations are automatically cleared after copying or sending.
  final bool autoClearAfterCopy;

  /// Whether host application gestures are blocked during inspection mode.
  final bool blockInteractions;

  /// Whether to include Flutter widget component types in exported annotations.
  final bool flutterComponentsEnabled;

  /// Whether the toolbar is hidden until app restart.
  final bool hideUntilRestart;

  /// Optional Agentation MCP server HTTP endpoint (e.g. 'http://localhost:4747').
  final String? mcpEndpoint;

  /// Optional active session ID for Agent Sync.
  final String? sessionId;

  /// Optional webhook URL for external notification dispatching.
  final String? webhookUrl;

  /// Whether the embedded Flutter MCP server is enabled.
  final bool mcpEnabled;

  /// Port on which the embedded MCP server listens (default: 4747).
  final int mcpPort;

  /// Whether annotations are automatically dispatched to the webhook URL on creation and updates.
  final bool autoSendWebhook;

  /// Whether annotations are automatically broadcast to AI agents via MCP on creation and updates.
  final bool autoSendMcp;

  ToolbarSettings copyWith({
    OutputDetailLevel? outputDetail,
    CopyFormat? copyFormat,
    bool? isDarkMode,
    String? markerColorId,
    bool? autoClearAfterCopy,
    bool? blockInteractions,
    bool? flutterComponentsEnabled,
    bool? hideUntilRestart,
    String? mcpEndpoint,
    String? sessionId,
    String? webhookUrl,
    bool? mcpEnabled,
    int? mcpPort,
    bool? autoSendWebhook,
    bool? autoSendMcp,
  }) {
    return ToolbarSettings(
      outputDetail: outputDetail ?? this.outputDetail,
      copyFormat: copyFormat ?? this.copyFormat,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      markerColorId: markerColorId ?? this.markerColorId,
      autoClearAfterCopy: autoClearAfterCopy ?? this.autoClearAfterCopy,
      blockInteractions: blockInteractions ?? this.blockInteractions,
      flutterComponentsEnabled:
          flutterComponentsEnabled ?? this.flutterComponentsEnabled,
      hideUntilRestart: hideUntilRestart ?? this.hideUntilRestart,
      mcpEndpoint: mcpEndpoint ?? this.mcpEndpoint,
      sessionId: sessionId ?? this.sessionId,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      mcpEnabled: mcpEnabled ?? this.mcpEnabled,
      mcpPort: mcpPort ?? this.mcpPort,
      autoSendWebhook: autoSendWebhook ?? this.autoSendWebhook,
      autoSendMcp: autoSendMcp ?? this.autoSendMcp,
    );
  }

  /// Converts settings to a JSON map for persistence.
  /// Note: [hideUntilRestart] is excluded because it is only meant to hide the toolbar until the next restart.
  Map<String, dynamic> toJson() {
    return {
      'outputDetail': outputDetail.name,
      'copyFormat': copyFormat.name,
      'isDarkMode': isDarkMode,
      'markerColorId': markerColorId,
      'autoClearAfterCopy': autoClearAfterCopy,
      'blockInteractions': blockInteractions,
      'flutterComponentsEnabled': flutterComponentsEnabled,
      'mcpEnabled': mcpEnabled,
      'mcpPort': mcpPort,
      if (mcpEndpoint != null) 'mcpEndpoint': mcpEndpoint,
      if (sessionId != null) 'sessionId': sessionId,
      if (webhookUrl != null) 'webhookUrl': webhookUrl,
      'autoSendWebhook': autoSendWebhook,
      'autoSendMcp': autoSendMcp,
    };
  }

  /// Creates a new [ToolbarSettings] by merging persisted JSON data into this instance.
  ToolbarSettings mergeFromJson(Map<String, dynamic> json) {
    OutputDetailLevel newOutputDetail = outputDetail;
    if (json['outputDetail'] is String) {
      for (final val in OutputDetailLevel.values) {
        if (val.name == json['outputDetail']) {
          newOutputDetail = val;
          break;
        }
      }
    }

    CopyFormat newCopyFormat = copyFormat;
    if (json['copyFormat'] is String) {
      for (final val in CopyFormat.values) {
        if (val.name == json['copyFormat']) {
          newCopyFormat = val;
          break;
        }
      }
    }

    return copyWith(
      outputDetail: newOutputDetail,
      copyFormat: newCopyFormat,
      isDarkMode: json['isDarkMode'] as bool? ?? isDarkMode,
      markerColorId: json['markerColorId'] as String? ?? markerColorId,
      autoClearAfterCopy:
          json['autoClearAfterCopy'] as bool? ?? autoClearAfterCopy,
      blockInteractions:
          json['blockInteractions'] as bool? ?? blockInteractions,
      flutterComponentsEnabled:
          json['flutterComponentsEnabled'] as bool? ?? flutterComponentsEnabled,
      hideUntilRestart: false,
      mcpEndpoint: json.containsKey('mcpEndpoint')
          ? json['mcpEndpoint'] as String?
          : mcpEndpoint,
      sessionId: json.containsKey('sessionId')
          ? json['sessionId'] as String?
          : sessionId,
      webhookUrl: json.containsKey('webhookUrl')
          ? json['webhookUrl'] as String?
          : webhookUrl,
      mcpEnabled: json['mcpEnabled'] as bool? ?? mcpEnabled,
      mcpPort: (json['mcpPort'] as num?)?.toInt() ?? mcpPort,
      autoSendWebhook: json['autoSendWebhook'] as bool? ?? autoSendWebhook,
      autoSendMcp: json['autoSendMcp'] as bool? ?? autoSendMcp,
    );
  }

  /// Creates a [ToolbarSettings] from persisted JSON data.
  factory ToolbarSettings.fromJson(Map<String, dynamic> json) {
    return const ToolbarSettings().mergeFromJson(json);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToolbarSettings &&
        other.outputDetail == outputDetail &&
        other.copyFormat == copyFormat &&
        other.isDarkMode == isDarkMode &&
        other.markerColorId == markerColorId &&
        other.autoClearAfterCopy == autoClearAfterCopy &&
        other.blockInteractions == blockInteractions &&
        other.flutterComponentsEnabled == flutterComponentsEnabled &&
        other.hideUntilRestart == hideUntilRestart &&
        other.mcpEndpoint == mcpEndpoint &&
        other.sessionId == sessionId &&
        other.webhookUrl == webhookUrl &&
        other.mcpEnabled == mcpEnabled &&
        other.mcpPort == mcpPort &&
        other.autoSendWebhook == autoSendWebhook &&
        other.autoSendMcp == autoSendMcp;
  }

  @override
  int get hashCode => Object.hash(
        outputDetail,
        copyFormat,
        isDarkMode,
        markerColorId,
        autoClearAfterCopy,
        blockInteractions,
        mcpEndpoint,
        sessionId,
        webhookUrl,
        mcpEnabled,
        mcpPort,
        autoSendWebhook,
        autoSendMcp,
      );
}
