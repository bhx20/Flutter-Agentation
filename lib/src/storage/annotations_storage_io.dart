import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

@visibleForTesting
bool debugForceDiskIo = false;

@visibleForTesting
bool persistAnnotationsInTest = false;

List<File> _getCandidateFiles() {
  final files = <File>[];
  try {
    var dir = Directory.current;
    for (int i = 0; i < 5; i++) {
      final agentationDir = Directory('${dir.path}/.flutter_agentation');
      if (agentationDir.existsSync()) {
        files.add(File('${agentationDir.path}/annotations.json'));
        break;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
  } catch (_) {}
  try {
    final tempDir = Directory.systemTemp.path;
    files.add(File('$tempDir/flutter_agentation_annotations.json'));
  } catch (_) {}
  return files;
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
    for (final file in _getCandidateFiles()) {
      if (file.existsSync()) {
        final content = file.readAsStringSync().trim();
        if (content.isNotEmpty) {
          final json = jsonDecode(content);
          if (json is List) {
            return json
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList();
          }
        }
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
    final payload = jsonEncode(annotationsJson);
    for (final file in _getCandidateFiles()) {
      try {
        file.writeAsStringSync(payload);
      } catch (_) {}
    }
  } catch (_) {}
}

void clearStoredAnnotationsJson() {
  if (_isTestEnvironment()) {
    _testMemoryAnnotations = null;
    return;
  }
  try {
    for (final file in _getCandidateFiles()) {
      try {
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }
  } catch (_) {}
}

