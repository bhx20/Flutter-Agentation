import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/core/agentation_controller.dart';
import 'package:flutter_agentation/src/networking/mcp/flutter_mcp_server.dart';
import 'package:flutter_agentation/src/networking/webhook_dispatcher.dart';
import 'package:flutter_agentation/src/storage/memory_annotation_storage.dart';

void main() {
  HttpOverrides.global = null;

  group('MCP & Webhook Full Flow Parity Tests (Matching agentation-main)', () {
    late AgentationController controller;
    late FlutterMcpServer server;
    const testPort = 4858;

    setUp(() async {
      controller = AgentationController(
        storage: MemoryAnnotationStorage(),
      );
      server = FlutterMcpServer(controller);
      await server.start(port: testPort);
    });

    tearDown(() async {
      await server.stop();
      controller.dispose();
    });

    test('REST /sessions, /pending, and /health match agentation-main HTTP endpoints', () async {
      final client = HttpClient();

      // 1. GET /health
      final healthReq = await client.getUrl(Uri.parse('http://127.0.0.1:$testPort/health'));
      final healthRes = await healthReq.close();
      expect(healthRes.statusCode, equals(HttpStatus.ok));
      final healthBody = jsonDecode(await utf8.decoder.bind(healthRes).join()) as Map<String, dynamic>;
      expect(healthBody['status'], equals('running'));
      expect(healthBody['tools'], contains('agentation_watch_annotations'));

      // 2. GET /sessions
      final sessionsReq = await client.getUrl(Uri.parse('http://127.0.0.1:$testPort/sessions'));
      final sessionsRes = await sessionsReq.close();
      expect(sessionsRes.statusCode, equals(HttpStatus.ok));
      final sessionsList = jsonDecode(await utf8.decoder.bind(sessionsRes).join()) as List;
      expect(sessionsList, isNotEmpty);
      expect(sessionsList[0]['status'], equals('active'));

      // 3. GET /pending when empty
      final pendingReq = await client.getUrl(Uri.parse('http://127.0.0.1:$testPort/pending'));
      final pendingRes = await pendingReq.close();
      expect(pendingRes.statusCode, equals(HttpStatus.ok));
      final pendingBody = jsonDecode(await utf8.decoder.bind(pendingRes).join()) as Map<String, dynamic>;
      expect(pendingBody['count'], equals(0));
      expect(pendingBody['annotations'], isEmpty);

      client.close();
    });

    test('REST /sessions/:id/action emits action.requested event and delivers response', () async {
      final client = HttpClient();
      await controller.createAnnotation(comment: 'Need fix here');

      final actionReq = await client.postUrl(Uri.parse('http://127.0.0.1:$testPort/sessions/default/action'));
      actionReq.headers.contentType = ContentType.json;
      actionReq.write(jsonEncode({
        'output': 'Please fix the widget layout',
      }));
      final actionRes = await actionReq.close();
      expect(actionRes.statusCode, equals(HttpStatus.ok));
      final actionBody = jsonDecode(await utf8.decoder.bind(actionRes).join()) as Map<String, dynamic>;
      expect(actionBody['success'], isTrue);
      expect(actionBody['annotationCount'], equals(1));
      expect(actionBody['delivered']['total'], isNotNull);

      client.close();
    });

    test('tools/call agentation_watch_annotations drains pending annotations immediately', () async {
      await controller.createAnnotation(comment: 'Watch test annotation');

      final client = HttpClient();
      final watchReq = await client.postUrl(Uri.parse('http://127.0.0.1:$testPort/mcp'));
      watchReq.headers.contentType = ContentType.json;
      watchReq.write(jsonEncode({
        'jsonrpc': '2.0',
        'id': 100,
        'method': 'tools/call',
        'params': {
          'name': 'agentation_watch_annotations',
          'arguments': {
            'timeoutSeconds': 2,
            'batchWindowSeconds': 1,
          },
        },
      }));

      final watchRes = await watchReq.close();
      expect(watchRes.statusCode, equals(HttpStatus.ok));
      final body = jsonDecode(await utf8.decoder.bind(watchRes).join()) as Map<String, dynamic>;
      final resultText = body['result']['content'][0]['text'] as String;
      final resultData = jsonDecode(resultText) as Map<String, dynamic>;

      expect(resultData['timeout'], isFalse);
      expect(resultData['count'], equals(1));
      final returnedAnnotations = resultData['annotations'] as List;
      expect(returnedAnnotations[0]['comment'], equals('Watch test annotation'));

      client.close();
    });

    test('WebhookDispatcher handles retry and error responses cleanly', () async {
      final dispatcher = WebhookDispatcher(
        config: const WebhookConfig(maxRetries: 1, timeoutMs: 500, baseDelayMs: 10),
      );

      final result = await dispatcher.send(
        'http://127.0.0.1:59999/nonexistent',
        jsonEncode({'test': true}),
        eventType: 'test.ping',
      );

      expect(result.ok, isFalse);
      expect(result.attempts, greaterThanOrEqualTo(1));
      dispatcher.close();
      expect(dispatcher.isClosed, isTrue);
    });
  });
}
