import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_status.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';
import 'package:tic_tac_toe/src/features/game_modes/two_player/providers/game_provider.dart';

void main() {
  group('Game provider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('initial state', () {
      test('build() returns GameState.initial()', () {
        final state = container.read(twoPlayerGameProvider);

        expect(state.board.length, equals(9));
        expect(state.currentPlayer, equals(Player.x));
        expect(state.status, equals(GameStatus.playing));
      });

      test('initial board is empty', () {
        final state = container.read(twoPlayerGameProvider);

        expect(state.board.every((cell) => cell == null), isTrue);
      });

      test('initial currentPlayer is Player.x', () {
        final state = container.read(twoPlayerGameProvider);

        expect(state.currentPlayer, equals(Player.x));
      });

      test('initial status is GameStatus.playing', () {
        final state = container.read(twoPlayerGameProvider);

        expect(state.status, equals(GameStatus.playing));
      });
    });

    group('makeMove - valid moves', () {
      test('valid move updates board with current player mark', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(0);

        final state = container.read(twoPlayerGameProvider);
        expect(state.board[0], equals(Player.x));
      });

      test('valid move switches to opposite player', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(0); // X plays
        final state = container.read(twoPlayerGameProvider);

        expect(state.currentPlayer, equals(Player.o));
      });

      test('X wins horizontally (top row)', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(0); // X
        notifier.makeMove(3); // O
        notifier.makeMove(1); // X
        notifier.makeMove(4); // O
        notifier.makeMove(2); // X wins

        final state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.xWins));
        expect(state.board[0], equals(Player.x));
        expect(state.board[1], equals(Player.x));
        expect(state.board[2], equals(Player.x));
      });

      test('X wins vertically (left column)', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(0); // X
        notifier.makeMove(1); // O
        notifier.makeMove(3); // X
        notifier.makeMove(2); // O
        notifier.makeMove(6); // X wins

        final state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.xWins));
      });

      test('X wins diagonally (top-left to bottom-right)', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(0); // X
        notifier.makeMove(1); // O
        notifier.makeMove(4); // X
        notifier.makeMove(2); // O
        notifier.makeMove(8); // X wins

        final state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.xWins));
      });

      test('O wins horizontally (middle row)', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(0); // X
        notifier.makeMove(3); // O
        notifier.makeMove(1); // X
        notifier.makeMove(4); // O
        notifier.makeMove(6); // X
        notifier.makeMove(5); // O wins

        final state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.oWins));
      });

      test('O wins vertically (right column)', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(0); // X
        notifier.makeMove(2); // O
        notifier.makeMove(1); // X
        notifier.makeMove(5); // O
        notifier.makeMove(6); // X
        notifier.makeMove(8); // O wins

        final state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.oWins));
      });

      test('O wins diagonally (top-right to bottom-left)', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(0); // X
        notifier.makeMove(2); // O
        notifier.makeMove(1); // X
        notifier.makeMove(4); // O
        notifier.makeMove(5); // X
        notifier.makeMove(6); // O wins

        final state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.oWins));
      });

      test('draw scenario (board full, no winner)', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        // Create a draw scenario
        // X X O
        // O O X
        // X O X
        notifier.makeMove(0); // X
        notifier.makeMove(3); // O
        notifier.makeMove(1); // X
        notifier.makeMove(4); // O
        notifier.makeMove(5); // X
        notifier.makeMove(2); // O
        notifier.makeMove(6); // X
        notifier.makeMove(8); // O
        notifier.makeMove(7); // X

        final state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.draw));
        expect(state.board.every((cell) => cell != null), isTrue);
      });
    });

    group('makeMove - invalid moves', () {
      test('move on occupied cell does nothing', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(0); // X plays
        final stateAfterFirstMove = container.read(twoPlayerGameProvider);

        notifier.makeMove(0); // Try to play on same cell
        final stateAfterSecondMove = container.read(twoPlayerGameProvider);

        // State should be unchanged (still O's turn)
        expect(
          stateAfterSecondMove.currentPlayer,
          equals(stateAfterFirstMove.currentPlayer),
        );
        expect(stateAfterSecondMove.board[0], equals(Player.x));
      });

      test('move with negative index does nothing', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(-1);
        final state = container.read(twoPlayerGameProvider);

        expect(state.board.every((cell) => cell == null), isTrue);
        expect(state.currentPlayer, equals(Player.x)); // Still X's turn
      });

      test('move with index >= 9 does nothing', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(9);
        final state = container.read(twoPlayerGameProvider);

        expect(state.board.every((cell) => cell == null), isTrue);
        expect(state.currentPlayer, equals(Player.x)); // Still X's turn
      });

      test('move after game is over (xWins) does nothing', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        // Create X win
        notifier.makeMove(0); // X
        notifier.makeMove(3); // O
        notifier.makeMove(1); // X
        notifier.makeMove(4); // O
        notifier.makeMove(2); // X wins

        final stateAfterWin = container.read(twoPlayerGameProvider);
        expect(stateAfterWin.status, equals(GameStatus.xWins));

        // Try to make another move
        notifier.makeMove(5);
        final stateAfterExtraMove = container.read(twoPlayerGameProvider);

        // State should be unchanged
        expect(stateAfterExtraMove.board[5], isNull);
        expect(stateAfterExtraMove.status, equals(GameStatus.xWins));
      });

      test('move after game is over (draw) does nothing', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        // Create a draw
        notifier.makeMove(0); // X
        notifier.makeMove(3); // O
        notifier.makeMove(1); // X
        notifier.makeMove(4); // O
        notifier.makeMove(5); // X
        notifier.makeMove(2); // O
        notifier.makeMove(6); // X
        notifier.makeMove(8); // O
        notifier.makeMove(7); // X - draw

        final stateAfterDraw = container.read(twoPlayerGameProvider);
        expect(stateAfterDraw.status, equals(GameStatus.draw));

        // Try to make another move (shouldn't be possible, but test it)
        final boardBeforeExtraMove = List<Player?>.from(stateAfterDraw.board);
        notifier.makeMove(0); // Try to overwrite
        final stateAfterExtraMove = container.read(twoPlayerGameProvider);

        // State should be unchanged
        expect(stateAfterExtraMove.board, equals(boardBeforeExtraMove));
        expect(stateAfterExtraMove.status, equals(GameStatus.draw));
      });
    });

    group('makeMove - game flow', () {
      test('complete game sequence from start to X win', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        // Initial state
        var state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.playing));
        expect(state.currentPlayer, equals(Player.x));

        // Move 1: X plays
        notifier.makeMove(4);
        state = container.read(twoPlayerGameProvider);
        expect(state.board[4], equals(Player.x));
        expect(state.currentPlayer, equals(Player.o));
        expect(state.status, equals(GameStatus.playing));

        // Move 2: O plays
        notifier.makeMove(0);
        state = container.read(twoPlayerGameProvider);
        expect(state.board[0], equals(Player.o));
        expect(state.currentPlayer, equals(Player.x));

        // Move 3: X plays
        notifier.makeMove(1);
        state = container.read(twoPlayerGameProvider);
        expect(state.currentPlayer, equals(Player.o));

        // Move 4: O plays
        notifier.makeMove(2);
        state = container.read(twoPlayerGameProvider);
        expect(state.currentPlayer, equals(Player.x));

        // Move 5: X wins
        notifier.makeMove(7);
        state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.xWins));
        expect(
          state.currentPlayer,
          equals(Player.x),
        ); // Winner stays as current player
      });

      test('complete game sequence from start to O win', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(0); // X
        notifier.makeMove(4); // O
        notifier.makeMove(1); // X
        notifier.makeMove(3); // O
        notifier.makeMove(6); // X
        notifier.makeMove(5); // O wins (diagonal)

        final state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.oWins));
        expect(state.currentPlayer, equals(Player.o));
      });

      test('complete game sequence from start to draw', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        // Play out a draw game
        notifier.makeMove(4); // X - center
        expect(
          container.read(twoPlayerGameProvider).status,
          equals(GameStatus.playing),
        );

        notifier.makeMove(0); // O - top-left
        expect(
          container.read(twoPlayerGameProvider).status,
          equals(GameStatus.playing),
        );

        notifier.makeMove(1); // X - top-center
        expect(
          container.read(twoPlayerGameProvider).status,
          equals(GameStatus.playing),
        );

        notifier.makeMove(7); // O - bottom-center
        expect(
          container.read(twoPlayerGameProvider).status,
          equals(GameStatus.playing),
        );

        notifier.makeMove(2); // X - top-right
        expect(
          container.read(twoPlayerGameProvider).status,
          equals(GameStatus.playing),
        );

        notifier.makeMove(6); // O - bottom-left
        expect(
          container.read(twoPlayerGameProvider).status,
          equals(GameStatus.playing),
        );

        notifier.makeMove(3); // X - middle-left
        expect(
          container.read(twoPlayerGameProvider).status,
          equals(GameStatus.playing),
        );

        notifier.makeMove(5); // O - middle-right
        expect(
          container.read(twoPlayerGameProvider).status,
          equals(GameStatus.playing),
        );

        notifier.makeMove(8); // X - bottom-right (final move)
        final state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.draw));
      });
    });

    group('resetGame', () {
      test('resetGame() after some moves restores initial state', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        // Make some moves
        notifier.makeMove(0);
        notifier.makeMove(1);
        notifier.makeMove(2);

        // Verify moves were made
        var state = container.read(twoPlayerGameProvider);
        expect(state.board[0], equals(Player.x));
        expect(state.board[1], equals(Player.o));
        expect(state.board[2], equals(Player.x));
        expect(state.currentPlayer, equals(Player.o));

        // Reset
        notifier.resetGame();
        state = container.read(twoPlayerGameProvider);

        // Verify reset to initial state
        expect(state.board.every((cell) => cell == null), isTrue);
        expect(state.currentPlayer, equals(Player.x));
        expect(state.status, equals(GameStatus.playing));
      });

      test('resetGame() after game over restores initial state', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        // Play to X win
        notifier.makeMove(0); // X
        notifier.makeMove(3); // O
        notifier.makeMove(1); // X
        notifier.makeMove(4); // O
        notifier.makeMove(2); // X wins

        var state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.xWins));

        // Reset
        notifier.resetGame();
        state = container.read(twoPlayerGameProvider);

        // Verify reset to initial state
        expect(state.board.every((cell) => cell == null), isTrue);
        expect(state.currentPlayer, equals(Player.x));
        expect(state.status, equals(GameStatus.playing));
      });
    });

    group('edge cases', () {
      test('winner does not switch player', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(0); // X
        notifier.makeMove(3); // O
        notifier.makeMove(1); // X
        notifier.makeMove(4); // O
        notifier.makeMove(2); // X wins

        final state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.xWins));
        expect(
          state.currentPlayer,
          equals(Player.x),
        ); // Winner stays as current player
      });

      test('game status changes correctly on winning move', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        notifier.makeMove(0); // X
        notifier.makeMove(3); // O
        notifier.makeMove(1); // X

        var state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.playing));

        notifier.makeMove(4); // O
        state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.playing));

        notifier.makeMove(2); // X wins
        state = container.read(twoPlayerGameProvider);
        expect(state.status, equals(GameStatus.xWins));
      });

      test('multiple resets work correctly', () {
        final notifier = container.read(twoPlayerGameProvider.notifier);

        // Play and reset multiple times
        for (var i = 0; i < 3; i++) {
          notifier.makeMove(0);
          notifier.makeMove(1);

          var state = container.read(twoPlayerGameProvider);
          expect(state.board[0], equals(Player.x));
          expect(state.board[1], equals(Player.o));

          notifier.resetGame();
          state = container.read(twoPlayerGameProvider);
          expect(state.board.every((cell) => cell == null), isTrue);
          expect(state.currentPlayer, equals(Player.x));
        }
      });
    });
  });
}
