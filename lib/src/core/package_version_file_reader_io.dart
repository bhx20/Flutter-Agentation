import 'dart:convert';
import 'dart:io';

/// Native (desktop/mobile/tests) reader for package pubspec.yaml from file system.
String? readPubspecYamlFromFile(String path) {
  try {
    final file = File(path);
    if (file.existsSync()) {
      return file.readAsStringSync(encoding: utf8);
    }
  } catch (_) {}
  return null;
}

