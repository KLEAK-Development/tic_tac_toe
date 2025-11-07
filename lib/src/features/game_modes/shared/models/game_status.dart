import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';

enum GameStatus {
  playing,
  xWins,
  oWins,
  draw;

  /// Returns true if the game is over
  bool get isGameOver {
    return this != GameStatus.playing;
  }

  /// Returns the winner, or null if no winner
  Player? get winner {
    return switch (this) {
      GameStatus.xWins => Player.x,
      GameStatus.oWins => Player.o,
      GameStatus.playing || GameStatus.draw => null,
    };
  }
}
