import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';

/// All possible winning combinations on a tic-tac-toe board
const List<List<int>> winningCombinations = [
  // Rows
  [0, 1, 2],
  [3, 4, 5],
  [6, 7, 8],
  // Columns
  [0, 3, 6],
  [1, 4, 7],
  [2, 5, 8],
  // Diagonals
  [0, 4, 8],
  [2, 4, 6],
];

/// Extension methods for game board operations
extension GameBoardExtension on List<Player?> {
  /// Checks if the given player has won the game
  bool hasWinner(Player player) {
    return winningCombinations.any((combination) {
      return combination.every((index) => this[index] == player);
    });
  }

  /// Checks if the game has not started (all cells are empty)
  bool get hasNotStarted {
    return every((cell) => cell == null);
  }

  /// Checks if the board is full (all cells are filled)
  bool get isFull {
    return every((cell) => cell != null);
  }

  /// Checks if the game is a draw (board is full and no winner)
  bool get isDraw {
    return isFull && !hasWinner(Player.x) && !hasWinner(Player.o);
  }

  /// Checks if a move is valid (cell is empty)
  bool isValidMove(int index) {
    if (index < 0 || index >= 9) {
      return false;
    }
    return this[index] == null;
  }
}
