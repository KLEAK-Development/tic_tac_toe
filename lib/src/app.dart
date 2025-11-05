import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/core/l10n/app_localizations.dart';
import 'package:tic_tac_toe/src/features/locale_settings/provider/locale_provider.dart';
import 'package:tic_tac_toe/src/core/providers/theme_mode_provider.dart';
import 'package:tic_tac_toe/src/core/routing/app_router.dart';
import 'package:tic_tac_toe/src/core/theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(effectiveLocaleProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
