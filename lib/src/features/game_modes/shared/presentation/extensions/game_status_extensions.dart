import 'package:flutter/material.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/game_status.dart';

extension GameStatusL10n on GameStatus {
  /// Returns a localized message for the game status
  String message(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case GameStatus.playing:
        return '';
      case GameStatus.xWins:
        return l10n.playerXWins;
      case GameStatus.oWins:
        return l10n.playerOWins;
      case GameStatus.draw:
        return l10n.draw;
    }
  }
}
