import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/core/providers/locale_provider.dart';
import 'package:tic_tac_toe/src/shared/widgets/checkable_menu_item.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(appLocaleProvider);

    return PopupMenuButton<Locale?>(
      key: const Key('menu_language_button'),
      icon: const Icon(Icons.language),
      tooltip: l10n.language,
      onSelected: (Locale? locale) {
        ref.read(appLocaleProvider.notifier).setLocale(locale);
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_system'),
            value: systemDefaultLocale,
            child: CheckableMenuItem(
              isSelected: currentLocale == null,
              label: l10n.languageSystemDefault,
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_en'),
            value: const Locale('en'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'en',
              label: l10n.languageEnglish,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_fr'),
            value: const Locale('fr'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'fr',
              label: l10n.languageFrench,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_es'),
            value: const Locale('es'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'es',
              label: l10n.languageSpanish,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_de'),
            value: const Locale('de'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'de',
              label: l10n.languageGerman,
            ),
          ),
        ];
      },
    );
  }
}
