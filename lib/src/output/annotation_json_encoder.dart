import 'dart:convert';
import '../models/annotation.dart';

/// Formats annotations into JSON strings with support for indented or compact representations.
class AnnotationJsonEncoder {
  const AnnotationJsonEncoder();

  static const _indentEncoder = JsonEncoder.withIndent('  ');

  /// Encodes a single [annotation] to a JSON string.
  String encode(Annotation annotation, {bool pretty = true}) {
    final map = annotation.toJson();
    return pretty ? _indentEncoder.convert(map) : jsonEncode(map);
  }

  /// Encodes a collection of [annotations] into a JSON array string.
  String encodeAll(List<Annotation> annotations, {bool pretty = true}) {
    if (annotations.isEmpty) {
      return '[]';
    }
    final list = annotations.map((a) => a.toJson()).toList();
    return pretty ? _indentEncoder.convert(list) : jsonEncode(list);
  }

  /// Encodes an arbitrary map (e.g. from an adapter) into a JSON string.
  String encodeMap(Map<String, dynamic> map, {bool pretty = true}) {
    return pretty ? _indentEncoder.convert(map) : jsonEncode(map);
  }
}
