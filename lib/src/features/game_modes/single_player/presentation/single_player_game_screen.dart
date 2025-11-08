import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/presentation/game_screen.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/providers/game_provider.dart';
import 'package:tic_tac_toe/src/features/game_modes/single_player/providers/game_provider.dart';

class SinglePlayerGameScreen extends ConsumerWidget {
  const SinglePlayerGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return ProviderScope(
      overrides: [
        gameProvider.overrideWith(() => SinglePlayerGame()),
      ],
      child: GameScreen(title: l10n.singlePlayerGame),
    );
  }
}
