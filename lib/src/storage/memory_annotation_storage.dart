import '../models/annotation.dart';
import 'annotation_storage.dart';

/// In-memory implementation of [AnnotationStorage].
///
/// Holds annotations in memory during the active session with zero disk or database dependencies.
class MemoryAnnotationStorage implements AnnotationStorage {
  final Map<String, Annotation> _storage = {};

  @override
  Future<void> save(Annotation annotation) async {
    _storage[annotation.id] = annotation;
  }

  @override
  Future<Annotation?> getById(String id) async {
    return _storage[id];
  }

  @override
  Future<List<Annotation>> getAll() async {
    final list = _storage.values.toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return List.unmodifiable(list);
  }

  @override
  Future<List<Annotation>> getByRoute(String route) async {
    final list = _storage.values.where((ann) => ann.route == route).toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return List.unmodifiable(list);
  }

  @override
  Future<bool> delete(String id) async {
    return _storage.remove(id) != null;
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}
