import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_agentation/flutter_agentation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgentSyncClient & Model Context Protocol (User Story 6)', () {
    late List<Map<String, dynamic>> dispatchedRequests;
    late AgentSyncClient client;

    setUp(() {
      dispatchedRequests = [];
      client = AgentSyncClient(
        endpoint: 'http://localhost:4747',
        httpTransport: (method, uri, {headers, body}) async {
          dispatchedRequests.add({
            'method': method,
            'uri': uri.toString(),
            'headers': headers,
            'body': body != null ? jsonDecode(body) : null,
          });

          if (uri.path.endsWith('/sessions') && method == 'GET') {
            return HttpResponseData(200, jsonEncode([
              {'id': 'sess_1', 'url': 'http://localhost:3000'},
            ]));
          }

          if (uri.path.endsWith('/sessions') && method == 'POST') {
            return HttpResponseData(200, jsonEncode({
              'id': 'sess_new_42',
              'url': 'http://app.local',
            }));
          }

          if (uri.path.contains('/annotations') && method == 'POST') {
            return HttpResponseData(200, jsonEncode({
              'id': 'ann_server_1',
              'comment': 'Synced note',
            }));
          }

          if (uri.path.contains('/action') && method == 'POST') {
            return HttpResponseData(200, jsonEncode({
              'success': true,
              'annotationCount': 1,
              'delivered': {'sseListeners': 1, 'webhooks': 0, 'total': 1},
            }));
          }

          return const HttpResponseData(200, '{}');
        },
      );
    });

    test('listSessions retrieves active sessions from server', () async {
      final sessions = await client.listSessions();
      expect(sessions.length, equals(1));
      expect(sessions.first['id'], equals('sess_1'));
      expect(dispatchedRequests.first['method'], equals('GET'));
      expect(dispatchedRequests.first['uri'], equals('http://localhost:4747/sessions'));
    });

    test('createSession posts app URL and returns session map', () async {
      final session = await client.createSession(url: 'http://app.local');
      expect(session['id'], equals('sess_new_42'));
      expect(dispatchedRequests.first['method'], equals('POST'));
      expect(dispatchedRequests.first['uri'], equals('http://localhost:4747/sessions'));
      expect(dispatchedRequests.first['body']['url'], equals('http://app.local'));
    });

    test('syncAnnotation sends annotation payload to /sessions/:id/annotations', () async {
      final annotation = Annotation(
        id: 'ann_test',
        comment: 'Fix header alignment',
        timestamp: DateTime(2026, 9, 25),
        bounds: const WidgetBounds(x: 10, y: 20, width: 100, height: 40),
        targetWidget: const WidgetIdentity(id: 'header', widgetType: 'AppBar'),
      );

      final result = await client.syncAnnotation('sess_new_42', annotation);
      expect(result['id'], equals('ann_server_1'));
      expect(dispatchedRequests.first['method'], equals('POST'));
      expect(dispatchedRequests.first['uri'],
          equals('http://localhost:4747/sessions/sess_new_42/annotations'));
      expect(dispatchedRequests.first['body']['comment'], equals('Fix header alignment'));
    });

    test('requestAction sends formatted instructions to agent', () async {
      final actionRes = await client.requestAction('sess_new_42', '### User Annotations\n1. Fix');
      expect(actionRes['success'], isTrue);
      expect(dispatchedRequests.first['method'], equals('POST'));
      expect(dispatchedRequests.first['uri'],
          equals('http://localhost:4747/sessions/sess_new_42/action'));
    });

    test('dispatchWebhook sends custom event to webhook URL', () async {
      final ok = await client.dispatchWebhook(
        'http://webhook.service/events',
        event: 'annotation.created',
        payload: {'id': 'ann_123'},
      );
      expect(ok, isTrue);
      expect(dispatchedRequests.first['method'], equals('POST'));
      expect(dispatchedRequests.first['uri'], equals('http://webhook.service/events'));
      expect(dispatchedRequests.first['body']['event'], equals('annotation.created'));
    });

    test('handles network errors gracefully without crashing', () async {
      final failingClient = AgentSyncClient(
        endpoint: 'http://unreachable:9999',
        httpTransport: (_, _, {headers, body}) async {
          throw Exception('Connection refused');
        },
      );

      final sessions = await failingClient.listSessions();
      expect(sessions, isEmpty);

      final session = await failingClient.createSession();
      expect(session, isEmpty);
    });

    test('AgentationController auto-syncs created annotations when syncClient attached', () async {
      final storage = MemoryAnnotationStorage();
      final controller = AgentationController(
        storage: storage,
        syncClient: client,
      );
      controller.activate();

      // Set active sessionId
      controller.updateSettings(controller.settings.copyWith(
        sessionId: 'sess_new_42',
        mcpEndpoint: 'http://localhost:4747',
      ));

      await controller.createAnnotation(
        comment: 'Need bigger button',
        targetResult: const WidgetInspectionResult(
          identity: WidgetIdentity(id: 'btn', widgetType: 'ElevatedButton'),
          bounds: WidgetBounds(x: 0, y: 0, width: 100, height: 40),
          context: WidgetContext.empty(),
          ancestors: [],
        ),
      );

      // Verify request was dispatched through client
      expect(dispatchedRequests.any((r) =>
          r['uri'] == 'http://localhost:4747/sessions/sess_new_42/annotations'), isTrue);
    });

    test('addThreadMessage appends message and syncs updated annotation to server', () async {
      final storage = MemoryAnnotationStorage();
      final controller = AgentationController(
        storage: storage,
        syncClient: client,
      );
      controller.activate();
      controller.updateSettings(controller.settings.copyWith(
        sessionId: 'sess_new_42',
      ));

      final created = await controller.createAnnotation(
        comment: 'Initial issue',
        targetResult: const WidgetInspectionResult(
          identity: WidgetIdentity(id: 'btn', widgetType: 'ElevatedButton'),
          bounds: WidgetBounds(x: 0, y: 0, width: 100, height: 40),
          context: WidgetContext.empty(),
          ancestors: [],
        ),
      );

      final updated = await controller.addThreadMessage(
        created.id,
        'Agent proposed solution: use OutlinedButton',
        role: 'agent',
      );

      expect(updated, isNotNull);
      expect(updated!.thread.length, equals(1));
      expect(updated.thread.first.content, contains('OutlinedButton'));
      expect(updated.thread.first.role, equals('agent'));

      // Verify synced to server
      expect(dispatchedRequests.where((r) =>
          r['uri'] == 'http://localhost:4747/sessions/sess_new_42/annotations').length, equals(2));
    });

    testWidgets('AnnotationDetailCard renders conversational thread and sends reply', (tester) async {
      final storage = MemoryAnnotationStorage();
      final controller = AgentationController(
        storage: storage,
      );
      controller.activate();

      final message = ThreadMessage(
        id: 'msg_1',
        role: 'agent',
        content: 'I can fix this padding for you.',
        timestamp: DateTime(2026, 9, 25, 12, 30),
      );

      final annotation = Annotation(
        id: 'ann_card_1',
        comment: 'Check padding',
        timestamp: DateTime(2026, 9, 25),
        bounds: const WidgetBounds(x: 20, y: 50, width: 200, height: 60),
        targetWidget: const WidgetIdentity(id: 'box', widgetType: 'Container'),
        thread: [message],
      );

      await storage.save(annotation);
      await controller.storage.getAll();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AgentationScope(
              controller: controller,
              child: Stack(
                children: [
                  AnnotationDetailCard(
                    index: 1,
                    annotation: annotation,
                    onClose: () {},
                    onDelete: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('AI Agent'), findsOneWidget);
      expect(find.text('I can fix this padding for you.'), findsOneWidget);
      expect(find.text('Check padding'), findsOneWidget);

      // Type a human reply
      await tester.enterText(find.byType(TextField), 'Yes please, 16px padding');
      await tester.tap(find.byTooltip('Send reply'));
      await tester.pump();

      // Controller should have received message
      final stored = await storage.getById('ann_card_1');
      expect(stored!.thread.length, equals(2));
      expect(stored.thread.last.content, equals('Yes please, 16px padding'));
      expect(stored.thread.last.role, equals('human'));
    });
  });
}
