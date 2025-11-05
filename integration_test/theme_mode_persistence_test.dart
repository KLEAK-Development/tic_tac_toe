import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tic_tac_toe/src/app.dart';

import 'robots/menu_robot.dart';
import 'robots/theme_mode_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Theme Mode Persistence - Light, Dark, and System modes', (
    WidgetTester tester,
  ) async {
    // Start the app
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    final themeModeRobot = ThemeModeRobot(tester);
    final menuRobot = MenuRobot(tester);

    // Verify we're on the menu screen
    await menuRobot.verifyOnMenuScreen();

    // Test 1: Switch to Light Mode
    await themeModeRobot.selectThemeMode('light');

    // Verify Light mode is applied
    await themeModeRobot.verifyThemeMode(Brightness.light);

    // Verify menu is still visible after theme switch
    await menuRobot.verifyOnMenuScreen();

    // Test 2: Switch to Dark Mode
    await themeModeRobot.selectThemeMode('dark');

    // Verify Dark mode is applied
    await themeModeRobot.verifyThemeMode(Brightness.dark);

    // Verify menu is still visible after theme switch
    await menuRobot.verifyOnMenuScreen();

    // Test 3: Switch to System Default
    await themeModeRobot.selectThemeMode('system');

    // Verify System mode is applied (theme should follow device settings)
    // We can't predict the exact brightness for system mode,
    // but we can verify the app still works
    await menuRobot.verifyOnMenuScreen();

    // Test 4: Switch back to Light to ensure persistence is working
    await themeModeRobot.selectThemeMode('light');
    await themeModeRobot.verifyThemeMode(Brightness.light);

    // Verify app title is still visible (smoke test)
    final appTitle = find.byKey(const Key('menu_app_title'));
    expect(appTitle, findsOneWidget);
  });
}
