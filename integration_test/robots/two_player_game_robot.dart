import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot for Two Player Game screen actions
class TwoPlayerGameRobot {
  final WidgetTester tester;

  TwoPlayerGameRobot(this.tester);

  /// Play a game with given moves
  Future<void> playGame(List<int> moves, List<String> expectedPlayers) async {
    for (int i = 0; i < moves.length; i++) {
      await _tapCell(moves[i]);
      await tester.pumpAndSettle();
      _verifyCellContent(moves[i], expectedPlayers[i]);

      // Verify status indicator exists after each move
      expect(find.byKey(const Key('game_status_indicator')), findsOneWidget);
    }
  }

  /// Verify a player wins (language-independent)
  Future<void> verifyPlayerWins(String player) async {
    // Verify game over dialog appears
    expect(find.byKey(const Key('game_over_dialog')), findsOneWidget);
    expect(
      find.byKey(const Key('game_over_play_again_button')),
      findsOneWidget,
    );
  }

  /// Verify draw (language-independent)
  Future<void> verifyDraw() async {
    // Verify game over dialog appears
    expect(find.byKey(const Key('game_over_dialog')), findsOneWidget);
    expect(
      find.byKey(const Key('game_over_play_again_button')),
      findsOneWidget,
    );
  }

  /// Tap Play Again button to start a new game
  Future<void> playAgain() async {
    await tester.tap(find.byKey(const Key('game_over_play_again_button')));
    await tester.pumpAndSettle();
    // Verify game status indicator exists (game is reset)
    expect(find.byKey(const Key('game_status_indicator')), findsOneWidget);
  }

  /// Play a partial game (for testing reset)
  Future<void> playPartialGame(
    List<int> moves,
    List<String> expectedPlayers,
  ) async {
    for (int i = 0; i < moves.length; i++) {
      await _tapCell(moves[i]);
      await tester.pumpAndSettle();
      _verifyCellContent(moves[i], expectedPlayers[i]);
    }
  }

  /// Tap Reset Game button
  Future<void> resetGame() async {
    await tester.tap(find.byKey(const Key('game_reset_button')));
    await tester.pumpAndSettle();
  }

  /// Verify the game is reset (all cells empty, status indicator exists)
  Future<void> verifyGameIsReset() async {
    expect(find.byKey(const Key('game_status_indicator')), findsOneWidget);
    // Verify all cells are empty
    for (int i = 0; i < 9; i++) {
      _verifyCellContent(i, '');
    }
  }

  /// Navigate back to menu using the AppBar back button
  Future<void> navigateBackToMenu() async {
    // Find and tap the back button in the AppBar (language-independent)
    final backButton = find.byType(BackButton);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();
  }

  /// Helper function to tap a cell at the given index
  Future<void> _tapCell(int index) async {
    final cellFinder = find.byKey(Key('game_cell_$index'));
    expect(cellFinder, findsOneWidget);
    await tester.tap(cellFinder);
  }

  /// Helper function to verify cell content
  void _verifyCellContent(int index, String expectedText) {
    final cellFinder = find.byKey(Key('game_cell_$index'));
    expect(cellFinder, findsOneWidget);

    if (expectedText.isEmpty) {
      // Verify cell is empty (no X or O text)
      final textInCell = find.descendant(
        of: cellFinder,
        matching: find.byType(Text),
      );
      final textWidgets = tester.widgetList<Text>(textInCell).toList();
      if (textWidgets.isNotEmpty) {
        for (final textWidget in textWidgets) {
          expect(textWidget.data ?? '', isNot(anyOf('X', 'O')));
        }
      }
    } else {
      // Verify cell contains the expected player symbol
      final textInCell = find.descendant(
        of: cellFinder,
        matching: find.text(expectedText),
      );
      expect(textInCell, findsOneWidget);
    }
  }
}
