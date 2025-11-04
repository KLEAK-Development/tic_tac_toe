import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_status.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';

void main() {
  group('GameStatus', () {
    group('isGameOver', () {
      test('returns false for playing', () {
        expect(GameStatus.playing.isGameOver, isFalse);
      });

      test('returns true for xWins', () {
        expect(GameStatus.xWins.isGameOver, isTrue);
      });

      test('returns true for oWins', () {
        expect(GameStatus.oWins.isGameOver, isTrue);
      });

      test('returns true for draw', () {
        expect(GameStatus.draw.isGameOver, isTrue);
      });
    });

    group('winner', () {
      test('returns Player.x for xWins', () {
        expect(GameStatus.xWins.winner, equals(Player.x));
      });

      test('returns Player.o for oWins', () {
        expect(GameStatus.oWins.winner, equals(Player.o));
      });

      test('returns null for playing', () {
        expect(GameStatus.playing.winner, isNull);
      });

      test('returns null for draw', () {
        expect(GameStatus.draw.winner, isNull);
      });
    });
  });
}
