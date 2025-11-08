import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tic_tac_toe/src/app.dart';

import 'robots/game_robot.dart';
import 'robots/menu_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Single Player Game - All Scenarios (English)', (
    WidgetTester tester,
  ) async {
    // Start the app once
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    // Create robots
    final menuRobot = MenuRobot(tester);
    final gameRobot = GameRobot(tester);

    // Scenario 1: Computer automatically responds after human move
    await menuRobot.verifyOnMenuScreen();
    await menuRobot.startSinglePlayerGame();
    await gameRobot.makeHumanMove(4); // Human plays center
    gameRobot.verifyComputerResponded(); // Verify computer made a move
    await gameRobot.navigateBackToMenu();
    await menuRobot.verifyOnMenuScreen();

    // Scenario 2: Computer blocks human win - Top row (DETERMINISTIC)
    await menuRobot.startSinglePlayerGame();
    await gameRobot.makeHumanMove(0); // X at 0
    gameRobot.verifyComputerResponded(); // O somewhere (random)
    // Find which top-row cell is still empty (1 or 2)
    final secondMove = gameRobot.isCellEmpty(1) ? 1 : 2;
    await gameRobot.makeHumanMove(secondMove); // X at available cell
    // Computer MUST block at the remaining top row cell
    final blockCell = secondMove == 1 ? 2 : 1;
    gameRobot.verifyComputerBlockedAt(blockCell);
    await gameRobot.navigateBackToMenu();
    await menuRobot.verifyOnMenuScreen();

    // Scenario 3: Computer blocks human win - Vertical column (DETERMINISTIC)
    await menuRobot.startSinglePlayerGame();
    await gameRobot.makeHumanMove(1); // X at top-middle
    gameRobot.verifyComputerResponded(); // O somewhere (random)
    // Find which middle-column cell is still empty (4 or 7)
    final thirdMove = gameRobot.isCellEmpty(4) ? 4 : 7;
    await gameRobot.makeHumanMove(thirdMove); // X at available cell
    // Computer MUST block at the remaining middle-column cell
    final blockColumnCell = thirdMove == 4 ? 7 : 4;
    gameRobot.verifyComputerBlockedAt(blockColumnCell);
    await gameRobot.navigateBackToMenu();
    await menuRobot.verifyOnMenuScreen();

    // Scenario 4: Board state validity (X and O counts match)
    await menuRobot.startSinglePlayerGame();
    // Play 3 rounds and verify board state is always valid
    for (int turn = 0; turn < 3; turn++) {
      final emptyCellIndex = gameRobot.findEmptyCell();
      expect(
        emptyCellIndex,
        isNot(-1),
        reason: 'Board should have empty cells',
      );

      await gameRobot.makeHumanMove(emptyCellIndex);

      final boardState = gameRobot.getBoardState();
      final xCount = boardState.where((c) => c == 'X').length;
      final oCount = boardState.where((c) => c == 'O').length;

      // After human move and computer response, counts should be equal
      expect(
        xCount,
        equals(oCount),
        reason: 'X and O counts should be equal after computer responds',
      );
    }
    // Game might have ended (dialog showing) or still playing - either is valid
    // Navigate back to menu to clean up
    await gameRobot.navigateBackToMenu();
    await menuRobot.verifyOnMenuScreen();

    // Scenario 5: Reset game (uses findEmptyCell for flexibility)
    await menuRobot.startSinglePlayerGame();
    await gameRobot.makeHumanMove(4); // Center
    gameRobot.verifyComputerResponded();
    // Find any empty cell for second move
    final emptyCell = gameRobot.findEmptyCell();
    expect(emptyCell, isNot(-1), reason: 'Should find empty cell');
    await gameRobot.makeHumanMove(emptyCell);
    await gameRobot.resetGame();
    await gameRobot.verifyGameIsReset();
  });
}
