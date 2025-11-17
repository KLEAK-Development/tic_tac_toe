import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/features/settings/locale/provider/locale_provider.dart';

export 'package:tic_tac_toe/src/features/settings/locale/data/tables/locale_settings_table.dart';
export 'package:tic_tac_toe/src/features/settings/locale/presentation/widgets/language_selector.dart';
export 'package:tic_tac_toe/src/features/settings/locale/provider/locale_provider.dart'
    show effectiveLocaleProvider;

/// Initialize locale settings during app startup
///
/// This function loads the locale preference from the database and
/// initializes the locale provider. It should be called during app
/// startup to ensure locale preferences are loaded before the UI is displayed.
Future<void> initializeLocaleSettings(Ref ref) async {
  await ref.watch(appLocaleProvider.future);
}
