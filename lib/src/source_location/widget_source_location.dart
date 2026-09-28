import 'package:flutter/foundation.dart';

/// Immutable model representing the source code location of a Flutter widget.
@immutable
class WidgetSourceLocation {
  /// Base file name (e.g. 'login_page.dart').
  final String? fileName;

  /// Project-relative file path (e.g. 'lib/features/auth/login_page.dart').
  final String? filePath;

  /// 1-based source code line number where the widget was constructed.
  final int? line;

  /// 1-based source code column number where the widget was constructed.
  final int? column;

  const WidgetSourceLocation({
    this.fileName,
    this.filePath,
    this.line,
    this.column,
  });

  /// Fallback representation when source location cannot be determined.
  const WidgetSourceLocation.unavailable()
      : fileName = null,
        filePath = null,
        line = null,
        column = null;

  /// Whether any valid source file or line metadata was resolved.
  bool get isAvailable => filePath != null || line != null;

  /// Formatted line display (e.g. '87' or 'unavailable').
  String get lineString => line != null ? line.toString() : 'unavailable';

  /// Formatted file name display.
  String get fileString => fileName ?? 'unavailable';

  /// Formatted relative location display.
  String get locationString => filePath ?? 'unavailable';

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'filePath': filePath,
        'line': line,
        'column': column,
      };

  /// Deserializes from a JSON map.
  factory WidgetSourceLocation.fromJson(Map<String, dynamic> json) {
    return WidgetSourceLocation(
      fileName: json['fileName'] as String?,
      filePath: json['filePath'] as String?,
      line: json['line'] as int?,
      column: json['column'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetSourceLocation &&
          runtimeType == other.runtimeType &&
          fileName == other.fileName &&
          filePath == other.filePath &&
          line == other.line &&
          column == other.column;

  @override
  int get hashCode => Object.hash(fileName, filePath, line, column);

  @override
  String toString() =>
      'WidgetSourceLocation($locationString:$lineString:$column)';
}
