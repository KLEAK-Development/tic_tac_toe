import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot for Game screen actions (works for both single-player and two-player)
class GameRobot {
  final WidgetTester tester;

  GameRobot(this.tester);

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
  /// Handles game over dialog if present by clicking Play Again
  Future<void> navigateBackToMenu() async {
    // Check if game over dialog is showing
    final gameOverDialog = find.byKey(const Key('game_over_dialog'));
    if (tester.widgetList(gameOverDialog).isNotEmpty) {
      // Dialog is showing - use playAgain to close it and reset game
      await playAgain();
    }

    // Now tap back button to go to menu
    final backButton = find.byType(BackButton);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  // ========== Single-Player Mode Methods ==========

  /// Make a human move in single-player mode (waits for computer response)
  Future<void> makeHumanMove(int index) async {
    // Tap the cell (human move)
    await _tapCell(index);
    await tester.pumpAndSettle();

    // Verify human move (X) was placed
    _verifyCellContent(index, 'X');

    // Wait a bit more to ensure computer has responded
    await tester.pumpAndSettle();

    // Verify status indicator still exists
    expect(find.byKey(const Key('game_status_indicator')), findsOneWidget);
  }

  /// Verify that the computer has responded (at least one O on the board)
  void verifyComputerResponded() {
    bool foundO = false;
    for (int i = 0; i < 9; i++) {
      final cellFinder = find.byKey(Key('game_cell_$i'));
      final textInCell = find.descendant(
        of: cellFinder,
        matching: find.text('O'),
      );
      if (tester.widgetList(textInCell).isNotEmpty) {
        foundO = true;
        break;
      }
    }
    expect(foundO, true, reason: 'Computer should have made a move (O)');
  }

  /// Verify computer blocked at a specific cell
  void verifyComputerBlockedAt(int index) {
    _verifyCellContent(index, 'O');
  }

  /// Verify the entire board state
  void verifyBoardState(List<String> expected) {
    expect(expected.length, 9, reason: 'Board state must have 9 cells');
    for (int i = 0; i < 9; i++) {
      _verifyCellContent(i, expected[i]);
    }
  }

  /// Get the current board state (returns list of 9 cells: 'X', 'O', or '')
  List<String> getBoardState() {
    final state = <String>[];
    for (int i = 0; i < 9; i++) {
      final cellFinder = find.byKey(Key('game_cell_$i'));

      // Check for X
      final xFinder = find.descendant(
        of: cellFinder,
        matching: find.text('X'),
      );
      if (tester.widgetList(xFinder).isNotEmpty) {
        state.add('X');
        continue;
      }

      // Check for O
      final oFinder = find.descendant(
        of: cellFinder,
        matching: find.text('O'),
      );
      if (tester.widgetList(oFinder).isNotEmpty) {
        state.add('O');
        continue;
      }

      // Cell is empty
      state.add('');
    }
    return state;
  }

  /// Check if a specific cell is empty
  bool isCellEmpty(int index) {
    final cellFinder = find.byKey(Key('game_cell_$index'));

    final xFinder = find.descendant(
      of: cellFinder,
      matching: find.text('X'),
    );
    final oFinder = find.descendant(
      of: cellFinder,
      matching: find.text('O'),
    );

    return tester.widgetList(xFinder).isEmpty &&
        tester.widgetList(oFinder).isEmpty;
  }

  /// Find the first empty cell on the board (returns -1 if board is full)
  int findEmptyCell() {
    for (int i = 0; i < 9; i++) {
      if (isCellEmpty(i)) {
        return i;
      }
    }
    return -1;
  }

  /// Make a human move at the first available cell from the list
  /// Returns the index where the move was made, or -1 if none available
  Future<int> makeHumanMoveAtFirstAvailable(List<int> preferredCells) async {
    for (final cellIndex in preferredCells) {
      if (isCellEmpty(cellIndex)) {
        await makeHumanMove(cellIndex);
        return cellIndex;
      }
    }
    return -1;
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
