/// Cross-platform conditional export for [FlutterMcpServer].
///
/// Uses [flutter_mcp_server_io.dart] when `dart:io` is available (Windows, macOS, Linux, Android, iOS),
/// or falls back cleanly to [flutter_mcp_server_stub.dart] on Web environments.
library;

export 'flutter_mcp_server_stub.dart'
    if (dart.library.io) 'flutter_mcp_server_io.dart';

