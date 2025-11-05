import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/core/database/app_database.dart';
import 'package:tic_tac_toe/src/core/l10n/app_localizations.dart';
import 'package:tic_tac_toe/src/core/providers/database_provider.dart';
import 'package:tic_tac_toe/src/features/menu/presentation/menu_screen.dart';

void main() {
  group('MenuScreen', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MenuScreen(),
        ),
      );
    }

    testWidgets('displays app title, theme selector, and language selector', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      // Verify app title is displayed
      expect(find.byKey(const Key('menu_app_title')), findsOneWidget);

      // Verify theme selector button is displayed
      expect(find.byKey(const Key('menu_theme_button')), findsOneWidget);

      // Verify language selector button is displayed
      expect(find.byKey(const Key('menu_language_button')), findsOneWidget);

      // Verify new game button is displayed
      expect(
        find.byKey(const Key('menu_two_player_game_button')),
        findsOneWidget,
      );
    });
  });
}
