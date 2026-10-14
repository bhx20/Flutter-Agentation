/// Utility responsible for extracting a clean, idiomatic Flutter Dart widget
/// snippet from source code text given a target line number and widget type.
String? extractSnippetFromSource(String sourceText, int line, String? widgetType) {
  if (sourceText.isEmpty || line <= 0) return null;

  // Normalize line endings
  final lines = sourceText.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
  if (lines.isEmpty || line > lines.length) return null;

  final targetLineIdx = line - 1;
  final startLine = lines[targetLineIdx];

  // Check if widgetType (or its raw non-generic name) is in this line or nearby (-2 to +2 lines)
  final typeName = widgetType ?? '';
  final rawTypeName = typeName.contains('<') ? typeName.substring(0, typeName.indexOf('<')).trim() : typeName;
  int codeStartIdx = targetLineIdx;

  bool lineMatches(String lineContent) {
    if (typeName.isNotEmpty && lineContent.contains(typeName)) return true;
    if (rawTypeName.isNotEmpty && lineContent.contains(rawTypeName)) return true;
    return false;
  }

  if (rawTypeName.isNotEmpty && !lineMatches(startLine)) {
    for (int offset = -2; offset <= 2; offset++) {
      final checkIdx = targetLineIdx + offset;
      if (checkIdx >= 0 && checkIdx < lines.length && lineMatches(lines[checkIdx])) {
        codeStartIdx = checkIdx;
        break;
      }
    }
  }

  final snippetLines = <String>[];
  int parenDepth = 0;
  bool started = false;

  // Read up to 100 lines from codeStartIdx or until balanced parentheses
  const maxScanLines = 100;
  for (int i = codeStartIdx; i < lines.length && i < codeStartIdx + maxScanLines; i++) {
    final currentLine = lines[i];
    snippetLines.add(currentLine);

    for (int c = 0; c < currentLine.length; c++) {
      final char = currentLine[c];
      if (char == '(') {
        parenDepth++;
        started = true;
      } else if (char == ')') {
        parenDepth--;
      }
    }

    if (started && parenDepth <= 0) {
      break;
    }
  }

  if (snippetLines.isEmpty) return null;

  // Trim property prefix if any (e.g. "child: const WidgetCard(", "return Card(")
  final firstRaw = snippetLines.first.trimLeft();
  final propRegex = RegExp(r'^(?:[a-zA-Z0-9_]+:\s*|return\s+|=?>?\s*)((?:const\s+)?[A-Z].*)');
  final match = propRegex.firstMatch(firstRaw);
  if (match != null) {
    snippetLines[0] = match.group(1)!;
  } else {
    snippetLines[0] = firstRaw;
  }

  // Calculate common base indentation from the original codeStartIdx
  final baseIndent = lines[codeStartIdx].indexOf(RegExp(r'\S'));

  if (baseIndent > 0 && snippetLines.length > 1) {
    for (int i = 1; i < snippetLines.length; i++) {
      final rawLine = lines[codeStartIdx + i];
      if (rawLine.trim().isEmpty) {
        snippetLines[i] = '';
      } else {
        final indent = rawLine.indexOf(RegExp(r'\S'));
        final relIndent = indent != -1 ? (indent >= baseIndent ? indent - baseIndent : 0) : 0;
        snippetLines[i] = (' ' * relIndent) + rawLine.trimLeft();
      }
    }
  } else if (snippetLines.length > 1) {
    int? minIndent;
    for (int i = 1; i < snippetLines.length; i++) {
      final l = snippetLines[i];
      if (l.trim().isEmpty) continue;
      final indent = l.indexOf(RegExp(r'\S'));
      if (indent != -1) {
        if (minIndent == null || indent < minIndent) {
          minIndent = indent;
        }
      }
    }

    if (minIndent != null && minIndent > 0) {
      for (int i = 1; i < snippetLines.length; i++) {
        final l = snippetLines[i];
        if (l.trim().isEmpty) {
          snippetLines[i] = '';
        } else {
          final currentIndent = l.indexOf(RegExp(r'\S'));
          final extraIndent = (currentIndent >= minIndent) ? currentIndent - minIndent : 0;
          snippetLines[i] = '  ' + (' ' * extraIndent) + l.trimLeft();
        }
      }
    }
  }

  // Strip trailing comma or semicolon from last line for clean display
  var last = snippetLines.last.trimRight();
  if (last.endsWith(';') || last.endsWith(',')) {
    snippetLines[snippetLines.length - 1] = last.substring(0, last.length - 1);
  }

  final result = snippetLines.join('\n').trim();
  return result.isNotEmpty ? result : null;
}
