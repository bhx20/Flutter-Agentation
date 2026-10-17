/// Lifecycle status of an annotation.
enum AnnotationStatus {
  /// Newly filed feedback awaiting triage or review.
  pending,

  /// Actively being investigated or implemented.
  inProgress,

  /// Feedback addressed and validated.
  resolved,

  /// Dismissed or determined not applicable.
  rejected;

  /// Serializes the enum to a string.
  String toJson() => name;

  /// Deserializes a string into an [AnnotationStatus].
  static AnnotationStatus fromJson(String value) {
    return AnnotationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AnnotationStatus.pending,
    );
  }
}
