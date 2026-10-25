import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import '../../core/agentation_controller.dart';
import '../../core/agentation_logger.dart';
import '../../domain/annotation_severity.dart';
import '../../domain/annotation_status.dart';
import '../../output/clipboard_exporter.dart';
import '../webhook_dispatcher.dart';
import 'mcp_protocol.dart';

/// Embedded Model Context Protocol (MCP) and REST HTTP server for Flutter.
///
/// Runs directly within the Flutter host application using `dart:io.HttpServer`.
/// Exposes Server-Sent Events (SSE), standard REST endpoints matching official
/// Agentation (`agentation-main`), and JSON-RPC 2.0 endpoints for AI agents
/// (Antigravity, Claude Desktop, Cursor) and external toolbars.
class FlutterMcpServer {
  FlutterMcpServer(this.controller);

  final AgentationController controller;

  /// Callback invoked whenever the server starts, stops, or changes state.
  VoidCallback? onStatusChanged;

  HttpServer? _server;
  int _port = 4747;
  Timer? _heartbeatTimer;

  final Set<HttpResponse> _sseClients = {};
  final Map<String, HttpResponse> _sessionClients = {};
  StreamController<Map<String, dynamic>> _eventStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  int _globalSequence = 0;
  WebhookDispatcher _webhookDispatcher = WebhookDispatcher();
  String? _errorMessage;

  bool get isRunning => _server != null;
  bool get isSupported => true;
  int get port => _port;
  int get connectedClientsCount => _sseClients.length;
  String? get errorMessage => _errorMessage;
  String get sseUrl => 'http://127.0.0.1:$_port/sse';
  String get httpUrl => 'http://127.0.0.1:$_port/mcp';

  /// Starts the embedded MCP server on the specified [port].
  ///
  /// Automatically tries fallback ports if [port] is already occupied,
  /// ensuring smooth startup across Windows, macOS, Linux, Android, and iOS.
  Future<bool> start({int port = 4747}) async {
    if (_server != null) {
      if (_port == port) return true;
      await stop();
    }

    _errorMessage = null;
    int targetPort = port;
    HttpServer? boundServer;
    String? lastError;

    // Try target port first, then up to 10 fallback ports.
    // Binds to anyIPv4 (0.0.0.0) first to accept connections across Windows, Linux, macOS,
    // as well as Android (via adb forward) and iOS (Simulator / local Wi-Fi).
    for (int p = targetPort; p <= targetPort + 10; p++) {
      try {
        boundServer = await HttpServer.bind(
          InternetAddress.anyIPv4,
          p,
          shared: true,
        );
        _port = p;
        break;
      } on SocketException {
        try {
          boundServer = await HttpServer.bind(
            InternetAddress.loopbackIPv4,
            p,
            shared: true,
          );
          _port = p;
          break;
        } on SocketException catch (e2) {
          lastError = e2.message;
          AgentationLogger.debug('Port $p busy, trying next port...');
        }
      } catch (e) {
        lastError = e.toString();
        break;
      }
    }

    if (boundServer == null) {
      _errorMessage = lastError ?? 'Failed to bind port $port';
      AgentationLogger.error('Failed to start Flutter MCP Server: $_errorMessage');
      _server = null;
      onStatusChanged?.call();
      return false;
    }

    _server = boundServer;
    if (_eventStreamController.isClosed) {
      _eventStreamController = StreamController<Map<String, dynamic>>.broadcast();
    }
    if (_webhookDispatcher.isClosed) {
      _webhookDispatcher = WebhookDispatcher();
    }

    AgentationLogger.debug('Flutter MCP Server running on port $_port');

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _broadcastHeartbeat();
    });

    _server!.listen(
      _handleRequest,
      onError: (e, stack) {
        AgentationLogger.error('MCP Server error', e, stack);
      },
      cancelOnError: false,
    );

    onStatusChanged?.call();
    return true;
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

    final serverToClose = _server;
    _server = null;
    if (serverToClose != null) {
      try {
        await serverToClose.close(force: true);
      } catch (_) {}
    }

    onStatusChanged?.call();
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

  /// Broadcasts a structured AFS event to all SSE streams matching official Agentation EventBus.
  void broadcastAfsEvent(String type, Map<String, dynamic> payload, {String? sessionId}) {
    final event = <String, dynamic>{
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'sessionId': sessionId ?? controller.settings.sessionId ?? 'default',
      'sequence': ++_globalSequence,
      'payload': payload,
    };

    if (!_eventStreamController.isClosed) {
      _eventStreamController.add(event);
    }

    _broadcastEvent(event: type, data: jsonEncode(event));
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
        client.flush().catchError((_) {});
      } catch (_) {
        deadClients.add(client);
      }
    }

    _sseClients.removeAll(deadClients);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      _applyCorsHeaders(request.response);

      if (request.method == 'OPTIONS') {
        request.response.statusCode = HttpStatus.noContent;
        await request.response.close();
        return;
      }

      final path = request.uri.path;
      final method = request.method;

      // ── Health & Status ──
      if (method == 'GET' && (path == '/' || path == '/status' || path == '/health')) {
        await _handleStatus(request);
        return;
      }

      // ── SSE Streams ──
      if (method == 'GET' &&
          (path == '/sse' || path == '/events' || (path.startsWith('/sessions/') && path.endsWith('/events')))) {
        await _handleSse(request);
        return;
      }

      // ── MCP JSON-RPC endpoints ──
      if (method == 'POST' && (path == '/messages' || path == '/mcp' || path == '/')) {
        await _handleJsonRpc(request);
        return;
      }

      // ── REST API (Sessions) ──
      if (path == '/sessions') {
        if (method == 'GET') {
          await _handleListSessions(request);
          return;
        } else if (method == 'POST') {
          await _handleCreateSession(request);
          return;
        }
      }

      // ── REST API (Pending) ──
      if (path == '/pending' && method == 'GET') {
        await _handleGetAllPending(request);
        return;
      }

      // ── Parameterized routes ──
      final sessionAnnotationsMatch = RegExp(r'^/sessions/([^/]+)/annotations$').firstMatch(path);
      if (sessionAnnotationsMatch != null && method == 'POST') {
        final sessionId = sessionAnnotationsMatch.group(1)!;
        await _handleAddAnnotation(request, sessionId);
        return;
      }

      final sessionPendingMatch = RegExp(r'^/sessions/([^/]+)/pending$').firstMatch(path);
      if (sessionPendingMatch != null && method == 'GET') {
        final sessionId = sessionPendingMatch.group(1)!;
        await _handleGetPending(request, sessionId);
        return;
      }

      final sessionActionMatch = RegExp(r'^/sessions/([^/]+)/action$').firstMatch(path);
      if (sessionActionMatch != null && method == 'POST') {
        final sessionId = sessionActionMatch.group(1)!;
        await _handleRequestAction(request, sessionId);
        return;
      }

      final sessionDetailMatch = RegExp(r'^/sessions/([^/]+)$').firstMatch(path);
      if (sessionDetailMatch != null && method == 'GET') {
        final sessionId = sessionDetailMatch.group(1)!;
        await _handleGetSession(request, sessionId);
        return;
      }

      final annotationThreadMatch = RegExp(r'^/annotations/([^/]+)/thread$').firstMatch(path);
      if (annotationThreadMatch != null && method == 'POST') {
        final annotationId = annotationThreadMatch.group(1)!;
        await _handleAddThread(request, annotationId);
        return;
      }

      final annotationDetailMatch = RegExp(r'^/annotations/([^/]+)$').firstMatch(path);
      if (annotationDetailMatch != null) {
        final annotationId = annotationDetailMatch.group(1)!;
        if (method == 'GET') {
          await _handleGetAnnotation(request, annotationId);
          return;
        } else if (method == 'PATCH') {
          await _handleUpdateAnnotation(request, annotationId);
          return;
        } else if (method == 'DELETE') {
          await _handleDeleteAnnotation(request, annotationId);
          return;
        }
      }

      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Not Found');
      await request.response.close();
    } catch (e, stack) {
      AgentationLogger.error('MCP request error', e, stack);
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.write('Internal Server Error: $e');
        await request.response.close();
      } catch (_) {}
    }
  }

  void _applyCorsHeaders(HttpResponse response) {
    response.headers.set('Access-Control-Allow-Origin', '*');
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS');
    response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, X-Api-Key');
    response.headers.set('Access-Control-Max-Age', '86400');
  }

  void _sendJson(HttpResponse res, int statusCode, dynamic data) {
    res.statusCode = statusCode;
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(data));
    res.close().catchError((_) {});
  }

  void _sendError(HttpResponse res, int statusCode, String message) {
    _sendJson(res, statusCode, {'error': message});
  }

  Future<dynamic> _parseBody(HttpRequest req) async {
    final raw = await utf8.decoder.bind(req).join();
    if (raw.trim().isEmpty) return <String, dynamic>{};
    return jsonDecode(raw);
  }

  // ── REST Route Handlers ──

  Future<void> _handleStatus(HttpRequest request) async {
    final webhookUrl = controller.settings.webhookUrl;
    final status = {
      'server': McpProtocol.serverName,
      'version': McpProtocol.serverVersion,
      'status': 'running',
      'port': _port,
      'sseUrl': sseUrl,
      'httpUrl': httpUrl,
      'activeAnnotations': controller.annotations.length,
      'connectedClients': _sseClients.length,
      'webhooksConfigured': webhookUrl != null && webhookUrl.isNotEmpty,
      'autoSendWebhook': controller.settings.autoSendWebhook,
      'tools': McpProtocol.tools.map((t) => t['name']).toList(),
    };

    _sendJson(request.response, HttpStatus.ok, status);
  }

  Future<void> _handleListSessions(HttpRequest request) async {
    final sessionId = controller.settings.sessionId ?? 'default';
    _sendJson(request.response, HttpStatus.ok, [
      {
        'id': sessionId,
        'url': '/',
        'status': 'active',
        'createdAt': DateTime.now().toIso8601String(),
      }
    ]);
  }

  Future<void> _handleCreateSession(HttpRequest request) async {
    try {
      final body = await _parseBody(request);
      final sessionId = 'sess_${DateTime.now().millisecondsSinceEpoch}';
      final url = (body is Map ? body['url'] as String? : null) ?? '/';

      controller.updateSettings(
        controller.settings.copyWith(sessionId: sessionId),
      );

      _sendJson(request.response, HttpStatus.created, {
        'id': sessionId,
        'url': url,
        'status': 'active',
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _sendError(request.response, HttpStatus.badRequest, e.toString());
    }
  }

  Future<void> _handleGetSession(HttpRequest request, String sessionId) async {
    final annotations = controller.annotations.map((a) => a.toJson()).toList();
    _sendJson(request.response, HttpStatus.ok, {
      'id': sessionId,
      'url': '/',
      'status': 'active',
      'createdAt': DateTime.now().toIso8601String(),
      'annotations': annotations,
    });
  }

  Future<void> _handleAddAnnotation(HttpRequest request, String sessionId) async {
    try {
      final body = await _parseBody(request);
      if (body is! Map<String, dynamic>) {
        _sendError(request.response, HttpStatus.badRequest, 'Invalid annotation payload');
        return;
      }

      final comment = body['comment'] as String? ?? 'Annotation';
      final x = (body['x'] as num?)?.toDouble() ?? 100.0;
      final y = (body['y'] as num?)?.toDouble() ?? 100.0;

      final annotation = await controller.createAnnotation(
        comment: comment,
        tapPosition: Offset(x, y),
      );

      _sendJson(request.response, HttpStatus.created, annotation.toJson());
    } catch (e) {
      _sendError(request.response, HttpStatus.badRequest, e.toString());
    }
  }

  Future<void> _handleGetAnnotation(HttpRequest request, String annotationId) async {
    final annotation = controller.annotations.where((a) => a.id == annotationId).firstOrNull;
    if (annotation == null) {
      _sendError(request.response, HttpStatus.notFound, 'Annotation not found');
      return;
    }
    _sendJson(request.response, HttpStatus.ok, annotation.toJson());
  }

  Future<void> _handleUpdateAnnotation(HttpRequest request, String annotationId) async {
    try {
      final body = await _parseBody(request);
      if (body is! Map<String, dynamic>) {
        _sendError(request.response, HttpStatus.badRequest, 'Invalid payload');
        return;
      }

      AnnotationStatus? status;
      if (body.containsKey('status')) {
        final statusStr = body['status'] as String?;
        if (statusStr == 'acknowledged' || statusStr == 'inProgress') {
          status = AnnotationStatus.inProgress;
        } else if (statusStr == 'resolved') {
          status = AnnotationStatus.resolved;
        } else if (statusStr == 'dismissed' || statusStr == 'rejected') {
          status = AnnotationStatus.rejected;
        }
      }

      final comment = body['comment'] as String?;
      final updated = await controller.updateAnnotation(
        annotationId,
        comment: comment,
        status: status,
      );

      if (updated == null) {
        _sendError(request.response, HttpStatus.notFound, 'Annotation not found');
        return;
      }

      _sendJson(request.response, HttpStatus.ok, updated.toJson());
    } catch (e) {
      _sendError(request.response, HttpStatus.badRequest, e.toString());
    }
  }

  Future<void> _handleDeleteAnnotation(HttpRequest request, String annotationId) async {
    final success = await controller.deleteAnnotation(annotationId);
    if (!success) {
      _sendError(request.response, HttpStatus.notFound, 'Annotation not found');
      return;
    }
    _sendJson(request.response, HttpStatus.ok, {'deleted': true, 'annotationId': annotationId});
  }

  Future<void> _handleAddThread(HttpRequest request, String annotationId) async {
    try {
      final body = await _parseBody(request);
      if (body is! Map<String, dynamic>) {
        _sendError(request.response, HttpStatus.badRequest, 'Invalid payload');
        return;
      }

      final role = (body['role'] as String?) ?? 'agent';
      final content = (body['content'] as String?) ?? '';
      if (content.isEmpty) {
        _sendError(request.response, HttpStatus.badRequest, 'content is required');
        return;
      }

      final updated = await controller.addThreadMessage(
        annotationId,
        content,
        role: role,
      );

      if (updated == null) {
        _sendError(request.response, HttpStatus.notFound, 'Annotation not found');
        return;
      }

      _sendJson(request.response, HttpStatus.ok, updated.toJson());
    } catch (e) {
      _sendError(request.response, HttpStatus.badRequest, e.toString());
    }
  }

  Future<void> _handleGetPending(HttpRequest request, String sessionId) async {
    final pending = controller.annotations
        .where((a) => a.status != AnnotationStatus.resolved && a.status != AnnotationStatus.rejected)
        .where((a) => a.sessionId == null || a.sessionId == sessionId)
        .map((a) => a.toJson())
        .toList();

    _sendJson(request.response, HttpStatus.ok, {
      'count': pending.length,
      'annotations': pending,
    });
  }

  Future<void> _handleGetAllPending(HttpRequest request) async {
    final pending = controller.annotations
        .where((a) => a.status != AnnotationStatus.resolved && a.status != AnnotationStatus.rejected)
        .map((a) => a.toJson())
        .toList();

    _sendJson(request.response, HttpStatus.ok, {
      'count': pending.length,
      'annotations': pending,
    });
  }

  Future<void> _handleRequestAction(HttpRequest request, String sessionId) async {
    try {
      final body = await _parseBody(request);
      final output = (body is Map ? body['output'] as String? : null) ?? '';

      final annotationsList = controller.annotations.map((a) => a.toJson()).toList();
      final actionPayload = <String, dynamic>{
        'sessionId': sessionId,
        'annotations': annotationsList,
        'output': output,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // 1. Emit action.requested event via SSE
      broadcastAfsEvent('action.requested', actionPayload, sessionId: sessionId);

      // 2. Dispatch server-side webhooks if configured
      int webhooksDelivered = 0;
      final webhookUrl = controller.settings.webhookUrl;
      if (webhookUrl != null && webhookUrl.isNotEmpty) {
        final res = await _webhookDispatcher.send(
          webhookUrl,
          jsonEncode({
            'event': 'action.requested',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'url': '/',
            ...actionPayload,
          }),
          eventType: 'action.requested',
        );
        if (res.ok) webhooksDelivered = 1;
      }

      final sseListeners = _sseClients.length;
      _sendJson(request.response, HttpStatus.ok, {
        'success': true,
        'annotationCount': controller.annotations.length,
        'delivered': {
          'sseListeners': sseListeners,
          'webhooks': webhooksDelivered,
          'total': sseListeners + webhooksDelivered,
        },
      });
    } catch (e) {
      _sendError(request.response, HttpStatus.badRequest, e.toString());
    }
  }

  // ── SSE Handler ──

  Future<void> _handleSse(HttpRequest request) async {
    final response = request.response;

    response.headers.set('Content-Type', 'text/event-stream; charset=utf-8');
    response.headers.set('Cache-Control', 'no-cache, no-transform');
    response.headers.set('Connection', 'keep-alive');

    final sessionId = 'sess_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(10000)}';

    _sseClients.add(response);
    _sessionClients[sessionId] = response;
    onStatusChanged?.call();

    // Send the MCP endpoint announcement event
    response.writeln('event: endpoint');
    response.writeln('data: /messages?sessionId=$sessionId');
    response.writeln();
    await response.flush();

    request.response.done.then((_) {
      _sseClients.remove(response);
      _sessionClients.remove(sessionId);
      onStatusChanged?.call();
    }).catchError((_) {
      _sseClients.remove(response);
      _sessionClients.remove(sessionId);
      onStatusChanged?.call();
    });
  }

  // ── JSON-RPC Handler ──

  Future<void> _handleJsonRpc(HttpRequest request) async {
    final response = request.response;
    response.headers.contentType = ContentType.json;

    dynamic id;
    final sessionId = request.uri.queryParameters['sessionId'];

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

      id = decoded['id'];
      final method = decoded['method'] as String?;
      final params = (decoded['params'] as Map<String, dynamic>?) ?? {};

      if (method == null) {
        response.write(jsonEncode(McpProtocol.error(id, -32600, 'Method is required')));
        await response.close();
        return;
      }

      final result = await _executeMethod(method, params);

      // JSON-RPC Notification: no 'id' provided.
      if (id == null) {
        response.statusCode = HttpStatus.accepted;
        await response.close();
        return;
      }

      final rpcResponse = McpProtocol.success(id, result);
      final encodedResponse = jsonEncode(rpcResponse);

      // 1. Deliver over active SSE stream if connected
      _dispatchSseResponse(sessionId, encodedResponse);

      // 2. Deliver in HTTP POST response body
      response.statusCode = HttpStatus.ok;
      response.write(encodedResponse);
      await response.close();
    } catch (e, stack) {
      AgentationLogger.error('MCP JSON-RPC execution error', e, stack);
      if (id != null) {
        final errResponse = McpProtocol.error(id, -32603, 'Internal error: $e');
        final encodedErr = jsonEncode(errResponse);
        _dispatchSseResponse(sessionId, encodedErr);
        response.statusCode = HttpStatus.ok;
        response.write(encodedErr);
      } else {
        response.statusCode = HttpStatus.internalServerError;
        response.write(jsonEncode(McpProtocol.error(null, -32603, 'Internal error: $e')));
      }
      await response.close();
    }
  }

  void _dispatchSseResponse(String? sessionId, String encodedPayload) {
    HttpResponse? targetClient;
    if (sessionId != null && _sessionClients.containsKey(sessionId)) {
      targetClient = _sessionClients[sessionId];
    } else if (_sseClients.length == 1) {
      targetClient = _sseClients.first;
    }

    if (targetClient != null) {
      try {
        targetClient.writeln('event: message');
        for (final line in encodedPayload.split('\n')) {
          targetClient.writeln('data: $line');
        }
        targetClient.writeln();
        targetClient.flush().catchError((_) {});
      } catch (_) {}
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

  Future<dynamic> _readResource(String? uri) async {
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
    if (uri == 'agentation://annotations/markdown' || uri == 'agentation://annotations.md') {
      final md = await controller.exportAnnotations(format: ExportFormat.markdown);
      return {
        'contents': [
          {
            'uri': 'agentation://annotations/markdown',
            'mimeType': 'text/markdown',
            'text': md ?? 'No active annotations.',
          },
        ],
      };
    }
    if (uri == 'agentation://app-info') {
      return {
        'contents': [
          {
            'uri': 'agentation://app-info',
            'mimeType': 'application/json',
            'text': jsonEncode({
              'appName': controller.appName ?? 'Flutter App',
              'platform': controller.currentPlatformName,
              'screenSize': controller.screenSize != null
                  ? {
                      'width': controller.screenSize!.width,
                      'height': controller.screenSize!.height,
                    }
                  : null,
              'isDarkMode': controller.settings.isDarkMode,
              'totalAnnotations': controller.annotations.length,
            }),
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
        final list = controller.annotations
            .where((a) => a.status != AnnotationStatus.resolved && a.status != AnnotationStatus.rejected)
            .map((a) => a.toJson())
            .toList();
        return {
          'content': [
            {
              'type': 'text',
              'text': jsonEncode({
                'count': list.length,
                'annotations': list,
              }),
            },
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
        final sessionId = controller.settings.sessionId ?? 'default';
        return {
          'content': [
            {
              'type': 'text',
              'text': jsonEncode({
                'sessions': [
                  {
                    'id': sessionId,
                    'url': '/',
                    'status': 'active',
                    'createdAt': DateTime.now().toIso8601String(),
                  }
                ],
              }),
            },
          ],
        };

      case 'agentation_get_session':
        final sessionId = (args['sessionId'] as String?) ?? controller.settings.sessionId ?? 'default';
        return {
          'content': [
            {
              'type': 'text',
              'text': jsonEncode({
                'id': sessionId,
                'url': '/',
                'status': 'active',
                'createdAt': DateTime.now().toIso8601String(),
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
              'text': jsonEncode({
                'acknowledged': updated != null,
                'annotationId': annotationId,
              }),
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

      // ── Watch Annotations (Hands-Free Loop) ──
      case 'agentation_watch_annotations':
        final sessionId = args['sessionId'] as String?;
        final batchWindowSec = math.min(60, math.max(1, (args['batchWindowSeconds'] as num?)?.toInt() ?? 10));
        final timeoutSec = math.min(300, math.max(1, (args['timeoutSeconds'] as num?)?.toInt() ?? 120));

        // 1. Drain: return any currently pending annotations immediately before blocking
        final pending = controller.annotations
            .where((a) => a.status != AnnotationStatus.resolved && a.status != AnnotationStatus.rejected)
            .where((a) => sessionId == null || a.sessionId == sessionId)
            .toList();

        if (pending.isNotEmpty) {
          final sessions = pending.map((a) => a.sessionId ?? controller.settings.sessionId ?? 'default').toSet().toList();
          return {
            'content': [
              {
                'type': 'text',
                'text': jsonEncode({
                  'timeout': false,
                  'count': pending.length,
                  'sessions': sessions,
                  'annotations': pending.map((a) => a.toJson()).toList(),
                }),
              },
            ],
          };
        }

        // 2. Watch for new arrivals
        final completer = Completer<Map<String, dynamic>>();
        final collected = <Map<String, dynamic>>[];
        final detectedSessions = <String>{};
        Timer? batchTimer;
        Timer? timeoutTimer;
        StreamSubscription? sub;

        void finish(Map<String, dynamic> result) {
          batchTimer?.cancel();
          timeoutTimer?.cancel();
          sub?.cancel();
          if (!completer.isCompleted) {
            completer.complete(result);
          }
        }

        timeoutTimer = Timer(Duration(seconds: timeoutSec), () {
          finish({
            'timeout': true,
            'message': 'No new annotations within $timeoutSec seconds',
          });
        });

        sub = _eventStreamController.stream.listen((event) {
          if (event['type'] == 'annotation.created') {
            final evSessionId = event['sessionId'] as String?;
            if (sessionId != null && evSessionId != sessionId) return;

            final payload = event['payload'];
            if (payload is Map<String, dynamic>) {
              collected.add(payload);
              if (evSessionId != null) detectedSessions.add(evSessionId);
            }

            batchTimer ??= Timer(Duration(seconds: batchWindowSec), () {
              finish({
                'timeout': false,
                'count': collected.length,
                'sessions': detectedSessions.toList(),
                'annotations': collected,
              });
            });
          }
        });

        final result = await completer.future;
        return {
          'content': [
            {
              'type': 'text',
              'text': jsonEncode(result),
            },
          ],
        };

      // ── Create Annotation from AI agent ──
      case 'agentation_create_annotation':
      case 'create_annotation':
        final comment = args['comment'] as String?;
        if (comment == null || comment.isEmpty) {
          throw Exception('Missing required parameter: comment');
        }
        final x = (args['x'] as num?)?.toDouble() ?? 100.0;
        final y = (args['y'] as num?)?.toDouble() ?? 100.0;
        final severityStr = args['severity'] as String?;
        final severity = severityStr != null
            ? AnnotationSeverity.fromJson(severityStr)
            : AnnotationSeverity.suggestion;

        final annotation = await controller.createAnnotation(
          comment: comment,
          tapPosition: Offset(x, y),
          severity: severity,
        );
        return {
          'content': [
            {
              'type': 'text',
              'text': jsonEncode({
                'message': 'Annotation created successfully',
                'annotation': annotation.toJson(),
              }),
            },
          ],
        };

      // ── App runtime info ──
      case 'agentation_get_app_info':
      case 'get_app_info':
        return {
          'content': [
            {
              'type': 'text',
              'text': jsonEncode({
                'appName': controller.appName ?? 'Flutter App',
                'platform': controller.currentPlatformName,
                'screenSize': controller.screenSize != null
                    ? {
                        'width': controller.screenSize!.width,
                        'height': controller.screenSize!.height,
                      }
                    : null,
                'isDarkMode': controller.settings.isDarkMode,
                'isInspecting': controller.isInspecting,
                'activeMode': controller.mode.name,
                'totalAnnotations': controller.annotations.length,
                'pendingAnnotations': controller.annotations
                    .where((a) => a.status != AnnotationStatus.resolved && a.status != AnnotationStatus.rejected)
                    .length,
                'resolvedAnnotations': controller.annotations
                    .where((a) => a.status == AnnotationStatus.resolved)
                    .length,
                'mcpPort': _port,
              }),
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
    _eventStreamController.close();
    _webhookDispatcher.close();
  }
}
