import 'package:flutter_agentation/src/models/annotation.dart';
import 'package:flutter_agentation/src/models/widget_bounds.dart';
import 'package:flutter_agentation/src/models/widget_identity.dart';
import 'package:flutter_agentation/src/storage/memory_annotation_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemoryAnnotationStorage', () {
    late MemoryAnnotationStorage storage;

    setUp(() {
      storage = MemoryAnnotationStorage();
    });

    Annotation createDummy(String id, {String? route, DateTime? time}) {
      return Annotation(
        id: id,
        comment: 'Comment for $id',
        timestamp: time ?? DateTime.now(),
        targetWidget: WidgetIdentity(id: 'w_$id', widgetType: 'Button'),
        bounds: const WidgetBounds.zero(),
        route: route,
      );
    }

    test('saves and retrieves annotations by ID and all sorted chronologically',
        () async {
      final t1 = DateTime(2026, 9, 25, 10, 0);
      final t2 = DateTime(2026, 9, 25, 11, 0);
      final t3 = DateTime(2026, 9, 25, 12, 0);

      final a2 = createDummy('a2', time: t2);
      final a1 = createDummy('a1', time: t1);
      final a3 = createDummy('a3', time: t3);

      await storage.save(a2);
      await storage.save(a1);
      await storage.save(a3);

      final retrieved = await storage.getById('a1');
      expect(retrieved, equals(a1));

      final all = await storage.getAll();
      expect(all.length, equals(3));
      // Should be sorted by timestamp ascending
      expect(all[0].id, equals('a1'));
      expect(all[1].id, equals('a2'));
      expect(all[2].id, equals('a3'));
    });

    test('getByRoute filters annotations by matching route', () async {
      final a1 = createDummy('a1', route: '/home');
      final a2 = createDummy('a2', route: '/settings');
      final a3 = createDummy('a3', route: '/home');

      await storage.save(a1);
      await storage.save(a2);
      await storage.save(a3);

      final homeList = await storage.getByRoute('/home');
      expect(homeList.length, equals(2));
      expect(homeList.map((a) => a.id), containsAll(['a1', 'a3']));

      final settingsList = await storage.getByRoute('/settings');
      expect(settingsList.length, equals(1));
      expect(settingsList.first.id, equals('a2'));
    });

    test('delete removes annotation and clear wipes repository', () async {
      final a1 = createDummy('a1');
      final a2 = createDummy('a2');

      await storage.save(a1);
      await storage.save(a2);

      final deleted = await storage.delete('a1');
      expect(deleted, isTrue);

      final missing = await storage.getById('a1');
      expect(missing, isNull);

      final nonExistent = await storage.delete('unknown');
      expect(nonExistent, isFalse);

      await storage.clear();
      final all = await storage.getAll();
      expect(all, isEmpty);
    });
  });
}
