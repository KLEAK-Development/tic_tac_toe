import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/core/database/app_database.dart';
import 'package:tic_tac_toe/src/core/providers/database_provider.dart';
import 'package:tic_tac_toe/src/features/theme_settings/provider/theme_mode_provider.dart';

void main() {
  group('AppThemeMode Provider -', () {
    ProviderContainer makeContainer() {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      return ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
    }

    test('initial state is ThemeMode.system', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final themeMode = container.read(effectiveThemeModeProvider);

      expect(themeMode, equals(ThemeMode.system));
    });

    test('setThemeMode updates state to light mode', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      container
          .read(appThemeModeProvider.notifier)
          .setThemeMode(ThemeMode.light);

      final themeMode = container.read(effectiveThemeModeProvider);

      expect(themeMode, equals(ThemeMode.light));
    });

    test('setThemeMode updates state to dark mode', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      container
          .read(appThemeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      final themeMode = container.read(effectiveThemeModeProvider);

      expect(themeMode, equals(ThemeMode.dark));
    });

    test('setThemeMode can switch between modes multiple times', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appThemeModeProvider.notifier);

      notifier.setThemeMode(ThemeMode.light);
      expect(
        container.read(effectiveThemeModeProvider),
        equals(ThemeMode.light),
      );

      notifier.setThemeMode(ThemeMode.dark);
      expect(
        container.read(effectiveThemeModeProvider),
        equals(ThemeMode.dark),
      );

      notifier.setThemeMode(ThemeMode.system);
      expect(
        container.read(effectiveThemeModeProvider),
        equals(ThemeMode.system),
      );
    });

    group('Widget Integration -', () {
      testWidgets('MaterialApp respects theme mode changes', (tester) async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [appDatabaseProvider.overrideWithValue(db)],
            child: Consumer(
              builder: (context, ref, _) {
                final themeMode = ref.watch(effectiveThemeModeProvider);

                return MaterialApp(
                  themeMode: themeMode,
                  theme: ThemeData.light(),
                  darkTheme: ThemeData.dark(),
                  home: Scaffold(
                    body: ElevatedButton(
                      key: const Key('theme_toggle'),
                      onPressed: () {
                        ref
                            .read(appThemeModeProvider.notifier)
                            .setThemeMode(ThemeMode.dark);
                      },
                      child: const Text('Toggle Theme'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Initial theme should be system
        final MaterialApp initialApp = tester.widget(find.byType(MaterialApp));
        expect(initialApp.themeMode, equals(ThemeMode.system));

        // Tap button to change to dark mode
        await tester.tap(find.byKey(const Key('theme_toggle')));
        await tester.pumpAndSettle();

        // Theme should now be dark
        final MaterialApp updatedApp = tester.widget(find.byType(MaterialApp));
        expect(updatedApp.themeMode, equals(ThemeMode.dark));
      });

      testWidgets('theme mode persists across rebuilds', (tester) async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [appDatabaseProvider.overrideWithValue(db)],
            child: Consumer(
              builder: (context, ref, _) {
                final themeMode = ref.watch(effectiveThemeModeProvider);

                return MaterialApp(
                  themeMode: themeMode,
                  home: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(appThemeModeProvider.notifier)
                          .setThemeMode(ThemeMode.light);
                    },
                    child: const Text('Set Light'),
                  ),
                );
              },
            ),
          ),
        );

        // Initially system theme
        final MaterialApp initialApp = tester.widget(find.byType(MaterialApp));
        expect(initialApp.themeMode, equals(ThemeMode.system));

        // Set to light theme
        await tester.tap(find.text('Set Light'));
        await tester.pumpAndSettle();

        // Theme should be light
        final MaterialApp updatedApp = tester.widget(find.byType(MaterialApp));
        expect(updatedApp.themeMode, equals(ThemeMode.light));

        // Trigger a rebuild (hot reload simulation)
        await tester.pump();

        // Theme should still be light after rebuild
        final MaterialApp rebuiltApp = tester.widget(find.byType(MaterialApp));
        expect(rebuiltApp.themeMode, equals(ThemeMode.light));
      });
    });
  });
}
