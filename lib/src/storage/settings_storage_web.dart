import 'dart:convert';
import 'dart:js_interop';

@JS('window.localStorage.getItem')
external String? _jsGetItem(String key);

@JS('window.localStorage.setItem')
external void _jsSetItem(String key, String value);

@JS('window.localStorage.removeItem')
external void _jsRemoveItem(String key);

const _storageKey = 'flutter_agentation_settings';

Map<String, dynamic>? loadStoredSettings() {
  try {
    final raw = _jsGetItem(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }
  } catch (_) {}
  return null;
}

void saveStoredSettings(Map<String, dynamic> settingsJson) {
  try {
    _jsSetItem(_storageKey, jsonEncode(settingsJson));
  } catch (_) {}
}

void clearStoredSettings() {
  try {
    _jsRemoveItem(_storageKey);
    _jsRemoveItem('flutter_agentation_marker_color');
  } catch (_) {}
}

String? loadStoredMarkerColor() {
  final settings = loadStoredSettings();
  if (settings != null && settings['markerColorId'] is String) {
    return settings['markerColorId'] as String;
  }
  try {
    return _jsGetItem('flutter_agentation_marker_color');
  } catch (_) {
    return null;
  }
}

void saveStoredMarkerColor(String colorId) {
  final settings = loadStoredSettings() ?? {};
  settings['markerColorId'] = colorId;
  saveStoredSettings(settings);
  try {
    _jsSetItem('flutter_agentation_marker_color', colorId);
  } catch (_) {}
}

void clearStoredMarkerColor() {
  clearStoredSettings();
}
