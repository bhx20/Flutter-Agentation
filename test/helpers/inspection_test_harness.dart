import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness providing mock widget trees and pump utilities for inspection testing.
class InspectionTestHarness {
  /// Pumps a standard test widget tree containing various widget types, keys, and text.
  static Future<void> pumpStandardTree(
    WidgetTester tester, {
    Widget? customChild,
    Key? targetKey,
    String targetText = 'Click Me',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Inspection Test')),
          body: Center(
            child: customChild ??
                ElevatedButton(
                  key: targetKey ?? const ValueKey('test_button'),
                  onPressed: () {},
                  child: Text(targetText),
                ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Pumps a deeply nested widget hierarchy of depth [depth].
  static Future<void> pumpDeepHierarchy(
    WidgetTester tester, {
    int depth = 20,
    String leafText = 'Deep Leaf',
  }) async {
    Widget current = Container(
      key: const ValueKey('deep_leaf_container'),
      child: Text(leafText),
    );

    for (int i = 0; i < depth; i++) {
      current = Padding(
        key: ValueKey('padding_$i'),
        padding: const EdgeInsets.all(1.0),
        child: current,
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: current),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Pumps a transformed widget tree (rotation and scaling).
  static Future<void> pumpTransformedTree(
    WidgetTester tester, {
    Key? targetKey,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Transform.rotate(
              angle: 0.5, // ~28.6 degrees
              child: Container(
                key: targetKey ?? const ValueKey('transformed_box'),
                width: 100,
                height: 100,
                color: Colors.blue,
                child: const Center(child: Text('Transformed')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}
