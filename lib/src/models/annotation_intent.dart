/// Categorizes the primary objective or nature of an annotation.
enum AnnotationIntent {
  /// Request a modification to UI, copy, or behavior.
  change,

  /// Report a defect or unexpected behavior.
  bug,

  /// Provide a design or architectural recommendation.
  suggestion,

  /// Inquire about implementation details or UX rationale.
  question,

  /// General informative observation or context note.
  note;

  /// Serializes the enum to a string.
  String toJson() => name;

  /// Deserializes a string into an [AnnotationIntent].
  static AnnotationIntent fromJson(String value) {
    return AnnotationIntent.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AnnotationIntent.note,
    );
  }
}
