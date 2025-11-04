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

  testWidgets('Locale Switching - Multiple languages', (
    WidgetTester tester,
  ) async {
    // Start the app
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    final localeRobot = LocaleRobot(tester);
    final menuRobot = MenuRobot(tester);

    // Start at System Default
    await menuRobot.verifyOnMenuScreen();

    // Switch to English
    await localeRobot.selectLanguage('en');
    await localeRobot.verifyLocaleIs('en');
    final contextEn = tester.element(find.byType(Scaffold).first);
    final l10nEn = AppLocalizations.of(contextEn);
    menuRobot.verifyAppTitle(l10nEn.appTitle);

    // Switch to French
    await localeRobot.selectLanguage('fr');
    await localeRobot.verifyLocaleIs('fr');
    final contextFr = tester.element(find.byType(Scaffold).first);
    final l10nFr = AppLocalizations.of(contextFr);
    menuRobot.verifyAppTitle(l10nFr.appTitle);

    // Switch to Spanish
    await localeRobot.selectLanguage('es');
    await localeRobot.verifyLocaleIs('es');
    final contextEs = tester.element(find.byType(Scaffold).first);
    final l10nEs = AppLocalizations.of(contextEs);
    menuRobot.verifyAppTitle(l10nEs.appTitle);

    // Switch to German
    await localeRobot.selectLanguage('de');
    await localeRobot.verifyLocaleIs('de');
    final contextDe = tester.element(find.byType(Scaffold).first);
    final l10nDe = AppLocalizations.of(contextDe);
    menuRobot.verifyAppTitle(l10nDe.appTitle);

    // Switch back to System Default
    await localeRobot.selectLanguage('system');
    await menuRobot.verifyOnMenuScreen();
    expect(menuRobot.getAppTitleText(), isNotEmpty);

    // Switch to French again to verify it still works after going to system
    await localeRobot.selectLanguage('fr');
    await localeRobot.verifyLocaleIs('fr');
    final contextFr2 = tester.element(find.byType(Scaffold).first);
    final l10nFr2 = AppLocalizations.of(contextFr2);
    menuRobot.verifyAppTitle(l10nFr2.appTitle);

    // And back to system one more time
    await localeRobot.selectLanguage('system');
    await menuRobot.verifyOnMenuScreen();
    expect(menuRobot.getAppTitleText(), isNotEmpty);
  });
}
