// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/app.dart';
import 'package:tic_tac_toe/src/core/database/app_database.dart';
import 'package:tic_tac_toe/src/core/providers/app_startup_provider.dart';
import 'package:tic_tac_toe/src/core/providers/database_provider.dart';

void main() {
  testWidgets('Menu screen displays new game button and controls', (
    WidgetTester tester,
  ) async {
    // Create in-memory database for testing
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async => await database.close());

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          // Skip app startup initialization in tests
          appStartupProvider.overrideWith((ref) async {}),
        ],
        child: const App(),
      ),
    );

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that our menu screen displays the new game button
    expect(
      find.byKey(const Key('menu_two_player_game_button')),
      findsOneWidget,
    );

    // Verify that the language selector and theme toggle are present in the AppBar
    expect(find.byKey(const Key('menu_language_button')), findsOneWidget);
    expect(find.byKey(const Key('menu_theme_button')), findsOneWidget);
  });
}
