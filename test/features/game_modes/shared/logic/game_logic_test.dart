import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/logic/game_logic.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';

void main() {
  group('GameBoardExtension', () {
    group('hasWinner', () {
      test('returns true for X winning in top row', () {
        final board = <Player?>[
          Player.x,
          Player.x,
          Player.x,
          Player.o,
          Player.o,
          null,
          null,
          null,
          null,
        ];
        expect(board.hasWinner(Player.x), isTrue);
      });

      test('returns true for X winning in middle row', () {
        final board = <Player?>[
          Player.o,
          Player.o,
          null,
          Player.x,
          Player.x,
          Player.x,
          null,
          null,
          null,
        ];
        expect(board.hasWinner(Player.x), isTrue);
      });

      test('returns true for X winning in bottom row', () {
        final board = <Player?>[
          Player.o,
          Player.o,
          null,
          null,
          null,
          null,
          Player.x,
          Player.x,
          Player.x,
        ];
        expect(board.hasWinner(Player.x), isTrue);
      });

      test('returns true for O winning in left column', () {
        final board = <Player?>[
          Player.o,
          Player.x,
          Player.x,
          Player.o,
          Player.x,
          null,
          Player.o,
          null,
          null,
        ];
        expect(board.hasWinner(Player.o), isTrue);
      });

      test('returns true for O winning in middle column', () {
        final board = <Player?>[
          Player.x,
          Player.o,
          Player.x,
          null,
          Player.o,
          null,
          null,
          Player.o,
          null,
        ];
        expect(board.hasWinner(Player.o), isTrue);
      });

      test('returns true for O winning in right column', () {
        final board = <Player?>[
          Player.x,
          Player.x,
          Player.o,
          null,
          null,
          Player.o,
          null,
          null,
          Player.o,
        ];
        expect(board.hasWinner(Player.o), isTrue);
      });

      test(
        'returns true for X winning in top-left to bottom-right diagonal',
        () {
          final board = <Player?>[
            Player.x,
            Player.o,
            Player.o,
            null,
            Player.x,
            null,
            null,
            null,
            Player.x,
          ];
          expect(board.hasWinner(Player.x), isTrue);
        },
      );

      test(
        'returns true for O winning in top-right to bottom-left diagonal',
        () {
          final board = <Player?>[
            Player.x,
            Player.x,
            Player.o,
            null,
            Player.o,
            null,
            Player.o,
            null,
            null,
          ];
          expect(board.hasWinner(Player.o), isTrue);
        },
      );

      test('returns false for empty board', () {
        final board = <Player?>[
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
        ];
        expect(board.hasWinner(Player.x), isFalse);
        expect(board.hasWinner(Player.o), isFalse);
      });

      test('returns false for partial board with no winner', () {
        final board = <Player?>[
          Player.x,
          Player.o,
          Player.x,
          Player.o,
          null,
          null,
          null,
          null,
          null,
        ];
        expect(board.hasWinner(Player.x), isFalse);
        expect(board.hasWinner(Player.o), isFalse);
      });

      test('returns false for full board with no winner (draw)', () {
        final board = <Player?>[
          Player.x,
          Player.o,
          Player.x,
          Player.x,
          Player.o,
          Player.o,
          Player.o,
          Player.x,
          Player.x,
        ];
        expect(board.hasWinner(Player.x), isFalse);
        expect(board.hasWinner(Player.o), isFalse);
      });
    });

    group('isValidMove', () {
      test('returns true for valid move on empty cell', () {
        final board = <Player?>[
          Player.x,
          Player.o,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
        ];
        expect(board.isValidMove(2), isTrue);
        expect(board.isValidMove(5), isTrue);
        expect(board.isValidMove(8), isTrue);
      });

      test('returns false for move on occupied cell', () {
        final board = <Player?>[
          Player.x,
          Player.o,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
        ];
        expect(board.isValidMove(0), isFalse);
        expect(board.isValidMove(1), isFalse);
      });

      test('returns false for negative index', () {
        final board = <Player?>[
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
        ];
        expect(board.isValidMove(-1), isFalse);
        expect(board.isValidMove(-5), isFalse);
      });

      test('returns false for index >= 9', () {
        final board = <Player?>[
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
        ];
        expect(board.isValidMove(9), isFalse);
        expect(board.isValidMove(10), isFalse);
        expect(board.isValidMove(100), isFalse);
      });
    });

    group('isFull', () {
      test('returns false for empty board', () {
        final board = <Player?>[
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
        ];
        expect(board.isFull, isFalse);
      });

      test('returns false for partially filled board', () {
        final board = <Player?>[
          Player.x,
          Player.o,
          Player.x,
          Player.o,
          null,
          null,
          null,
          null,
          null,
        ];
        expect(board.isFull, isFalse);
      });

      test('returns true for completely filled board', () {
        final board = <Player?>[
          Player.x,
          Player.o,
          Player.x,
          Player.x,
          Player.o,
          Player.o,
          Player.o,
          Player.x,
          Player.x,
        ];
        expect(board.isFull, isTrue);
      });
    });

    group('isDraw', () {
      test('returns true for full board with no winner', () {
        final board = <Player?>[
          Player.x,
          Player.o,
          Player.x,
          Player.x,
          Player.o,
          Player.o,
          Player.o,
          Player.x,
          Player.x,
        ];
        expect(board.isDraw, isTrue);
      });

      test('returns false for empty board', () {
        final board = <Player?>[
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
        ];
        expect(board.isDraw, isFalse);
      });

      test('returns false for partial board', () {
        final board = <Player?>[
          Player.x,
          Player.o,
          Player.x,
          Player.o,
          null,
          null,
          null,
          null,
          null,
        ];
        expect(board.isDraw, isFalse);
      });

      test('returns false when board is full but there is a winner', () {
        // isDraw should return false if there's a winner, even if board is full
        final board = <Player?>[
          Player.x,
          Player.x,
          Player.x,
          Player.o,
          Player.o,
          Player.x,
          Player.o,
          Player.x,
          Player.o,
        ];
        expect(board.isDraw, isFalse);
        expect(board.isFull, isTrue);
        expect(board.hasWinner(Player.x), isTrue);
      });
    });
  });

  group('winningCombinations', () {
    test('contains all 8 winning combinations', () {
      expect(winningCombinations.length, equals(8));
    });

    test('contains all row combinations', () {
      expect(winningCombinations[0], equals([0, 1, 2])); // top row
      expect(winningCombinations[1], equals([3, 4, 5])); // middle row
      expect(winningCombinations[2], equals([6, 7, 8])); // bottom row
    });

    test('contains all column combinations', () {
      expect(winningCombinations[3], equals([0, 3, 6])); // left column
      expect(winningCombinations[4], equals([1, 4, 7])); // middle column
      expect(winningCombinations[5], equals([2, 5, 8])); // right column
    });

    test('contains all diagonal combinations', () {
      expect(
        winningCombinations[6],
        equals([0, 4, 8]),
      ); // top-left to bottom-right
      expect(
        winningCombinations[7],
        equals([2, 4, 6]),
      ); // top-right to bottom-left
    });
  });
}
