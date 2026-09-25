import 'package:flutter/services.dart';
import '../models/annotation.dart';
import '../models/toolbar_settings.dart';
import 'agentation_format_adapter.dart';
import 'annotation_json_encoder.dart';
import 'annotation_markdown_encoder.dart';

/// Supported export formats for annotations.
enum ExportFormat {
  /// GitHub Flavored Markdown format matching Section 27 and Agentation protocol.
  markdown,

  /// Pretty-printed or compact JSON.
  json,

  /// Canonical Agentation format adapter payload.
  agentationJson,

  /// List of detected source code file and line references.
  source,

  /// List of captured identifying developer Keys and attributes.
  attributes,
}

/// Utility for exporting annotations and copying them to the system clipboard.
class ClipboardExporter {
  final AnnotationMarkdownEncoder markdownEncoder;
  final AnnotationJsonEncoder jsonEncoder;
  final AgentationFormatAdapter formatAdapter;

  const ClipboardExporter({
    this.markdownEncoder = const AnnotationMarkdownEncoder(),
    this.jsonEncoder = const AnnotationJsonEncoder(),
    this.formatAdapter = const AgentationFormatAdapter(),
  });

  /// Formats the given [annotations] into the requested [format].
  String formatAnnotations(
    List<Annotation> annotations, {
    ExportFormat format = ExportFormat.markdown,
    OutputDetailLevel detailLevel = OutputDetailLevel.standard,
    bool prettyJson = true,
    String? pathname,
    String? appName,
  }) {
    switch (format) {
      case ExportFormat.markdown:
        return markdownEncoder.formatDocument(
          annotations,
          detailLevel: detailLevel,
          pathname: pathname,
          appName: appName,
        );
      case ExportFormat.json:
        return jsonEncoder.encodeAll(annotations, pretty: prettyJson);
      case ExportFormat.agentationJson:
        final map = formatAdapter.adaptAll(annotations);
        return jsonEncoder.encodeMap(map, pretty: prettyJson);
      case ExportFormat.source:
        return annotations
            .map((a) => a.sourceFile)
            .whereType<String>()
            .toSet()
            .join('\n');
      case ExportFormat.attributes:
        return annotations
            .map((a) => a.targetWidget.keyString ?? a.targetWidget.id)
            .where((s) => s.isNotEmpty)
            .toSet()
            .join('\n');
    }
  }

  /// Copies formatted annotations to the system clipboard.
  /// Returns the text copied, or null if copying failed.
  Future<String?> copyToClipboard(
    List<Annotation> annotations, {
    ExportFormat format = ExportFormat.markdown,
    OutputDetailLevel detailLevel = OutputDetailLevel.standard,
    bool prettyJson = true,
    String? pathname,
    String? appName,
  }) async {
    if (annotations.isEmpty) {
      return null;
    }

    final formattedText = formatAnnotations(
      annotations,
      format: format,
      detailLevel: detailLevel,
      prettyJson: prettyJson,
      pathname: pathname,
      appName: appName,
    );

    try {
      await Clipboard.setData(ClipboardData(text: formattedText));
      return formattedText;
    } catch (_) {
      return null;
    }
  }
}
