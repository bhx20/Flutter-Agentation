import '../../core/agentation_controller.dart';

/// Web stub for the embedded Flutter MCP Server.
class FlutterMcpServer {
  FlutterMcpServer(this.controller);

  final AgentationController controller;

  bool get isRunning => false;
  bool get isSupported => false;
  int get port => 4747;
  String get sseUrl => '';

  Future<bool> start({int port = 4747}) async => false;

  Future<void> stop() async {}

  void broadcastUpdate() {}

  void dispose() {}
}
