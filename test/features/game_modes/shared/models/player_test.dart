import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';

void main() {
  group('Player', () {
    group('symbol', () {
      test('returns "X" for Player.x', () {
        expect(Player.x.symbol, equals('X'));
      });

      test('returns "O" for Player.o', () {
        expect(Player.o.symbol, equals('O'));
      });
    });

    group('opposite', () {
      test('returns Player.o for Player.x', () {
        expect(Player.x.opposite, equals(Player.o));
      });

      test('returns Player.x for Player.o', () {
        expect(Player.o.opposite, equals(Player.x));
      });
    });
  });
}
