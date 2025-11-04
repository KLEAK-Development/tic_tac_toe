import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/core/l10n/app_localizations.dart';
import 'package:tic_tac_toe/src/core/providers/theme_mode_provider.dart';
import 'package:tic_tac_toe/src/features/theme_settings/presentation/widgets/theme_mode_selector.dart';

void main() {
  group('ThemeModeSelector', () {
    Widget buildTestWidget({ThemeMode? initialThemeMode}) {
      return ProviderScope(
        overrides: [
          // Override the provider to start with a specific theme mode
          if (initialThemeMode != null)
            appThemeModeProvider.overrideWith(
              () => TestAppThemeMode(initialThemeMode),
            ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: AppBar(actions: const [ThemeModeSelector()]),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'displays checkmark on System Default when theme mode is system',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(initialThemeMode: ThemeMode.system),
        );

        // Open theme menu
        await tester.tap(find.byKey(const Key('menu_theme_button')));
        await tester.pumpAndSettle();

        // Find System Default menu item and verify it has a checkmark
        final systemDefaultItem = find.byKey(const Key('menu_theme_system'));
        expect(systemDefaultItem, findsOneWidget);

        // Verify checkmark icon is present (CheckableMenuItem shows Icon when selected)
        final checkmarkInSystemDefault = find.descendant(
          of: systemDefaultItem,
          matching: find.byIcon(Icons.check),
        );
        expect(checkmarkInSystemDefault, findsOneWidget);
      },
    );

    testWidgets('displays checkmark on Light when theme mode is light', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(initialThemeMode: ThemeMode.light),
      );

      // Open theme menu
      await tester.tap(find.byKey(const Key('menu_theme_button')));
      await tester.pumpAndSettle();

      // Verify Light has checkmark
      final lightItem = find.byKey(const Key('menu_theme_light'));
      expect(lightItem, findsOneWidget);

      final checkmarkInLight = find.descendant(
        of: lightItem,
        matching: find.byIcon(Icons.check),
      );
      expect(checkmarkInLight, findsOneWidget);

      // Verify System Default does NOT have checkmark
      final systemDefaultItem = find.byKey(const Key('menu_theme_system'));
      final checkmarkInSystemDefault = find.descendant(
        of: systemDefaultItem,
        matching: find.byIcon(Icons.check),
      );
      expect(checkmarkInSystemDefault, findsNothing);
    });

    testWidgets('displays checkmark on Dark when theme mode is dark', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(initialThemeMode: ThemeMode.dark),
      );

      // Open theme menu
      await tester.tap(find.byKey(const Key('menu_theme_button')));
      await tester.pumpAndSettle();

      // Verify Dark has checkmark
      final darkItem = find.byKey(const Key('menu_theme_dark'));
      expect(darkItem, findsOneWidget);

      final checkmarkInDark = find.descendant(
        of: darkItem,
        matching: find.byIcon(Icons.check),
      );
      expect(checkmarkInDark, findsOneWidget);

      // Verify System Default does NOT have checkmark
      final systemDefaultItem = find.byKey(const Key('menu_theme_system'));
      final checkmarkInSystemDefault = find.descendant(
        of: systemDefaultItem,
        matching: find.byIcon(Icons.check),
      );
      expect(checkmarkInSystemDefault, findsNothing);
    });

    testWidgets('can switch from System Default to Light', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: AppBar(actions: const [ThemeModeSelector()]),
              ),
            ),
          ),
        ),
      );

      // Initially should be system (default)
      expect(container.read(appThemeModeProvider), equals(ThemeMode.system));

      // Open theme menu
      await tester.tap(find.byKey(const Key('menu_theme_button')));
      await tester.pumpAndSettle();

      // Tap Light
      await tester.tap(find.byKey(const Key('menu_theme_light')));
      await tester.pumpAndSettle();

      // Verify theme mode changed to Light
      expect(container.read(appThemeModeProvider), equals(ThemeMode.light));
    });

    testWidgets('can switch from Light to Dark', (tester) async {
      final container = ProviderContainer(
        overrides: [
          appThemeModeProvider.overrideWith(
            () => TestAppThemeMode(ThemeMode.light),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: AppBar(actions: const [ThemeModeSelector()]),
              ),
            ),
          ),
        ),
      );

      // Initially should be Light
      expect(container.read(appThemeModeProvider), equals(ThemeMode.light));

      // Open theme menu
      await tester.tap(find.byKey(const Key('menu_theme_button')));
      await tester.pumpAndSettle();

      // Tap Dark
      await tester.tap(find.byKey(const Key('menu_theme_dark')));
      await tester.pumpAndSettle();

      // Verify theme mode changed to Dark
      expect(container.read(appThemeModeProvider), equals(ThemeMode.dark));
    });

    testWidgets('can switch from Dark back to System Default', (tester) async {
      final container = ProviderContainer(
        overrides: [
          appThemeModeProvider.overrideWith(
            () => TestAppThemeMode(ThemeMode.dark),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: AppBar(actions: const [ThemeModeSelector()]),
              ),
            ),
          ),
        ),
      );

      // Initially should be Dark
      expect(container.read(appThemeModeProvider), equals(ThemeMode.dark));

      // Open theme menu
      await tester.tap(find.byKey(const Key('menu_theme_button')));
      await tester.pumpAndSettle();

      // Tap System Default
      await tester.tap(find.byKey(const Key('menu_theme_system')));
      await tester.pumpAndSettle();

      // Verify theme mode changed to System
      expect(container.read(appThemeModeProvider), equals(ThemeMode.system));
    });

    testWidgets('can switch between all theme modes', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: AppBar(actions: const [ThemeModeSelector()]),
              ),
            ),
          ),
        ),
      );

      // Switch to Light
      await tester.tap(find.byKey(const Key('menu_theme_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu_theme_light')));
      await tester.pumpAndSettle();
      expect(container.read(appThemeModeProvider), equals(ThemeMode.light));

      // Switch to Dark
      await tester.tap(find.byKey(const Key('menu_theme_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu_theme_dark')));
      await tester.pumpAndSettle();
      expect(container.read(appThemeModeProvider), equals(ThemeMode.dark));

      // Switch back to System
      await tester.tap(find.byKey(const Key('menu_theme_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu_theme_system')));
      await tester.pumpAndSettle();
      expect(container.read(appThemeModeProvider), equals(ThemeMode.system));
    });
  });
}

/// Test implementation of AppThemeMode for overriding initial state
class TestAppThemeMode extends AppThemeMode {
  TestAppThemeMode(this.initialThemeMode);

  final ThemeMode initialThemeMode;

  @override
  ThemeMode build() {
    return initialThemeMode;
  }
}
