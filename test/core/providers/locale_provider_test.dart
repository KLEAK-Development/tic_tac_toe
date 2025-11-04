import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/core/providers/locale_provider.dart';

void main() {
  group('AppLocale provider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('initial state', () {
      test('build() returns null (system default)', () {
        final state = container.read(appLocaleProvider);

        expect(state, isNull);
      });
    });

    group('setLocale', () {
      test('setting English locale updates state', () {
        final notifier = container.read(appLocaleProvider.notifier);

        notifier.setLocale(const Locale('en'));

        final state = container.read(appLocaleProvider);
        expect(state, equals(const Locale('en')));
        expect(state?.languageCode, equals('en'));
      });

      test('setting French locale updates state', () {
        final notifier = container.read(appLocaleProvider.notifier);

        notifier.setLocale(const Locale('fr'));

        final state = container.read(appLocaleProvider);
        expect(state, equals(const Locale('fr')));
        expect(state?.languageCode, equals('fr'));
      });

      test('setting Spanish locale updates state', () {
        final notifier = container.read(appLocaleProvider.notifier);

        notifier.setLocale(const Locale('es'));

        final state = container.read(appLocaleProvider);
        expect(state, equals(const Locale('es')));
        expect(state?.languageCode, equals('es'));
      });

      test('setting German locale updates state', () {
        final notifier = container.read(appLocaleProvider.notifier);

        notifier.setLocale(const Locale('de'));

        final state = container.read(appLocaleProvider);
        expect(state, equals(const Locale('de')));
        expect(state?.languageCode, equals('de'));
      });

      test('setting null locale resets to system default', () {
        final notifier = container.read(appLocaleProvider.notifier);

        // First set a locale
        notifier.setLocale(const Locale('fr'));
        expect(container.read(appLocaleProvider), equals(const Locale('fr')));

        // Then reset to system default
        notifier.setLocale(null);

        final state = container.read(appLocaleProvider);
        expect(state, isNull);
      });

      test('changing locale multiple times maintains correct state', () {
        final notifier = container.read(appLocaleProvider.notifier);

        notifier.setLocale(const Locale('en'));
        expect(container.read(appLocaleProvider)?.languageCode, equals('en'));

        notifier.setLocale(const Locale('fr'));
        expect(container.read(appLocaleProvider)?.languageCode, equals('fr'));

        notifier.setLocale(const Locale('es'));
        expect(container.read(appLocaleProvider)?.languageCode, equals('es'));

        notifier.setLocale(const Locale('de'));
        expect(container.read(appLocaleProvider)?.languageCode, equals('de'));
      });

      test('setting systemDefaultLocale sentinel converts to null', () {
        final notifier = container.read(appLocaleProvider.notifier);

        // First set a locale
        notifier.setLocale(const Locale('fr'));
        expect(container.read(appLocaleProvider), equals(const Locale('fr')));

        // Then set the sentinel value
        notifier.setLocale(systemDefaultLocale);

        // Should be converted to null internally
        final state = container.read(appLocaleProvider);
        expect(state, isNull);
      });
    });

    group('locale persistence', () {
      test('locale persists across provider reads', () {
        final notifier = container.read(appLocaleProvider.notifier);

        notifier.setLocale(const Locale('fr'));

        // Read multiple times
        final state1 = container.read(appLocaleProvider);
        final state2 = container.read(appLocaleProvider);
        final state3 = container.read(appLocaleProvider);

        expect(state1, equals(const Locale('fr')));
        expect(state2, equals(const Locale('fr')));
        expect(state3, equals(const Locale('fr')));
      });
    });
  });

  group('effectiveLocale provider', () {
    late ProviderContainer container;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('derived locale computation', () {
      test('returns system locale when appLocale is null', () {
        // appLocaleProvider is null by default
        final effectiveLocale = container.read(effectiveLocaleProvider);

        // Should return a concrete Locale object (system locale)
        expect(effectiveLocale, isA<Locale>());
        expect(effectiveLocale.languageCode, isNotEmpty);
      });

      test('returns preferred locale when explicitly set', () {
        final notifier = container.read(appLocaleProvider.notifier);

        // Set a specific locale
        notifier.setLocale(const Locale('fr'));

        final effectiveLocale = container.read(effectiveLocaleProvider);

        expect(effectiveLocale, equals(const Locale('fr')));
        expect(effectiveLocale.languageCode, equals('fr'));
      });

      test('returns system locale when reset to null', () {
        final notifier = container.read(appLocaleProvider.notifier);

        // First set a locale
        notifier.setLocale(const Locale('es'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('es')),
        );

        // Then reset to system default
        notifier.setLocale(null);

        final effectiveLocale = container.read(effectiveLocaleProvider);

        // Should return system locale (a concrete Locale object)
        expect(effectiveLocale, isA<Locale>());
        expect(effectiveLocale.languageCode, isNotEmpty);
      });

      test('always returns a concrete Locale object (never null)', () {
        final notifier = container.read(appLocaleProvider.notifier);

        // Test multiple scenarios
        final initialLocale = container.read(effectiveLocaleProvider);
        expect(initialLocale, isA<Locale>());

        notifier.setLocale(const Locale('en'));
        final enLocale = container.read(effectiveLocaleProvider);
        expect(enLocale, isA<Locale>());

        notifier.setLocale(null);
        final resetLocale = container.read(effectiveLocaleProvider);
        expect(resetLocale, isA<Locale>());
      });

      test('reacts to changes in appLocaleProvider', () {
        final notifier = container.read(appLocaleProvider.notifier);
        int changeCount = 0;

        // Listen to changes
        container.listen(effectiveLocaleProvider, (previous, next) {
          changeCount++;
        }, fireImmediately: false);

        // Change locale - should trigger listener
        notifier.setLocale(const Locale('de'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('de')),
        );
        expect(changeCount, greaterThan(0));

        final changeCountAfterFirst = changeCount;

        // Change to different locale - should trigger listener again
        notifier.setLocale(const Locale('fr'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('fr')),
        );
        expect(changeCount, greaterThan(changeCountAfterFirst));

        // Reset to null - effective locale will be system locale
        // If system locale happens to be 'fr', this won't trigger a change
        notifier.setLocale(null);
        final systemLocale = container.read(effectiveLocaleProvider);
        expect(systemLocale, isA<Locale>());
        expect(systemLocale.languageCode, isNotEmpty);
      });

      test('handles switching between multiple locales', () {
        final notifier = container.read(appLocaleProvider.notifier);

        notifier.setLocale(const Locale('en'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('en')),
        );

        notifier.setLocale(const Locale('fr'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('fr')),
        );

        notifier.setLocale(const Locale('es'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('es')),
        );

        notifier.setLocale(const Locale('de'));
        expect(
          container.read(effectiveLocaleProvider),
          equals(const Locale('de')),
        );

        notifier.setLocale(null);
        final systemLocale = container.read(effectiveLocaleProvider);
        expect(systemLocale, isA<Locale>());
      });
    });
  });
}
