import 'package:tic_tac_toe/src/features/game_modes/shared/logic/game_logic.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_status.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';

class GameState {
  /// The game board - a 3x3 grid represented as a list of 9 cells
  /// Index mapping: 0-2 (top row), 3-5 (middle row), 6-8 (bottom row)
  final List<Player?> board;

  /// The player whose turn it is
  final Player currentPlayer;

  /// The current status of the game
  final GameStatus status;

  const GameState({
    required this.board,
    required this.currentPlayer,
    required this.status,
  });

  /// Creates a new game with an empty board
  factory GameState.initial() {
    return GameState(
      board: List.filled(9, null),
      currentPlayer: Player.x,
      status: GameStatus.playing,
    );
  }

  /// Creates a copy of this state with updated fields
  GameState copyWith({
    List<Player?>? board,
    Player? currentPlayer,
    GameStatus? status,
  }) {
    return GameState(
      board: board ?? List.from(this.board),
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
    );
  }

  /// Makes a move at the specified index and returns the new state
  /// Returns the current state if the move is invalid or game is over
  GameState makeMove(int index) {
    // Only allow moves if game is still playing
    if (status != GameStatus.playing) {
      return this;
    }

    // Validate the move
    if (!board.isValidMove(index)) {
      return this;
    }

    // Create a new board with the move
    final newBoard = List<Player?>.from(board);
    newBoard[index] = currentPlayer;

    // Check for winner
    GameStatus newStatus = GameStatus.playing;
    if (newBoard.hasWinner(currentPlayer)) {
      newStatus = currentPlayer == Player.x
          ? GameStatus.xWins
          : GameStatus.oWins;
    } else if (newBoard.isDraw) {
      newStatus = GameStatus.draw;
    }

    // Return new state
    return copyWith(
      board: newBoard,
      currentPlayer: newStatus == GameStatus.playing
          ? currentPlayer.opposite
          : currentPlayer,
      status: newStatus,
    );
  }
}
