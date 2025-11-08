import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/logic/game_logic.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';

void main() {
  group('findComputerMove', () {
    test('should take winning move when available', () {
      // Computer (O) can win at index 8
      final board = [
        Player.o, Player.x, Player.x, // 0, 1, 2
        Player.x, Player.o, Player.x, // 3, 4, 5
        null, null, null, // 6, 7, 8
      ];

      final move = findComputerMove(board, Player.o);
      expect(move, 8); // Diagonal win
    });

    test('should block human player from winning', () {
      // Human (X) can win at index 2, computer should block
      final board = [
        Player.x, Player.x, null, // 0, 1, 2
        Player.o, null, null, // 3, 4, 5
        null, null, null, // 6, 7, 8
      ];

      final move = findComputerMove(board, Player.o);
      expect(move, 2); // Block the win
    });

    test('should prioritize winning over blocking', () {
      // Computer (O) can win at 6 (diagonal 2-4-6), human (X) can win at 2 (row 0-1-2)
      final board = [
        Player.x, Player.x, null, // 0, 1, 2
        null, Player.o, null, // 3, 4, 5
        Player.o, null, null, // 6, 7, 8
      ];

      final move = findComputerMove(board, Player.o);
      expect(move, 2); // Take the win on diagonal 2-4-6 (not 6, it's 2!)
    });

    test('should pick any available move when no win or block needed', () {
      final board = [
        Player.x, null, null, // 0, 1, 2
        null, null, null, // 3, 4, 5
        null, null, null, // 6, 7, 8
      ];

      final move = findComputerMove(board, Player.o);
      // Should return any valid index (1-8)
      expect(move, greaterThanOrEqualTo(1));
      expect(move, lessThanOrEqualTo(8));
      expect(board[move], isNull);
    });

    test('should block column win', () {
      // X can win in column 0 at index 6
      final board = [
        Player.x, null, null, // 0, 1, 2
        Player.x, Player.o, null, // 3, 4, 5
        null, null, Player.o, // 6, 7, 8
      ];

      final move = findComputerMove(board, Player.o);
      expect(move, 6); // Block column
    });

    test('should block diagonal win', () {
      // X can win diagonal at index 4
      final board = [
        Player.x, null, null, // 0, 1, 2
        null, null, Player.o, // 3, 4, 5
        null, null, Player.x, // 6, 7, 8
      ];

      final move = findComputerMove(board, Player.o);
      expect(move, 4); // Block diagonal
    });

    test('should throw when board is full', () {
      final board = [
        Player.x, Player.o, Player.x,
        Player.x, Player.o, Player.o,
        Player.o, Player.x, Player.x,
      ];

      expect(
        () => findComputerMove(board, Player.o),
        throwsA(isA<StateError>()),
      );
    });
  });
}
