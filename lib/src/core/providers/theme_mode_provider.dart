import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_provider.g.dart';

/// Provider for the app's theme mode
///
/// Returns ThemeMode.system by default, which means the app follows device settings.
/// Call setThemeMode() to change between light, dark, or system mode at runtime.
@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() {
    return ThemeMode.system; // Follow system theme by default
  }

  /// Sets the app theme mode
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}
