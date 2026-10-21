import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import '../../core/agentation_controller.dart';
import '../../core/agentation_logger.dart';
import '../../domain/annotation_status.dart';
import '../../output/clipboard_exporter.dart';
import 'mcp_protocol.dart';

/// Embedded Model Context Protocol (MCP) server for Flutter.
///
/// Runs directly within the Flutter host application using `dart:io.HttpServer`.
/// Exposes Server-Sent Events (SSE) and JSON-RPC 2.0 endpoints that AI agents
/// like Antigravity, Claude Desktop, and Cursor can connect to for real-time
/// UI inspection and annotation context.
class FlutterMcpServer {
  FlutterMcpServer(this.controller);

  final AgentationController controller;

  HttpServer? _server;
  int _port = 4747;
  Timer? _heartbeatTimer;

  final Set<HttpResponse> _sseClients = {};
  final Map<String, HttpResponse> _sessionClients = {};

  bool get isRunning => _server != null;
  bool get isSupported => true;
  int get port => _port;
  String get sseUrl => 'http://127.0.0.1:$_port/sse';
  String get httpUrl => 'http://127.0.0.1:$_port/mcp';

  /// Starts the embedded MCP server on the specified [port].
  Future<bool> start({int port = 4747}) async {
    if (_server != null) {
      if (_port == port) return true;
      await stop();
    }

    _port = port;

    try {
      _server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        _port,
        shared: true,
      );
      _server!.idleTimeout = Duration.zero;

      AgentationLogger.debug('Flutter MCP Server running on http://127.0.0.1:$_port');

      _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
        _broadcastHeartbeat();
      });

      _server!.listen(
        _handleRequest,
        onError: (e, stack) {
          AgentationLogger.error('MCP Server error', e, stack);
        },
      );

      return true;
    } catch (e, stack) {
      AgentationLogger.error('Failed to start Flutter MCP Server on port $port', e, stack);
      _server = null;
      return false;
    }
  }

  /// Stops the embedded MCP server and disconnects active SSE clients.
  Future<void> stop() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    for (final client in _sseClients) {
      try {
        client.close();
      } catch (_) {}
    }
    _sseClients.clear();
    _sessionClients.clear();

    if (_server != null) {
      try {
        await _server!.close(force: true);
      } catch (_) {}
      _server = null;
    }
  }

  /// Broadcasts a resource update notification to all connected SSE clients.
  void broadcastUpdate() {
    if (_sseClients.isEmpty) return;

    final notification = jsonEncode({
      'jsonrpc': '2.0',
      'method': 'notifications/resources/updated',
      'params': {
        'uri': 'agentation://annotations',
      },
    });

    _broadcastEvent(event: 'message', data: notification);
  }

  void _broadcastHeartbeat() {
    _broadcastEvent(comment: 'heartbeat');
  }

  void _broadcastEvent({String? event, String? data, String? comment}) {
    final buffer = StringBuffer();
    if (comment != null) {
      buffer.writeln(': $comment');
    }
    if (event != null) {
      buffer.writeln('event: $event');
    }
    if (data != null) {
      buffer.writeln('data: $data');
    }
    buffer.writeln();

    final payload = buffer.toString();
    final deadClients = <HttpResponse>[];

    for (final client in _sseClients) {
      try {
        client.write(payload);
      } catch (_) {
        deadClients.add(client);
      }
    }

    _sseClients.removeAll(deadClients);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    _applyCorsHeaders(request.response);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    final path = request.uri.path;

    if (request.method == 'GET' && (path == '/' || path == '/status')) {
      await _handleStatus(request);
      return;
    }

    if (request.method == 'GET' && path == '/sse') {
      await _handleSse(request);
      return;
    }

    if (request.method == 'POST' && (path == '/messages' || path == '/mcp' || path == '/')) {
      await _handleJsonRpc(request);
      return;
    }

    request.response.statusCode = HttpStatus.notFound;
    request.response.write('Not Found');
    await request.response.close();
  }

  void _applyCorsHeaders(HttpResponse response) {
    response.headers.set('Access-Control-Allow-Origin', '*');
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  }

  Future<void> _handleStatus(HttpRequest request) async {
    final response = request.response;
    response.headers.contentType = ContentType.json;

    final status = {
      'server': McpProtocol.serverName,
      'version': McpProtocol.serverVersion,
      'status': 'running',
      'port': _port,
      'sseUrl': sseUrl,
      'httpUrl': httpUrl,
      'activeAnnotations': controller.annotations.length,
      'connectedClients': _sseClients.length,
      'tools': McpProtocol.tools.map((t) => t['name']).toList(),
    };

    response.write(jsonEncode(status));
    await response.close();
  }

  Future<void> _handleSse(HttpRequest request) async {
    final response = request.response;

    response.headers.set('Content-Type', 'text/event-stream; charset=utf-8');
    response.headers.set('Cache-Control', 'no-cache, no-transform');
    response.headers.set('Connection', 'keep-alive');

    final sessionId = 'sess_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(10000)}';

    _sseClients.add(response);
    _sessionClients[sessionId] = response;

    // Send the MCP endpoint announcement event
    response.writeln('event: endpoint');
    response.writeln('data: /messages?sessionId=$sessionId');
    response.writeln();

    request.response.done.then((_) {
      _sseClients.remove(response);
      _sessionClients.remove(sessionId);
    }).catchError((_) {
      _sseClients.remove(response);
      _sessionClients.remove(sessionId);
    });
  }

  Future<void> _handleJsonRpc(HttpRequest request) async {
    final response = request.response;
    response.headers.contentType = ContentType.json;

    try {
      final body = await utf8.decoder.bind(request).join();
      if (body.isEmpty) {
        response.write(jsonEncode(McpProtocol.error(null, -32700, 'Empty request body')));
        await response.close();
        return;
      }

      final dynamic decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        response.write(jsonEncode(McpProtocol.error(null, -32600, 'Invalid Request')));
        await response.close();
        return;
      }

      final id = decoded['id'];
      final method = decoded['method'] as String?;
      final params = (decoded['params'] as Map<String, dynamic>?) ?? {};

      if (method == null) {
        response.write(jsonEncode(McpProtocol.error(id, -32600, 'Method is required')));
        await response.close();
        return;
      }

      final result = await _executeMethod(method, params);

      final rpcResponse = McpProtocol.success(id, result);
      response.write(jsonEncode(rpcResponse));
      await response.close();
    } catch (e, stack) {
      AgentationLogger.error('MCP JSON-RPC execution error', e, stack);
      response.write(jsonEncode(McpProtocol.error(null, -32603, 'Internal error: $e')));
      await response.close();
    }
  }

  Future<dynamic> _executeMethod(String method, Map<String, dynamic> params) async {
    switch (method) {
      case 'initialize':
        return McpProtocol.initializeResult();

      case 'notifications/initialized':
        return {};

      case 'ping':
        return {};

      case 'tools/list':
        return {'tools': McpProtocol.tools};

      case 'resources/list':
        return {'resources': McpProtocol.resources};

      case 'resources/read':
        return _readResource(params['uri'] as String?);

      case 'tools/call':
        final toolName = params['name'] as String?;
        final arguments = (params['arguments'] as Map<String, dynamic>?) ?? {};
        return _callTool(toolName, arguments);

      default:
        throw Exception('Method not found: $method');
    }
  }

  dynamic _readResource(String? uri) {
    if (uri == 'agentation://annotations') {
      return {
        'contents': [
          {
            'uri': 'agentation://annotations',
            'mimeType': 'application/json',
            'text': jsonEncode(
              controller.annotations.map((a) => a.toJson()).toList(),
            ),
          },
        ],
      };
    }
    throw Exception('Resource not found: $uri');
  }

  Future<Map<String, dynamic>> _callTool(
    String? name,
    Map<String, dynamic> args,
  ) async {
    switch (name) {
      // ── Get pending annotations ──
      case 'agentation_get_all_pending':
      case 'agentation_get_pending':
      case 'get_annotations':
        final format = args['format'] as String? ?? 'json';
        if (format == 'markdown') {
          final md = await controller.exportAnnotations(format: ExportFormat.markdown);
          return {
            'content': [
              {'type': 'text', 'text': md ?? 'No active annotations.'},
            ],
          };
        }
        final list = controller.annotations.map((a) => a.toJson()).toList();
        return {
          'content': [
            {'type': 'text', 'text': jsonEncode(list)},
          ],
        };

      case 'get_latest_annotation':
        if (controller.annotations.isEmpty) {
          return {
            'content': [
              {'type': 'text', 'text': 'No active annotations.'},
            ],
          };
        }
        final latest = controller.annotations.last;
        return {
          'content': [
            {'type': 'text', 'text': jsonEncode(latest.toJson())},
          ],
        };

      // ── Sessions ──
      case 'agentation_list_sessions':
      case 'agentation_get_session':
        final sessionId = controller.settings.sessionId ?? 'default';
        return {
          'content': [
            {
              'type': 'text',
              'text': jsonEncode({
                'sessionId': sessionId,
                'annotations': controller.annotations.map((a) => a.toJson()).toList(),
              }),
            },
          ],
        };

      // ── Acknowledge / Resolve / Dismiss ──
      case 'agentation_acknowledge':
        final annotationId = args['annotationId'] as String?;
        if (annotationId == null) throw Exception('Missing annotationId parameter');
        final updated = await controller.updateAnnotation(
          annotationId,
          status: AnnotationStatus.inProgress,
        );
        return {
          'content': [
            {
              'type': 'text',
              'text': updated != null
                  ? 'Acknowledged annotation $annotationId'
                  : 'Annotation $annotationId not found',
            },
          ],
        };

      case 'agentation_resolve':
      case 'resolve_annotation':
        final annotationId = args['annotationId'] as String?;
        final summary = args['summary'] as String?;
        if (annotationId == null) throw Exception('Missing annotationId parameter');
        if (summary != null && summary.isNotEmpty) {
          await controller.addThreadMessage(
            annotationId,
            'Resolved: $summary',
            role: 'assistant',
          );
        }
        final updated = await controller.updateAnnotation(
          annotationId,
          status: AnnotationStatus.resolved,
        );
        return {
          'content': [
            {
              'type': 'text',
              'text': updated != null
                  ? 'Successfully marked annotation $annotationId as resolved.'
                  : 'Annotation $annotationId not found.',
            },
          ],
        };

      case 'agentation_dismiss':
        final annotationId = args['annotationId'] as String?;
        final reason = args['reason'] as String?;
        if (annotationId == null) throw Exception('Missing annotationId parameter');
        if (reason != null && reason.isNotEmpty) {
          await controller.addThreadMessage(
            annotationId,
            'Dismissed: $reason',
            role: 'assistant',
          );
        }
        final updated = await controller.updateAnnotation(
          annotationId,
          status: AnnotationStatus.rejected,
        );
        return {
          'content': [
            {
              'type': 'text',
              'text': updated != null
                  ? 'Dismissed annotation $annotationId.'
                  : 'Annotation $annotationId not found.',
            },
          ],
        };

      // ── Reply ──
      case 'agentation_reply':
      case 'add_agent_response':
        final annotationId = args['annotationId'] as String?;
        final message = args['message'] as String?;
        if (annotationId == null || message == null) {
          throw Exception('Missing annotationId or message parameter');
        }
        final updated = await controller.addThreadMessage(
          annotationId,
          message,
          role: 'assistant',
        );
        return {
          'content': [
            {
              'type': 'text',
              'text': updated != null
                  ? 'Agent response posted to annotation $annotationId thread.'
                  : 'Annotation $annotationId not found.',
            },
          ],
        };

      case 'clear_annotations':
        await controller.clearAnnotations();
        return {
          'content': [
            {'type': 'text', 'text': 'All annotations cleared from canvas.'},
          ],
        };

      default:
        throw Exception('Unknown tool: $name');
    }
  }

  void dispose() {
    stop();
  }
}
