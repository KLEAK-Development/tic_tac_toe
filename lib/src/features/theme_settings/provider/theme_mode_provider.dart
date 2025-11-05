import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe/src/core/providers/database_provider.dart';
import 'package:tic_tac_toe/src/features/theme_settings/data/theme_mode_repository.dart';

part 'theme_mode_provider.g.dart';

/// Provider for the theme mode repository
@riverpod
ThemeModeRepository themeModeRepository(Ref ref) {
  final db = ref.read(appDatabaseProvider);
  return ThemeModeRepository(db);
}

/// Provider for the app's theme mode (loads from DB and persists changes)
@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  Future<ThemeMode> build() async {
    final repo = ref.read(themeModeRepositoryProvider);
    return repo.getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncValue.data(mode);
    final repo = ref.read(themeModeRepositoryProvider);
    // ignore: unawaited_futures
    repo.saveThemeMode(mode);
  }
}

/// Derived provider that maps loading/error to ThemeMode.system
@riverpod
ThemeMode effectiveThemeMode(Ref ref) {
  final asyncMode = ref.watch(appThemeModeProvider);
  return asyncMode.when(
    data: (m) => m,
    loading: () => ThemeMode.system,
    error: (_, _) => ThemeMode.system,
  );
}
