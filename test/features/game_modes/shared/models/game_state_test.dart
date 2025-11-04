import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_state.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_status.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';

void main() {
  group('GameState', () {
    group('constructor', () {
      test('creates GameState with given parameters', () {
        final board = <Player?>[
          Player.x,
          null,
          null,
          null,
          Player.o,
          null,
          null,
          null,
          null,
        ];

        final state = GameState(
          board: board,
          currentPlayer: Player.o,
          status: GameStatus.playing,
        );

        expect(state.board, equals(board));
        expect(state.currentPlayer, equals(Player.o));
        expect(state.status, equals(GameStatus.playing));
      });
    });

    group('initial', () {
      test('creates empty board with 9 nulls', () {
        final state = GameState.initial();

        expect(state.board.length, equals(9));
        expect(state.board.every((cell) => cell == null), isTrue);
      });

      test('sets currentPlayer to Player.x', () {
        final state = GameState.initial();

        expect(state.currentPlayer, equals(Player.x));
      });

      test('sets status to GameStatus.playing', () {
        final state = GameState.initial();

        expect(state.status, equals(GameStatus.playing));
      });
    });

    group('copyWith', () {
      late GameState originalState;

      setUp(() {
        originalState = GameState(
          board: <Player?>[
            Player.x,
            null,
            null,
            null,
            Player.o,
            null,
            null,
            null,
            null,
          ],
          currentPlayer: Player.x,
          status: GameStatus.playing,
        );
      });

      test('updates only board when board is provided', () {
        final newBoard = <Player?>[
          Player.x,
          Player.o,
          null,
          null,
          Player.o,
          null,
          null,
          null,
          null,
        ];

        final newState = originalState.copyWith(board: newBoard);

        expect(newState.board, equals(newBoard));
        expect(newState.currentPlayer, equals(originalState.currentPlayer));
        expect(newState.status, equals(originalState.status));
      });

      test('updates only currentPlayer when currentPlayer is provided', () {
        final newState = originalState.copyWith(currentPlayer: Player.o);

        expect(newState.board, equals(originalState.board));
        expect(newState.currentPlayer, equals(Player.o));
        expect(newState.status, equals(originalState.status));
      });

      test('updates only status when status is provided', () {
        final newState = originalState.copyWith(status: GameStatus.xWins);

        expect(newState.board, equals(originalState.board));
        expect(newState.currentPlayer, equals(originalState.currentPlayer));
        expect(newState.status, equals(GameStatus.xWins));
      });

      test('updates multiple fields when multiple parameters are provided', () {
        final newBoard = <Player?>[
          Player.x,
          Player.x,
          Player.x,
          null,
          Player.o,
          null,
          null,
          null,
          null,
        ];

        final newState = originalState.copyWith(
          board: newBoard,
          status: GameStatus.xWins,
        );

        expect(newState.board, equals(newBoard));
        expect(newState.currentPlayer, equals(originalState.currentPlayer));
        expect(newState.status, equals(GameStatus.xWins));
      });

      test('preserves all values when no parameters are provided', () {
        final newState = originalState.copyWith();

        expect(newState.board, equals(originalState.board));
        expect(newState.currentPlayer, equals(originalState.currentPlayer));
        expect(newState.status, equals(originalState.status));
      });

      test('creates a copy of the board, not a reference', () {
        final newState = originalState.copyWith();

        expect(newState.board, isNot(same(originalState.board)));
        expect(newState.board, equals(originalState.board));
      });

      test('modifying copied board does not affect original', () {
        final newState = originalState.copyWith();
        final originalBoardCopy = List<Player?>.from(originalState.board);

        // Modify the new state's board
        newState.board[0] = Player.o;

        // Original should be unchanged
        expect(originalState.board, equals(originalBoardCopy));
        expect(originalState.board[0], equals(Player.x));
      });
    });
  });
}
