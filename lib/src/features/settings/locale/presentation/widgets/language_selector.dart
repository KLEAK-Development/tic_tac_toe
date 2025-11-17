import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/features/settings/locale/provider/locale_provider.dart';
import 'package:tic_tac_toe/src/shared/widgets/checkable_menu_item.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref
        .watch(appLocaleProvider)
        .when(
          data: (locale) => locale,
          loading: () => null,
          error: (_, _) => null,
        );

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
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_bg'),
            value: const Locale('bg'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'bg',
              label: l10n.languageBulgarian,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_hr'),
            value: const Locale('hr'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'hr',
              label: l10n.languageCroatian,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_cs'),
            value: const Locale('cs'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'cs',
              label: l10n.languageCzech,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_da'),
            value: const Locale('da'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'da',
              label: l10n.languageDanish,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_nl'),
            value: const Locale('nl'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'nl',
              label: l10n.languageDutch,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_et'),
            value: const Locale('et'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'et',
              label: l10n.languageEstonian,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_fi'),
            value: const Locale('fi'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'fi',
              label: l10n.languageFinnish,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_el'),
            value: const Locale('el'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'el',
              label: l10n.languageGreek,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_hu'),
            value: const Locale('hu'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'hu',
              label: l10n.languageHungarian,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_ga'),
            value: const Locale('ga'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'ga',
              label: l10n.languageIrish,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_it'),
            value: const Locale('it'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'it',
              label: l10n.languageItalian,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_lv'),
            value: const Locale('lv'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'lv',
              label: l10n.languageLatvian,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_lt'),
            value: const Locale('lt'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'lt',
              label: l10n.languageLithuanian,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_mt'),
            value: const Locale('mt'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'mt',
              label: l10n.languageMaltese,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_pl'),
            value: const Locale('pl'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'pl',
              label: l10n.languagePolish,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_pt'),
            value: const Locale('pt'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'pt',
              label: l10n.languagePortuguese,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_ro'),
            value: const Locale('ro'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'ro',
              label: l10n.languageRomanian,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_sk'),
            value: const Locale('sk'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'sk',
              label: l10n.languageSlovak,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_sl'),
            value: const Locale('sl'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'sl',
              label: l10n.languageSlovene,
            ),
          ),
          PopupMenuItem<Locale?>(
            key: const Key('menu_language_sv'),
            value: const Locale('sv'),
            child: CheckableMenuItem(
              isSelected: currentLocale?.languageCode == 'sv',
              label: l10n.languageSwedish,
            ),
          ),
        ];
      },
    );
  }
}
