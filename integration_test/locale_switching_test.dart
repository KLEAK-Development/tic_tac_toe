import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tic_tac_toe/src/app.dart';
import 'package:tic_tac_toe/src/core/l10n/app_localizations.dart';

import 'robots/locale_robot.dart';
import 'robots/menu_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Locale Switching - All languages and system default', (
    WidgetTester tester,
  ) async {
    // Start the app
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    final localeRobot = LocaleRobot(tester);
    final menuRobot = MenuRobot(tester);

    // Verify starting at menu screen
    await menuRobot.verifyOnMenuScreen();

    // Test each supported language with strict validation
    for (final localeCode in ['en', 'fr', 'es', 'de']) {
      await localeRobot.selectLanguage(localeCode);
      await localeRobot.verifyLocaleIs(localeCode);
      final context = tester.element(find.byType(Scaffold).first);
      final l10n = AppLocalizations.of(context);
      menuRobot.verifyAppTitle(l10n.appTitle);
    }

    // Test switching back to system default
    await localeRobot.selectLanguage('system');
    await menuRobot.verifyOnMenuScreen();
    expect(menuRobot.getAppTitleText(), isNotEmpty);

    // Verify persistence: switch to French again after system default
    await localeRobot.selectLanguage('fr');
    await localeRobot.verifyLocaleIs('fr');
    final contextFr = tester.element(find.byType(Scaffold).first);
    final l10nFr = AppLocalizations.of(contextFr);
    menuRobot.verifyAppTitle(l10nFr.appTitle);

    // Final return to system default
    await localeRobot.selectLanguage('system');
    await menuRobot.verifyOnMenuScreen();
    expect(menuRobot.getAppTitleText(), isNotEmpty);
  });
}
