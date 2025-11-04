import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/core/providers/theme_mode_provider.dart';

void main() {
  group('AppThemeMode Provider -', () {
    test('initial state is ThemeMode.system', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final themeMode = container.read(appThemeModeProvider);

      expect(themeMode, equals(ThemeMode.system));
    });

    test('setThemeMode updates state to light mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(appThemeModeProvider.notifier)
          .setThemeMode(ThemeMode.light);

      final themeMode = container.read(appThemeModeProvider);

      expect(themeMode, equals(ThemeMode.light));
    });

    test('setThemeMode updates state to dark mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(appThemeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      final themeMode = container.read(appThemeModeProvider);

      expect(themeMode, equals(ThemeMode.dark));
    });

    test('setThemeMode can switch between modes multiple times', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appThemeModeProvider.notifier);

      notifier.setThemeMode(ThemeMode.light);
      expect(container.read(appThemeModeProvider), equals(ThemeMode.light));

      notifier.setThemeMode(ThemeMode.dark);
      expect(container.read(appThemeModeProvider), equals(ThemeMode.dark));

      notifier.setThemeMode(ThemeMode.system);
      expect(container.read(appThemeModeProvider), equals(ThemeMode.system));
    });

    group('Widget Integration -', () {
      testWidgets('MaterialApp respects theme mode changes', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, _) {
                final themeMode = ref.watch(appThemeModeProvider);

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
        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, _) {
                final themeMode = ref.watch(appThemeModeProvider);

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
