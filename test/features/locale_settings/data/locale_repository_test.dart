import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/core/database/app_database.dart';
import 'package:tic_tac_toe/src/features/locale_settings/data/locale_repository.dart';

void main() {
  late AppDatabase database;
  late LocaleRepository repository;

  setUp(() {
    // Use in-memory database for tests
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocaleRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('LocaleRepository', () {
    group('getLocale', () {
      test('returns null when no locale is saved (first launch)', () async {
        final locale = await repository.getLocale();
        expect(locale, isNull);
      });

      test('returns saved locale', () async {
        await repository.saveLocale(const Locale('fr'));
        final locale = await repository.getLocale();

        expect(locale, isNotNull);
        expect(locale?.languageCode, equals('fr'));
      });

      test(
          'returns null when locale is explicitly set to system default',
          () async {
        await repository.saveLocale(const Locale('fr'));
        await repository.saveLocale(null); // Reset to system default

        final locale = await repository.getLocale();
        expect(locale, isNull);
      });

      test('handles all supported locales', () async {
        final locales = ['en', 'fr', 'es', 'de'];

        for (final code in locales) {
          await repository.saveLocale(Locale(code));
          final locale = await repository.getLocale();
          expect(locale?.languageCode, equals(code),
              reason: 'Failed for locale: $code');
        }
      });
    });

    group('saveLocale', () {
      test('saves English locale', () async {
        await repository.saveLocale(const Locale('en'));
        final locale = await repository.getLocale();

        expect(locale?.languageCode, equals('en'));
      });

      test('saves French locale', () async {
        await repository.saveLocale(const Locale('fr'));
        final locale = await repository.getLocale();

        expect(locale?.languageCode, equals('fr'));
      });

      test('saves Spanish locale', () async {
        await repository.saveLocale(const Locale('es'));
        final locale = await repository.getLocale();

        expect(locale?.languageCode, equals('es'));
      });

      test('saves German locale', () async {
        await repository.saveLocale(const Locale('de'));
        final locale = await repository.getLocale();

        expect(locale?.languageCode, equals('de'));
      });

      test('saves null (system default)', () async {
        await repository.saveLocale(const Locale('fr'));
        await repository.saveLocale(null);

        final locale = await repository.getLocale();
        expect(locale, isNull);
      });

      test('updates existing locale', () async {
        await repository.saveLocale(const Locale('en'));
        await repository.saveLocale(const Locale('fr'));
        await repository.saveLocale(const Locale('es'));

        final locale = await repository.getLocale();
        expect(locale?.languageCode, equals('es'));
      });

      test('persists across multiple reads', () async {
        await repository.saveLocale(const Locale('fr'));

        // Read multiple times
        for (var i = 0; i < 5; i++) {
          final locale = await repository.getLocale();
          expect(locale?.languageCode, equals('fr'),
              reason: 'Failed on read $i');
        }
      });
    });

    group('clearSettings', () {
      test('removes saved locale', () async {
        await repository.saveLocale(const Locale('fr'));
        await repository.clearSettings();

        final locale = await repository.getLocale();
        expect(locale, isNull);
      });

      test('can save after clearing', () async {
        await repository.saveLocale(const Locale('fr'));
        await repository.clearSettings();
        await repository.saveLocale(const Locale('es'));

        final locale = await repository.getLocale();
        expect(locale?.languageCode, equals('es'));
      });
    });

    group('error handling', () {
      test('returns null on database error', () async {
        // Save a value first
        await repository.saveLocale(const Locale('fr'));

        // Close database to simulate error
        await database.close();

        // Should return null instead of throwing
        final locale = await repository.getLocale();
        expect(locale, isNull);
      });

      test('save fails silently on database error', () async {
        // Close database to simulate error
        await database.close();

        // Should not throw
        expect(() async => await repository.saveLocale(const Locale('fr')),
            returnsNormally);
      });
    });

    group('edge cases', () {
      test('handles rapid consecutive saves', () async {
        // Simulate rapid language switching
        await repository.saveLocale(const Locale('en'));
        await repository.saveLocale(const Locale('fr'));
        await repository.saveLocale(const Locale('es'));
        await repository.saveLocale(const Locale('de'));

        final locale = await repository.getLocale();
        expect(locale?.languageCode, equals('de'));
      });

      test('handles save and read interleaving', () async {
        await repository.saveLocale(const Locale('en'));
        var locale = await repository.getLocale();
        expect(locale?.languageCode, equals('en'));

        await repository.saveLocale(const Locale('fr'));
        locale = await repository.getLocale();
        expect(locale?.languageCode, equals('fr'));
      });
    });
  });
}
