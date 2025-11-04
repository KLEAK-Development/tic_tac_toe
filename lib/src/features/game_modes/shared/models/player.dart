import 'package:flutter/material.dart';

enum Player {
  x,
  o;

  /// Returns the symbol to display for this player
  String get symbol {
    switch (this) {
      case Player.x:
        return 'X';
      case Player.o:
        return 'O';
    }
  }

  /// Returns the opposite player
  Player get opposite {
    switch (this) {
      case Player.x:
        return Player.o;
      case Player.o:
        return Player.x;
    }
  }

  /// Returns the theme-appropriate color for this player
  Color color(ColorScheme colorScheme) {
    switch (this) {
      case Player.x:
        return colorScheme.primary;
      case Player.o:
        return colorScheme.secondary;
    }
  }
}
