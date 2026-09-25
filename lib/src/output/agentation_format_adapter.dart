import '../models/annotation.dart';

/// Adapter converting native Flutter [Annotation] objects into the canonical
/// Agentation-compatible schema for AI and web interoperability (Section 28 of flow.md).
class AgentationFormatAdapter {
  const AgentationFormatAdapter();

  /// Canonical static helper to adapt a single [Annotation].
  static Map<String, dynamic> adaptAnnotation(Annotation annotation) =>
      const AgentationFormatAdapter().adapt(annotation);

  /// Converts a single Flutter [Annotation] to an Agentation-compatible map.
  Map<String, dynamic> adapt(Annotation annotation) {
    final path = annotation.metadata['path'] as String? ??
        annotation.metadata['widgetPath'] as String? ??
        annotation.targetWidget.widgetType;

    return {
      'id': annotation.id,
      'type': 'annotation',
      'platform': 'flutter',
      'comment': annotation.comment,
      'timestamp': annotation.timestamp.toIso8601String(),
      'intent': annotation.intent.name,
      'severity': annotation.severity.name,
      'status': annotation.status.name,
      'element': {
        'type': annotation.targetWidget.widgetType,
        'identifier': annotation.targetWidget.id,
        if (annotation.targetWidget.keyString != null)
          'key': annotation.targetWidget.keyString,
        'path': path,
        if (annotation.text != null) 'text': annotation.text,
        if (annotation.route != null) 'route': annotation.route,
      },
      'bounds': {
        'x': annotation.bounds.x,
        'y': annotation.bounds.y,
        'width': annotation.bounds.width,
        'height': annotation.bounds.height,
      },
      if (annotation.selectedText != null)
        'selectedText': annotation.selectedText,
      if (annotation.metadata.isNotEmpty) 'metadata': annotation.metadata,
    };
  }

  /// Converts a list of Flutter [Annotation] objects into a canonical Agentation session payload.
  Map<String, dynamic> adaptAll(
    List<Annotation> annotations, {
    Map<String, dynamic>? sessionMetadata,
  }) {
    final payload = <String, dynamic>{
      'version': '1.0',
      'source': 'flutter_agentation',
      'timestamp': DateTime.now().toIso8601String(),
      'count': annotations.length,
      'annotations': annotations.map(adapt).toList(),
    };
    if (sessionMetadata != null) {
      payload['session'] = sessionMetadata;
    }
    return payload;
  }
}
