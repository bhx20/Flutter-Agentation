import 'package:flutter/widgets.dart';

import '../domain/widget_bounds.dart';
import '../domain/widget_inspection_result.dart';
import 'widget_code_asset_reader.dart';
import 'widget_code_file_reader.dart';
import 'widget_source_location.dart';

/// Helper responsible for extracting exact developer source code or generating
/// canonical Flutter Dart widget code for inspected elements.
class WidgetCodeResolver {
  WidgetCodeResolver._();

  /// Asynchronously resolves exact developer source code from bundled assets (works on Web and all platforms).
  static Future<String?> resolveAsyncWidgetCode({
    String? filePath,
    int? line,
    String? widgetType,
  }) async {
    if (filePath == null || line == null) return null;
    return readSourceCodeFromAsset(filePath, line, widgetType);
  }

  /// Resolves the cleanest, most accurate widget code representation.
  static String resolveWidgetCode({
    WidgetInspectionResult? result,
    Element? element,
    WidgetSourceLocation? sourceLocation,
    String? widgetType,
    String? text,
    String? keyString,
    WidgetBounds? bounds,
  }) {
    if (result?.widgetCode != null && result!.widgetCode!.trim().isNotEmpty) {
      return result.widgetCode!;
    }
    final effectiveType = widgetType ?? result?.identity.widgetType ?? 'Widget';
    final effectiveText = text ?? result?.text;
    final effectiveKey = keyString ?? result?.identity.keyString;
    final effectiveBounds = bounds ?? result?.bounds;
    final effectiveLocation = sourceLocation ?? result?.sourceLocation;

    // 1. Try reading the exact source code from file on disk
    if (effectiveLocation != null &&
        (effectiveLocation.rawPath != null || effectiveLocation.filePath != null) &&
        effectiveLocation.line != null) {
      final fileCode = readSourceCodeFromFile(
        effectiveLocation.rawPath ?? effectiveLocation.filePath,
        effectiveLocation.line,
        effectiveType,
      );
      if (fileCode != null && fileCode.trim().isNotEmpty) {
        return fileCode;
      }
    }

    // 2. Reconstruct canonical Dart code using widget properties
    return resolveCanonicalWidgetCode(
      widgetType: effectiveType,
      text: effectiveText,
      keyString: effectiveKey,
      bounds: effectiveBounds,
      element: element,
    );
  }

  /// Generates clean, idiomatic Flutter Dart code for a widget.
  static String resolveCanonicalWidgetCode({
    required String widgetType,
    String? text,
    String? keyString,
    WidgetBounds? bounds,
    Element? element,
  }) {
    final cleanKey = keyString != null && keyString.isNotEmpty
        ? (keyString.startsWith('[') && keyString.endsWith(']')
            ? keyString.substring(1, keyString.length - 1)
            : keyString)
        : null;

    final keyParam = cleanKey != null ? "key: const Key('$cleanKey'),\n  " : '';

    switch (widgetType) {
      case 'Text':
        final content = text ?? 'Sample text';
        return cleanKey != null
            ? "Text(\n  key: const Key('$cleanKey'),\n  '$content',\n)"
            : "Text('$content')";

      case 'RichText':
        return "RichText(\n  ${keyParam}text: TextSpan(\n    text: '${text ?? "Text"}',\n  ),\n)";

      case 'ElevatedButton':
        final childText = text != null && text.isNotEmpty ? text : 'Button';
        return 'ElevatedButton(\n  ${keyParam}onPressed: () {},\n  child: Text(\'$childText\'),\n)';

      case 'FilledButton':
        final childText = text != null && text.isNotEmpty ? text : 'Button';
        return 'FilledButton(\n  ${keyParam}onPressed: () {},\n  child: Text(\'$childText\'),\n)';

      case 'OutlinedButton':
        final childText = text != null && text.isNotEmpty ? text : 'Button';
        return 'OutlinedButton(\n  ${keyParam}onPressed: () {},\n  child: Text(\'$childText\'),\n)';

      case 'TextButton':
        final childText = text != null && text.isNotEmpty ? text : 'Button';
        return 'TextButton(\n  ${keyParam}onPressed: () {},\n  child: Text(\'$childText\'),\n)';

      case 'IconButton':
        return 'IconButton(\n  ${keyParam}icon: const Icon(Icons.touch_app),\n  onPressed: () {},\n)';

      case 'FloatingActionButton':
        return 'FloatingActionButton(\n  ${keyParam}onPressed: () {},\n  child: const Icon(Icons.add),\n)';

      case 'Icon':
        final iconName = text != null && text.isNotEmpty ? text.toLowerCase().replaceAll(' ', '_') : 'star';
        return 'Icon(\n  ${keyParam}Icons.$iconName,\n  size: 24.0,\n)';

      case 'Card':
        final child = text != null && text.isNotEmpty
            ? "Padding(\n    padding: const EdgeInsets.all(16.0),\n    child: Text('$text'),\n  )"
            : 'Container()';
        return 'Card(\n  ${keyParam}elevation: 2.0,\n  child: $child,\n)';

      case 'Container':
        final width = bounds != null && bounds.width > 0 ? bounds.width.round() : null;
        final height = bounds != null && bounds.height > 0 ? bounds.height.round() : null;
        final sizeParams = [
          if (width != null) 'width: $width.0',
          if (height != null) 'height: $height.0',
        ];
        final sizeStr = sizeParams.isNotEmpty ? '${sizeParams.join(',\n  ')},\n  ' : '';
        final childStr = text != null && text.isNotEmpty ? "child: Text('$text'),\n" : '';
        if (keyParam.isEmpty && sizeStr.isEmpty && childStr.isEmpty) {
          return 'Container()';
        }
        return 'Container(\n  $keyParam$sizeStr$childStr)';

      case 'TextField':
        final hint = text != null && text.isNotEmpty ? text : 'Enter text...';
        return 'TextField(\n  ${keyParam}decoration: InputDecoration(\n    hintText: \'$hint\',\n  ),\n)';

      case 'ListTile':
        final title = text != null && text.isNotEmpty ? text : 'Title';
        return 'ListTile(\n  ${keyParam}title: Text(\'$title\'),\n  onTap: () {},\n)';

      case 'Switch':
        return 'Switch(\n  ${keyParam}value: true,\n  onChanged: (val) {},\n)';

      case 'Checkbox':
        return 'Checkbox(\n  ${keyParam}value: true,\n  onChanged: (val) {},\n)';

      case 'CircularProgressIndicator':
        return 'CircularProgressIndicator(\n  ${keyParam}strokeWidth: 3.0,\n)';

      case 'LinearProgressIndicator':
        return 'LinearProgressIndicator(\n  ${keyParam}value: 0.7,\n)';

      default:
        if (text != null && text.isNotEmpty) {
          return '$widgetType(\n  ${keyParam}child: Text(\'$text\'),\n)';
        }
        if (keyParam.isNotEmpty) {
          return '$widgetType(\n  $keyParam)';
        }
        return '$widgetType()';
    }
  }
}

