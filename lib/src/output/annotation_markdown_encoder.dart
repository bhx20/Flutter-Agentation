import '../models/annotation.dart';

/// Formats annotations into GitHub Flavored Markdown matching Section 27 of flow.md.
class AnnotationMarkdownEncoder {
  const AnnotationMarkdownEncoder();

  /// Encodes a single [annotation] into a formatted Markdown string.
  /// If [index] is provided, formats the heading as `## Annotation #$index`.
  String encode(Annotation annotation, {int? index}) {
    final buffer = StringBuffer();
    final header = index != null ? '## Annotation #$index' : '## Annotation';
    buffer.writeln(header);
    buffer.writeln();

    buffer.writeln('Comment:');
    buffer.writeln(annotation.comment);
    buffer.writeln();

    buffer.writeln('Widget:');
    buffer.writeln(annotation.targetWidget.widgetType);
    buffer.writeln();

    if (annotation.targetWidget.id.isNotEmpty) {
      buffer.writeln('Identifier:');
      buffer.writeln(annotation.targetWidget.id);
      buffer.writeln();
    }

    final path = annotation.metadata['path'] as String? ??
        annotation.metadata['widgetPath'] as String?;
    if (path != null && path.isNotEmpty) {
      buffer.writeln('Path:');
      buffer.writeln(path);
      buffer.writeln();
    }

    if (annotation.route != null && annotation.route!.isNotEmpty) {
      buffer.writeln('Route:');
      buffer.writeln(annotation.route);
      buffer.writeln();
    }

    final b = annotation.bounds;
    final bx = b.x.truncate() == b.x ? b.x.toInt().toString() : b.x.toStringAsFixed(1);
    final by = b.y.truncate() == b.y ? b.y.toInt().toString() : b.y.toStringAsFixed(1);
    final bw = b.width.truncate() == b.width ? b.width.toInt().toString() : b.width.toStringAsFixed(1);
    final bh = b.height.truncate() == b.height ? b.height.toInt().toString() : b.height.toStringAsFixed(1);
    buffer.writeln('Bounds:');
    buffer.writeln('x=$bx y=$by width=$bw height=$bh');
    buffer.writeln();

    if (annotation.text != null && annotation.text!.isNotEmpty) {
      buffer.writeln('Text:');
      buffer.writeln(annotation.text);
      buffer.writeln();
    }

    buffer.writeln('Severity:');
    buffer.writeln(annotation.severity.name);
    buffer.writeln();

    buffer.writeln('Status:');
    buffer.writeln(annotation.status.name);

    return buffer.toString().trimRight();
  }

  /// Encodes a list of [annotations] into a single Markdown document.
  String encodeAll(List<Annotation> annotations) {
    if (annotations.isEmpty) {
      return '_No annotations recorded._';
    }

    final buffer = StringBuffer();
    for (var i = 0; i < annotations.length; i++) {
      if (i > 0) {
        buffer.writeln();
        buffer.writeln();
      }
      buffer.write(encode(annotations[i], index: i + 1));
    }
    return buffer.toString();
  }
}
