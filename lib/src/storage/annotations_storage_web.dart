import 'dart:convert';
import 'dart:js_interop';

@JS('window.localStorage.getItem')
external String? _jsGetItem(String key);

@JS('window.localStorage.setItem')
external void _jsSetItem(String key, String value);

@JS('window.localStorage.removeItem')
external void _jsRemoveItem(String key);

const _storageKey = 'flutter_agentation_annotations';

List<Map<String, dynamic>>? loadStoredAnnotationsJson() {
  try {
    final raw = _jsGetItem(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    }
  } catch (_) {}
  return null;
}

void saveStoredAnnotationsJson(List<Map<String, dynamic>> annotationsJson) {
  try {
    _jsSetItem(_storageKey, jsonEncode(annotationsJson));
  } catch (_) {}
}

void clearStoredAnnotationsJson() {
  try {
    _jsRemoveItem(_storageKey);
  } catch (_) {}
}

