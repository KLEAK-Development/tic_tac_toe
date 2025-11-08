import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/core/l10n/app_localizations.dart';
import 'package:tic_tac_toe/src/features/game_modes/two_player/presentation/two_player_game_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Shared GameScreen -', () {
    // Note: Uses TwoPlayerGameScreen to provide gameProvider override
    // Tests are mode-agnostic and verify shared GameScreen components
    Widget buildTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const TwoPlayerGameScreen(),
        ),
      );
    }

    group('GameScreen', () {
      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Verify screen renders
        expect(find.byType(TwoPlayerGameScreen), findsOneWidget);
      });

      testWidgets('displays status indicator', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byKey(const Key('game_status_indicator')), findsOneWidget);
      });

      testWidgets('displays all 9 game cells', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        for (int i = 0; i < 9; i++) {
          expect(find.byKey(Key('game_cell_$i')), findsOneWidget);
        }
      });

      testWidgets('displays reset button', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byKey(const Key('game_reset_button')), findsOneWidget);
      });

      testWidgets('reset button is disabled initially', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final button = tester.widget<ElevatedButton>(
          find.byKey(const Key('game_reset_button')),
        );

        expect(button.onPressed, isNull);
      });
    });

    group('GameCell', () {
      testWidgets('has minimum tap target size of 48x48', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Find the first cell container
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byKey(const Key('game_cell_0')),
                matching: find.byType(Container),
              )
              .first,
        );

        final constraints = container.constraints as BoxConstraints;
        expect(constraints.minHeight, equals(48));
        expect(constraints.minWidth, equals(48));
      });

      testWidgets('has semantic label for accessibility', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Check that the first cell has Semantics widgets for accessibility
        // (may be multiple due to ScrollView and other implicit semantics)
        final semantics = find.descendant(
          of: find.byKey(const Key('game_cell_0')),
          matching: find.byType(Semantics),
        );

        expect(semantics, findsWidgets);
      });

      testWidgets('cells are initially empty', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // No X or O symbols should be displayed initially
        expect(find.text('X'), findsNothing);
        expect(find.text('O'), findsNothing);
      });
    });

    group('GamePlay', () {
      testWidgets('allows moves on empty cells', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Tap first cell
        await tester.tap(find.byKey(const Key('game_cell_0')));
        await tester.pump();

        // X should appear
        expect(find.text('X'), findsOneWidget);
      });

      testWidgets('alternates between players', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // First move: X
        await tester.tap(find.byKey(const Key('game_cell_0')));
        await tester.pump();
        expect(find.text('X'), findsOneWidget);

        // Second move: O
        await tester.tap(find.byKey(const Key('game_cell_1')));
        await tester.pump();
        expect(find.text('O'), findsOneWidget);
      });

      testWidgets('enables reset button after first move', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Make a move
        await tester.tap(find.byKey(const Key('game_cell_0')));
        await tester.pump();

        final button = tester.widget<ElevatedButton>(
          find.byKey(const Key('game_reset_button')),
        );

        expect(button.onPressed, isNotNull);
      });
    });
  });
}
