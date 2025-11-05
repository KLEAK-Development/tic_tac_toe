import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show Locale;
import 'package:tic_tac_toe/src/core/database/app_database.dart';

/// Repository for managing locale persistence
///
/// This repository is owned by the locale_settings feature and handles
/// all locale-related database operations following the features-based
/// architecture principle.
class LocaleRepository {
  final AppDatabase _db;

  LocaleRepository(this._db);

  /// The single settings row ID
  static const int _settingsRowId = 1;

  /// Get the saved locale preference
  ///
  /// Returns:
  /// - Locale object if a specific language was saved
  /// - null if system default should be used
  /// - null if no preference exists yet (first app launch)
  /// - null if database errors occur (graceful fallback)
  Future<Locale?> getLocale() async {
    try {
      final query = _db.select(_db.localeSettings)
        ..where((tbl) => tbl.id.equals(_settingsRowId));

      final setting = await query.getSingleOrNull();

      // No saved preference or explicitly set to system default
      if (setting == null || setting.localeCode == null) {
        return null;
      }

      // Validate locale code format (2-3 letter language code)
      final code = setting.localeCode!;
      if (code.isEmpty || code.length > 3) {
        return null; // Invalid format, fallback to system default
      }

      return Locale(code);
    } catch (e) {
      // Database error: gracefully fallback to system default
      // In production, consider logging this error
      return null;
    }
  }

  /// Save locale preference
  ///
  /// Parameters:
  /// - locale: The locale to save, or null for system default
  Future<void> saveLocale(Locale? locale) async {
    try {
      final localeCode = locale?.languageCode;

      await _db
          .into(_db.localeSettings)
          .insertOnConflictUpdate(
            LocaleSettingsCompanion.insert(
              id: const Value(_settingsRowId),
              localeCode: Value(localeCode),
            ),
          );
    } catch (e, stacktrace) {
      // Database error: fail silently to avoid disrupting user experience
      // The in-memory state will still work, just won't persist
      // In production, consider logging this error
    }
  }

  /// Clear all settings (useful for testing/debugging)
  Future<void> clearSettings() async {
    try {
      await (_db.delete(
        _db.localeSettings,
      )..where((tbl) => tbl.id.equals(_settingsRowId))).go();
    } catch (e) {
      // Fail silently
    }
  }
}
