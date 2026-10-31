import 'annotations_storage_stub.dart'
    if (dart.library.io) 'annotations_storage_io.dart'
    if (dart.library.js_interop) 'annotations_storage_web.dart' as impl;

/// Loads stored annotations JSON list from persistent storage.
List<Map<String, dynamic>>? loadStoredAnnotationsJson() =>
    impl.loadStoredAnnotationsJson();

/// Saves annotations JSON list to persistent storage.
void saveStoredAnnotationsJson(List<Map<String, dynamic>> annotationsJson) =>
    impl.saveStoredAnnotationsJson(annotationsJson);

/// Clears stored annotations from persistent storage.
void clearStoredAnnotationsJson() => impl.clearStoredAnnotationsJson();

