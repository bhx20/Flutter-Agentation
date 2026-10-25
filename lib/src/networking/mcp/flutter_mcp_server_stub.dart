import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/agentation_controller.dart';

/// Full Web implementation of the Flutter MCP Server using an HTTP Bridge.
///
/// Because web browsers run in a sandbox that cannot bind raw TCP listening ports,
/// this implementation seamlessly syncs live annotations, app state, and screenshots
/// with the local Flutter Agentation MCP Bridge (`http://127.0.0.1:4747/sync`).
class FlutterMcpServer {
  FlutterMcpServer(this.controller) {
    _initWebSync();
  }

  final AgentationController controller;

  /// Callback invoked whenever the server starts, stops, or changes state.
  VoidCallback? onStatusChanged;

  bool _isRunning = false;
  int _port = 4747;
  String? _errorMessage;
  Timer? _syncTimer;
  int _connectedClientsCount = 0;

  bool get isRunning => _isRunning;
  bool get isSupported => true;
  int get port => _port;
  int get connectedClientsCount => _connectedClientsCount;
  String get sseUrl => 'http://127.0.0.1:$_port/sse';
  String get httpUrl => 'http://127.0.0.1:$_port/mcp';
  String? get errorMessage => _errorMessage;

  void _initWebSync() {
    controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (_isRunning) {
      _syncToBridge();
    }
  }

  /// Starts the Web MCP Bridge connection on the specified [port].
  Future<bool> start({int port = 4747}) async {
    _port = port;
    _errorMessage = null;
    onStatusChanged?.call();

    final success = await _pingBridge();

    if (success) {
      _isRunning = true;
      _errorMessage = null;
      _startPolling();
      await _syncToBridge();
    } else {
      _isRunning = false;
      _errorMessage = 'Bridge waiting (run: dart run flutter_agentation:mcp)';
      _startPolling(); // Keep trying in the background
    }

    onStatusChanged?.call();
    return success;
  }

  /// Stops the Web MCP Bridge connection and cancels background timers.
  Future<void> stop() async {
    _isRunning = false;
    _syncTimer?.cancel();
    _syncTimer = null;
    _errorMessage = null;
    onStatusChanged?.call();
  }

  void _startPolling() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _syncToBridge();
    });
  }

  Future<bool> _pingBridge() async {
    try {
      final uri = Uri.parse('http://127.0.0.1:$_port/status');
      final res = await http.get(uri).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _connectedClientsCount = (data['connectedAgentsCount'] as int?) ?? 1;
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> _syncToBridge() async {
    try {
      final uri = Uri.parse('http://127.0.0.1:$_port/sync');
      final payload = {
        'platform': 'web',
        'annotations': controller.annotations.map((a) => a.toJson()).toList(),
        'appState': {
          'platform': 'web',
          'annotationsCount': controller.annotations.length,
          'mode': controller.mode.name,
        },
      };

      final res = await http
          .post(
            uri,
            headers: {'content-type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 2));

      if (res.statusCode == 200) {
        if (!_isRunning) {
          _isRunning = true;
          _errorMessage = null;
          onStatusChanged?.call();
        }

        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final pendingActions = data['pendingActions'] as List? ?? [];
        for (final item in pendingActions) {
          if (item is Map<String, dynamic>) {
            final action = item['action'];
            if (action == 'clear_annotations') {
              controller.clearAnnotations();
            }
          }
        }
      } else {
        if (_isRunning) {
          _isRunning = false;
          _errorMessage = 'Bridge disconnected';
          onStatusChanged?.call();
        }
      }
    } catch (_) {
      if (_isRunning) {
        _isRunning = false;
        _errorMessage = 'Bridge waiting (run: dart run flutter_agentation:mcp)';
        onStatusChanged?.call();
      }
    }
  }

  void broadcastUpdate() {
    if (_isRunning) {
      _syncToBridge();
    }
  }

  void broadcastAfsEvent(String type, Map<String, dynamic> payload, {String? sessionId}) {
    if (_isRunning) {
      _syncToBridge();
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    controller.removeListener(_onControllerChanged);
  }
}
