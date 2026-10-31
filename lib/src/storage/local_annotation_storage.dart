import '../domain/annotation.dart';
import 'annotation_storage.dart';
import 'annotations_storage.dart';

/// Production-ready persistent annotation storage.
///
/// Automatically stores annotations on disk (IO desktop/mobile) or
/// `window.localStorage` (Web), ensuring user comments and feedback persist
/// across Flutter hot reloads, hot restarts, and application launches.
class LocalAnnotationStorage implements AnnotationStorage {
  LocalAnnotationStorage() {
    _loadFromPersistence();
  }

  final Map<String, Annotation> _cache = {};

  void _loadFromPersistence() {
    try {
      final jsonList = loadStoredAnnotationsJson();
      if (jsonList != null) {
        for (final item in jsonList) {
          try {
            final ann = Annotation.fromJson(item);
            _cache[ann.id] = ann;
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  void _persist() {
    try {
      final list = _cache.values.map((a) => a.toJson()).toList();
      saveStoredAnnotationsJson(list);
    } catch (_) {}
  }

  @override
  Future<void> save(Annotation annotation) async {
    _cache[annotation.id] = annotation;
    _persist();
  }

  @override
  Future<Annotation?> getById(String id) async {
    return _cache[id];
  }

  @override
  Future<List<Annotation>> getAll() async {
    return getAllSync();
  }

  /// Synchronously returns all stored annotations ordered chronologically.
  List<Annotation> getAllSync() {
    final list = _cache.values.toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  @override
  Future<List<Annotation>> getByRoute(String route) async {
    final list = _cache.values.where((ann) => ann.route == route).toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  @override
  Future<bool> delete(String id) async {
    final removed = _cache.remove(id) != null;
    if (removed) {
      _persist();
    }
    return removed;
  }

  @override
  Future<void> clear() async {
    _cache.clear();
    clearStoredAnnotationsJson();
  }

  /// Reloads annotations from persistent storage into memory cache.
  void reloadSync() {
    _cache.clear();
    _loadFromPersistence();
  }
}

