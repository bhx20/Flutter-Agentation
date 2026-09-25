import 'package:flutter/widgets.dart';

/// Semantic accessibility metadata extracted from a widget or RenderObject.
class SemanticsInfo {
  final String? label;
  final String? hint;
  final String? value;

  const SemanticsInfo({
    this.label,
    this.hint,
    this.value,
  });

  bool get isEmpty =>
      (label == null || label!.isEmpty) &&
      (hint == null || hint!.isEmpty) &&
      (value == null || value!.isEmpty);
}

/// Specialized resolver responsible for extracting accessibility semantics
/// from inspected widgets and RenderObjects.
class SemanticsResolver {
  /// Extracts accessibility labels, hints, and values from [renderObject] and [element].
  SemanticsInfo? extractSemantics(RenderObject? renderObject, Element? element) {
    String? label;
    String? hint;
    String? value;

    // 1. Check if Element or immediate ancestor is a Semantics widget
    if (element != null) {
      if (element.widget is Semantics) {
        final sem = element.widget as Semantics;
        final props = sem.properties;
        label = props.label;
        hint = props.hint;
        value = props.value;
      } else {
        element.visitAncestorElements((ancestor) {
          if (ancestor.widget is Semantics) {
            final sem = ancestor.widget as Semantics;
            final props = sem.properties;
            label ??= props.label;
            hint ??= props.hint;
            value ??= props.value;
            return false;
          }
          return true;
        });
      }
    }

    // 2. Check RenderObject's debugSemantics if still empty
    if ((label?.isEmpty ?? true) && renderObject != null) {
      try {
        final node = renderObject.debugSemantics;
        if (node != null) {
          label ??= node.label.isNotEmpty ? node.label : null;
          hint ??= node.hint.isNotEmpty ? node.hint : null;
          value ??= node.value.isNotEmpty ? node.value : null;
        }
      } catch (_) {
        // Safe fallback if debugSemantics is unavailable
      }
    }

    final info = SemanticsInfo(label: label, hint: hint, value: value);
    return info.isEmpty ? null : info;
  }
}
