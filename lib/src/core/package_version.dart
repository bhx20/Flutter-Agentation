import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Provides dynamic access to the package version defined in `pubspec.yaml`.
class PackageVersion {
  PackageVersion._();

  /// Default fallback version matching pubspec.yaml.
  static const String defaultVersion = '0.0.1';

  static String _version = defaultVersion;

  /// Current package version (e.g. '0.0.1').
  static String get current => _version;

  /// Update the current in-memory version.
  static void setVersion(String version) {
    _version = version;
  }

  /// Parses `version: <value>` from pubspec.yaml content.
  static String? parseYamlVersion(String yamlContent) {
    final match = RegExp(r'^version:\s*([^\s#+]+)', multiLine: true).firstMatch(yamlContent);
    return match?.group(1)?.trim();
  }

  /// Attempts to load the version from `pubspec.yaml`.
  ///
  /// Checks rootBundle assets first, then falls back to file system (in unit tests / CLI),
  /// and defaults to [defaultVersion].
  static Future<String> loadFromYaml({AssetBundle? bundle}) async {
    // 1. Try loading from asset bundle
    try {
      final b = bundle ?? rootBundle;
      String? yaml;
      try {
        yaml = await b.loadString('packages/flutter_agentation/pubspec.yaml');
      } catch (_) {
        try {
          yaml = await b.loadString('pubspec.yaml');
        } catch (_) {}
      }

      if (yaml != null && yaml.isNotEmpty) {
        final parsed = parseYamlVersion(yaml);
        if (parsed != null && parsed.isNotEmpty) {
          _version = parsed;
          return _version;
        }
      }
    } catch (_) {}

    // 2. In non-web environments (tests, desktop tools), try reading directly from file system
    if (!kIsWeb) {
      try {
        final candidates = [
          'pubspec.yaml',
          '../pubspec.yaml',
        ];
        for (final path in candidates) {
          final file = File(path);
          if (file.existsSync()) {
            final content = file.readAsStringSync(encoding: utf8);
            final parsed = parseYamlVersion(content);
            if (parsed != null && parsed.isNotEmpty) {
              _version = parsed;
              return _version;
            }
          }
        }
      } catch (_) {}
    }

    return _version;
  }
}
