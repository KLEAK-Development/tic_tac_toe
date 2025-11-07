import 'package:flutter/material.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_status.dart';

extension GameStatusL10n on GameStatus {
  /// Returns a localized message for the game status
  String message(BuildContext context) {
    final l10n = context.l10n;

    return switch (this) {
      GameStatus.playing => '',
      GameStatus.xWins => l10n.playerXWins,
      GameStatus.oWins => l10n.playerOWins,
      GameStatus.draw => l10n.draw,
    };
  }
}
