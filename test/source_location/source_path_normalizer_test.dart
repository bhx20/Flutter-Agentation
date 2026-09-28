import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agentation/src/source_location/source_path_normalizer.dart';

void main() {
  group('source_path_normalizer', () {
    group('normalizeProjectPath', () {
      test('normalizes Windows absolute path to lib/ path', () {
        const input = r'C:\Users\sanket\Projects\my_app\lib\features\auth\login_page.dart';
        expect(normalizeProjectPath(input), equals('lib/features/auth/login_page.dart'));
      });

      test('normalizes Unix absolute path to lib/ path', () {
        const input = '/Users/sanket/Projects/my_app/lib/features/auth/login_page.dart';
        expect(normalizeProjectPath(input), equals('lib/features/auth/login_page.dart'));
      });

      test('normalizes file URI on Windows', () {
        const input = 'file:///C:/project/lib/views/home_screen.dart';
        expect(normalizeProjectPath(input), equals('lib/views/home_screen.dart'));
      });

      test('normalizes file URI on Unix', () {
        const input = 'file:///workspace/project/lib/main.dart';
        expect(normalizeProjectPath(input), equals('lib/main.dart'));
      });

      test('normalizes package: URI to lib/ path', () {
        const input = 'package:my_app/features/profile/settings_page.dart';
        expect(normalizeProjectPath(input), equals('lib/features/profile/settings_page.dart'));
      });

      test('preserves test/ paths', () {
        const input = r'D:\projects\flutter_agentation\test\source_location\normalizer_test.dart';
        expect(normalizeProjectPath(input), equals('test/source_location/normalizer_test.dart'));
      });

      test('preserves example/ paths', () {
        const input = r'/home/user/repo/example/lib/main.dart';
        expect(normalizeProjectPath(input), equals('lib/main.dart'));
      });

      test('returns original string safely if empty', () {
        expect(normalizeProjectPath(''), equals(''));
      });

      test('returns clean path if no standard marker found', () {
        const input = r'custom_folder\widgets\custom_button.dart';
        expect(normalizeProjectPath(input), equals('custom_folder/widgets/custom_button.dart'));
      });
    });

    group('extractFileName', () {
      test('extracts filename from Windows path', () {
        expect(extractFileName(r'C:\project\lib\login_page.dart'), equals('login_page.dart'));
      });

      test('extracts filename from Unix path', () {
        expect(extractFileName('/project/lib/login_page.dart'), equals('login_page.dart'));
      });

      test('extracts filename from file URI', () {
        expect(extractFileName('file:///project/lib/features/auth/login_page.dart'), equals('login_page.dart'));
      });

      test('returns unavailable for empty path', () {
        expect(extractFileName(''), equals('unavailable'));
      });
    });
  });
}
