import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

@visibleForTesting
bool debugForceDiskIo = false;

@visibleForTesting
bool persistAnnotationsInTest = false;

File _getAnnotationsFile() {
  final tempDir = Directory.systemTemp.path;
  return File('$tempDir/flutter_agentation_annotations.json');
}

bool _isTestEnvironment() {
  if (debugForceDiskIo) return false;
  return Platform.environment.containsKey('FLUTTER_TEST');
}

List<Map<String, dynamic>>? _testMemoryAnnotations;

List<Map<String, dynamic>>? loadStoredAnnotationsJson() {
  if (_isTestEnvironment()) {
    if (persistAnnotationsInTest && _testMemoryAnnotations != null) {
      return List<Map<String, dynamic>>.from(
        _testMemoryAnnotations!.map((m) => Map<String, dynamic>.from(m)),
      );
    }
    return null;
  }
  try {
    final file = _getAnnotationsFile();
    if (file.existsSync()) {
      final json = jsonDecode(file.readAsStringSync());
      if (json is List) {
        return json
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    }
  } catch (_) {}
  return null;
}

void saveStoredAnnotationsJson(List<Map<String, dynamic>> annotationsJson) {
  if (_isTestEnvironment()) {
    if (persistAnnotationsInTest) {
      _testMemoryAnnotations = List<Map<String, dynamic>>.from(
        annotationsJson.map((m) => Map<String, dynamic>.from(m)),
      );
    }
    return;
  }
  try {
    final file = _getAnnotationsFile();
    file.writeAsStringSync(jsonEncode(annotationsJson));
  } catch (_) {}
}

void clearStoredAnnotationsJson() {
  if (_isTestEnvironment()) {
    _testMemoryAnnotations = null;
    return;
  }
  try {
    final file = _getAnnotationsFile();
    if (file.existsSync()) {
      file.deleteSync();
    }
  } catch (_) {}
}

