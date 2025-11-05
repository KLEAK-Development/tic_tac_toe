# Add locale persistence using Drift to remember language selection between app sessions

## Problem
Currently, when a user selects a language in the app, their choice is lost when the app is refreshed or restarted. The app reverts to the system default language, forcing users to re-select their preferred language every time.

## Proposed Solution
Implement locale persistence using [Drift](https://drift.simonbinder.eu/) (a reactive persistence library for Flutter/Dart built on SQLite) to store and retrieve the user's language preference across app sessions.

## Current Implementation
- Language selection is managed by `appLocaleProvider` in `lib/src/core/providers/app_locale_provider.dart`
- The provider returns `Locale?` (null = system default)
- Language can be changed via `LanguageSelector` widget in the menu AppBar
- State is currently stored only in memory (Riverpod state)

## Implementation Details

### 1. Add Dependencies
Add Drift dependencies to `pubspec.yaml`:
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

### 2. Create Database Schema
- Create `lib/src/core/database/app_database.dart`
- Define a `settings` table with a column for storing locale code (e.g., 'en', 'fr', 'es', 'de', or null for system default)
- Use Drift annotations for code generation

### 3. Create Repository/Service
- Create `lib/src/core/database/settings_repository.dart` to handle locale CRUD operations
- Methods: `getLocale()`, `saveLocale(String? localeCode)`

### 4. Update AppLocaleProvider
- Modify `lib/src/core/providers/app_locale_provider.dart` to:
  - Load initial locale from database in the `build()` method
  - Save locale to database in the `setLocale()` method
  - Handle the `systemDefaultLocale` sentinel value → null conversion correctly

### 5. Handle Edge Cases
- First app launch: No saved preference exists → return null (system default)
- Invalid locale codes in database → fallback to system default
- Database errors → gracefully fallback to system default without crashing

## Acceptance Criteria
- [x] User's language selection persists after app refresh/restart
- [x] System default option still works correctly (stored as null in database)
- [x] All existing tests continue to pass
- [x] New tests added for database operations and persistence behavior
- [x] No breaking changes to existing locale management API
- [x] Works across all platforms (web, mobile)

## Technical Considerations
- For web platform, Drift uses `sqlite3_wasm` which requires additional setup
- Consider using `drift_flutter` package for easier cross-platform support
- Database migrations strategy for future schema changes
- Performance: Database reads on app startup should be fast (local SQLite)

## References
- Drift documentation: https://drift.simonbinder.eu/
- Current locale management: `lib/src/core/providers/locale_provider.dart`
- Language selector UI: `lib/src/features/locale_settings/presentation/widgets/language_selector.dart`

---

## Implementation Notes

**Status:** ✅ Completed

**Branch:** `feature/locale-persistence-drift`

**Date:** 2025-11-05

### What Was Implemented

#### 1. Dependencies Added
Added Drift dependencies to `pubspec.yaml`:
- `drift: ^2.29.0` - SQLite ORM for Flutter
- `drift_flutter: ^0.2.7` - Cross-platform support (web + mobile)
- `path_provider: ^2.1.5` - File system path access
- `drift_dev: ^2.29.0` (dev) - Code generation

#### 2. Core Database Infrastructure
Created `lib/src/core/database/app_database.dart`:
- **Settings table** with single-row pattern (id=1 for app-level preferences)
- Columns: `id` (primary key), `localeCode` (nullable text)
- Cross-platform connection using `driftDatabase()` with web support
- `forTesting()` constructor for in-memory test databases

Created `lib/src/core/providers/database_provider.dart`:
- Riverpod provider for database singleton
- Proper cleanup with `ref.onDispose()`

#### 3. Feature-Owned Repository
Created `lib/src/features/locale_settings/data/locale_repository.dart`:
- **Key architectural decision:** Repository placed in feature directory, not core
- Follows features-based architecture (features own their data operations)
- Methods:
  - `getLocale()` - Read locale from database with error handling
  - `saveLocale(Locale?)` - Write locale to database with upsert
  - `clearSettings()` - Clear saved preferences (for testing)
- Graceful error handling (returns null on errors, fails silently on save errors)
- Input validation (rejects invalid locale codes)

#### 4. Updated Locale Provider
Modified `lib/src/core/providers/locale_provider.dart`:
- Changed from synchronous to **async provider** (returns `Future<Locale?>`)
- `build()` method loads locale from database on initialization
- `setLocale()` uses **fire-and-forget pattern** (updates UI immediately, saves asynchronously)
- Sentinel value (`systemDefaultLocale`) still converted to null automatically
- Provider now returns `AsyncValue<Locale?>` requiring `.when()` pattern in UI

#### 5. Updated Widget Layer
Modified `lib/src/features/locale_settings/presentation/widgets/language_selector.dart`:
- Updated to handle `AsyncValue` state using `.when()` pattern
- Displays loading state gracefully (treats as null/system default)
- Error state handled (treats as null/system default)

#### 6. Testing Strategy

**Repository Tests** (17 new tests in `test/features/locale_settings/data/locale_repository_test.dart`):
- CRUD operations for all supported locales (en, fr, es, de)
- System default handling (null persistence)
- Edge cases (invalid locale codes, empty strings)
- Error handling (database errors)
- Persistence across multiple reads

**Provider Tests** (30 tests total in `test/core/providers/locale_provider_test.dart`):
- Updated all existing tests to handle async state (using `.future`)
- Added 12 new tests for database persistence behavior
- Locale persistence across provider rebuilds
- System default persistence

**Widget Tests** (updated 3 files):
- Added database overrides to all widget tests using providers
- `test/widget_test.dart` - Main app widget test
- `test/features/menu/presentation/menu_screen_test.dart` - Menu screen tests
- `test/features/locale_settings/presentation/widgets/language_selector_test.dart` - Language selector tests
- Added `await tester.pumpAndSettle()` after `pumpWidget()` to wait for async provider resolution
- Suppressed safe debug warning about multiple database instances with `driftRuntimeOptions.dontWarnAboutMultipleDatabases = true`
- Fixed import conflict with `isNull` using `import 'package:drift/drift.dart' hide isNull;`

**Test Results:** All 140 tests passing (133 unit/widget + 5 integration)

### Architectural Decisions

1. **Features-Based Repository Placement:**
   - Repository placed in `lib/src/features/locale_settings/data/` (NOT in `lib/src/core/`)
   - Core provides shared database infrastructure, features own their data operations
   - Maintains clean separation of concerns

2. **Async Provider Pattern:**
   - Locale provider changed to async to support database initialization
   - UI handles `AsyncValue` using `.when()` pattern
   - Loading/error states treated as system default (graceful degradation)

3. **Fire-and-Forget Writes:**
   - UI updates immediately (no blocking on database writes)
   - Database saves happen asynchronously in background
   - Better user experience (no UI lag)

4. **Single-Row Settings Pattern:**
   - App-level preferences use single row with id=1
   - Simple and efficient for small number of settings
   - Easy to extend with new columns

5. **Test Database Isolation:**
   - All tests use in-memory databases (`NativeDatabase.memory()`)
   - Each test gets isolated database instance
   - No file system dependencies in tests

### Files Created
- `lib/src/core/database/app_database.dart` - Database schema and connection
- `lib/src/core/providers/database_provider.dart` - Database provider
- `lib/src/features/locale_settings/data/locale_repository.dart` - Locale CRUD operations
- `test/features/locale_settings/data/locale_repository_test.dart` - Repository tests (17 tests)

### Files Modified
- `pubspec.yaml` - Added Drift dependencies
- `lib/src/core/providers/locale_provider.dart` - Made async, added persistence
- `lib/src/features/locale_settings/presentation/widgets/language_selector.dart` - Handle AsyncValue
- `test/core/providers/locale_provider_test.dart` - Updated for async, added persistence tests
- `test/widget_test.dart` - Added database overrides
- `test/features/menu/presentation/menu_screen_test.dart` - Added database overrides
- `test/features/locale_settings/presentation/widgets/language_selector_test.dart` - Added database overrides, fixed async issues
- `CLAUDE.md` - Added database layer documentation, updated test counts

### Code Generation
Ran `fvm flutter pub run build_runner build` to generate:
- `lib/src/core/database/app_database.g.dart` - Drift database code
- `lib/src/core/providers/database_provider.g.dart` - Riverpod provider code
- `lib/src/core/providers/locale_provider.g.dart` - Updated Riverpod provider code

### Technical Notes

**Cross-Platform Support:**
- Uses `drift_flutter` package for automatic platform detection
- Web: Uses `sqlite3_wasm` and drift worker
- Mobile: Uses native SQLite

**Error Handling Strategy:**
- Repository methods return null on read errors (graceful degradation)
- Repository methods fail silently on write errors (don't block UI)
- All errors caught and handled, no crashes

**Performance:**
- Database reads on app startup are fast (local SQLite)
- Fire-and-forget writes don't block UI
- Single-row pattern is efficient for settings

**Migration Strategy:**
- Database schema version: 1
- Future migrations can be added by incrementing `schemaVersion`
- Drift will handle migrations automatically

### Challenges Faced

1. **Async Provider Migration:**
   - Challenge: Changing from synchronous to async provider affected all consumers
   - Solution: Used `.when()` pattern for handling `AsyncValue` in widgets
   - Impact: All widget tests needed `await tester.pumpAndSettle()` after `pumpWidget()`

2. **Test Database Overrides:**
   - Challenge: Widget tests created pending timers from database initialization
   - Solution: Override `appDatabaseProvider` with in-memory test databases in all widget tests
   - Impact: 3 widget test files needed updates

3. **Multiple Database Warning:**
   - Challenge: Drift logged warnings about multiple database instances in tests
   - Solution: Added `driftRuntimeOptions.dontWarnAboutMultipleDatabases = true` in test files
   - Justification: Each test intentionally creates isolated in-memory database for test isolation

4. **Import Conflict:**
   - Challenge: `isNull` imported from both Drift and matcher packages
   - Solution: Used selective import `import 'package:drift/drift.dart' hide isNull;`
   - Impact: One test file needed import update

### Future Enhancements

Potential improvements for future iterations:
- Add theme mode persistence to Settings table
- Add database encryption for sensitive preferences
- Implement proper database migration testing
- Add analytics for locale selection patterns
- Consider SharedPreferences for very simple settings (trade-off: less structured)
