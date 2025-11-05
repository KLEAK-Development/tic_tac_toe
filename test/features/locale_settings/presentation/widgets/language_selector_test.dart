import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/core/database/app_database.dart';
import 'package:tic_tac_toe/src/core/l10n/app_localizations.dart';
import 'package:tic_tac_toe/src/core/providers/database_provider.dart';
import 'package:tic_tac_toe/src/features/locale_settings/provider/locale_provider.dart';
import 'package:tic_tac_toe/src/features/locale_settings/presentation/widgets/language_selector.dart';

void main() {
  // Suppress Drift warning about multiple database instances in tests
  // This is safe because each test creates its own isolated in-memory database
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  group('LanguageSelector', () {
    Widget buildTestWidget({Locale? initialLocale}) {
      return ProviderScope(
        overrides: [
          // Override the provider to start with a specific locale
          if (initialLocale != null)
            appLocaleProvider.overrideWith(() => TestAppLocale(initialLocale)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: AppBar(actions: const [LanguageSelector()]),
            ),
          ),
        ),
      );
    }

    testWidgets('displays checkmark on System Default when locale is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Open language menu
      await tester.tap(find.byKey(const Key('menu_language_button')));
      await tester.pumpAndSettle();

      // Find System Default menu item and verify it has a checkmark
      final systemDefaultItem = find.byKey(const Key('menu_language_system'));
      expect(systemDefaultItem, findsOneWidget);

      // Verify checkmark icon is present (CheckableMenuItem shows Icon when selected)
      final checkmarkInSystemDefault = find.descendant(
        of: systemDefaultItem,
        matching: find.byIcon(Icons.check),
      );
      expect(checkmarkInSystemDefault, findsOneWidget);
    });

    testWidgets('displays checkmark on French when locale is French', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(initialLocale: const Locale('fr')),
      );
      await tester.pumpAndSettle();

      // Open language menu
      await tester.tap(find.byKey(const Key('menu_language_button')));
      await tester.pumpAndSettle();

      // Verify French has checkmark
      final frenchItem = find.byKey(const Key('menu_language_fr'));
      expect(frenchItem, findsOneWidget);

      final checkmarkInFrench = find.descendant(
        of: frenchItem,
        matching: find.byIcon(Icons.check),
      );
      expect(checkmarkInFrench, findsOneWidget);

      // Verify System Default does NOT have checkmark
      final systemDefaultItem = find.byKey(const Key('menu_language_system'));
      final checkmarkInSystemDefault = find.descendant(
        of: systemDefaultItem,
        matching: find.byIcon(Icons.check),
      );
      expect(checkmarkInSystemDefault, findsNothing);
    });

    testWidgets('can switch from System Default to French', (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: AppBar(actions: const [LanguageSelector()]),
              ),
            ),
          ),
        ),
      );

      // Initially should be null (System Default)
      var locale = await container.read(appLocaleProvider.future);
      expect(locale, isNull);

      // Open language menu
      await tester.tap(find.byKey(const Key('menu_language_button')));
      await tester.pumpAndSettle();

      // Tap French
      await tester.tap(find.byKey(const Key('menu_language_fr')));
      await tester.pumpAndSettle();

      // Verify locale changed to French
      locale = await container.read(appLocaleProvider.future);
      expect(locale, equals(const Locale('fr')));
    });

    testWidgets('can switch from French back to System Default', (
      tester,
    ) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appLocaleProvider.overrideWith(
            () => TestAppLocale(const Locale('fr')),
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: AppBar(actions: const [LanguageSelector()]),
              ),
            ),
          ),
        ),
      );

      // Initially should be French
      var locale = await container.read(appLocaleProvider.future);
      expect(locale, equals(const Locale('fr')));

      // Open language menu
      await tester.tap(find.byKey(const Key('menu_language_button')));
      await tester.pumpAndSettle();

      // Tap System Default
      await tester.tap(find.byKey(const Key('menu_language_system')));
      await tester.pumpAndSettle();

      // Verify locale changed to null (System Default)
      locale = await container.read(appLocaleProvider.future);
      expect(locale, isNull);
    });

    testWidgets('can switch between multiple languages', (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(() async {
        container.dispose();
        await database.close();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: AppBar(actions: const [LanguageSelector()]),
              ),
            ),
          ),
        ),
      );

      // Switch to French
      await tester.tap(find.byKey(const Key('menu_language_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu_language_fr')));
      await tester.pumpAndSettle();
      var locale = await container.read(appLocaleProvider.future);
      expect(locale, equals(const Locale('fr')));

      // Switch to Spanish
      await tester.tap(find.byKey(const Key('menu_language_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu_language_es')));
      await tester.pumpAndSettle();
      locale = await container.read(appLocaleProvider.future);
      expect(locale, equals(const Locale('es')));

      // Switch to German
      await tester.tap(find.byKey(const Key('menu_language_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu_language_de')));
      await tester.pumpAndSettle();
      locale = await container.read(appLocaleProvider.future);
      expect(locale, equals(const Locale('de')));

      // Switch back to System Default
      await tester.tap(find.byKey(const Key('menu_language_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu_language_system')));
      await tester.pumpAndSettle();
      locale = await container.read(appLocaleProvider.future);
      expect(locale, isNull);
    });
  });
}

/// Test implementation of AppLocale for overriding initial state
class TestAppLocale extends AppLocale {
  TestAppLocale(this.initialLocale);

  final Locale? initialLocale;

  @override
  Future<Locale?> build() async {
    return initialLocale;
  }
}
