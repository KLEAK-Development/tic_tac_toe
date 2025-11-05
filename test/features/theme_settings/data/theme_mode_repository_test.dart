import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/core/database/app_database.dart';
import 'package:tic_tac_toe/src/features/theme_settings/data/theme_mode_repository.dart';

void main() {
  late AppDatabase database;
  late ThemeModeRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ThemeModeRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('ThemeModeRepository', () {
    group('getThemeMode', () {
      test(
        'returns ThemeMode.system when no value is saved (first launch)',
        () async {
          final mode = await repository.getThemeMode();
          expect(mode, equals(ThemeMode.system));
        },
      );

      test('returns saved light mode', () async {
        await repository.saveThemeMode(ThemeMode.light);
        final mode = await repository.getThemeMode();
        expect(mode, equals(ThemeMode.light));
      });

      test('returns saved dark mode', () async {
        await repository.saveThemeMode(ThemeMode.dark);
        final mode = await repository.getThemeMode();
        expect(mode, equals(ThemeMode.dark));
      });

      test(
        'system mode stored as null maps back to ThemeMode.system',
        () async {
          await repository.saveThemeMode(ThemeMode.system);
          final mode = await repository.getThemeMode();
          expect(mode, equals(ThemeMode.system));
        },
      );
    });

    group('saveThemeMode', () {
      test('updates existing value', () async {
        await repository.saveThemeMode(ThemeMode.light);
        await repository.saveThemeMode(ThemeMode.dark);
        final mode = await repository.getThemeMode();
        expect(mode, equals(ThemeMode.dark));
      });

      test('persists across multiple reads', () async {
        await repository.saveThemeMode(ThemeMode.dark);
        for (var i = 0; i < 5; i++) {
          final mode = await repository.getThemeMode();
          expect(mode, equals(ThemeMode.dark), reason: 'Failed on read $i');
        }
      });
    });

    group('error handling', () {
      test('returns system on database error', () async {
        await repository.saveThemeMode(ThemeMode.dark);
        await database.close();
        final mode = await repository.getThemeMode();
        expect(mode, equals(ThemeMode.system));
      });

      test('save fails silently on database error', () async {
        await database.close();
        expect(
          () async => await repository.saveThemeMode(ThemeMode.light),
          returnsNormally,
        );
      });
    });

    group('edge cases', () {
      test('handles rapid consecutive saves', () async {
        await repository.saveThemeMode(ThemeMode.system);
        await repository.saveThemeMode(ThemeMode.light);
        await repository.saveThemeMode(ThemeMode.dark);
        final mode = await repository.getThemeMode();
        expect(mode, equals(ThemeMode.dark));
      });
    });
  });
}
