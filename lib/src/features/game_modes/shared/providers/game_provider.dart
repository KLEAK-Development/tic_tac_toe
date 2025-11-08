import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_state.dart';

/// Mixin providing shared game notifier functionality
/// Provides resetGame() implementation for all game modes
mixin GameNotifierMixin {
  /// The current game state - must be provided by the class using this mixin
  set state(GameState value);

  /// Resets the game to initial state
  void resetGame() {
    state = GameState.initial();
  }
}

/// Abstract base class for game notifiers
/// All game mode implementations must implement this interface
abstract class GameNotifier extends Notifier<GameState> {
  /// Makes a move at the specified index
  void makeMove(int index);

  /// Resets the game to initial state
  void resetGame();
}

/// Generic game provider that will be overridden by specific game modes
/// This allows the UI to be completely reusable across different game modes
final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  throw UnimplementedError(
    'gameProvider must be overridden with a specific game mode implementation',
  );
});
