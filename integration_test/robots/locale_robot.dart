import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/core/l10n/app_localizations.dart';

/// Robot for Locale selection actions
class LocaleRobot {
  final WidgetTester tester;

  LocaleRobot(this.tester);

  /// Selects a language from the language menu
  /// [localeCode] should be 'en', 'fr', 'es', 'de', or 'system' for system default
  Future<void> selectLanguage(String localeCode) async {
    // Open the language menu
    await tester.tap(find.byKey(const Key('menu_language_button')));
    await tester.pumpAndSettle();

    // Tap the language option
    final languageKey = localeCode == 'system'
        ? 'menu_language_system'
        : 'menu_language_$localeCode';
    await tester.tap(find.byKey(Key(languageKey)));
    await tester.pumpAndSettle();
  }

  /// Verifies that the app's locale matches the expected locale code
  Future<void> verifyLocaleIs(String localeCode) async {
    // Get the context to access localizations
    final context = tester.element(find.byType(Scaffold).first);
    final l10n = AppLocalizations.of(context);

    // Verify the locale is correct
    expect(l10n.localeName, equals(localeCode));
  }
}
