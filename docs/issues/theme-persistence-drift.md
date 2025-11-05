# Add theme mode persistence using Drift to remember theme selection between app sessions

## Problem
Currently, when a user selects a theme mode (Light, Dark, or System Default) in the app, their choice is lost when the app is refreshed or restarted. The app reverts to the system default theme, forcing users to re-select their preferred theme every time.

## Proposed Solution
Implement theme mode persistence using [Drift](https://drift.simonbinder.eu/) (a reactive persistence library for Flutter/Dart built on SQLite) to store and retrieve the user's theme preference across app sessions.

## Current Implementation
- Theme mode selection is managed by `appThemeModeProvider` in `lib/src/core/providers/app_theme_mode_provider.dart`
- The provider returns `ThemeMode` (system, light, or dark)
- Default value is `ThemeMode.system` (follows device theme settings)
- Theme can be changed via `ThemeModeSelector` widget in the menu AppBar
- State is currently stored only in memory (Riverpod state)

## Implementation Details

### 1. Add Dependencies
Add Drift dependencies to `pubspec.yaml` (if not already added for locale persistence):
```yaml
dependencies:
  drift: ^latest
  sqlite3_flutter_libs: ^latest
  path_provider: ^latest
  path: ^latest

dev_dependencies:
  drift_dev: ^latest
  build_runner: ^latest
```

### 2. Extend Database Schema
- Modify existing `lib/src/core/database/app_database.dart` (or create if doesn't exist)
- Add a column to the `settings` table for storing theme mode (e.g., 'system', 'light', 'dark')
- Use Drift annotations for code generation

### 3. Extend Repository/Service
- Modify `lib/src/core/database/settings_repository.dart` to include theme CRUD operations
- Methods: `getThemeMode()`, `saveThemeMode(String themeMode)`

### 4. Update AppThemeModeProvider
- Modify `lib/src/core/providers/app_theme_mode_provider.dart` to:
  - Load initial theme mode from database in the `build()` method
  - Save theme mode to database in the `setThemeMode()` method
  - Convert between `ThemeMode` enum and string values for storage

### 5. Handle Edge Cases
- First app launch: No saved preference exists → return `ThemeMode.system` (default)
- Invalid theme mode values in database → fallback to `ThemeMode.system`
- Database errors → gracefully fallback to `ThemeMode.system` without crashing

## Acceptance Criteria
- [ ] User's theme mode selection persists after app refresh/restart
- [ ] All three theme modes work correctly: System Default, Light, Dark
- [ ] All existing tests continue to pass
- [ ] New tests added for database operations and persistence behavior
- [ ] No breaking changes to existing theme management API
- [ ] Works across all platforms (web, mobile)

## Technical Considerations
- Store theme mode as string ('system', 'light', 'dark') in database
- Convert between string and `ThemeMode` enum values
- For web platform, Drift uses `sqlite3_wasm` which requires additional setup
- Consider using `drift_flutter` package for easier cross-platform support
- If implementing with locale persistence, use same database and migrations strategy
- Performance: Database reads on app startup should be fast (local SQLite)

## References
- Drift documentation: https://drift.simonbinder.eu/
- Current theme management: `lib/src/core/providers/app_theme_mode_provider.dart`
- Theme selector UI: `lib/src/features/theme_settings/presentation/widgets/theme_mode_selector.dart`
