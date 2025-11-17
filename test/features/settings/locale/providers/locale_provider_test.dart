import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/core/database/app_database.dart';
import 'package:tic_tac_toe/src/core/providers/database_provider.dart';
import 'package:tic_tac_toe/src/features/settings/locale/provider/locale_provider.dart';

void main() {
  group('AppLocale provider', () {
    late ProviderContainer container;
    late AppDatabase database;

    setUp(() {
      // Create in-memory database for testing
      database = AppDatabase.forTesting(NativeDatabase.memory());

      // Override the database provider with test database
      container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    group('initial state', () {
      test('build() returns null (system default)', () async {
        final state = await container.read(appLocaleProvider.future);

        expect(state, isNull);
      });
    });

    group('setLocale', () {
      test('setting English locale updates state', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        await notifier.setLocale(const Locale('en'));

        final state = await container.read(appLocaleProvider.future);
        expect(state, equals(const Locale('en')));
        expect(state?.languageCode, equals('en'));
      });

      test('setting French locale updates state', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        await notifier.setLocale(const Locale('fr'));

        final state = await container.read(appLocaleProvider.future);
        expect(state, equals(const Locale('fr')));
        expect(state?.languageCode, equals('fr'));
      });

      test('setting Spanish locale updates state', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        await notifier.setLocale(const Locale('es'));

        final state = await container.read(appLocaleProvider.future);
        expect(state, equals(const Locale('es')));
        expect(state?.languageCode, equals('es'));
      });

      test('setting German locale updates state', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        await notifier.setLocale(const Locale('de'));

        final state = await container.read(appLocaleProvider.future);
        expect(state, equals(const Locale('de')));
        expect(state?.languageCode, equals('de'));
      });

      test('setting null locale resets to system default', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        // First set a locale
        await notifier.setLocale(const Locale('fr'));
        var state = await container.read(appLocaleProvider.future);
        expect(state, equals(const Locale('fr')));

        // Then reset to system default
        await notifier.setLocale(null);

        state = await container.read(appLocaleProvider.future);
        expect(state, isNull);
      });

      test('changing locale multiple times maintains correct state', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        await notifier.setLocale(const Locale('en'));
        var state = await container.read(appLocaleProvider.future);
        expect(state?.languageCode, equals('en'));

        await notifier.setLocale(const Locale('fr'));
        state = await container.read(appLocaleProvider.future);
        expect(state?.languageCode, equals('fr'));

        await notifier.setLocale(const Locale('es'));
        state = await container.read(appLocaleProvider.future);
        expect(state?.languageCode, equals('es'));

        await notifier.setLocale(const Locale('de'));
        state = await container.read(appLocaleProvider.future);
        expect(state?.languageCode, equals('de'));
      });

      test('setting systemDefaultLocale sentinel converts to null', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        // First set a locale
        await notifier.setLocale(const Locale('fr'));
        var state = await container.read(appLocaleProvider.future);
        expect(state, equals(const Locale('fr')));

        // Then set the sentinel value
        await notifier.setLocale(systemDefaultLocale);

        // Should be converted to null internally
        state = await container.read(appLocaleProvider.future);
        expect(state, isNull);
      });
    });

    group('locale persistence', () {
      test('locale persists across provider reads', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        await notifier.setLocale(const Locale('fr'));

        // Read multiple times
        final state1 = await container.read(appLocaleProvider.future);
        final state2 = await container.read(appLocaleProvider.future);
        final state3 = await container.read(appLocaleProvider.future);

        expect(state1, equals(const Locale('fr')));
        expect(state2, equals(const Locale('fr')));
        expect(state3, equals(const Locale('fr')));
      });

      test('locale persists to database and loads on rebuild', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        // Save a locale
        await notifier.setLocale(const Locale('es'));

        // Create a new container with same database
        final newContainer = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
        );

        // Should load the saved locale from database
        final loadedLocale = await newContainer.read(appLocaleProvider.future);
        expect(loadedLocale?.languageCode, equals('es'));

        newContainer.dispose();
      });

      test('locale persists null (system default) correctly', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        // Set a locale first
        await notifier.setLocale(const Locale('fr'));

        // Reset to system default
        await notifier.setLocale(null);

        // Create a new container with same database
        final newContainer = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
        );

        // Should load null from database
        final loadedLocale = await newContainer.read(appLocaleProvider.future);
        expect(loadedLocale, isNull);

        newContainer.dispose();
      });
    });
  });

  group('effectiveLocale provider', () {
    late ProviderContainer container;
    late AppDatabase database;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Create in-memory database for testing
      database = AppDatabase.forTesting(NativeDatabase.memory());

      // Override the database provider with test database
      container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    group('derived locale computation', () {
      test('returns system locale when appLocale is null', () {
        // appLocaleProvider is null by default
        final effectiveLocale = container.read(effectiveLocaleProvider);

        // Should return a concrete Locale object (system locale)
        expect(effectiveLocale, isA<Locale>());
        expect(effectiveLocale.languageCode, isNotEmpty);
      });

      test('returns preferred locale when explicitly set', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        // Set a specific locale
        await notifier.setLocale(const Locale('fr'));

        final effectiveLocale = container.read(effectiveLocaleProvider);

        expect(effectiveLocale, equals(const Locale('fr')));
        expect(effectiveLocale.languageCode, equals('fr'));
      });

      test('returns system locale when reset to null', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        // First set a locale
        await notifier.setLocale(const Locale('es'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('es')),
        );

        // Then reset to system default
        await notifier.setLocale(null);

        final effectiveLocale = container.read(effectiveLocaleProvider);

        // Should return system locale (a concrete Locale object)
        expect(effectiveLocale, isA<Locale>());
        expect(effectiveLocale.languageCode, isNotEmpty);
      });

      test('always returns a concrete Locale object (never null)', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        // Test multiple scenarios
        final initialLocale = container.read(effectiveLocaleProvider);
        expect(initialLocale, isA<Locale>());

        await notifier.setLocale(const Locale('en'));
        final enLocale = container.read(effectiveLocaleProvider);
        expect(enLocale, isA<Locale>());

        await notifier.setLocale(null);
        final resetLocale = container.read(effectiveLocaleProvider);
        expect(resetLocale, isA<Locale>());
      });

      test('reacts to changes in appLocaleProvider', () async {
        final notifier = container.read(appLocaleProvider.notifier);
        int changeCount = 0;

        // Listen to changes
        container.listen(effectiveLocaleProvider, (previous, next) {
          changeCount++;
        }, fireImmediately: false);

        // Change locale - should trigger listener
        await notifier.setLocale(const Locale('de'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('de')),
        );
        expect(changeCount, greaterThan(0));

        final changeCountAfterFirst = changeCount;

        // Change to different locale - should trigger listener again
        await notifier.setLocale(const Locale('fr'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('fr')),
        );
        expect(changeCount, greaterThan(changeCountAfterFirst));

        // Reset to null - effective locale will be system locale
        // If system locale happens to be 'fr', this won't trigger a change
        await notifier.setLocale(null);
        final systemLocale = container.read(effectiveLocaleProvider);
        expect(systemLocale, isA<Locale>());
        expect(systemLocale.languageCode, isNotEmpty);
      });

      test('handles switching between multiple locales', () async {
        final notifier = container.read(appLocaleProvider.notifier);

        await notifier.setLocale(const Locale('en'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('en')),
        );

        await notifier.setLocale(const Locale('fr'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('fr')),
        );

        await notifier.setLocale(const Locale('es'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('es')),
        );

        await notifier.setLocale(const Locale('de'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('de')),
        );

        await notifier.setLocale(null);
        final systemLocale = container.read(effectiveLocaleProvider);
        expect(systemLocale, isA<Locale>());
      });
    });
  });
}
