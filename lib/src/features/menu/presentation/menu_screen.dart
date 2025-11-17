import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/core/routing/app_router.dart';
import 'package:tic_tac_toe/src/core/theme/app_spacing.dart' as spacing;
import 'package:tic_tac_toe/src/features/settings/settings.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle, key: const Key('menu_app_title')),
        actions: const [ThemeModeSelector(), LanguageSelector()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(spacing.md),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('menu_single_player_game_button'),
                    onPressed: () => const SinglePlayerGameRoute().go(context),
                    child: Text(l10n.singlePlayerGame),
                  ),
                ),
                const SizedBox(height: spacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('menu_two_player_game_button'),
                    onPressed: () => const TwoPlayerGameRoute().go(context),
                    child: Text(l10n.twoPlayerGame),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
