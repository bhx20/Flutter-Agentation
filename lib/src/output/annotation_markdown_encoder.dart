import 'package:flutter/widgets.dart';
import '../domain/annotation.dart';
import '../domain/toolbar_settings.dart';

/// Flutter component hierarchy detail mode corresponding to ReactComponentMode in Agentation.
enum FlutterComponentMode {
  off,
  filtered,
  smart,
  all;
}

/// Parity mapping matching OUTPUT_TO_REACT_MODE from agentation-main.
const Map<OutputDetailLevel, FlutterComponentMode> outputToFlutterMode = {
  OutputDetailLevel.compact: FlutterComponentMode.off,
  OutputDetailLevel.standard: FlutterComponentMode.filtered,
  OutputDetailLevel.detailed: FlutterComponentMode.smart,
  OutputDetailLevel.forensic: FlutterComponentMode.all,
};

/// UI model representing detail options matching OUTPUT_DETAIL_OPTIONS.
class OutputDetailOption {
  final OutputDetailLevel value;
  final String label;

  const OutputDetailOption({required this.value, required this.label});
}

const List<OutputDetailOption> outputDetailOptions = [
  OutputDetailOption(value: OutputDetailLevel.compact, label: 'Compact'),
  OutputDetailOption(value: OutputDetailLevel.standard, label: 'Standard'),
  OutputDetailOption(value: OutputDetailLevel.detailed, label: 'Detailed'),
  OutputDetailOption(value: OutputDetailLevel.forensic, label: 'Forensic'),
];

/// Formats annotations into Markdown matching the official Agentation protocol and Section 27.
class AnnotationMarkdownEncoder {
  const AnnotationMarkdownEncoder();

  /// Generates the Markdown output header matching agentation-main's `generateOutputHeader`.
  static String generateOutputHeader(String pathname, {String? appName}) {
    final buffer = StringBuffer();
    buffer.writeln('## Page Feedback: $pathname');
    final name = appName?.replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim();
    if (name != null && name.isNotEmpty) {
      final escaped = name.replaceAllMapped(
        RegExp(r'[\\`*_{}\[\]<>]'),
        (m) => '\\${m[0]}',
      );
      buffer.writeln('**App:** $escaped');
    }
    return buffer.toString();
  }

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

  /// Generates the output matching the official Agentation TypeScript `generateOutput()` function.
  String generateOutput(
    List<Annotation> annotations,
    String pathname, {
    OutputDetailLevel detailLevel = OutputDetailLevel.standard,
    String? appName,
    Size? viewport,
    String? platform,
    double? devicePixelRatio,
    String? url,
    String? userAgent,
    DateTime? timestamp,
  }) {
    return formatDocument(
      annotations,
      detailLevel: detailLevel,
      pathname: pathname,
      appName: appName,
      viewport: viewport,
      platform: platform,
      devicePixelRatio: devicePixelRatio,
      url: url,
      userAgent: userAgent,
      timestamp: timestamp,
    );
  }

  /// Formats [annotations] according to the specified Agentation [detailLevel].
  String formatDocument(
    List<Annotation> annotations, {
    OutputDetailLevel detailLevel = OutputDetailLevel.standard,
    String? pathname,
    String? appName,
    Size? viewport,
    String? platform,
    double? devicePixelRatio,
    String? url,
    String? userAgent,
    DateTime? timestamp,
  }) {
    if (annotations.isEmpty) return '';

    final path = pathname ?? annotations.first.route ?? '/';
    final vp = viewport != null
        ? '${viewport.width.round()}×${viewport.height.round()}'
        : '390×844';

    final buffer = StringBuffer();
    buffer.write(generateOutputHeader(path, appName: appName));

    if (detailLevel == OutputDetailLevel.forensic) {
      buffer.writeln();
      buffer.writeln('**Environment:**');
      buffer.writeln('- Viewport: $vp');
      buffer.writeln('- Screen Size: $vp');
      if (url != null && url.isNotEmpty) {
        buffer.writeln('- URL: $url');
      } else {
        buffer.writeln('- Route: $path');
      }
      if (platform != null && platform.isNotEmpty) {
        buffer.writeln('- Platform: $platform');
      }
      if (userAgent != null && userAgent.isNotEmpty) {
        buffer.writeln('- User Agent: $userAgent');
      }
      final ts = (timestamp ?? DateTime.now().toUtc()).toIso8601String();
      buffer.writeln('- Timestamp: $ts');
      final dpr = devicePixelRatio ?? 2.0;
      final dprStr = dpr.truncate() == dpr ? dpr.toInt().toString() : dpr.toString();
      buffer.writeln('- Device Pixel Ratio: $dprStr');
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    } else if (detailLevel != OutputDetailLevel.compact) {
      if (platform != null && platform.isNotEmpty) {
        buffer.writeln('**Platform:** $platform');
      }
      buffer.writeln('**Screen Size:** $vp');
      buffer.writeln('**Viewport:** $vp');
      buffer.writeln();
    } else {
      if (platform != null && platform.isNotEmpty) {
        buffer.writeln('**Platform:** $platform');
      }
      if (viewport != null) {
        buffer.writeln('**Screen Size:** $vp');
      }
      buffer.writeln();
    }

    for (int i = 0; i < annotations.length; i++) {
      final a = annotations[i];
      final num = i + 1;
      final type = a.targetWidget.widgetType.isNotEmpty
          ? a.targetWidget.widgetType
          : 'Widget';
      
      String location;
      if (a.kind == AnnotationKind.placement || a.placement != null || a.metadata.containsKey('treePlacement')) {
        final breadcrumb = a.metadata['parentBreadcrumb'] as String? ?? a.metadata['path'] as String?;
        final treeDesc = a.metadata['treePlacement'] as String? ?? a.placement?.treePlacement;
        if (breadcrumb != null && breadcrumb.isNotEmpty) {
          if (treeDesc != null && treeDesc.isNotEmpty && !breadcrumb.contains(treeDesc)) {
            location = '$breadcrumb ($treeDesc)';
          } else {
            location = breadcrumb;
          }
        } else {
          location = treeDesc ?? a.placement?.parentWidget ?? a.metadata['path'] as String? ?? '';
        }
      } else if (a.targetWidget.widgetType == 'AreaSelection') {
        final rawPath = a.metadata['path'] as String? ?? a.metadata['widgetPath'] as String?;
        if (rawPath != null && rawPath.isNotEmpty && rawPath != 'AreaSelection') {
          location = rawPath;
        } else {
          final b = a.bounds;
          final bw = b.width.round();
          final bh = b.height.round();
          final bx = b.x.round();
          final by = b.y.round();
          location = 'Area ($bw×${bh}px at x:$bx, y:$by)';
        }
      } else {
        final rawPath = a.metadata['path'] as String? ?? a.metadata['widgetPath'] as String?;
        if (rawPath != null && rawPath.isNotEmpty) {
          location = rawPath;
        } else if (a.targetWidget.id.isNotEmpty && a.targetWidget.id != type) {
          location = a.targetWidget.id;
        } else {
          location = type;
        }
      }

      final flutterComponent = a.metadata['flutterComponents'] as String? ??
          a.metadata['reactComponents'] as String?;

      if (detailLevel == OutputDetailLevel.compact) {
        final src = (a.sourceFile != null && a.sourceFile!.isNotEmpty)
            ? ' (${a.sourceFile})'
            : '';
        final comment = a.comment;
        String selected = '';
        if (a.selectedText != null && a.selectedText!.isNotEmpty) {
          final text = a.selectedText!;
          final truncated = text.length > 30 ? '${text.substring(0, 30)}...' : text;
          selected = ' (re: "$truncated")';
        }
        buffer.writeln('$num. **$type**$src: $comment$selected');
      } else if (detailLevel == OutputDetailLevel.forensic) {
        buffer.writeln('### $num. $type');
        final fullPath = a.metadata['fullPath'] as String? ??
            a.metadata['fullDomPath'] as String? ??
            a.metadata['fullWidgetPath'] as String? ??
            (location.isNotEmpty ? location : null);
        if (a.isMultiSelect && fullPath != null) {
          buffer.writeln('*Forensic data shown for first element of selection*');
        }
        if (fullPath != null && fullPath.isNotEmpty) {
          buffer.writeln('**Full DOM Path:** $fullPath');
        }
        final cssClasses = a.metadata['cssClasses'] as String? ??
            a.metadata['classes'] as String?;
        if (cssClasses != null && cssClasses.isNotEmpty) {
          buffer.writeln('**CSS Classes:** $cssClasses');
        }
        final b = a.bounds;
        buffer.writeln('**Position:** x:${b.x.round()}, y:${b.y.round()} (${b.width.round()}×${b.height.round()}px)');

        final vpWidth = viewport?.width ?? 390.0;
        final posX = a.tapPosition?.dx ?? b.x;
        final posY = a.tapPosition?.dy ?? (a.isFixed ? b.y : b.y + a.scrollY);
        final xPercent = vpWidth > 0 ? (posX / vpWidth * 100.0).clamp(0.0, 100.0) : 0.0;
        buffer.writeln('**Annotation at:** ${xPercent.toStringAsFixed(1)}% from left, ${posY.round()}px from top');

        if (a.selectedText != null && a.selectedText!.isNotEmpty) {
          buffer.writeln('**Selected text:** "${a.selectedText}"');
        }
        final nearby = a.text ?? a.metadata['nearbyText'] as String?;
        if (nearby != null &&
            nearby.isNotEmpty &&
            (a.selectedText == null || a.selectedText!.isEmpty)) {
          final ctx = nearby.length > 100 ? nearby.substring(0, 100) : nearby;
          buffer.writeln('**Context:** $ctx');
        }
        final styles = a.metadata['computedStyles'] as String? ??
            a.metadata['properties'] as String?;
        if (styles != null && styles.isNotEmpty) {
          buffer.writeln('**Computed Styles:** $styles');
        }
        final a11y = a.metadata['accessibility'] as String? ??
            a.metadata['semanticsLabel'] as String?;
        if (a11y != null && a11y.isNotEmpty) {
          buffer.writeln('**Accessibility:** $a11y');
        }
        final nearbyEls = a.metadata['nearbyElements'] as String?;
        if (nearbyEls != null && nearbyEls.isNotEmpty) {
          buffer.writeln('**Nearby Elements:** $nearbyEls');
        }
        if (a.sourceFile != null && a.sourceFile!.isNotEmpty) {
          buffer.writeln('**Source:** ${a.sourceFile}');
        }
        if (flutterComponent != null && flutterComponent.isNotEmpty) {
          final label = a.metadata.containsKey('reactComponents') ? 'React' : 'Flutter';
          buffer.writeln('**$label:** $flutterComponent');
        }
        buffer.writeln('**Feedback:** ${a.comment}');
        buffer.writeln();
      } else {
        // standard and detailed
        buffer.writeln('### $num. $type');
        if (location.isNotEmpty) {
          buffer.writeln('**Location:** $location');
        }
        if (a.sourceFile != null && a.sourceFile!.isNotEmpty) {
          buffer.writeln('**Source:** ${a.sourceFile}');
        }
        if (flutterComponent != null && flutterComponent.isNotEmpty) {
          final label = a.metadata.containsKey('reactComponents') ? 'React' : 'Flutter';
          buffer.writeln('**$label:** $flutterComponent');
        }
        if (detailLevel == OutputDetailLevel.detailed) {
          final cssClasses = a.metadata['cssClasses'] as String? ??
              a.metadata['classes'] as String?;
          if (cssClasses != null && cssClasses.isNotEmpty) {
            buffer.writeln('**Classes:** $cssClasses');
          }
          final b = a.bounds;
          buffer.writeln('**Position:** ${b.x.round()}px, ${b.y.round()}px (${b.width.round()}×${b.height.round()}px)');
        }
        if (a.selectedText != null && a.selectedText!.isNotEmpty) {
          buffer.writeln('**Selected text:** "${a.selectedText}"');
        }
        if (detailLevel == OutputDetailLevel.detailed) {
          final nearby = a.text ?? a.metadata['nearbyText'] as String?;
          if (nearby != null &&
              nearby.isNotEmpty &&
              (a.selectedText == null || a.selectedText!.isEmpty)) {
            final ctx = nearby.length > 100 ? nearby.substring(0, 100) : nearby;
            buffer.writeln('**Context:** $ctx');
          }
        }
        buffer.writeln('**Feedback:** ${a.comment}');
        buffer.writeln();
      }
    }

    return buffer.toString().trim();
  }
}


