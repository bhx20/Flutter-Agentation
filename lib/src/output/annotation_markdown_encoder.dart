import 'package:flutter/widgets.dart';
import '../models/annotation.dart';
import '../models/toolbar_settings.dart';

/// Formats annotations into Markdown matching the official Agentation protocol and Section 27.
class AnnotationMarkdownEncoder {
  const AnnotationMarkdownEncoder();

  /// Encodes a single [annotation] into a formatted Markdown string (Section 27 legacy).
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

  /// Encodes a list of [annotations] into a single Markdown document (Section 27 legacy).
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

  /// Formats [annotations] according to the specified Agentation [detailLevel].
  String formatDocument(
    List<Annotation> annotations, {
    OutputDetailLevel detailLevel = OutputDetailLevel.standard,
    String? pathname,
    String? appName,
    Size? viewport,
    String? platform,
  }) {
    if (annotations.isEmpty) return '';

    final path = pathname ?? annotations.first.route ?? '/';
    final vp = viewport != null
        ? '${viewport.width.round()}×${viewport.height.round()}'
        : '390×844';

    final buffer = StringBuffer();
    buffer.writeln('## Page Feedback: $path');
    if (appName != null && appName.trim().isNotEmpty) {
      buffer.writeln('**App:** ${appName.trim()}');
    }

    if (detailLevel == OutputDetailLevel.forensic) {
      buffer.writeln();
      buffer.writeln('**Environment:**');
      buffer.writeln('- Viewport: $vp');
      buffer.writeln('- Route: $path');
      if (platform != null) buffer.writeln('- Platform: $platform');
      buffer.writeln('- Timestamp: ${DateTime.now().toUtc().toIso8601String()}');
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    } else if (detailLevel != OutputDetailLevel.compact) {
      buffer.writeln('**Viewport:** $vp');
      buffer.writeln();
    } else {
      buffer.writeln();
    }

    for (int i = 0; i < annotations.length; i++) {
      final a = annotations[i];
      final num = i + 1;
      final type = a.targetWidget.widgetType;
      final location = a.metadata['path'] as String? ?? a.targetWidget.id;

      if (detailLevel == OutputDetailLevel.compact) {
        final src = a.sourceFile != null ? ' (${a.sourceFile})' : '';
        final comment = a.comment;
        final selected = a.selectedText != null ? ' (re: "${a.selectedText}")' : '';
        buffer.writeln('$num. **$type**$src: $comment$selected');
      } else if (detailLevel == OutputDetailLevel.forensic) {
        buffer.writeln('### $num. $type');
        if (location.isNotEmpty) {
          buffer.writeln('**Location:** $location');
        }
        final b = a.bounds;
        buffer.writeln('**Position:** x:${b.x.round()}, y:${b.y.round()} (${b.width.round()}×${b.height.round()}px)');
        if (a.text != null && a.text!.isNotEmpty) {
          buffer.writeln('**Context:** ${a.text}');
        }
        if (a.sourceFile != null) {
          buffer.writeln('**Source:** ${a.sourceFile}');
        }
        buffer.writeln('**Feedback:** ${a.comment}');
        buffer.writeln();
      } else {
        // standard and detailed
        buffer.writeln('### $num. $type');
        if (location.isNotEmpty) {
          buffer.writeln('**Location:** $location');
        }
        if (a.sourceFile != null) {
          buffer.writeln('**Source:** ${a.sourceFile}');
        }
        if (detailLevel == OutputDetailLevel.detailed) {
          final b = a.bounds;
          buffer.writeln('**Position:** ${b.x.round()}px, ${b.y.round()}px (${b.width.round()}×${b.height.round()}px)');
          if (a.text != null && a.text!.isNotEmpty) {
            buffer.writeln('**Context:** ${a.text}');
          }
        }
        buffer.writeln('**Feedback:** ${a.comment}');
        buffer.writeln();
      }
    }

    return buffer.toString().trim();
  }
}
