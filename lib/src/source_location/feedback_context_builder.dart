import 'dart:ui';
import '../domain/annotation.dart';
import '../domain/toolbar_settings.dart';
import 'feedback_target.dart';

/// Formatter that generates clean, token-efficient, AI-readable UI feedback messages.
///
/// Strictly conforms to Master Prompt Sections 11, 12, and 13, enriched with platform and screen size context,
/// and dynamically responds to [OutputDetailLevel] (compact, standard, detailed, forensic).
class FeedbackContextBuilder {
  const FeedbackContextBuilder();

  /// Formats a single feedback item.
  String build(
    FeedbackTarget target,
    String comment, {
    String? platform,
    Size? screenSize,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('[Flutter UI Feedback]');
    if (platform != null && platform.isNotEmpty) {
      buffer.writeln('Platform: $platform');
    }
    if (screenSize != null) {
      buffer.writeln('Screen Size: ${screenSize.width.round()}×${screenSize.height.round()}');
    }
    _writeTargetDetails(buffer, target, comment);
    return buffer.toString().trimRight();
  }

  /// Formats a single [Annotation] into clean, structured feedback.
  /// For component placements (drag & drop) and widget feedback, it adapts dynamically
  /// to the chosen [detailLevel].
  String buildAnnotation(
    Annotation annotation, {
    OutputDetailLevel detailLevel = OutputDetailLevel.standard,
    String? platform,
    Size? screenSize,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('[Flutter UI Feedback]');
    if (detailLevel == OutputDetailLevel.forensic) {
      if (platform != null && platform.isNotEmpty) {
        buffer.writeln('Platform: $platform');
      }
      if (screenSize != null) {
        buffer.writeln('Screen Size: ${screenSize.width.round()}×${screenSize.height.round()}');
        buffer.writeln('Viewport: ${screenSize.width.round()}×${screenSize.height.round()}');
      }
      buffer.writeln('Detail Level: forensic');
    } else {
      if (platform != null && platform.isNotEmpty) {
        buffer.writeln('Platform: $platform');
      }
      if (screenSize != null) {
        buffer.writeln('Screen Size: ${screenSize.width.round()}×${screenSize.height.round()}');
      }
    }
    _writeAnnotationDetails(buffer, annotation, detailLevel: detailLevel);
    return buffer.toString().trimRight();
  }

  /// Formats multiple [Annotation] items sequentially numbered.
  String buildMultipleAnnotations(
    List<Annotation> annotations, {
    OutputDetailLevel detailLevel = OutputDetailLevel.standard,
    String? platform,
    Size? screenSize,
  }) {
    if (annotations.isEmpty) return '';
    if (annotations.length == 1) {
      return buildAnnotation(
        annotations.first,
        detailLevel: detailLevel,
        platform: platform,
        screenSize: screenSize,
      );
    }

    final buffer = StringBuffer();
    buffer.writeln('[Flutter UI Feedback]');
    if (detailLevel == OutputDetailLevel.forensic) {
      if (platform != null && platform.isNotEmpty) {
        buffer.writeln('Platform: $platform');
      }
      if (screenSize != null) {
        buffer.writeln('Screen Size: ${screenSize.width.round()}×${screenSize.height.round()}');
        buffer.writeln('Viewport: ${screenSize.width.round()}×${screenSize.height.round()}');
      }
      buffer.writeln('Detail Level: forensic');
    } else {
      if (platform != null && platform.isNotEmpty) {
        buffer.writeln('Platform: $platform');
      }
      if (screenSize != null) {
        buffer.writeln('Screen Size: ${screenSize.width.round()}×${screenSize.height.round()}');
      }
    }
    buffer.writeln();

    for (int i = 0; i < annotations.length; i++) {
      buffer.writeln('${i + 1}.');
      _writeAnnotationDetails(buffer, annotations[i], detailLevel: detailLevel);
      if (i < annotations.length - 1) {
        buffer.writeln();
      }
    }

    return buffer.toString().trimRight();
  }

  /// Formats multiple feedback items sequentially numbered per Section 12.
  String buildMultiple(
    List<({FeedbackTarget target, String comment})> items, {
    String? platform,
    Size? screenSize,
  }) {
    if (items.isEmpty) return '';
    if (items.length == 1) {
      return build(
        items.first.target,
        items.first.comment,
        platform: platform,
        screenSize: screenSize,
      );
    }

    final buffer = StringBuffer();
    buffer.writeln('[Flutter UI Feedback]');
    if (platform != null && platform.isNotEmpty) {
      buffer.writeln('Platform: $platform');
    }
    if (screenSize != null) {
      buffer.writeln('Screen Size: ${screenSize.width.round()}×${screenSize.height.round()}');
    }
    buffer.writeln();

    for (int i = 0; i < items.length; i++) {
      buffer.writeln('${i + 1}.');
      _writeTargetDetails(buffer, items[i].target, items[i].comment);
      if (i < items.length - 1) {
        buffer.writeln();
      }
    }

    return buffer.toString().trimRight();
  }

  void _writeTargetDetails(StringBuffer buffer, FeedbackTarget target, String comment) {
    buffer.writeln('Widget: ${target.widgetName}');
    buffer.writeln('File: ${target.source.fileString}');
    buffer.writeln('Location: ${target.source.locationString}');
    buffer.writeln('Line: ${target.source.lineString}');
    buffer.writeln('Comment: $comment');
  }

  void _writeAnnotationDetails(
    StringBuffer buffer,
    Annotation annotation, {
    OutputDetailLevel detailLevel = OutputDetailLevel.standard,
  }) {
    if (annotation.kind == AnnotationKind.placement || annotation.placement != null) {
      _writePlacementDetails(buffer, annotation, detailLevel: detailLevel);
    } else {
      _writeWidgetFeedbackDetails(buffer, annotation, detailLevel: detailLevel);
    }
  }

  void _writeWidgetFeedbackDetails(
    StringBuffer buffer,
    Annotation annotation, {
    OutputDetailLevel detailLevel = OutputDetailLevel.standard,
  }) {
    final target = annotation.toFeedbackTarget();
    final b = annotation.bounds;
    final meta = annotation.metadata;

    switch (detailLevel) {
      case OutputDetailLevel.compact:
        // Compact: Single concise overview per Section 27 / Agentation compact standard
        final src = target.source.isAvailable ? ' (${target.source.locationString}:${target.source.lineString})' : '';
        buffer.writeln('Widget: ${target.widgetName}$src');
        buffer.writeln('Comment: ${annotation.comment}');
        break;

      case OutputDetailLevel.standard:
        // Standard Section 11/12
        buffer.writeln('Widget: ${target.widgetName}');
        buffer.writeln('File: ${target.source.fileString}');
        buffer.writeln('Location: ${target.source.locationString}');
        buffer.writeln('Line: ${target.source.lineString}');
        buffer.writeln('Comment: ${annotation.comment}');
        break;

      case OutputDetailLevel.detailed:
        // Detailed: adds bounding box coordinates, CSS/styling classes, flutter components, and nearby context
        buffer.writeln('Widget: ${target.widgetName}');
        final path = meta['path'] as String? ?? meta['widgetPath'] as String?;
        if (path != null && path.isNotEmpty) {
          buffer.writeln('Hierarchy: $path');
        }
        buffer.writeln('File: ${target.source.fileString}');
        buffer.writeln('Location: ${target.source.locationString}');
        buffer.writeln('Line: ${target.source.lineString}');
        final bx = b.x.truncate() == b.x ? b.x.toInt().toString() : b.x.toStringAsFixed(1);
        final by = b.y.truncate() == b.y ? b.y.toInt().toString() : b.y.toStringAsFixed(1);
        final bw = b.width.truncate() == b.width ? b.width.toInt().toString() : b.width.toStringAsFixed(1);
        final bh = b.height.truncate() == b.height ? b.height.toInt().toString() : b.height.toStringAsFixed(1);
        buffer.writeln('Position: x:$bx, y:$by ($bw×${bh}px)');
        if (annotation.targetWidget.keyString != null && annotation.targetWidget.keyString!.isNotEmpty) {
          buffer.writeln('Key: ${annotation.targetWidget.keyString}');
        }
        final cssClasses = annotation.cssClasses;
        if (cssClasses != null && cssClasses.isNotEmpty) {
          buffer.writeln('Classes: $cssClasses');
        }
        final flutterComp = annotation.flutterComponents;
        if (flutterComp != null && flutterComp.isNotEmpty) {
          buffer.writeln('Flutter Components: $flutterComp');
        }
        if (annotation.selectedText != null && annotation.selectedText!.isNotEmpty) {
          buffer.writeln('Selected Text: "${annotation.selectedText}"');
        }
        final nearby = annotation.nearbyText;
        if (nearby != null && nearby.isNotEmpty && (annotation.selectedText == null || annotation.selectedText!.isEmpty)) {
          final ctx = nearby.length > 100 ? nearby.substring(0, 100) : nearby;
          buffer.writeln('Context: $ctx');
        }
        buffer.writeln('Comment: ${annotation.comment}');
        break;

      case OutputDetailLevel.forensic:
        // Forensic: full inspection data, full DOM/Widget path, accessibility, computed styles, nearby elements
        buffer.writeln('Widget: ${target.widgetName}');
        final fullPath = annotation.fullPath ?? meta['path'] as String? ?? meta['widgetPath'] as String?;
        if (fullPath != null && fullPath.isNotEmpty) {
          buffer.writeln('Full Hierarchy Path: $fullPath');
        }
        buffer.writeln('File: ${target.source.fileString}');
        buffer.writeln('Location: ${target.source.locationString}');
        buffer.writeln('Line: ${target.source.lineString}');
        final bx = b.x.truncate() == b.x ? b.x.toInt().toString() : b.x.toStringAsFixed(1);
        final by = b.y.truncate() == b.y ? b.y.toInt().toString() : b.y.toStringAsFixed(1);
        final bw = b.width.truncate() == b.width ? b.width.toInt().toString() : b.width.toStringAsFixed(1);
        final bh = b.height.truncate() == b.height ? b.height.toInt().toString() : b.height.toStringAsFixed(1);
        buffer.writeln('Position: x:$bx, y:$by ($bw×${bh}px)');
        if (annotation.targetWidget.id.isNotEmpty && annotation.targetWidget.id != target.widgetName) {
          buffer.writeln('Identifier: ${annotation.targetWidget.id}');
        }
        if (annotation.targetWidget.keyString != null && annotation.targetWidget.keyString!.isNotEmpty) {
          buffer.writeln('Key: ${annotation.targetWidget.keyString}');
        }
        final cssClasses = annotation.cssClasses;
        if (cssClasses != null && cssClasses.isNotEmpty) {
          buffer.writeln('Classes: $cssClasses');
        }
        final styles = annotation.computedStyles;
        if (styles != null && styles.isNotEmpty) {
          buffer.writeln('Computed Styles: $styles');
        }
        final a11y = annotation.accessibility;
        if (a11y != null && a11y.isNotEmpty) {
          buffer.writeln('Accessibility: $a11y');
        }
        final nearbyEls = annotation.nearbyElements;
        if (nearbyEls != null && nearbyEls.isNotEmpty) {
          buffer.writeln('Nearby Elements: $nearbyEls');
        }
        final flutterComp = annotation.flutterComponents;
        if (flutterComp != null && flutterComp.isNotEmpty) {
          buffer.writeln('Flutter Components: $flutterComp');
        }
        buffer.writeln('Severity: ${annotation.severity.name}');
        buffer.writeln('Status: ${annotation.status.name}');
        buffer.writeln('Comment: ${annotation.comment}');
        break;
    }
  }

  void _writePlacementDetails(
    StringBuffer buffer,
    Annotation annotation, {
    OutputDetailLevel detailLevel = OutputDetailLevel.standard,
  }) {
    final placement = annotation.placement;
    final meta = annotation.metadata;
    final compType = placement?.componentType ??
        (meta['componentType'] as String?) ??
        annotation.targetWidget.widgetType;
    final label = placement?.label ?? (meta['label'] as String?) ?? compType;

    final parent = placement?.parentWidget ?? (meta['parentWidget'] as String?);
    final breadcrumb = placement?.parentBreadcrumb ??
        (meta['parentBreadcrumb'] as String?) ??
        (meta['path'] as String?);
    final treePlacement = placement?.treePlacement ?? (meta['treePlacement'] as String?);
    final direction = placement?.direction ?? (meta['direction'] as String?);
    final relTarget = placement?.relativeTarget ?? (meta['relativeTarget'] as String?);
    final childIndex = placement?.childIndex ?? (meta['childIndex'] as int?);
    final totalChildren = placement?.totalChildren ?? (meta['totalChildren'] as int?);
    final sibBefore = placement?.siblingBefore ?? (meta['siblingBefore'] as String?);
    final sibAfter = placement?.siblingAfter ?? (meta['siblingAfter'] as String?);
    final source = placement?.source ?? (meta['source'] as String?);
    final variant = placement?.variant ?? (meta['variant'] as String?);

    final width = placement?.width ?? annotation.bounds.width;
    final height = placement?.height ?? annotation.bounds.height;
    final b = annotation.bounds;

    final target = annotation.toFeedbackTarget();

    buffer.writeln('Action: Place Component');
    buffer.writeln('Component: $label');
    if (compType != label) {
      buffer.writeln('Component Type: $compType');
    }
    if (source != null && source.isNotEmpty) {
      buffer.writeln('Source / Path: $source');
    }
    if (variant != null && variant.isNotEmpty) {
      buffer.writeln('Variant / Style: $variant');
    }
    buffer.writeln('Development Instruction: Understand the project theme, decorations, and design language in this codebase, and develop this component to match the existing project style.');
    if (parent != null && parent.isNotEmpty) {
      buffer.writeln('Target Container: $parent');
    }
    if (breadcrumb != null && breadcrumb.isNotEmpty) {
      buffer.writeln('Hierarchy: $breadcrumb');
    }
    if (treePlacement != null && treePlacement.isNotEmpty) {
      buffer.writeln('Placement: $treePlacement');
    }

    if (detailLevel != OutputDetailLevel.compact) {
      if (direction != null && direction.isNotEmpty) {
        buffer.writeln('Direction: $direction');
      }
      if (relTarget != null && relTarget.isNotEmpty) {
        buffer.writeln('Relative Target: $relTarget');
      }
      if (childIndex != null) {
        if (totalChildren != null) {
          buffer.writeln('Insertion Index: child #$childIndex of $totalChildren');
        } else {
          buffer.writeln('Insertion Index: child #$childIndex');
        }
      }
      if (sibBefore != null && sibBefore.isNotEmpty) {
        buffer.writeln('Sibling Before: $sibBefore');
      }
      if (sibAfter != null && sibAfter.isNotEmpty) {
        buffer.writeln('Sibling After: $sibAfter');
      }
    }

    final wStr = width.truncate() == width ? width.toInt().toString() : width.toStringAsFixed(1);
    final hStr = height.truncate() == height ? height.toInt().toString() : height.toStringAsFixed(1);
    buffer.writeln('Dimensions: $wStr×${hStr}px');
    final bx = b.x.truncate() == b.x ? b.x.toInt().toString() : b.x.toStringAsFixed(1);
    final by = b.y.truncate() == b.y ? b.y.toInt().toString() : b.y.toStringAsFixed(1);
    buffer.writeln('Drop Position: x:$bx, y:$by');

    if (detailLevel == OutputDetailLevel.forensic) {
      final fullPath = annotation.fullPath ?? meta['fullPath'] as String?;
      if (fullPath != null && fullPath.isNotEmpty) {
        buffer.writeln('Full Hierarchy Path: $fullPath');
      }
      final styles = annotation.computedStyles;
      if (styles != null && styles.isNotEmpty) {
        buffer.writeln('Computed Styles: $styles');
      }
      final a11y = annotation.accessibility;
      if (a11y != null && a11y.isNotEmpty) {
        buffer.writeln('Accessibility: $a11y');
      }
      buffer.writeln('Severity: ${annotation.severity.name}');
      buffer.writeln('Status: ${annotation.status.name}');
    }

    buffer.writeln('File: ${target.source.fileString}');
    buffer.writeln('Location: ${target.source.locationString}');
    buffer.writeln('Line: ${target.source.lineString}');
    buffer.writeln('Comment: ${annotation.comment}');
  }
}

