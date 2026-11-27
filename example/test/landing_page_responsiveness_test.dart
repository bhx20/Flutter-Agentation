import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:example/src/components/navbar.dart';

void main() {
  group('Landing Page Full Responsiveness & Integration Tests', () {
    testWidgets('renders completely without overflow on Mobile (375 x 812)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const AgentationExampleApp());
      await tester.pumpAndSettle();

      expect(find.byType(LandingPage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify opening mobile drawer
      final menuButton = find.byKey(const ValueKey('mobile_menu_button'));
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsOneWidget);
      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Installation'), findsOneWidget);

      // Tap navigation link to close drawer
      await tester.tap(find.text('Installation'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets('renders completely without overflow on Tablet (768 x 1024)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const AgentationExampleApp());
      await tester.pumpAndSettle();

      expect(find.byType(LandingPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders completely without overflow on Desktop (1440 x 900)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const AgentationExampleApp());
      await tester.pumpAndSettle();

      expect(find.byType(LandingPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'renders completely without overflow on Web Wide Screen (1920 x 945)',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 945);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const AgentationExampleApp());
        await tester.pumpAndSettle();

        expect(find.byType(LandingPage), findsOneWidget);
        expect(find.byType(NavbarSection), findsOneWidget);
        final err = tester.takeException();
        if (err != null) {
          if (err is FlutterError) {
            for (final d in err.diagnostics) {
              debugPrint('DIAG: ${d.name}: $d');
            }
          }
        }
        expect(err, isNull);
      },
    );

    testWidgets(
      'renders completely without overflow on 4K Display (2560 x 1440)',
      (tester) async {
        tester.view.physicalSize = const Size(2560, 1440);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const AgentationExampleApp());
        await tester.pumpAndSettle();

        expect(find.byType(LandingPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
