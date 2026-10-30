import 'settings_storage_stub.dart'
    if (dart.library.io) 'settings_storage_io.dart'
    if (dart.library.js_interop) 'settings_storage_web.dart' as impl;

/// Loads the persisted settings map from storage.
Map<String, dynamic>? loadStoredSettings() => impl.loadStoredSettings();

/// Saves the settings map to persistent storage.
void saveStoredSettings(Map<String, dynamic> settingsJson) =>
    impl.saveStoredSettings(settingsJson);

/// Clears persisted settings from storage.
void clearStoredSettings() => impl.clearStoredSettings();

/// Loads the last selected marker color ID from persistent storage.
String? loadStoredMarkerColor() => impl.loadStoredMarkerColor();

/// Saves the selected marker color ID to persistent storage.
void saveStoredMarkerColor(String colorId) => impl.saveStoredMarkerColor(colorId);

/// Clears the selected marker color ID from persistent storage.
void clearStoredMarkerColor() => impl.clearStoredMarkerColor();
