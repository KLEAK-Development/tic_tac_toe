import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_state.dart';
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
    state = state.makeMove(index);
  }
}
