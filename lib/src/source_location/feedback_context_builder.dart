import 'feedback_target.dart';

/// Formatter that generates clean, token-efficient, AI-readable UI feedback messages.
///
/// Strictly conforms to Master Prompt Sections 11, 12, and 13:
/// Output contains ONLY:
/// - Header: `[Flutter UI Feedback]`
/// - `Widget: <name>`
/// - `File: <file name>`
/// - `Location: <project-relative file path>`
/// - `Line: <line number>`
/// - `Comment: <user comment>`
class FeedbackContextBuilder {
  const FeedbackContextBuilder();

  /// Formats a single feedback item.
  String build(
    FeedbackTarget target,
    String comment,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('[Flutter UI Feedback]');
    _writeTargetDetails(buffer, target, comment);
    return buffer.toString().trimRight();
  }

  /// Formats multiple feedback items sequentially numbered per Section 12.
  String buildMultiple(
    List<({FeedbackTarget target, String comment})> items,
  ) {
    if (items.isEmpty) return '';
    if (items.length == 1) {
      return build(items.first.target, items.first.comment);
    }

    final buffer = StringBuffer();
    buffer.writeln('[Flutter UI Feedback]');
    buffer.writeln();

    for (int i = 0; i < items.length; i++) {
      buffer.writeln('${i + 1}.');
      _writeTargetDetails(buffer, items[i].target, items[i].comment);
      if (i < items.length - 1) {
        buffer.writeln();
      }
    }

    return buffer.toString().trimRight();
  }

  void _writeTargetDetails(StringBuffer buffer, FeedbackTarget target, String comment) {
    buffer.writeln('Widget: ${target.widgetName}');
    buffer.writeln('File: ${target.source.fileString}');
    buffer.writeln('Location: ${target.source.locationString}');
    buffer.writeln('Line: ${target.source.lineString}');
    buffer.writeln('Comment: $comment');
  }
}
