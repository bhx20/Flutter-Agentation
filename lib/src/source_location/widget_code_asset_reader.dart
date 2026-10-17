import 'package:flutter/services.dart';
import 'source_code_extractor.dart';

/// Reads the exact source code snippet from Flutter AssetBundle (e.g. on Flutter Web).
Future<String?> readSourceCodeFromAsset(String? rawPath, int? line, String? widgetType) async {
  if (rawPath == null || rawPath.isEmpty || line == null || line <= 0) {
    return null;
  }

  try {
    // 1. Clean URI schemes and normalize slashes
    String cleanPath = rawPath;
    if (cleanPath.startsWith('file:///')) {
      try {
        cleanPath = Uri.parse(cleanPath).toFilePath();
      } catch (_) {
        cleanPath = cleanPath.replaceFirst('file:///', '');
      }
    } else if (cleanPath.startsWith('file://')) {
      cleanPath = cleanPath.replaceFirst(RegExp(r'^file://+'), '');
    }

    final normalized = cleanPath.replaceAll(r'\', '/');

    // Candidate asset paths to check in rootBundle
    final candidates = <String>[
      normalized,
      if (normalized.contains('lib/')) normalized.substring(normalized.indexOf('lib/')),
      if (normalized.contains('example/')) normalized.substring(normalized.indexOf('example/')),
      if (normalized.contains('lib/')) 'assets/${normalized.substring(normalized.indexOf('lib/'))}',
      if (normalized.contains('example/')) 'assets/${normalized.substring(normalized.indexOf('example/'))}',
      'assets/$normalized',
      if (cleanPath.contains('/')) cleanPath.substring(cleanPath.lastIndexOf('/') + 1),
    ];

    for (final candidate in candidates) {
      try {
        final content = await rootBundle.loadString(candidate);
        if (content.isNotEmpty) {
          final snippet = extractSnippetFromSource(content, line, widgetType);
          if (snippet != null && snippet.isNotEmpty) {
            return snippet;
          }
        }
      } catch (_) {}
    }

    return null;
  } catch (_) {
    return null;
  }
}

