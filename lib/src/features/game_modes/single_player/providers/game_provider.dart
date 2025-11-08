import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/logic/game_logic.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_state.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_status.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/providers/game_provider.dart';

part 'game_provider.g.dart';

@riverpod
class SinglePlayerGame extends _$SinglePlayerGame
    with GameNotifierMixin
    implements GameNotifier {
  @override
  GameState build() {
    return GameState.initial();
  }

  /// Makes a move at the specified index (human player)
  /// After the human move, the computer automatically makes its move
  @override
  void makeMove(int index) {
    // Only allow moves if game is still playing
    if (state.status != GameStatus.playing) {
      return;
    }

    // Validate the move
    if (!state.board.isValidMove(index)) {
      return;
    }

    // Human player is always X (goes first)
    final humanPlayer = Player.x;
    final computerPlayer = Player.o;

    // Create a new board with the human's move
    final newBoard = List<Player?>.from(state.board);
    newBoard[index] = humanPlayer;

    // Check for winner after human move
    GameStatus newStatus = GameStatus.playing;
    if (newBoard.hasWinner(humanPlayer)) {
      newStatus = GameStatus.xWins;
    } else if (newBoard.isDraw) {
      newStatus = GameStatus.draw;
    }

    // Update state with human's move
    state = state.copyWith(
      board: newBoard,
      currentPlayer: newStatus == GameStatus.playing
          ? computerPlayer
          : humanPlayer,
      status: newStatus,
    );

    // If game is still playing, make computer move
    if (state.status == GameStatus.playing) {
      _makeComputerMove();
    }
  }

  /// Makes the computer's move automatically
  void _makeComputerMove() {
    final computerPlayer = Player.o;
    final humanPlayer = Player.x;

    // Find the best move for the computer
    final computerMoveIndex = findComputerMove(state.board, computerPlayer);

    // Create a new board with the computer's move
    final newBoard = List<Player?>.from(state.board);
    newBoard[computerMoveIndex] = computerPlayer;

    // Check for winner after computer move
    GameStatus newStatus = GameStatus.playing;
    if (newBoard.hasWinner(computerPlayer)) {
      newStatus = GameStatus.oWins;
    } else if (newBoard.isDraw) {
      newStatus = GameStatus.draw;
    }

    // Update state with computer's move
    state = state.copyWith(
      board: newBoard,
      currentPlayer: newStatus == GameStatus.playing
          ? humanPlayer
          : computerPlayer,
      status: newStatus,
    );
  }
}
