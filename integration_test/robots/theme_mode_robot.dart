import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot for Theme Mode selection actions
class ThemeModeRobot {
  final WidgetTester tester;

  ThemeModeRobot(this.tester);

  /// Selects a theme mode from the theme menu
  /// [themeMode] should be 'light', 'dark', or 'system'
  Future<void> selectThemeMode(String themeMode) async {
    // Open the theme menu
    await tester.tap(find.byKey(const Key('menu_theme_button')));
    await tester.pumpAndSettle();

    // Tap the theme option
    final themeKey = 'menu_theme_$themeMode';
    await tester.tap(find.byKey(Key(themeKey)));
    await tester.pumpAndSettle();
  }

  /// Verifies the current theme mode by checking the theme brightness
  Future<void> verifyThemeMode(Brightness expectedBrightness) async {
    // Get the BuildContext from a widget in the tree
    final context = tester.element(find.byType(Scaffold).first);
    final theme = Theme.of(context);

    // Verify the theme brightness matches expected
    expect(
      theme.brightness,
      equals(expectedBrightness),
      reason: 'Theme brightness should be $expectedBrightness',
    );
  }
}
