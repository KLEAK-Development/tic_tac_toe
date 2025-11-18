import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/core/l10n/app_localizations.dart';
import 'package:tic_tac_toe/src/core/providers/app_startup_provider.dart';
import 'package:tic_tac_toe/src/core/routing/app_router.dart';
import 'package:tic_tac_toe/src/core/theme/app_theme.dart';
import 'package:tic_tac_toe/src/features/app_update/app_update.dart';
import 'package:tic_tac_toe/src/features/settings/settings.dart';
import 'package:tic_tac_toe/src/shared/widgets/app_error_widget.dart';
import 'package:tic_tac_toe/src/shared/widgets/app_loading_widget.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(effectiveLocaleProvider);
    final themeMode = ref.watch(effectiveThemeModeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return AppUpdateListener(
          child: _AppStartupHandler(child: child!),
        );
      },
    );
  }
}

/// Private widget that handles app startup state.
///
/// Isolated from [AppUpdateListener] to prevent unnecessary rebuilds
/// when the startup state changes.
class _AppStartupHandler extends ConsumerWidget {
  const _AppStartupHandler({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartupState = ref.watch(appStartupProvider);

    return appStartupState.when(
      data: (_) => child,
      loading: () => const AppLoadingWidget(),
      error: (error, stack) => AppErrorWidget(
        error: error,
        onRetry: () => ref.invalidate(appStartupProvider),
      ),
    );
  }
}
