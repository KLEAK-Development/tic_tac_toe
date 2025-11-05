import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/features/theme_settings/provider/theme_mode_provider.dart';
import 'package:tic_tac_toe/src/shared/widgets/checkable_menu_item.dart';

class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentThemeMode = ref.watch(effectiveThemeModeProvider);

    return PopupMenuButton<ThemeMode>(
      key: const Key('menu_theme_button'),
      icon: const Icon(Icons.brightness_6),
      tooltip: l10n.theme,
      onSelected: (ThemeMode mode) {
        ref.read(appThemeModeProvider.notifier).setThemeMode(mode);
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<ThemeMode>(
            key: const Key('menu_theme_system'),
            value: ThemeMode.system,
            child: CheckableMenuItem(
              isSelected: currentThemeMode == ThemeMode.system,
              label: l10n.themeSystemDefault,
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<ThemeMode>(
            key: const Key('menu_theme_light'),
            value: ThemeMode.light,
            child: CheckableMenuItem(
              isSelected: currentThemeMode == ThemeMode.light,
              label: l10n.themeLight,
            ),
          ),
          PopupMenuItem<ThemeMode>(
            key: const Key('menu_theme_dark'),
            value: ThemeMode.dark,
            child: CheckableMenuItem(
              isSelected: currentThemeMode == ThemeMode.dark,
              label: l10n.themeDark,
            ),
          ),
        ];
      },
    );
  }
}
