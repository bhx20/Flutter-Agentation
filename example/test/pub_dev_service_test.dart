import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:example/src/services/pub_dev_service.dart';

void main() {
  group('PubDevService Tests', () {
    test('PubPackageData.initial provides verified defaults and releases', () {
      final initial = PubPackageData.initial;
      expect(initial.name, 'flutter_agentation');
      expect(initial.version, '1.0.0');
      expect(initial.grantedPoints, 150);
      expect(initial.maxPoints, 160);
      expect(initial.likeCount, 9);
      expect(initial.downloadCount30Days, 756);
      expect(initial.publisherId, 'coddynet.com');
      expect(initial.platforms, contains('web'));
      expect(initial.isWasmReady, isTrue);
      expect(initial.releases.isNotEmpty, isTrue);
      expect(initial.releases.first.version, 'v1.0.0');
    });

    test('parseChangelogMarkdown correctly parses markdown headers and changes', () {
      const sample = '''
## 1.0.0

* First official stable release of Flutter Agentation.
* **Deep Widget Inspection**: Resolves exact RenderBox bounds and line numbers.

## 0.1.0

* Initial preview release.
''';

      final releases = PubDevService.parseChangelogMarkdown(sample);
      expect(releases.length, 2);
      expect(releases[0].version, 'v1.0.0');
      expect(releases[0].badge, 'Latest Release');
      expect(releases[0].changes.length, 2);
      expect(releases[0].changes[1].title, 'Deep Widget Inspection');
      expect(releases[1].version, 'v0.1.0');
    });

    test('fetchPackageData successfully parses pub.dev mock responses and changelog', () async {
      final service = PubDevService.instance;

      final mockClient = MockClient((request) async {
        final path = request.url.path;

        if (path.endsWith('/packages/flutter_agentation')) {
          return http.Response(
            jsonEncode({
              'name': 'flutter_agentation',
              'latest': {
                'version': '1.0.0',
                'published': '2026-11-02T15:12:26.912328Z',
                'pubspec': {
                  'name': 'flutter_agentation',
                  'description': 'Dynamic pub.dev test description',
                  'repository': 'https://github.com/bhx20/Flutter-Agentation',
                  'environment': {
                    'sdk': '^3.12.2',
                    'flutter': '>=3.16.0',
                  },
                },
              },
              'versions': [
                {'version': '1.0.0'},
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (path.endsWith('/packages/flutter_agentation/score')) {
          return http.Response(
            jsonEncode({
              'grantedPoints': 150,
              'maxPoints': 160,
              'likeCount': 12,
              'downloadCount30Days': 820,
              'tags': [
                'sdk:flutter',
                'platform:android',
                'platform:ios',
                'platform:windows',
                'platform:linux',
                'platform:macos',
                'platform:web',
                'is:wasm-ready',
                'publisher:coddynet.com',
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (path.endsWith('/packages/flutter_agentation/publisher')) {
          return http.Response(
            jsonEncode({
              'publisherId': 'coddynet.com',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (path.endsWith('/CHANGELOG.md')) {
          return http.Response(
            '''
## 1.0.0
* First official stable release of Flutter Agentation.
* Comprehensive Model Context Protocol (MCP) server daemon.
''',
            200,
          );
        }

        return http.Response('Not found', 404);
      });

      await service.fetchPackageData(client: mockClient);

      expect(service.current.version, '1.0.0');
      expect(service.current.grantedPoints, 150);
      expect(service.current.maxPoints, 160);
      expect(service.current.likeCount, 12);
      expect(service.current.downloadCount30Days, 820);
      expect(service.current.publisherId, 'coddynet.com');
      expect(service.current.platforms.length, 6);
      expect(service.current.isWasmReady, isTrue);
      expect(service.current.releases.isNotEmpty, isTrue);
      expect(service.current.isLoading, isFalse);
    });
  });
}
