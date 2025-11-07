import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:tic_tac_toe/src/core/database/app_database.dart';

/// Repository for managing theme mode persistence
class ThemeModeRepository {
  final AppDatabase _db;

  ThemeModeRepository(this._db);

  static const int _settingsRowId = 1;

  /// Load saved theme mode, defaulting to ThemeMode.system on any issue
  Future<ThemeMode> getThemeMode() async {
    try {
      final query = _db.select(_db.themeSettings)
        ..where((tbl) => tbl.id.equals(_settingsRowId));
      final setting = await query.getSingleOrNull();

      final value = setting?.themeMode;
      if (value == null) return ThemeMode.system; // null => system

      return switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {
      return ThemeMode.system;
    }
  }

  /// Persist theme mode. Store null for system, or concrete string otherwise
  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final String? value = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => null,
      };

      await _db
          .into(_db.themeSettings)
          .insertOnConflictUpdate(
            ThemeSettingsCompanion.insert(
              id: const Value(_settingsRowId),
              themeMode: Value(value),
            ),
          );
    } catch (_) {
      // Fail silently
    }
  }
}
