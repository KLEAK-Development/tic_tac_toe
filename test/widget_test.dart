// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tic_tac_toe/src/app.dart';

void main() {
  testWidgets('Menu screen displays new game button and controls', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Verify that our menu screen displays the new game button
    expect(
      find.byKey(const Key('menu_two_player_game_button')),
      findsOneWidget,
    );

    // Verify that the language selector and theme toggle are present in the AppBar
    expect(find.byKey(const Key('menu_language_button')), findsOneWidget);
    expect(find.byKey(const Key('menu_theme_button')), findsOneWidget);
  });
}
