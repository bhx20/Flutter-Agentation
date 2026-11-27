import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/src/utils/breakpoints.dart';
import 'package:example/src/utils/responsive_layout.dart';

void main() {
  group('Breakpoints Tests', () {
    testWidgets('identifies mobile device width', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Breakpoints.isMobile(context), isTrue);
              expect(Breakpoints.isTablet(context), isFalse);
              expect(Breakpoints.isDesktop(context), isFalse);
              expect(Breakpoints.getDeviceType(context), ScreenDeviceType.mobile);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('identifies tablet device width', (tester) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Breakpoints.isMobile(context), isFalse);
              expect(Breakpoints.isTablet(context), isTrue);
              expect(Breakpoints.isDesktop(context), isFalse);
              expect(Breakpoints.getDeviceType(context), ScreenDeviceType.tablet);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('identifies desktop device width', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Breakpoints.isMobile(context), isFalse);
              expect(Breakpoints.isTablet(context), isFalse);
              expect(Breakpoints.isDesktop(context), isTrue);
              expect(Breakpoints.getDeviceType(context), ScreenDeviceType.desktop);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('ResponsiveLayout Tests', () {
    testWidgets('renders mobile layout on narrow screens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(
              width: 500,
              child: ResponsiveLayout(
                mobile: Text('Mobile View'),
                desktop: Text('Desktop View'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Mobile View'), findsOneWidget);
      expect(find.text('Desktop View'), findsNothing);
    });

    testWidgets('renders desktop layout on wide screens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(
              width: 1100,
              child: ResponsiveLayout(
                mobile: Text('Mobile View'),
                desktop: Text('Desktop View'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Desktop View'), findsOneWidget);
      expect(find.text('Mobile View'), findsNothing);
    });
  });
}

