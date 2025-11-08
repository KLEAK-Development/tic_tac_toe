import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/core/theme/app_spacing.dart' as spacing;
import 'package:tic_tac_toe/src/features/game_modes/shared/logic/game_logic.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_status.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/presentation/extensions/game_status_extensions.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/presentation/extensions/player_extensions.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/providers/game_provider.dart';

/// Generic game screen that works with any game mode
/// The specific game provider is injected via ProviderScope override
class GameScreen extends ConsumerWidget {
  final String title;

  const GameScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(spacing.md),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    kToolbarHeight -
                    (spacing.md * 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GameStatusIndicator(),
                  const SizedBox(height: spacing.lg),
                  const _GameBoard(),
                  const SizedBox(height: spacing.lg),
                  const _ResetButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameStatusIndicator extends ConsumerWidget {
  const _GameStatusIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final l10n = context.l10n;
    final statusText = gameState.status == GameStatus.playing
        ? l10n.playerTurn(gameState.currentPlayer.displayName(context))
        : gameState.status.message(context);

    return Semantics(
      label: l10n.semanticGameStatus,
      value: statusText,
      liveRegion: true,
      child: Text(
        statusText,
        key: const Key('game_status_indicator'),
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _GameBoard extends ConsumerWidget {
  const _GameBoard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    // Listen for game over state changes and show dialog
    ref.listen(gameProvider, (previous, next) {
      if (next.status.isGameOver && previous?.status.isGameOver == false) {
        _showGameOverDialog(context, ref);
      }
    });

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: spacing.sm,
            mainAxisSpacing: spacing.sm,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            return _GameCell(
              key: Key('game_cell_$index'),
              index: index,
              player: gameState.board[index],
              onTap: () =>
                  ref.read(gameProvider.notifier).makeMove(index),
            );
          },
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _GameOverDialog(ref: ref),
    );
  }
}

class _ResetButton extends ConsumerWidget {
  const _ResetButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    void Function()? onPressed =
        ref.watch(gameProvider).board.hasNotStarted
        ? null
        : () => ref.read(gameProvider.notifier).resetGame();

    return ElevatedButton.icon(
      key: const Key('game_reset_button'),
      onPressed: onPressed,
      icon: const Icon(Icons.refresh),
      label: Text(l10n.resetGame),
    );
  }
}

class _GameOverDialog extends StatelessWidget {
  final WidgetRef ref;

  const _GameOverDialog({required this.ref});

  @override
  Widget build(BuildContext context) {
    final status = ref.read(gameProvider).status;
    final l10n = context.l10n;

    return AlertDialog(
      key: const Key('game_over_dialog'),
      title: Text(status.message(context)),
      content: Text(
        status == GameStatus.draw
            ? l10n.gameEndedDraw
            : l10n.playerWonGame(status.winner!.displayName(context)),
      ),
      actions: [
        TextButton(
          key: const Key('game_over_play_again_button'),
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(gameProvider.notifier).resetGame();
          },
          child: Text(l10n.playAgain),
        ),
      ],
    );
  }
}

class _GameCell extends StatelessWidget {
  final int index;
  final Player? player;
  final VoidCallback onTap;

  const _GameCell({
    super.key,
    required this.index,
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cellNumber = index + 1;
    final semanticLabel = player == null
        ? l10n.semanticCellEmpty(cellNumber.toString())
        : l10n.semanticCellFilled(cellNumber.toString(), player!.symbol);

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: player == null,
      child: InkWell(
        borderRadius: BorderRadius.circular(spacing.sm),
        onTap: player == null ? onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(spacing.sm),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              player?.symbol ?? '',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: player?.color(Theme.of(context).colorScheme),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
