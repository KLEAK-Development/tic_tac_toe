import 'dart:math' as math;

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

/// Finds the best move for the computer player
/// Strategy: Block player wins, otherwise pick random available cell
int findComputerMove(List<Player?> board, Player computerPlayer) {
  final humanPlayer = computerPlayer.opposite;

  // First, check if computer can win in the next move
  final winningMove = _findWinningMove(board, computerPlayer);
  if (winningMove != null) {
    return winningMove;
  }

  // Second, check if human player can win on their next move and block it
  final blockingMove = _findWinningMove(board, humanPlayer);
  if (blockingMove != null) {
    return blockingMove;
  }

  // Otherwise, pick a random available cell
  final availableMoves = <int>[];
  for (int i = 0; i < board.length; i++) {
    if (board.isValidMove(i)) {
      availableMoves.add(i);
    }
  }

  if (availableMoves.isEmpty) {
    throw StateError('No available moves on the board');
  }

  final random = math.Random();
  return availableMoves[random.nextInt(availableMoves.length)];
}

/// Helper function to find a winning move for the given player
/// Returns null if no winning move is available
int? _findWinningMove(List<Player?> board, Player player) {
  for (final combination in winningCombinations) {
    // Count how many cells in this combination the player occupies
    int playerCount = 0;
    int? emptyCell;

    for (final index in combination) {
      if (board[index] == player) {
        playerCount++;
      } else if (board[index] == null) {
        emptyCell = index;
      }
    }

    // If player has 2 cells and one is empty, that's a winning move
    if (playerCount == 2 && emptyCell != null) {
      return emptyCell;
    }
  }

  return null;
}
