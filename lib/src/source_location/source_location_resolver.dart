import 'dart:convert';
import 'package:flutter/widgets.dart';

import '../core/agentation_logger.dart';
import 'source_path_normalizer.dart';
import 'widget_source_location.dart';

/// Contract for resolving exact source code locations for inspected Flutter elements.
abstract interface class SourceLocationResolver {
  /// Resolves the source code file, line, and column for the given [element].
  ///
  /// Returns `null` or [WidgetSourceLocation.unavailable] if source location is unavailable.
  WidgetSourceLocation? resolve(Element element);
}

/// Primary Flutter implementation of [SourceLocationResolver] utilizing Flutter SDK's
/// [WidgetInspectorService] and AST constructor creation tracking.
class FlutterSourceLocationResolver implements SourceLocationResolver {
  final WidgetInspectorService inspectorService;
  static final Expando<WidgetSourceLocation> _cache = Expando<WidgetSourceLocation>();

  FlutterSourceLocationResolver({WidgetInspectorService? inspectorService})
      : inspectorService = inspectorService ?? WidgetInspectorService.instance;

  @override
  WidgetSourceLocation? resolve(Element element) {
    try {
      if (!inspectorService.isWidgetCreationTracked()) {
        AgentationLogger.debug('Widget creation tracking is disabled (profile/release mode).');
        return const WidgetSourceLocation.unavailable();
      }

      final cached = _cache[element];
      if (cached != null) return cached;

      final groupName = 'agentation_source_${DateTime.now().microsecondsSinceEpoch}';
      try {
        // 1. First attempt: resolve location for the element directly
        WidgetSourceLocation? loc = _resolveElementLocation(element, groupName);

        // 2. If the element is an internal framework widget (e.g. from flutter/packages/flutter),
        // walk up the ancestor chain to find the developer-authored widget in user project code
        if (loc == null || _isFrameworkFile(loc.filePath)) {
          final summaryLoc = _resolveSummaryLocation(groupName);
          if (summaryLoc != null && !_isFrameworkFile(summaryLoc.filePath)) {
            loc = summaryLoc;
          } else {
            // Walk ancestors to find nearest user code (limit to 5 steps, skip private framework widgets)
            int steps = 0;
            element.visitAncestorElements((ancestor) {
              if (++steps > 5) return false;
              final typeName = ancestor.widget.runtimeType.toString();
              if (typeName.startsWith('_')) return true;

              final ancestorCached = _cache[ancestor];
              if (ancestorCached != null) {
                if (!_isFrameworkFile(ancestorCached.filePath)) {
                  loc = ancestorCached;
                  return false;
                }
                return true;
              }

              final ancestorLoc = _resolveElementLocation(ancestor, groupName);
              if (ancestorLoc != null) {
                _cache[ancestor] = ancestorLoc;
                if (!_isFrameworkFile(ancestorLoc.filePath)) {
                  loc = ancestorLoc;
                  return false; // Stop walking
                }
              }
              return true;
            });
          }
        }

        final result = loc ?? const WidgetSourceLocation.unavailable();
        _cache[element] = result;
        return result;
      } finally {
        // ignore: invalid_use_of_protected_member
        inspectorService.disposeGroup(groupName);
      }
    } catch (e, st) {
      AgentationLogger.warning('Failed to resolve source location for element: $e');
      AgentationLogger.verbose(st.toString());
      return const WidgetSourceLocation.unavailable();
    }
  }

  WidgetSourceLocation? _resolveElementLocation(Element element, String groupName) {
    try {
      inspectorService.selection.currentElement = element;
      // ignore: invalid_use_of_protected_member
      final jsonStr = inspectorService.getSelectedWidget(null, groupName);
      if (jsonStr.isEmpty) return null;

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final creationLoc = data['creationLocation'] as Map<String, dynamic>?;
      if (creationLoc == null) return null;

      final rawFile = creationLoc['file'] as String?;
      if (rawFile == null || rawFile.isEmpty) return null;

      final line = creationLoc['line'] as int?;
      final column = creationLoc['column'] as int?;

      final normalizedPath = normalizeProjectPath(rawFile);
      final fileName = extractFileName(rawFile);

      return WidgetSourceLocation(
        fileName: fileName,
        filePath: normalizedPath,
        line: line,
        column: column,
      );
    } catch (_) {
      return null;
    }
  }

  WidgetSourceLocation? _resolveSummaryLocation(String groupName) {
    try {
      // ignore: invalid_use_of_protected_member
      final jsonStr = inspectorService.getSelectedSummaryWidget(null, groupName);
      if (jsonStr.isEmpty) return null;

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final creationLoc = data['creationLocation'] as Map<String, dynamic>?;
      if (creationLoc == null) return null;

      final rawFile = creationLoc['file'] as String?;
      if (rawFile == null || rawFile.isEmpty) return null;

      final line = creationLoc['line'] as int?;
      final column = creationLoc['column'] as int?;

      final normalizedPath = normalizeProjectPath(rawFile);
      final fileName = extractFileName(rawFile);

      return WidgetSourceLocation(
        fileName: fileName,
        filePath: normalizedPath,
        line: line,
        column: column,
      );
    } catch (_) {
      return null;
    }
  }

  static bool _isFrameworkFile(String? path) {
    if (path == null) return true;
    final lower = path.toLowerCase();
    return lower.contains('packages/flutter') ||
        lower.contains('flutter/packages') ||
        lower.contains('dart-sdk') ||
        lower.contains('flutter/bin/cache');
  }
}
