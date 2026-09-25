import '../models/annotation.dart';

/// Abstract persistence contract for storing and querying annotations.
abstract class AnnotationStorage {
  /// Saves or updates an [annotation].
  Future<void> save(Annotation annotation);

  /// Retrieves an annotation by its unique [id], or null if not found.
  Future<Annotation?> getById(String id);

  /// Retrieves all stored annotations, ordered chronologically.
  Future<List<Annotation>> getAll();

  /// Retrieves annotations filtered by active [route].
  Future<List<Annotation>> getByRoute(String route);

  /// Deletes an annotation by its unique [id].
  Future<bool> delete(String id);

  /// Clears all stored annotations.
  Future<void> clear();
}
