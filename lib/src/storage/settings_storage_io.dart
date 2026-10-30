import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

@visibleForTesting
bool debugForceDiskIo = false;

File _getSettingsFile() {
  final tempDir = Directory.systemTemp.path;
  return File('$tempDir/flutter_agentation_settings.json');
}

bool _isTestEnvironment() {
  if (debugForceDiskIo) return false;
  return Platform.environment.containsKey('FLUTTER_TEST');
}

Map<String, dynamic>? _testMemorySettings;

Map<String, dynamic>? loadStoredSettings() {
  if (_isTestEnvironment()) {
    if (_testMemorySettings != null) {
      return Map<String, dynamic>.from(_testMemorySettings!);
    }
    return null;
  }
  try {
    final file = _getSettingsFile();
    if (file.existsSync()) {
      final json = jsonDecode(file.readAsStringSync());
      if (json is Map) {
        return Map<String, dynamic>.from(json);
      }
    }
  } catch (_) {}
  return null;
}

void saveStoredSettings(Map<String, dynamic> settingsJson) {
  if (_isTestEnvironment()) {
    _testMemorySettings = Map<String, dynamic>.from(settingsJson);
    return;
  }
  try {
    final file = _getSettingsFile();
    file.writeAsStringSync(jsonEncode(settingsJson));
  } catch (_) {}
}

void clearStoredSettings() {
  if (_isTestEnvironment()) {
    _testMemorySettings = null;
    return;
  }
  try {
    final file = _getSettingsFile();
    if (file.existsSync()) {
      file.deleteSync();
    }
  } catch (_) {}
}

String? loadStoredMarkerColor() {
  final settings = loadStoredSettings();
  if (settings != null && settings['markerColorId'] is String) {
    return settings['markerColorId'] as String;
  }
  return null;
}

void saveStoredMarkerColor(String colorId) {
  final settings = loadStoredSettings() ?? {};
  settings['markerColorId'] = colorId;
  saveStoredSettings(settings);
}

void clearStoredMarkerColor() {
  clearStoredSettings();
}
