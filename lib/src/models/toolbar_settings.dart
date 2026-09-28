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
    this.markerColorId = 'indigo',
    this.autoClearAfterCopy = false,
    this.blockInteractions = true,
    this.flutterComponentsEnabled = true,
    this.hideUntilRestart = false,
    this.mcpEndpoint,
    this.sessionId,
    this.webhookUrl,
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
    );
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
        other.webhookUrl == webhookUrl;
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
      );
}
