# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

Flutter Tic Tac Toe game using features-based architecture with Riverpod v2, go_router, Drift database, and i18n support.

## Flutter Version Management

- Flutter version: **3.35.7** (configured in `.fvmrc`)
- Use `fvm flutter` instead of `flutter` for all commands

## Development Commands

```bash
# Running
fvm flutter run              # Debug mode
fvm flutter run -d chrome    # Run on Chrome
fvm flutter run --release    # Release mode

# Testing
fvm flutter test                           # Run all tests
fvm flutter test --coverage                # Run tests with coverage
fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/two_player_game_test.dart \
  -d chrome                                # Integration tests

# Code Quality
fvm flutter analyze                        # Static analysis
fvm flutter format .                       # Format code
fvm flutter format --set-exit-if-changed . # Check formatting (CI)

# Dependencies
fvm flutter pub get          # Install dependencies
fvm flutter pub upgrade      # Upgrade dependencies

# Code Generation
fvm flutter pub run build_runner build              # One-time build
fvm flutter pub run build_runner watch              # Watch mode
fvm flutter pub run build_runner build --delete-conflicting-outputs  # Clean build

# Localization
fvm flutter gen-l10n         # Generate localization files from ARB files

# Building
fvm flutter build web        # Build for web
fvm flutter build apk        # Build for Android
fvm flutter build ios        # Build for iOS
```

## Architecture

### Features-Based Architecture

Code is organized by feature rather than by layer. Each feature is self-contained with its own UI, logic, and state management.

```
lib/
├── main.dart                # Entry point only
└── src/
    ├── app.dart             # Root app widget
    ├── core/                # Shared utilities, constants, themes
    │   ├── database/        # Database infrastructure
    │   ├── extensions/      # BuildContext extensions (context.l10n)
    │   ├── l10n/arb/        # ARB translation files
    │   ├── providers/       # Core app-level providers
    │   ├── routing/         # go_router configuration
    │   └── theme/           # Theme configuration and spacing constants
    ├── features/            # Feature modules (fractal architecture)
    │   ├── menu/
    │   ├── settings/        # Settings feature (fractal parent)
    │   │   ├── settings.dart # Barrel export
    │   │   ├── theme/       # Theme mode selection sub-feature
    │   │   │   ├── theme.dart
    │   │   │   ├── providers/
    │   │   │   ├── data/
    │   │   │   └── presentation/
    │   │   └── locale/      # Language/locale selection sub-feature
    │   │       ├── locale.dart
    │   │       ├── providers/
    │   │       ├── data/
    │   │       └── presentation/
    │   └── game_modes/      # Game modes feature (fractal parent)
    │       ├── shared/      # Shared game logic, models, extensions
    │       └── two_player/  # Two-player local game sub-feature
    └── shared/widgets/      # Shared widgets (CheckableMenuItem, etc.)
```

**Important:** Only `main.dart` should be in `lib/`. All other code must be in `lib/src/`.

### Fractal Architecture Pattern

The codebase uses a **fractal architecture** pattern where complex features can contain sub-features with the same internal structure. This provides excellent scalability and organization.

**Example: Settings Feature**

The `settings` feature demonstrates fractal architecture:

```
features/settings/
├── settings.dart           # Parent barrel (cascading re-exports)
├── theme/                  # Theme sub-feature
│   ├── theme.dart          # Sub-feature barrel
│   ├── providers/          # Theme-specific providers
│   ├── data/               # Theme repository & tables
│   └── presentation/       # Theme widgets
└── locale/                 # Locale sub-feature
    ├── locale.dart         # Sub-feature barrel
    ├── providers/          # Locale-specific providers
    ├── data/               # Locale repository & tables
    └── presentation/       # Locale widgets
```

**Usage:**
```dart
// Single import for all settings functionality
import 'package:tic_tac_toe/src/features/settings/settings.dart';

// Access theme and locale providers, widgets, and tables
final themeMode = ref.watch(effectiveThemeModeProvider);
final locale = ref.watch(effectiveLocaleProvider);
```

**Benefits:**
- **Scalability**: Easy to add new settings sub-features (privacy, notifications, etc.)
- **Organization**: Related features grouped together logically
- **Encapsulation**: Each sub-feature is self-contained with its own data/providers/UI
- **Clean imports**: Single barrel export point for consumers

### State Management - Riverpod v2

- Use **Riverpod v2** with `riverpod_generator` for code generation
- Feature providers: `lib/src/features/*/providers/`
- Core app-level providers: `lib/src/core/providers/`
- Use `@riverpod` annotation for generated providers
- Notifier classes extend `_$NotifierName` for complex state

**Key Providers:**

**Settings Feature Providers** (`lib/src/features/settings/`):

- **appLocaleProvider**: Async locale preference (null = system default)
  - Location: `settings/locale/provider/locale_provider.dart`
  - `setLocale(Locale?)` to change language
  - Persists to Drift database
  - Converts `systemDefaultLocale` sentinel to null automatically

- **effectiveLocaleProvider**: Computes concrete locale (never null)
  - Returns user preference or system locale
  - Used by MaterialApp.router

- **appThemeModeProvider**: Async theme mode preference
  - Location: `settings/theme/provider/theme_mode_provider.dart`
  - `setThemeMode(ThemeMode)` to change theme
  - Persists to Drift database

- **effectiveThemeModeProvider**: Computes concrete theme mode
  - Handles loading/error states → ThemeMode.system
  - Used by MaterialApp.router

**Core App-Level Providers** (`lib/src/core/providers/`):

- **appStartupProvider**: Coordinates app initialization
  - `@Riverpod(keepAlive: true)` - runs once at startup
  - Initializes theme and locale concurrently
  - Used in MaterialApp.router's `builder` for loading/error states

- **appDatabaseProvider**: Provides singleton AppDatabase instance

**State Management Patterns:**

- Each widget accesses providers internally (not via parameters)
- Use `ref.watch()` for listening to state changes
- Use `ref.read()` for one-time actions (callbacks)
- Fire-and-forget writes: Update UI state immediately, save to DB asynchronously

### Game Logic

- **Top-level constants** for shared data (e.g., `winningCombinations`)
- **Extension methods** on models for game rules (e.g., `List<Player?>.hasWinner()`)
- **Avoid** class-as-namespace pattern (prefer top-level functions/extensions)
- **Models** are pure data classes with business logic only (no display strings)
- **Presentation extensions** add localized display functionality (e.g., `Player.displayName(context)`)

### Routing - go_router

- Type-safe routing with `go_router_builder`
- All routes use `@TypedGoRoute` annotations
- Route classes extend `GoRouteData` with generated mixin

```dart
@TypedGoRoute<MyRoute>(path: '/my-route')
class MyRoute extends GoRouteData with $MyRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) => const MyScreen();
}

// Navigation
const MyRoute().go(context);
```

**Current structure:**
```
/ (MenuRoute)
  └─ game/two-player (TwoPlayerGameRoute)
```

**Note:** Run code generation after modifying routes.

## Database Layer - Drift

Uses **Drift** (SQLite ORM) for local persistence. Core infrastructure is shared, but data operations (repositories) are owned by individual features.

**Core Database:**
- `AppDatabase` (`lib/src/core/database/app_database.dart`): Defines tables
- Single-row pattern for app-level settings (id=1)
- Cross-platform support via `drift_flutter`

**Feature-Owned Repositories:**
- Each feature owns its repository in `lib/src/features/*/data/`
- Repositories handle CRUD operations for their tables

**Testing Patterns:**

```dart
// In-memory database for tests
setUp(() {
  database = AppDatabase.forTesting(NativeDatabase.memory());
  container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
});

// Widget tests with database
testWidgets('test', (tester) async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(() async => await database.close());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const MyWidget(),
    ),
  );
  await tester.pumpAndSettle();
});

// Suppress multiple database warning in tests
driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

// Import conflict resolution
import 'package:drift/drift.dart' hide isNull;
```

**Best Practices:**
- Fire-and-forget writes (UI updates immediately, DB saves async)
- Graceful error handling (return null, don't crash)
- Test isolation with in-memory databases

## Code Generation

Run after modifying `@TypedGoRoute`, `@riverpod`, or `@DriftDatabase` definitions:

```bash
fvm flutter pub run build_runner build              # One-time
fvm flutter pub run build_runner watch              # Watch mode
fvm flutter pub run build_runner build --delete-conflicting-outputs  # Clean
```

**Generated files:** `*.g.dart` files (do not edit manually)

## Internationalization

**Supported Languages:** All 24 official EU languages

- English (en), French (fr), Spanish (es), German (de)
- Bulgarian (bg), Croatian (hr), Czech (cs), Danish (da), Dutch (nl)
- Estonian (et), Finnish (fi), Greek (el), Hungarian (hu), Irish (ga)
- Italian (it), Latvian (lv), Lithuanian (lt), Maltese (mt), Polish (pl)
- Portuguese (pt), Romanian (ro), Slovak (sk), Slovene (sl), Swedish (sv)

**Architecture:**
1. **Models** (`lib/src/features/game_modes/shared/models/`): No display strings
2. **BuildContext Extension** (`lib/src/core/extensions/`): `context.l10n`
3. **Presentation Extensions** (`lib/src/features/*/presentation/extensions/`): Localized display methods
4. **ARB Files** (`lib/src/core/l10n/arb/`): Translation strings (template: `app_en.arb`)

**Adding Translations:**

1. Add key/value to `app_en.arb`:
```json
{
  "myString": "My string",
  "@myString": {
    "description": "Description of usage"
  }
}
```

2. Add translations to other ARB files (all 24 languages)
3. Run `fvm flutter gen-l10n`
4. Use in widgets: `Text(context.l10n.myString)`

**Strings with parameters:**
```json
{
  "playerTurn": "{player}'s Turn",
  "@playerTurn": {
    "placeholders": {
      "player": {"type": "String"}
    }
  }
}
```

**Best Practices:**
- Always use `context.l10n` (not `AppLocalizations.of(context)`)
- Keep models free of display strings
- Use presentation extensions for localized display

## Testing

**Total: 140 tests** (133 unit/widget + 5 integration testWidgets across 3 files)

**Test Structure:**
```
test/
├── widget_test.dart         # Main app widget test
├── core/providers/          # Core app-level provider tests
└── features/
    ├── menu/presentation/
    ├── settings/            # Settings feature tests (fractal)
    │   ├── theme/
    │   │   ├── providers/
    │   │   ├── data/        # Repository tests
    │   │   └── presentation/widgets/
    │   └── locale/
    │       ├── providers/
    │       ├── data/        # Repository tests
    │       └── presentation/widgets/
    └── game_modes/
        ├── shared/
        │   ├── logic/       # Win detection, validation
        │   └── models/      # Player, GameState, GameStatus
        └── two_player/
            ├── presentation/
            └── providers/

integration_test/
├── robots/                  # Shared robot classes (Robot Pattern)
│   ├── locale_robot.dart
│   ├── menu_robot.dart
│   ├── theme_mode_robot.dart
│   └── two_player_game_robot.dart
├── two_player_game_test.dart
├── locale_switching_basic_test.dart
└── locale_switching_comprehensive_test.dart
```

**Running Tests:**
```bash
# Unit & Widget Tests
fvm flutter test                    # All tests
fvm flutter test --coverage         # With coverage

# Integration Tests
fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/two_player_game_test.dart \
  -d chrome
```

**Integration Test Architecture:**

- **Robot Pattern**: Shared robot classes in `integration_test/robots/` (DRY principle)
- **Key-Based Selectors**: Pattern `{screen}_{purpose}[_{index}]` for language-independence
- **Test Organization**: Each file contains exactly 1 `testWidgets`
- **Multi-Locale Testing**: Tests all 4 locales (en, fr, es, de) using LocaleRobot

**Testing with appStartupProvider:**
```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      appStartupProvider.overrideWith((ref) async {}),  // Skip initialization
    ],
    child: const App(),
  ),
);
await tester.pumpAndSettle();
```

**Best Practices:**
- Keep unit tests focused on single behavior
- Test edge cases and error conditions
- Use descriptive test names
- Extract robot classes for integration tests (no duplication)
- Add Keys to interactive widgets for testing
- Use key-based selectors (not text-based) for language-independence

## UI/UX Best Practices

**Spacing Constants:**
```dart
import 'package:tic_tac_toe/src/core/theme/app_spacing.dart' as spacing;

Padding(
  padding: EdgeInsets.all(spacing.md),
  child: const SizedBox(height: spacing.lg),
)
```

**Available:** `spacing.xs` (4.0), `spacing.sm` (8.0), `spacing.md` (16.0), `spacing.lg` (32.0), `spacing.xl` (48.0)

**Accessibility:**
- Minimum tap target size: 48x48dp (WCAG guidelines)
- Use `Semantics` widgets for screen reader support
- Mark dynamic content with `liveRegion: true`

## Dependencies

Key dependencies:
- `flutter_riverpod`, `riverpod_annotation` - State management
- `go_router` - Routing
- `drift`, `drift_flutter` - Database
- `flutter_localizations`, `intl` - i18n
- `riverpod_generator`, `go_router_builder`, `build_runner`, `drift_dev` - Code generation (dev)
- `integration_test` - Integration testing (dev)
