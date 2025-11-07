import 'package:flutter/material.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/features/game_modes/shared/models/player.dart';

extension PlayerL10n on Player {
  /// Returns a localized display name for the player
  String displayName(BuildContext context) {
    final l10n = context.l10n;

    return switch (this) {
      Player.x => l10n.playerX,
      Player.o => l10n.playerO,
    };
  }
}
