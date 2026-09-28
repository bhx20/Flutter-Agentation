import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/agentation_logger.dart';
import '../models/annotation.dart';
import '../output/agentation_format_adapter.dart';

/// Response payload from an HTTP request.
class HttpResponseData {
  const HttpResponseData(this.statusCode, this.body);

  final int statusCode;
  final String body;

  bool get isOk => statusCode >= 200 && statusCode < 300;
}

/// Abstract function signature for dispatching HTTP requests.
typedef HttpTransport = Future<HttpResponseData> Function(
  String method,
  Uri uri, {
  Map<String, String>? headers,
  String? body,
});

/// Default cross-platform [HttpTransport] implementation working on Web, Mobile, and Desktop.
Future<HttpResponseData> defaultHttpTransport(
  String method,
  Uri uri, {
  Map<String, String>? headers,
  String? body,
}) async {
  final client = http.Client();
  try {
    final request = http.Request(method, uri);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      if (!request.headers.containsKey('content-type')) {
        request.headers['content-type'] = 'application/json';
      }
      request.body = body;
    }
    final streamed = await client.send(request);
    final response = await http.Response.fromStream(streamed);
    return HttpResponseData(response.statusCode, response.body);
  } finally {
    client.close();
  }
}

/// Client for communicating with local or remote Agentation Model Context Protocol (MCP) servers.
class AgentSyncClient {
  AgentSyncClient({
    required this.endpoint,
    this.webhookUrl,
    HttpTransport? httpTransport,
  }) : _transport = httpTransport ?? defaultHttpTransport;

  /// The root server endpoint URL (e.g. `http://localhost:4747`).
  final String endpoint;

  /// Optional webhook URL for dispatching asynchronous events.
  final String? webhookUrl;

  final HttpTransport _transport;

  /// Underlying HTTP transport function.
  HttpTransport get transport => _transport;

  String get _normalizedEndpoint =>
      endpoint.endsWith('/') ? endpoint.substring(0, endpoint.length - 1) : endpoint;

  /// Creates a copy of this client with updated endpoint, webhookUrl, or transport.
  AgentSyncClient copyWith({
    String? endpoint,
    String? webhookUrl,
    HttpTransport? httpTransport,
  }) {
    return AgentSyncClient(
      endpoint: endpoint ?? this.endpoint,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      httpTransport: httpTransport ?? _transport,
    );
  }

  /// Pings the MCP server endpoint to verify connectivity.
  Future<bool> ping() async {
    try {
      if (endpoint.isEmpty) return false;
      final uri = Uri.parse('$_normalizedEndpoint/sessions');
      final res = await _transport('GET', uri);
      return res.isOk;
    } catch (_) {
      return false;
    }
  }

  /// Dispatches an event to the configured webhook URL or a specified override.
  Future<bool> sendWebhook({
    required String event,
    required Map<String, dynamic> payload,
    String? overrideUrl,
  }) async {
    final target = overrideUrl ?? webhookUrl;
    if (target == null || target.isEmpty) return false;
    return dispatchWebhook(target, event: event, payload: payload);
  }

  /// Lists all active sessions registered on the server.
  Future<List<Map<String, dynamic>>> listSessions() async {
    try {
      final uri = Uri.parse('$_normalizedEndpoint/sessions');
      final res = await _transport('GET', uri);
      if (res.isOk) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      }
      return const [];
    } catch (e, stack) {
      AgentationLogger.error('Failed to list sessions from $endpoint', e, stack);
      return const [];
    }
  }

  /// Creates a new session on the server for the current app context.
  Future<Map<String, dynamic>> createSession({String? url}) async {
    try {
      final uri = Uri.parse('$_normalizedEndpoint/sessions');
      final payload = jsonEncode({
        'url': ?url,
      });

      final res = await _transport(
        'POST',
        uri,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      if (res.isOk) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return const {};
    } catch (e, stack) {
      AgentationLogger.error('Failed to create session on $endpoint', e, stack);
      return const {};
    }
  }

  /// Fetches an existing session and all associated annotations.
  Future<Map<String, dynamic>> getSession(String sessionId) async {
    try {
      final uri = Uri.parse('$_normalizedEndpoint/sessions/$sessionId');
      final res = await _transport('GET', uri);
      if (res.isOk) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return const {};
    } catch (e, stack) {
      AgentationLogger.error('Failed to get session $sessionId', e, stack);
      return const {};
    }
  }

  /// Pushes a newly created or updated annotation to the active session.
  Future<Map<String, dynamic>> syncAnnotation(
    String sessionId,
    Annotation annotation,
  ) async {
    try {
      final uri = Uri.parse('$_normalizedEndpoint/sessions/$sessionId/annotations');
      final adapterPayload = AgentationFormatAdapter.adaptAnnotation(annotation);
      final payload = jsonEncode(adapterPayload);

      final res = await _transport(
        'POST',
        uri,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      if (res.isOk) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return const {};
    } catch (e, stack) {
      AgentationLogger.error('Failed to sync annotation ${annotation.id}', e, stack);
      return const {};
    }
  }

  /// Partially updates an existing annotation on the server.
  Future<Map<String, dynamic>> updateAnnotation(
    String annotationId,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse('$_normalizedEndpoint/annotations/$annotationId');
      final res = await _transport(
        'PATCH',
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (res.isOk) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return const {};
    } catch (e, stack) {
      AgentationLogger.error('Failed to update annotation $annotationId', e, stack);
      return const {};
    }
  }

  /// Deletes an annotation from the server.
  Future<void> deleteAnnotation(String annotationId) async {
    try {
      final uri = Uri.parse('$_normalizedEndpoint/annotations/$annotationId');
      await _transport('DELETE', uri);
    } catch (e, stack) {
      AgentationLogger.error('Failed to delete annotation $annotationId', e, stack);
    }
  }

  /// Requests the connected AI agent to act upon active annotations.
  Future<Map<String, dynamic>> requestAction(
    String sessionId,
    String output,
  ) async {
    try {
      final uri = Uri.parse('$_normalizedEndpoint/sessions/$sessionId/action');
      final res = await _transport(
        'POST',
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'output': output}),
      );

      if (res.isOk) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return const {};
    } catch (e, stack) {
      AgentationLogger.error('Failed to request agent action for session $sessionId', e, stack);
      return const {};
    }
  }

  /// Dispatches an event payload to a webhook URL.
  Future<bool> dispatchWebhook(
    String targetUrl, {
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final uri = Uri.parse(targetUrl);
      final body = jsonEncode({
        'event': event,
        'timestamp': DateTime.now().toIso8601String(),
        'data': payload,
      });

      final res = await _transport(
        'POST',
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      return res.isOk;
    } catch (e, stack) {
      AgentationLogger.error('Failed to dispatch webhook to $targetUrl', e, stack);
      return false;
    }
  }
}
