import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe/src/features/locale_settings/locale_settings.dart';
import 'package:tic_tac_toe/src/features/theme_settings/theme_settings.dart';

part 'app_startup_provider.g.dart';

/// Provider for app initialization
///
/// This provider coordinates the initialization of async providers during
/// app startup. It waits for both theme mode and locale preferences to load
/// from the database before the app is considered initialized.
///
/// The provider is kept alive throughout the app's lifetime and only runs once.
///
/// Example usage:
/// ```dart
/// MaterialApp.router(
///   builder: (context, child) {
///     final appStartupState = ref.watch(appStartupProvider);
///     return appStartupState.when(
///       data: (_) => child!,
///       loading: () => const AppLoadingWidget(),
///       error: (error, _) => AppErrorWidget(error: error, onRetry: ...),
///     );
///   },
/// )
/// ```
@Riverpod(keepAlive: true)
Future<void> appStartup(Ref ref) async {
  // Initialize theme mode and locale concurrently
  // Each feature controls its own initialization logic
  await Future.wait([
    initializeThemeSettings(ref),
    initializeLocaleSettings(ref),
  ]);
}
