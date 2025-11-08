import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tic_tac_toe/src/app.dart';

import 'robots/game_robot.dart';
import 'robots/locale_robot.dart';
import 'robots/menu_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Test all supported locales to verify language-independence
  const supportedLocales = ['en', 'fr', 'es', 'de'];

  testWidgets('Two Player Game - All Scenarios (All Locales)', (
    WidgetTester tester,
  ) async {
    // Start the app once
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    // Create robots
    final localeRobot = LocaleRobot(tester);
    final menuRobot = MenuRobot(tester);
    final gameRobot = GameRobot(tester);

    // Test each locale
    for (final localeCode in supportedLocales) {
      // Select the language via UI
      await menuRobot.verifyOnMenuScreen();
      await localeRobot.selectLanguage(localeCode);
      await tester.pumpAndSettle();

      // Scenario 1: Player X wins with top row
      await menuRobot.verifyOnMenuScreen();
      await menuRobot.startTwoPlayerGame();
      await gameRobot.playGame([0, 3, 1, 4, 2], ['X', 'O', 'X', 'O', 'X']);
      await gameRobot.verifyPlayerWins('X');
      await gameRobot.playAgain();

      // Scenario 2: Player O wins with middle row
      await gameRobot.playGame(
        [0, 3, 1, 4, 6, 5],
        ['X', 'O', 'X', 'O', 'X', 'O'],
      );
      await gameRobot.verifyPlayerWins('O');
      await gameRobot.playAgain();

      // Scenario 3: Draw game
      await gameRobot.playGame(
        [0, 3, 1, 4, 5, 2, 6, 8, 7],
        ['X', 'O', 'X', 'O', 'X', 'O', 'X', 'O', 'X'],
      );
      await gameRobot.verifyDraw();
      await gameRobot.playAgain();

      // Scenario 4: Reset game
      await gameRobot.playPartialGame([0, 3, 1, 4], ['X', 'O', 'X', 'O']);
      await gameRobot.resetGame();
      await gameRobot.verifyGameIsReset();

      // Navigate back to menu to select next language
      await gameRobot.navigateBackToMenu();
      await menuRobot.verifyOnMenuScreen();
    }
  });
}
