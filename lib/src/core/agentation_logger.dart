import 'package:flutter/foundation.dart';

/// Available log levels for Agentation diagnostic logging.
enum AgentationLogLevel {
  disabled,
  error,
  warning,
  debug,
  verbose,
}

/// Internal diagnostic logger for FlutterAgentation.
///
/// Ensures all logging is safe, defensive, and configurable without
/// crashing the host application or leaking sensitive data.
class AgentationLogger {
  static AgentationLogLevel level = kDebugMode
      ? AgentationLogLevel.warning
      : AgentationLogLevel.disabled;

  /// Logs an error message with optional exception and stack trace.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (level == AgentationLogLevel.disabled) return;
    debugPrint('[FlutterAgentation ERROR] $message');
    if (error != null) {
      debugPrint('  Details: $error');
    }
    if (stackTrace != null && level == AgentationLogLevel.verbose) {
      debugPrint('  Stack: $stackTrace');
    }
  }

  /// Logs a warning message.
  static void warning(String message) {
    if (level == AgentationLogLevel.disabled ||
        level == AgentationLogLevel.error) {
      return;
    }
    debugPrint('[FlutterAgentation WARN] $message');
  }

  /// Logs a debug message.
  static void debug(String message) {
    if (level == AgentationLogLevel.debug ||
        level == AgentationLogLevel.verbose) {
      debugPrint('[FlutterAgentation DEBUG] $message');
    }
  }

  /// Logs a verbose diagnostic trace.
  static void verbose(String message) {
    if (level == AgentationLogLevel.verbose) {
      debugPrint('[FlutterAgentation VERBOSE] $message');
    }
  }
}
