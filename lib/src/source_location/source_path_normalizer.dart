/// Utility responsible for normalizing file paths and URIs into clean, portable,
/// project-relative locations.
///
/// Designed per Master Prompt Section 8:
/// - Detects project `lib/` path where possible.
/// - Removes absolute workspace prefixes (Windows or Unix).
/// - Normalizes Windows backslashes (`\`) to standard forward slashes (`/`).
/// - Preserves `lib/...` or relative directories.
/// - Falls back safely if the project root cannot be determined.
String normalizeProjectPath(String path) {
  if (path.isEmpty) return path;

  // 1. Decode URI schemes (e.g. file:///... or file://...)
  String normalized = path;
  if (normalized.startsWith('file://')) {
    try {
      final uri = Uri.parse(normalized);
      normalized = uri.toFilePath();
    } catch (_) {
      normalized = normalized.replaceFirst(RegExp(r'^file://+'), '');
    }
  }

  // 2. Handle package: URIs (e.g. package:app_name/feature/foo.dart -> lib/feature/foo.dart)
  if (normalized.startsWith('package:')) {
    final slashIndex = normalized.indexOf('/');
    if (slashIndex != -1) {
      return 'lib/${normalized.substring(slashIndex + 1)}';
    }
  }

  // 3. Normalize all backslashes to forward slashes
  normalized = normalized.replaceAll(r'\', '/');

  // Strip leading slash on Windows paths (e.g. /C:/... -> C:/...)
  if (RegExp(r'^/[a-zA-Z]:').hasMatch(normalized)) {
    normalized = normalized.substring(1);
  }

  // 4. Locate project-relative directory markers: 'lib/', 'test/', 'example/', 'bin/'
  const markers = ['lib/', 'test/', 'example/', 'bin/'];
  for (final marker in markers) {
    final index = normalized.lastIndexOf(marker);
    if (index != -1) {
      // Check if there is an enclosing project segment before example/
      // e.g. /app/example/lib/main.dart -> example/lib/main.dart
      final sub = normalized.substring(index);
      return sub;
    }
  }

  // 5. If no standard directory marker found, return clean trimmed path
  return normalized;
}

/// Extracts the clean base file name from a path or URI (e.g. 'login_page.dart').
String extractFileName(String path) {
  if (path.isEmpty) return 'unavailable';

  String clean = path;
  if (clean.startsWith('file://')) {
    try {
      final uri = Uri.parse(clean);
      clean = uri.path;
    } catch (_) {}
  }

  clean = clean.replaceAll(r'\', '/');
  final lastSlash = clean.lastIndexOf('/');
  if (lastSlash != -1 && lastSlash < clean.length - 1) {
    return clean.substring(lastSlash + 1);
  }
  return clean;
}
