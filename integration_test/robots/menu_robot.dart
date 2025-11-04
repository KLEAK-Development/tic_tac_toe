import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot for Menu screen actions
class MenuRobot {
  final WidgetTester tester;

  MenuRobot(this.tester);

  /// Verify we're on the menu screen
  Future<void> verifyOnMenuScreen() async {
    expect(find.byKey(const Key('menu_app_title')), findsOneWidget);
    expect(
      find.byKey(const Key('menu_two_player_game_button')),
      findsOneWidget,
    );
  }

  /// Start a two-player game
  Future<void> startTwoPlayerGame() async {
    await tester.tap(find.byKey(const Key('menu_two_player_game_button')));
    await tester.pumpAndSettle();
  }

  /// Get the app title text from the menu screen
  String getAppTitleText() {
    final titleFinder = find.byKey(const Key('menu_app_title'));
    expect(titleFinder, findsOneWidget);
    final textWidget = tester.widget<Text>(titleFinder);
    return textWidget.data ?? '';
  }

  /// Verifies that the app title matches the expected text
  void verifyAppTitle(String expectedTitle) {
    final actualTitle = getAppTitleText();
    expect(actualTitle, equals(expectedTitle));
  }
}
