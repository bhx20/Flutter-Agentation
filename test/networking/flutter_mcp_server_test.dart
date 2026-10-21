import 'dart:convert';
import 'dart:io';

import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/domain/annotation_status.dart';
import 'package:flutter_agentation/src/networking/mcp/flutter_mcp_server.dart';
import 'package:flutter_agentation/src/networking/mcp/mcp_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterMcpServer Embedded MCP Tests', () {
    late AgentationController controller;
    late FlutterMcpServer server;
    const testPort = 4848;

    setUp(() async {
      controller = AgentationController();
      server = controller.mcpServer;
      await server.start(port: testPort);
    });

    tearDown(() async {
      await server.stop();
      controller.dispose();
    });

    test('Embedded server starts on configured port and responds to /status', () async {
      expect(server.isRunning, isTrue);
      expect(server.port, equals(testPort));

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('http://127.0.0.1:$testPort/status'));
      final response = await request.close();
      expect(response.statusCode, equals(HttpStatus.ok));

      final body = await utf8.decoder.bind(response).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      expect(json['server'], equals('flutter-agentation'));
      expect(json['status'], equals('running'));
      expect(json['port'], equals(testPort));
      expect(json['tools'], contains('agentation_get_all_pending'));
      expect(json['tools'], contains('agentation_resolve'));
      expect(json['tools'], contains('agentation_reply'));
      client.close();
    });

    test('Handles MCP JSON-RPC initialize and tools/list', () async {
      final client = HttpClient();

      // 1. initialize
      final initReq = await client.postUrl(Uri.parse('http://127.0.0.1:$testPort/mcp'));
      initReq.headers.contentType = ContentType.json;
      initReq.write(jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {},
      }));
      final initRes = await initReq.close();
      expect(initRes.statusCode, equals(HttpStatus.ok));
      final initBody = jsonDecode(await utf8.decoder.bind(initRes).join()) as Map<String, dynamic>;
      expect(initBody['result']['protocolVersion'], equals(McpProtocol.protocolVersion));
      expect(initBody['result']['serverInfo']['name'], equals('flutter-agentation'));

      // 2. tools/list
      final listReq = await client.postUrl(Uri.parse('http://127.0.0.1:$testPort/mcp'));
      listReq.headers.contentType = ContentType.json;
      listReq.write(jsonEncode({
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/list',
        'params': {},
      }));
      final listRes = await listReq.close();
      final listBody = jsonDecode(await utf8.decoder.bind(listRes).join()) as Map<String, dynamic>;
      final tools = listBody['result']['tools'] as List;
      expect(tools.any((t) => t['name'] == 'agentation_get_all_pending'), isTrue);
      expect(tools.any((t) => t['name'] == 'agentation_resolve'), isTrue);
      expect(tools.any((t) => t['name'] == 'agentation_reply'), isTrue);

      client.close();
    });

    test('tools/call agentation_get_all_pending returns live annotations', () async {
      // Add an annotation via controller
      await controller.createAnnotation(
        comment: 'Fix header padding',
        targetResult: null,
      );

      final client = HttpClient();
      final callReq = await client.postUrl(Uri.parse('http://127.0.0.1:$testPort/mcp'));
      callReq.headers.contentType = ContentType.json;
      callReq.write(jsonEncode({
        'jsonrpc': '2.0',
        'id': 3,
        'method': 'tools/call',
        'params': {
          'name': 'agentation_get_all_pending',
          'arguments': {},
        },
      }));
      final callRes = await callReq.close();
      final callBody = jsonDecode(await utf8.decoder.bind(callRes).join()) as Map<String, dynamic>;
      final textContent = callBody['result']['content'][0]['text'] as String;
      expect(textContent, contains('Fix header padding'));

      client.close();
    });

    test('tools/call agentation_reply posts agent reply into annotation thread', () async {
      final ann = await controller.createAnnotation(
        comment: 'Alignment issue on button',
        targetResult: null,
      );

      final client = HttpClient();
      final replyReq = await client.postUrl(Uri.parse('http://127.0.0.1:$testPort/mcp'));
      replyReq.headers.contentType = ContentType.json;
      replyReq.write(jsonEncode({
        'jsonrpc': '2.0',
        'id': 4,
        'method': 'tools/call',
        'params': {
          'name': 'agentation_reply',
          'arguments': {
            'annotationId': ann.id,
            'message': 'Fixed alignment in button.dart',
          },
        },
      }));
      final replyRes = await replyReq.close();
      final replyBody = jsonDecode(await utf8.decoder.bind(replyRes).join()) as Map<String, dynamic>;
      expect(replyBody['result']['content'][0]['text'], contains('Agent response posted'));

      // Verify thread message in controller
      final updatedAnn = controller.annotations.firstWhere((a) => a.id == ann.id);
      expect(updatedAnn.thread.length, equals(1));
      expect(updatedAnn.thread.first.content, equals('Fixed alignment in button.dart'));
      expect(updatedAnn.thread.first.role, equals('assistant'));

      client.close();
    });

    test('tools/call agentation_resolve marks annotation as resolved', () async {
      final ann = await controller.createAnnotation(
        comment: 'Color is incorrect',
        targetResult: null,
      );

      final client = HttpClient();
      final resolveReq = await client.postUrl(Uri.parse('http://127.0.0.1:$testPort/mcp'));
      resolveReq.headers.contentType = ContentType.json;
      resolveReq.write(jsonEncode({
        'jsonrpc': '2.0',
        'id': 5,
        'method': 'tools/call',
        'params': {
          'name': 'agentation_resolve',
          'arguments': {
            'annotationId': ann.id,
            'summary': 'Updated color token to primaryBlue',
          },
        },
      }));
      final resolveRes = await resolveReq.close();
      final resolveBody = jsonDecode(await utf8.decoder.bind(resolveRes).join()) as Map<String, dynamic>;
      expect(resolveBody['result']['content'][0]['text'], contains('Successfully marked annotation'));

      final updatedAnn = controller.annotations.firstWhere((a) => a.id == ann.id);
      expect(updatedAnn.status, equals(AnnotationStatus.resolved));
      expect(updatedAnn.thread.any((m) => m.content.contains('Resolved: Updated color token')), isTrue);

      client.close();
    });
  });
}
