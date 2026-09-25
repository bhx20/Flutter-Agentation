import 'package:flutter/widgets.dart';

/// Specialized resolver responsible for extracting primary text content
/// from widgets and their immediate child trees.
class TextResolver {
  /// Extracts the visible text string from [element] or its nearest text-bearing descendants.
  String? extractText(Element element) {
    // 1. Direct widget inspection
    final directText = _extractFromWidget(element.widget);
    if (directText != null && directText.trim().isNotEmpty) {
      return directText.trim();
    }

    // 2. Child traversal for buttons, labels, and compound widgets
    String? foundText;
    void visitor(Element child) {
      if (foundText != null) return;
      final text = _extractFromWidget(child.widget);
      if (text != null && text.trim().isNotEmpty) {
        foundText = text.trim();
        return;
      }
      child.visitChildren(visitor);
    }

    element.visitChildren(visitor);
    return foundText;
  }

  String? _extractFromWidget(Widget widget) {
    if (widget is Text) {
      if (widget.data != null) return widget.data;
      if (widget.textSpan != null) return widget.textSpan!.toPlainText();
    }
    if (widget is RichText) {
      return widget.text.toPlainText();
    }
    if (widget is EditableText) {
      return widget.controller.text;
    }
    return null;
  }
}
