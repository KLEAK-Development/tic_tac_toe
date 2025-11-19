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
  /// Makes a move at the specified index (human player)
  /// After the human move, the computer automatically makes its move
  @override
  void makeMove(int index) {
    // Make human move
    final newState = state.makeMove(index);

    // If state didn't change, the move was invalid or game is over
    if (newState == state) {
      return;
    }

    state = newState;

    // If game is still playing, make computer move
    if (state.status == GameStatus.playing) {
      _makeComputerMove();
    }
  }

  /// Makes the computer's move automatically
  void _makeComputerMove() {
    final computerPlayer = Player.o;

    // Find the best move for the computer
    final computerMoveIndex = findComputerMove(state.board, computerPlayer);

    // Make computer move
    state = state.makeMove(computerMoveIndex);
  }
}
