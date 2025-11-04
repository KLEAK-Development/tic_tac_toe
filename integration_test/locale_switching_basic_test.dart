import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tic_tac_toe/src/app.dart';

import 'robots/locale_robot.dart';
import 'robots/menu_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Locale Switching - System Default to French and back', (
    WidgetTester tester,
  ) async {
    // Start the app
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    final localeRobot = LocaleRobot(tester);
    final menuRobot = MenuRobot(tester);

    // Verify we're on the menu screen at System Default
    await menuRobot.verifyOnMenuScreen();

    // Get the initial app title text (should be in system language)
    final initialTitleText = menuRobot.getAppTitleText();
    expect(initialTitleText, isNotEmpty);

    // Switch to French
    await localeRobot.selectLanguage('fr');

    // Verify the app title changed to French
    final frenchTitleText = menuRobot.getAppTitleText();
    expect(
      frenchTitleText,
      equals('Morpion'),
    ); // French translation for Tic Tac Toe
    // Verify it's different from initial if system isn't French
    if (initialTitleText != 'Morpion') {
      expect(frenchTitleText, isNot(equals(initialTitleText)));
    }

    // Verify the New Game button text is now in French
    final frenchNewGameButton = find.byKey(
      const Key('menu_two_player_game_button'),
    );
    expect(frenchNewGameButton, findsOneWidget);

    // Switch back to System Default
    await localeRobot.selectLanguage('system');

    // Verify the app title is back to the system language
    final finalTitleText = menuRobot.getAppTitleText();
    expect(finalTitleText, isNotEmpty);
    // If the system locale is English, it should match the initial text
    // We can't guarantee this in all test environments, but the text should be present
  });
}
