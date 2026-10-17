import 'dart:convert';
import 'dart:io';
import 'source_code_extractor.dart';

/// Reads the exact source code snippet from a file on disk.
String? readSourceCodeFromFile(String? rawPath, int? line, String? widgetType) {
  if (rawPath == null || rawPath.isEmpty || line == null || line <= 0) {
    return null;
  }

  try {
    File? resolvedFile;

    // 1. Clean path
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

    // Normalize forward/backward slashes
    final normalized = cleanPath.replaceAll(r'\', '/');

    // Candidate file paths to check on disk
    final candidates = <String>[
      cleanPath,
      normalized,
      if (cleanPath.startsWith('/') && RegExp(r'^/[a-zA-Z]:').hasMatch(cleanPath))
        cleanPath.substring(1),
      if (normalized.startsWith('/') && RegExp(r'^/[a-zA-Z]:').hasMatch(normalized))
        normalized.substring(1),
      // Relative to current directory
      '${Directory.current.path}/$normalized',
      '${Directory.current.path}/$cleanPath',
      // If project has example/ subfolder
      '${Directory.current.path}/example/$normalized',
      // If running inside example/ subfolder
      '${Directory.current.parent.path}/$normalized',
      // If path contains lib/
      if (normalized.contains('lib/'))
        '${Directory.current.path}/${normalized.substring(normalized.indexOf('lib/'))}',
      if (normalized.contains('lib/'))
        '${Directory.current.path}/example/${normalized.substring(normalized.indexOf('lib/'))}',
      if (normalized.contains('lib/'))
        '${Directory.current.parent.path}/${normalized.substring(normalized.indexOf('lib/'))}',
      // If path contains test/
      if (normalized.contains('test/'))
        '${Directory.current.path}/${normalized.substring(normalized.indexOf('test/'))}',
      if (normalized.contains('test/'))
        '${Directory.current.parent.path}/${normalized.substring(normalized.indexOf('test/'))}',
    ];

    for (final candidate in candidates) {
      try {
        final f = File(candidate);
        if (f.existsSync()) {
          resolvedFile = f;
          break;
        }
      } catch (_) {}
    }

    if (resolvedFile == null) return null;

    final content = resolvedFile.readAsStringSync(encoding: utf8);
    return extractSnippetFromSource(content, line, widgetType);
  } catch (_) {
    return null;
  }
}

