import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/logic/game_logic.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_state.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_status.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/providers/game_provider.dart';

part 'game_provider.g.dart';

@riverpod
class TwoPlayerGame extends _$TwoPlayerGame
    with GameNotifierMixin
    implements GameNotifier {
  @override
  GameState build() {
    return GameState.initial();
  }

  /// Makes a move at the specified index
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

    // Create a new board with the move
    final newBoard = List<Player?>.from(state.board);
    newBoard[index] = state.currentPlayer;

    // Check for winner
    GameStatus newStatus = GameStatus.playing;
    if (newBoard.hasWinner(state.currentPlayer)) {
      newStatus = state.currentPlayer == Player.x
          ? GameStatus.xWins
          : GameStatus.oWins;
    } else if (newBoard.isDraw) {
      newStatus = GameStatus.draw;
    }

    // Update state
    state = state.copyWith(
      board: newBoard,
      currentPlayer: newStatus == GameStatus.playing
          ? state.currentPlayer.opposite
          : state.currentPlayer,
      status: newStatus,
    );
  }
}
