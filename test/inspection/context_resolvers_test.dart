import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/inspection/route_resolver.dart';
import 'package:flutter_agentation/src/inspection/semantics_resolver.dart';

void main() {
  group('Context Resolvers', () {
    final routeResolver = RouteResolver();
    final semanticsResolver = SemanticsResolver();

    testWidgets('RouteResolver resolves active named route correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/profile',
          routes: {
            '/profile': (context) => const Scaffold(
                  body: Center(
                    child: Text('Profile Screen'),
                  ),
                ),
          },
        ),
      );
      await tester.pumpAndSettle();

      final textElement = tester.element(find.text('Profile Screen'));
      final route = routeResolver.resolveRoute(textElement);

      expect(route, '/profile');
    });

    testWidgets('SemanticsResolver extracts label and hint from Semantics widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Semantics(
                label: 'Close window',
                hint: 'Double tap to close',
                child: const Icon(Icons.close),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final iconElement = tester.element(find.byType(Icon));
      final ro = tester.renderObject(find.byType(Icon));

      final semantics = semanticsResolver.extractSemantics(ro, iconElement);

      expect(semantics, isNotNull);
      expect(semantics!.label, 'Close window');
      expect(semantics.hint, 'Double tap to close');
    });
  });
}
