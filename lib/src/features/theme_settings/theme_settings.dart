import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/features/theme_settings/provider/theme_mode_provider.dart';

export 'package:tic_tac_toe/src/features/theme_settings/data/tables/theme_settings_table.dart';
export 'package:tic_tac_toe/src/features/theme_settings/presentation/widgets/theme_mode_selector.dart';

/// Initialize theme settings during app startup
///
/// This function loads the theme mode preference from the database and
/// initializes the theme mode provider. It should be called during app
/// startup to ensure theme preferences are loaded before the UI is displayed.
Future<void> initializeThemeSettings(Ref ref) async {
  await ref.watch(appThemeModeProvider.future);
}
