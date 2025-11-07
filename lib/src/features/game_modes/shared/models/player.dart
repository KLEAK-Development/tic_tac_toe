import 'package:flutter/material.dart';

enum Player {
  x,
  o;

  /// Returns the symbol to display for this player
  String get symbol {
    return switch (this) {
      Player.x => 'X',
      Player.o => 'O',
    };
  }

  /// Returns the opposite player
  Player get opposite {
    return switch (this) {
      Player.x => Player.o,
      Player.o => Player.x,
    };
  }

  /// Returns the theme-appropriate color for this player
  Color color(ColorScheme colorScheme) {
    return switch (this) {
      Player.x => colorScheme.primary,
      Player.o => colorScheme.secondary,
    };
  }
}
