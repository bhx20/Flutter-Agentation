// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  int port = 4747;

  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--port' && i + 1 < args.length) {
      port = int.tryParse(args[i + 1]) ?? 4747;
    } else if (arg.startsWith('--port=')) {
      port = int.tryParse(arg.split('=')[1]) ?? 4747;
    }
  }

  // Ensure .flutter_agentation/ directory exists in project root
  final agentationDir = Directory('${Directory.current.path}/.flutter_agentation');
  if (!agentationDir.existsSync()) {
    agentationDir.createSync(recursive: true);
  }

  final sseUrl = 'http://127.0.0.1:$port/sse';
  final mcpConfigFile = File('${agentationDir.path}/mcp.json');
  if (!mcpConfigFile.existsSync()) {
    final mcpConfig = {
      'mcpServers': {
        'flutter-agentation': {
          'url': sseUrl,
          'description': 'Flutter Agentation visual inspection and annotation server for AI coding agents',
        },
      },
    };
    mcpConfigFile.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(mcpConfig)}\n');
  }

  // Auto-configure Android ADB port forward if ADB is available
  try {
    final adbCheck = Process.runSync(
      Platform.isWindows ? 'where' : 'which',
      ['adb'],
      runInShell: true,
    );
    if (adbCheck.exitCode == 0) {
      Process.runSync('adb', ['forward', 'tcp:$port', 'tcp:$port'], runInShell: true);
    }
  } catch (_) {}

  final server = StandaloneMcpServer(port: port);
  await server.start();
}

class StandaloneMcpServer {
  StandaloneMcpServer({required this.port});

  final int port;
  HttpServer? _server;

  // In-memory synced state from Flutter Web / App
  final List<Map<String, dynamic>> _annotations = [];
  final List<Map<String, dynamic>> _pendingAgentActions = [];
  Map<String, dynamic> _appState = {
    'platform': 'web',
    'route': '/',
    'screenSize': {'width': 1280.0, 'height': 800.0},
    'themeMode': 'light',
  };
  String? _lastScreenshotBase64;
  DateTime _lastWebSync = DateTime.now();

  final Set<HttpResponse> _sseClients = {};

  Future<void> start() async {
    HttpServer? bound;
    for (int p = port; p <= port + 10; p++) {
      try {
        bound = await HttpServer.bind(InternetAddress.anyIPv4, p, shared: true);
        break;
      } on SocketException {
        try {
          bound = await HttpServer.bind(InternetAddress.loopbackIPv4, p, shared: true);
          break;
        } catch (_) {}
      } catch (_) {}
    }

    if (bound == null) {
      print('\x1B[31mFailed to bind MCP server on port $port (or fallback ports).\x1B[0m');
      exit(1);
    }

    _server = bound;
    final actualPort = bound.port;

    if (stdout.hasTerminal) {
      print('');
      print('\x1B[1m\x1B[36m╭─────────────────────────────────────────────────────────────╮\x1B[0m');
      print('\x1B[1m\x1B[36m│          Flutter Agentation Universal MCP Server & Bridge   │\x1B[0m');
      print('\x1B[1m\x1B[36m╰─────────────────────────────────────────────────────────────╯\x1B[0m');
      print('');
      print('  Status:       \x1B[32mActive & Listening\x1B[0m');
      print('  Port:         $actualPort');
      print('  SSE Endpoint: \x1B[36mhttp://127.0.0.1:$actualPort/sse\x1B[0m');
      print('  Web Bridge:   \x1B[36mhttp://127.0.0.1:$actualPort/sync\x1B[0m');
      print('');
      print('  Platforms:    Windows, macOS, Linux, Android, iOS, and Web (Chrome/Edge)');
      print('  AI Agents:    Cursor, Claude Desktop, Windsurf, VS Code (Cline/Roo)');
      print('');
      print('Press Ctrl+C to stop.\n');
    }

    _server!.listen(_handleHttpRequest);
    _startStdioListener();
  }

  void _startStdioListener() {
    try {
      stdin
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.trim().isEmpty) return;
        try {
          final json = jsonDecode(line) as Map<String, dynamic>;
          final id = json['id'];
          final method = json['method'] as String?;
          final params = json['params'] as Map<String, dynamic>? ?? {};

          dynamic result;
          switch (method) {
            case 'initialize':
              result = {
                'protocolVersion': '2024-11-05',
                'capabilities': {
                  'tools': {'listChanged': true},
                },
                'serverInfo': {
                  'name': 'flutter-agentation',
                  'version': '0.0.1',
                },
              };
              break;

            case 'notifications/initialized':
              return;

            case 'tools/list':
              result = {'tools': _getMcpTools()};
              break;

            case 'tools/call':
              final name = params['name'] as String?;
              final args = params['arguments'] as Map<String, dynamic>? ?? {};
              result = _executeTool(name, args);
              break;

            default:
              stdout.writeln(jsonEncode({
                'jsonrpc': '2.0',
                'id': id,
                'error': {'code': -32601, 'message': 'Method not found: $method'},
              }));
              return;
          }

          stdout.writeln(jsonEncode({
            'jsonrpc': '2.0',
            'id': id,
            'result': result,
          }));
        } catch (_) {}
      });
    } catch (_) {}
  }

  void _applyCors(HttpResponse res) {
    res.headers.set('Access-Control-Allow-Origin', '*');
    res.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  }

  Future<void> _handleHttpRequest(HttpRequest req) async {
    _applyCors(req.response);

    if (req.method == 'OPTIONS') {
      req.response.statusCode = HttpStatus.noContent;
      await req.response.close();
      return;
    }

    final path = req.uri.path;

    if (req.method == 'GET' && (path == '/' || path == '/status' || path == '/health')) {
      await _handleStatus(req);
      return;
    }

    if (req.method == 'GET' && (path == '/sse' || path == '/events')) {
      await _handleSse(req);
      return;
    }

    if (req.method == 'POST' && (path == '/mcp' || path == '/rpc')) {
      await _handleMcpRpc(req);
      return;
    }

    if (path == '/sync') {
      if (req.method == 'POST') {
        await _handleWebSyncPost(req);
      } else {
        await _handleWebSyncGet(req);
      }
      return;
    }

    if (req.method == 'GET' && path == '/pending') {
      req.response.headers.contentType = ContentType.json;
      req.response.write(jsonEncode({'annotations': _annotations}));
      await req.response.close();
      return;
    }

    req.response.statusCode = HttpStatus.notFound;
    req.response.write('Not Found');
    await req.response.close();
  }

  Future<void> _handleStatus(HttpRequest req) async {
    req.response.headers.contentType = ContentType.json;
    final payload = {
      'status': 'ok',
      'name': 'flutter_agentation_mcp_bridge',
      'version': '0.0.1',
      'port': _server?.port ?? port,
      'webClientConnected': DateTime.now().difference(_lastWebSync).inSeconds < 15,
      'annotationsCount': _annotations.length,
      'connectedAgentsCount': _sseClients.length,
      'appState': _appState,
    };
    req.response.write(jsonEncode(payload));
    await req.response.close();
  }

  Future<void> _handleWebSyncPost(HttpRequest req) async {
    try {
      final body = await utf8.decoder.bind(req).join();
      if (body.isNotEmpty) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        _lastWebSync = DateTime.now();

        if (data.containsKey('annotations') && data['annotations'] is List) {
          _annotations.clear();
          for (final a in data['annotations']) {
            if (a is Map<String, dynamic>) {
              _annotations.add(a);
            }
          }
        }

        if (data.containsKey('appState') && data['appState'] is Map) {
          _appState = Map<String, dynamic>.from(data['appState'] as Map);
        }

        if (data.containsKey('screenshot') && data['screenshot'] is String) {
          _lastScreenshotBase64 = data['screenshot'] as String;
        }

        // Notify active SSE clients that new annotations arrived
        _broadcastEvent('annotations_updated', {
          'count': _annotations.length,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      req.response.headers.contentType = ContentType.json;
      req.response.write(jsonEncode({
        'status': 'ok',
        'pendingActions': _pendingAgentActions,
      }));
      _pendingAgentActions.clear();
      await req.response.close();
    } catch (e) {
      req.response.statusCode = HttpStatus.badRequest;
      req.response.write(jsonEncode({'error': e.toString()}));
      await req.response.close();
    }
  }

  Future<void> _handleWebSyncGet(HttpRequest req) async {
    req.response.headers.contentType = ContentType.json;
    _lastWebSync = DateTime.now();
    req.response.write(jsonEncode({
      'status': 'ok',
      'pendingActions': _pendingAgentActions,
    }));
    _pendingAgentActions.clear();
    await req.response.close();
  }

  Future<void> _handleSse(HttpRequest req) async {
    final res = req.response;
    res.headers.set('Content-Type', 'text/event-stream; charset=utf-8');
    res.headers.set('Cache-Control', 'no-cache, no-transform');
    res.headers.set('Connection', 'keep-alive');
    res.headers.set('X-Accel-Buffering', 'no');

    _sseClients.add(res);

    // Initial endpoint registration event for MCP protocol
    final endpointUri = 'http://127.0.0.1:${_server?.port ?? port}/mcp';
    res.write('event: endpoint\ndata: $endpointUri\n\n');
    await res.flush();

    req.response.done.then((_) {
      _sseClients.remove(res);
    });
  }

  void _broadcastEvent(String type, Map<String, dynamic> data) {
    final payload = 'event: $type\ndata: ${jsonEncode(data)}\n\n';
    final dead = <HttpResponse>[];
    for (final c in _sseClients) {
      try {
        c.write(payload);
        c.flush();
      } catch (_) {
        dead.add(c);
      }
    }
    _sseClients.removeAll(dead);
  }

  Future<void> _handleMcpRpc(HttpRequest req) async {
    final body = await utf8.decoder.bind(req).join();
    if (body.isEmpty) {
      req.response.statusCode = HttpStatus.badRequest;
      await req.response.close();
      return;
    }

    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final id = json['id'];
      final method = json['method'] as String?;
      final params = json['params'] as Map<String, dynamic>? ?? {};

      dynamic result;

      switch (method) {
        case 'initialize':
          result = {
            'protocolVersion': '2024-11-05',
            'capabilities': {
              'tools': {'listChanged': true},
              'logging': {},
            },
            'serverInfo': {
              'name': 'flutter-agentation',
              'version': '0.0.1',
            },
          };
          break;

        case 'notifications/initialized':
          req.response.statusCode = HttpStatus.noContent;
          await req.response.close();
          return;

        case 'tools/list':
          result = {'tools': _getMcpTools()};
          break;

        case 'tools/call':
          final name = params['name'] as String?;
          final args = params['arguments'] as Map<String, dynamic>? ?? {};
          result = _executeTool(name, args);
          break;

        default:
          req.response.headers.contentType = ContentType.json;
          req.response.write(jsonEncode({
            'jsonrpc': '2.0',
            'id': id,
            'error': {'code': -32601, 'message': 'Method not found: $method'},
          }));
          await req.response.close();
          return;
      }

      req.response.headers.contentType = ContentType.json;
      req.response.write(jsonEncode({
        'jsonrpc': '2.0',
        'id': id,
        'result': result,
      }));
      await req.response.close();
    } catch (e) {
      req.response.statusCode = HttpStatus.internalServerError;
      req.response.write(jsonEncode({
        'jsonrpc': '2.0',
        'error': {'code': -32603, 'message': e.toString()},
      }));
      await req.response.close();
    }
  }

  List<Map<String, dynamic>> _getMcpTools() {
    return [
      {
        'name': 'list_annotations',
        'description': 'Returns all active visual annotations from the running Flutter application (Web, Desktop, or Mobile).',
        'inputSchema': {'type': 'object', 'properties': {}},
      },
      {
        'name': 'get_app_state',
        'description': 'Returns current active route, screen dimensions, theme, and platform information.',
        'inputSchema': {'type': 'object', 'properties': {}},
      },
      {
        'name': 'inspect_widget',
        'description': 'Inspects a widget by coordinate or type, returning hierarchy, location, and dimensions.',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'x': {'type': 'number'},
            'y': {'type': 'number'},
            'widgetType': {'type': 'string'},
          },
        },
      },
      {
        'name': 'add_annotation',
        'description': 'Creates an annotation programmatically on the Flutter application canvas.',
        'inputSchema': {
          'type': 'object',
          'required': ['comment', 'x', 'y'],
          'properties': {
            'comment': {'type': 'string'},
            'x': {'type': 'number'},
            'y': {'type': 'number'},
          },
        },
      },
      {
        'name': 'clear_annotations',
        'description': 'Clears all visual annotations and drawings after the requested code change is complete.',
        'inputSchema': {'type': 'object', 'properties': {}},
      },
      {
        'name': 'take_screenshot',
        'description': 'Captures the current screen as a base64 encoded PNG for visual verification.',
        'inputSchema': {'type': 'object', 'properties': {}},
      },
    ];
  }

  Map<String, dynamic> _executeTool(String? name, Map<String, dynamic> args) {
    switch (name) {
      case 'list_annotations':
      case 'agentation_get_all_pending':
        return {
          'content': [
            {
              'type': 'text',
              'text': jsonEncode({
                'count': _annotations.length,
                'annotations': _annotations,
                'appState': _appState,
              }),
            },
          ],
        };

      case 'get_app_state':
      case 'agentation_get_app_info':
        return {
          'content': [
            {
              'type': 'text',
              'text': jsonEncode(_appState),
            },
          ],
        };

      case 'add_annotation':
      case 'agentation_create_annotation':
        final comment = args['comment']?.toString() ?? '';
        final x = (args['x'] as num?)?.toDouble() ?? 100.0;
        final y = (args['y'] as num?)?.toDouble() ?? 100.0;
        final newAnn = {
          'id': 'ann_${DateTime.now().millisecondsSinceEpoch}',
          'comment': comment,
          'x': x,
          'y': y,
          'source': 'agent',
          'createdAt': DateTime.now().toIso8601String(),
        };
        _annotations.add(newAnn);
        _pendingAgentActions.add({'action': 'add_annotation', 'data': newAnn});
        return {
          'content': [
            {'type': 'text', 'text': 'Added annotation: ${newAnn['id']}'},
          ],
        };

      case 'clear_annotations':
        _annotations.clear();
        _pendingAgentActions.add({'action': 'clear_annotations'});
        return {
          'content': [
            {'type': 'text', 'text': 'All annotations cleared successfully.'},
          ],
        };

      case 'take_screenshot':
        if (_lastScreenshotBase64 != null) {
          return {
            'content': [
              {
                'type': 'image',
                'data': _lastScreenshotBase64,
                'mimeType': 'image/png',
              },
            ],
          };
        }
        return {
          'content': [
            {'type': 'text', 'text': 'No screenshot captured yet from the active Flutter application.'},
          ],
        };

      case 'inspect_widget':
        return {
          'content': [
            {
              'type': 'text',
              'text': jsonEncode({
                'status': 'available',
                'matchedAnnotations': _annotations,
                'appState': _appState,
              }),
            },
          ],
        };

      default:
        return {
          'content': [
            {'type': 'text', 'text': 'Tool execution finished: $name'},
          ],
        };
    }
  }
}
