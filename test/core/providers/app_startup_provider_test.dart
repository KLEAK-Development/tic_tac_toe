import 'dart:async';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/app.dart';
import 'package:tic_tac_toe/src/core/database/app_database.dart';
import 'package:tic_tac_toe/src/core/providers/app_startup_provider.dart';
import 'package:tic_tac_toe/src/core/providers/database_provider.dart';
import 'package:tic_tac_toe/src/shared/widgets/app_error_widget.dart';
import 'package:tic_tac_toe/src/shared/widgets/app_loading_widget.dart';

void main() {
  // Suppress Drift warning about multiple database instances in tests
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('App Startup Provider', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    testWidgets('shows loading widget during app initialization', (
      WidgetTester tester,
    ) async {
      // Create a completer to control when initialization completes
      final initCompleter = Completer<void>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            // Override to keep the provider in loading state
            appStartupProvider.overrideWith((ref) async {
              await initCompleter.future;
            }),
          ],
          child: const App(),
        ),
      );

      // First frame should show loading widget
      await tester.pump();

      // Verify AppLoadingWidget is displayed
      expect(find.byType(AppLoadingWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the initialization
      initCompleter.complete();
      await tester.pumpAndSettle();

      // Verify loading widget is gone and menu screen is shown
      expect(find.byType(AppLoadingWidget), findsNothing);
      expect(
        find.byKey(const Key('menu_two_player_game_button')),
        findsOneWidget,
      );
    });

    testWidgets('shows error widget when initialization fails', (
      WidgetTester tester,
    ) async {
      const errorMessage = 'Database initialization failed';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            // Override to simulate initialization error
            appStartupProvider.overrideWith((ref) async {
              throw Exception(errorMessage);
            }),
          ],
          child: const App(),
        ),
      );

      // Wait for the error to be thrown and handled
      await tester.pumpAndSettle();

      // Verify AppErrorWidget is displayed
      expect(find.byType(AppErrorWidget), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.textContaining(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('retry button reinitializes app after error', (
      WidgetTester tester,
    ) async {
      var shouldFail = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            // Override to simulate error then success on retry
            appStartupProvider.overrideWith((ref) async {
              if (shouldFail) {
                throw Exception('Initial failure');
              }
              // Success on retry
            }),
          ],
          child: const App(),
        ),
      );

      // Wait for the error to appear
      await tester.pumpAndSettle();

      // Verify error widget is shown
      expect(find.byType(AppErrorWidget), findsOneWidget);

      // Simulate fixing the error condition
      shouldFail = false;

      // Tap the retry button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify app successfully loads
      expect(find.byType(AppErrorWidget), findsNothing);
      expect(
        find.byKey(const Key('menu_two_player_game_button')),
        findsOneWidget,
      );
    });

    testWidgets('shows app content when initialization succeeds', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            // Normal successful initialization
            appStartupProvider.overrideWith((ref) async {
              // Simulate brief initialization
              await Future.delayed(const Duration(milliseconds: 10));
            }),
          ],
          child: const App(),
        ),
      );

      // First frame - loading
      await tester.pump();
      expect(find.byType(AppLoadingWidget), findsOneWidget);

      // Wait for initialization to complete
      await tester.pumpAndSettle();

      // Verify loading is gone and menu screen is shown
      expect(find.byType(AppLoadingWidget), findsNothing);
      expect(find.byType(AppErrorWidget), findsNothing);
      expect(
        find.byKey(const Key('menu_two_player_game_button')),
        findsOneWidget,
      );
    });

    testWidgets('loading screen appears before any app content', (
      WidgetTester tester,
    ) async {
      // Track frames to verify loading screen is first
      final frames = <String>[];
      final initCompleter = Completer<void>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            appStartupProvider.overrideWith((ref) async {
              await initCompleter.future;
            }),
          ],
          child: Builder(
            builder: (context) {
              return const App();
            },
          ),
        ),
      );

      // Frame 1: Initial pump - should show loading
      await tester.pump();
      final hasLoading = find.byType(AppLoadingWidget).evaluate().isNotEmpty;
      final hasMenuButton = find
          .byKey(const Key('menu_two_player_game_button'))
          .evaluate()
          .isNotEmpty;

      if (hasLoading) frames.add('loading');
      if (hasMenuButton) frames.add('menu');

      // Complete initialization
      initCompleter.complete();
      await tester.pumpAndSettle();

      // Frame 2: After initialization - should show menu
      final hasLoadingAfter =
          find.byType(AppLoadingWidget).evaluate().isNotEmpty;
      final hasMenuButtonAfter = find
          .byKey(const Key('menu_two_player_game_button'))
          .evaluate()
          .isNotEmpty;

      if (hasLoadingAfter) {
        frames.add('loading');
      }
      if (hasMenuButtonAfter) {
        frames.add('menu');
      }

      // Verify sequence: loading appears first, then menu
      expect(frames, equals(['loading', 'menu']));
      expect(hasLoading, isTrue, reason: 'Loading should appear first');
      expect(hasMenuButton, isFalse, reason: 'Menu should not appear during loading');
      expect(hasLoadingAfter, isFalse, reason: 'Loading should disappear after init');
      expect(hasMenuButtonAfter, isTrue, reason: 'Menu should appear after init');
    });
  });
}
