import 'package:flutter/services.dart';
import '../models/annotation.dart';
import 'agentation_format_adapter.dart';
import 'annotation_json_encoder.dart';
import 'annotation_markdown_encoder.dart';

/// Supported export formats for annotations.
enum ExportFormat {
  /// GitHub Flavored Markdown format matching Section 27 of flow.md.
  markdown,

  /// Pretty-printed or compact JSON.
  json,

  /// Canonical Agentation format adapter payload.
  agentationJson,
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
    bool prettyJson = true,
  }) {
    switch (format) {
      case ExportFormat.markdown:
        return markdownEncoder.encodeAll(annotations);
      case ExportFormat.json:
        return jsonEncoder.encodeAll(annotations, pretty: prettyJson);
      case ExportFormat.agentationJson:
        final map = formatAdapter.adaptAll(annotations);
        return jsonEncoder.encodeMap(map, pretty: prettyJson);
    }
  }

  /// Copies formatted annotations to the system clipboard.
  /// Returns the text copied, or null if copying failed.
  Future<String?> copyToClipboard(
    List<Annotation> annotations, {
    ExportFormat format = ExportFormat.markdown,
    bool prettyJson = true,
  }) async {
    if (annotations.isEmpty) {
      return null;
    }

    final formattedText = formatAnnotations(
      annotations,
      format: format,
      prettyJson: prettyJson,
    );

    try {
      await Clipboard.setData(ClipboardData(text: formattedText));
      return formattedText;
    } catch (_) {
      return null;
    }
  }
}
