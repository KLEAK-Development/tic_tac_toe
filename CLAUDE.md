# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

This is a Flutter application project for a Tic Tac Toe game using a
features-based architecture.

## Flutter Version Management

This project uses FVM (Flutter Version Manager) to lock the Flutter version:

- Flutter version: 3.35.7 (configured in `.fvmrc`)
- Use `fvm flutter` instead of `flutter` for all commands to ensure version
  consistency

## Development Commands

### Running the Application

```bash
fvm flutter run              # Run in debug mode
fvm flutter run -d chrome    # Run on chrome
fvm flutter run --release    # Run in release mode
```

### Hot Reload and Hot Restart

- **Hot Reload**: Press `r` in the terminal while app is running (preserves
  state)
- **Hot Restart**: Press `R` in the terminal (resets state)

### Building

```bash
fvm flutter build web        # Build for web
fvm flutter build apk        # Build for Android
fvm flutter build ios        # Build for iOS
```

### Testing

```bash
fvm flutter test                           # Run all tests
fvm flutter test test/widget_test.dart     # Run specific test file
fvm flutter test --coverage                # Run tests with coverage
```

### Code Quality

```bash
fvm flutter analyze          # Run static analysis
fvm flutter format .         # Format all Dart files
fvm flutter format --set-exit-if-changed .  # Check formatting (CI)
```

### Dependencies

```bash
fvm flutter pub get          # Install dependencies
fvm flutter pub upgrade      # Upgrade dependencies
fvm flutter pub outdated     # Check for outdated packages
```

### Localization

```bash
fvm flutter gen-l10n         # Generate localization files from ARB files
```

## Deployment

### Production Entrypoint

The project includes two entrypoints:

- **`lib/main.dart`**: Development entrypoint with hash-based URL strategy (default)
- **`lib/production.dart`**: Production entrypoint with path-based URL strategy (cleaner URLs)

The production entrypoint (`lib/production.dart`) is configured for web deployment with:
- **Path URL strategy**: Removes `#` from URLs (e.g., `/game/two-player` instead of `/#/game/two-player`)
- **PWA support**: Service worker registration for offline functionality
- **Production optimizations**: Configured for optimal web performance

### Building for Production

**Build for GitHub Pages:**

```bash
fvm flutter build web \
  --release \
  --web-renderer html \
  --base-href /tic_tac_toe/ \
  --target lib/production.dart
```

**Build for custom domain (root path):**

```bash
fvm flutter build web \
  --release \
  --web-renderer html \
  --base-href / \
  --target lib/production.dart
```

**Build options explained:**
- `--release`: Optimized production build
- `--web-renderer html`: HTML renderer for better compatibility (recommended for GitHub Pages)
- `--base-href`: Base path for the app (must match deployment path)
- `--target`: Use production entrypoint with path URL strategy

### GitHub Actions CI/CD

The project uses GitHub Actions for continuous integration and deployment testing:

**Workflow: `.github/workflows/ci.yml`**

**Matrix Strategy** - Tests across 3 Flutter channels:
- `stable` (production-ready)
- `beta` (preview features)
- `master` (bleeding edge)

**Jobs:**
1. **Setup & Validation**: Code generation, static analysis, format checking
2. **Unit & Widget Tests**: Comprehensive test suite with coverage reports
3. **Integration Tests**: Full app testing on Chrome browser
4. **Build Web Release**: Production build (stable channel only, on push to main)

**Triggers:**
- Pull requests to `main` branch (runs all tests to validate changes)
- Pushes to `main` branch (runs tests + creates deployment artifacts)

**Artifacts:**
- Coverage reports (uploaded to Codecov for stable channel)
- Web build artifact (available for 30 days after build)

**Running locally:**

All CI checks can be run locally before pushing:

```bash
# Static analysis
fvm flutter analyze

# Format check
fvm flutter format --set-exit-if-changed .

# Unit & widget tests with coverage
fvm flutter test --coverage

# Integration tests
fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/two_player_game_test.dart \
  -d chrome
```

### Deploying to GitHub Pages

1. **Enable GitHub Pages** in repository settings:
   - Go to Settings → Pages
   - Source: Deploy from a branch
   - Branch: `gh-pages` / `root`

2. **Build the production app**:
   ```bash
   fvm flutter build web \
     --release \
     --web-renderer html \
     --base-href /tic_tac_toe/ \
     --target lib/production.dart
   ```

3. **Deploy the build**:
   ```bash
   # Copy build/web/ contents to gh-pages branch
   # Or use a deployment tool like gh-pages:
   npm install -g gh-pages
   gh-pages -d build/web
   ```

4. **Access your app**:
   - URL: `https://<username>.github.io/tic_tac_toe/`

**Important:**
- The `--base-href` must match your repository name (e.g., `/tic_tac_toe/`)
- Use the production entrypoint for cleaner URLs
- Service worker enables offline functionality after first visit

## Architecture

### Features-Based Architecture

The codebase follows a features-based architecture where code is organized by
feature rather than by layer. Each feature is self-contained with its own UI,
logic, and state management.

**Project structure:**

```
lib/
├── main.dart                # Entry point only
└── src/
    ├── app.dart             # Root app widget
    ├── core/                # Shared utilities, constants, themes
    │   ├── database/        # Database infrastructure
    │   ├── extensions/      # BuildContext and other core extensions
    │   ├── l10n/            # Localization
    │   │   └── arb/         # ARB translation files
    │   ├── providers/       # Core app-level providers
    │   ├── routing/
    │   └── theme/           # Theme configuration and spacing constants
    ├── features/            # Feature modules
    │   ├── menu/            # Menu screen feature
    │   │   └── presentation/
    │   ├── theme_settings/  # Theme mode selection feature
    │   │   └── presentation/
    │   │       └── widgets/
    │   ├── locale_settings/ # Language/locale selection feature
    │   │   ├── data/        # Locale repository (database operations)
    │   │   └── presentation/
    │   │       └── widgets/
    │   ├── game_modes/      # Game mode features
    │   │   ├── shared/      # Shared game logic and models
    │   │   │   ├── logic/   # Game rules (win detection, validation)
    │   │   │   ├── models/  # Game models (Player, GameState, GameStatus)
    │   │   │   └── presentation/
    │   │   │       └── extensions/  # Extensions for localized strings
    │   │   ├── two_player/  # Two-player local game
    │   │   │   ├── presentation/
    │   │   │   └── providers/
    │   │   └── [other_modes]/  # Future: single_player, vs_ai, etc.
    │   └── [other_features]/
    └── shared/              # Shared widgets and components
        └── widgets/
```

**Important:** Only `main.dart` should be in `lib/`. All other code must be
organized under `lib/src/`.

### State Management - Riverpod v2

- Use **Riverpod v2** for state management
- Feature providers should be defined within their respective feature modules under
  `lib/src/features/*/providers/`
- Core app-level providers should be defined in `lib/src/core/providers/`
- Use code generation with `riverpod_generator` for provider definitions

**Provider patterns:**

- `@riverpod` annotation for generated providers
- Notifier classes extending `_$NotifierName` for complex state
- Simple providers for immutable data

**Core Providers** (`lib/src/core/providers/`):

App-level providers that are used across the entire application:

- **appLocaleProvider**: Controls the app's locale for internationalization
  - Returns `AsyncValue<Locale?>` (null = use device locale)
  - Provides `setLocale(Locale?)` method to change language at runtime
  - Automatically converts `systemDefaultLocale` sentinel to null
  - Persists locale preference to database using Drift
  - Accessible via language selector in menu screen AppBar

Example:
```dart
@riverpod
class AppLocale extends _$AppLocale {
  @override
  Future<Locale?> build() async {
    // Load saved locale from database
    final repository = ref.read(localeRepositoryProvider);
    return await repository.getLocale();
  }

  Future<void> setLocale(Locale? newLocale) async {
    // Convert sentinel value to null automatically
    final locale = (newLocale == systemDefaultLocale) ? null : newLocale;

    // Update state immediately (fire-and-forget pattern)
    state = AsyncValue.data(locale);

    // Save to database asynchronously
    final repository = ref.read(localeRepositoryProvider);
    repository.saveLocale(locale);
  }
}

// Usage in UI (must handle AsyncValue):
final asyncLocale = ref.watch(appLocaleProvider);
final currentLocale = asyncLocale.when(
  data: (locale) => locale,
  loading: () => null,
  error: (_, __) => null,
);

// Calling setLocale:
await ref.read(appLocaleProvider.notifier).setLocale(const Locale('fr'));

// Using the sentinel value (useful for PopupMenuButton):
await ref.read(appLocaleProvider.notifier).setLocale(systemDefaultLocale);
```

- **systemDefaultLocale** (sentinel constant): `Locale('__system__')`
  - A sentinel value used by UI components to represent "System Default" locale
  - **Why it exists**: Flutter's `PopupMenuButton` does not trigger the `onSelected`
    callback when a `PopupMenuItem` has a `null` value - it treats this as menu
    dismissal instead. This is a known Flutter framework behavior.
  - The sentinel provides a non-null value that can be selected in PopupMenuButton
  - The `AppLocale.setLocale()` method automatically converts this sentinel to null
    internally, keeping the UI code clean and simple
  - Any language selector UI should use this sentinel instead of null for the
    "System Default" option

- **effectiveLocaleProvider**: Derived provider that computes the effective locale
  - Returns `Locale` (always a concrete locale, never null)
  - Watches `appLocaleProvider` and returns the preferred locale if set, otherwise
    returns the device's system locale
  - Used by the `App` widget to configure `MaterialApp.router`
  - This ensures MaterialApp always receives a concrete Locale object, which is
    necessary for proper locale switching behavior (including switching back to
    system default)

Example:
```dart
@riverpod
Locale effectiveLocale(Ref ref) {
  final preferredLocale = ref.watch(appLocaleProvider);

  // If user explicitly selected a locale, use it
  if (preferredLocale != null) {
    return preferredLocale;
  }

  // Otherwise use device's system locale
  return WidgetsBinding.instance.platformDispatcher.locale;
}

// Usage in App widget:
final locale = ref.watch(effectiveLocaleProvider);
return MaterialApp.router(
  locale: locale,
  // ...
);
```

**Locale Management Pattern:**

The locale system uses a **separation of concerns** approach with **database persistence**:
- `appLocaleProvider` stores the user's preference (nullable, async) and persists to database
- `localeRepository` handles database CRUD operations for locale preferences
- `effectiveLocaleProvider` computes the actual locale to use (always concrete)
- This allows the user to explicitly select a language OR use system default
- When user selects "System Default", appLocaleProvider becomes null, but
  effectiveLocaleProvider still returns a concrete system Locale
- MaterialApp always receives a concrete Locale, ensuring proper reactivity
- Locale preference persists across app restarts via Drift database

- **appThemeModeProvider**: Controls the app's theme mode
  - Returns `AsyncValue<ThemeMode>` (system, light, or dark)
  - Provides `setThemeMode(ThemeMode)` method to change theme at runtime
  - Persists theme mode preference to database using Drift
  - Accessible via theme selector in menu screen AppBar
  - Located in `lib/src/features/theme_settings/provider/theme_mode_provider.dart`

Example:
```dart
@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  Future<ThemeMode> build() async {
    // Load saved theme mode from database
    final repository = ref.read(themeModeRepositoryProvider);
    return await repository.getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    // Update state immediately (fire-and-forget pattern)
    state = AsyncValue.data(mode);

    // Save to database asynchronously
    final repository = ref.read(themeModeRepositoryProvider);
    repository.saveThemeMode(mode);
  }
}

// Usage in UI (must handle AsyncValue):
final asyncThemeMode = ref.watch(appThemeModeProvider);
final currentThemeMode = asyncThemeMode.when(
  data: (mode) => mode,
  loading: () => ThemeMode.system,
  error: (_, __) => ThemeMode.system,
);

// Calling setThemeMode:
await ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.dark);
```

- **effectiveThemeModeProvider**: Derived provider that computes the effective theme mode
  - Returns `ThemeMode` (always a concrete theme mode, never async)
  - Watches `appThemeModeProvider` and handles loading/error states
  - Used by the `App` widget to configure `MaterialApp.router`
  - Maps loading and error states to `ThemeMode.system` for graceful fallback
  - This ensures MaterialApp always receives a concrete ThemeMode object

Example:
```dart
@riverpod
ThemeMode effectiveThemeMode(Ref ref) {
  final asyncMode = ref.watch(appThemeModeProvider);
  return asyncMode.when(
    data: (mode) => mode,
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
}

// Usage in App widget:
final themeMode = ref.watch(effectiveThemeModeProvider);
return MaterialApp.router(
  themeMode: themeMode,
  // ...
);
```

**Theme Mode Management Pattern:**

The theme mode system uses a **separation of concerns** approach with **database persistence**:
- `appThemeModeProvider` stores the user's preference (async) and persists to database
- `themeModeRepository` handles database CRUD operations for theme mode preferences
- `effectiveThemeModeProvider` computes the actual theme mode to use (always concrete)
- Theme mode is stored as nullable string in database: 'light', 'dark', or NULL (for system)
- NULL in database maps to `ThemeMode.system` (follows device theme settings)
- MaterialApp always receives a concrete ThemeMode, ensuring proper reactivity
- Theme preference persists across app restarts via Drift database

- **appStartupProvider**: Coordinates app initialization and loading state
  - Returns `AsyncValue<void>` - async provider that runs once at app startup
  - Uses `@Riverpod(keepAlive: true)` to persist throughout app lifetime
  - Initializes both `appThemeModeProvider` and `appLocaleProvider` concurrently
  - Used in MaterialApp.router's `builder` parameter to show loading/error states
  - Provides centralized error handling with retry capability

Example:
```dart
@Riverpod(keepAlive: true)
Future<void> appStartup(Ref ref) async {
  // Initialize theme mode and locale concurrently
  await Future.wait([
    ref.watch(appThemeModeProvider.future),
    ref.watch(appLocaleProvider.future),
  ]);
}

// Usage in App widget:
MaterialApp.router(
  locale: locale,
  themeMode: themeMode,
  // ... other config
  builder: (context, child) {
    final appStartupState = ref.watch(appStartupProvider);

    return appStartupState.when(
      data: (_) => child!,  // Show normal app content
      loading: () => const AppLoadingWidget(),  // Show loading screen
      error: (error, stack) => AppErrorWidget(  // Show error screen with retry
        error: error,
        onRetry: () => ref.invalidate(appStartupProvider),
      ),
    );
  },
)
```

**App Initialization Pattern:**

The app uses MaterialApp.router's `builder` parameter to handle loading and error states:
- `AppLoadingWidget` (`lib/src/shared/widgets/app_loading_widget.dart`): Simple Scaffold with CircularProgressIndicator
- `AppErrorWidget` (`lib/src/shared/widgets/app_error_widget.dart`): Error screen with retry button
- Both widgets inherit MaterialApp's theme and locale configuration
- Loading/error screens are shown while database initialization is in progress
- Once initialized, the normal app content (router child) is displayed

**Testing with appStartupProvider:**

In tests, override `appStartupProvider` to skip initialization:

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
await tester.pumpAndSettle();  // Wait for async operations
```

**Game State Pattern (Example from Two-Player Game):**

```dart
// Model with immutable state
class GameState {
  final List<Player?> board;
  final Player currentPlayer;
  final GameStatus status;

  GameState copyWith({...}) { ... }
}

// Notifier with business logic
@riverpod
class TwoPlayerGame extends _$TwoPlayerGame {
  @override
  GameState build() => GameState.initial();

  void makeMove(int index) {
    // Validate, update state, check win conditions
    state = state.copyWith(...);
  }

  void resetGame() {
    state = GameState.initial();
  }
}

// UI consumes via ConsumerWidget - widgets access provider internally
class _GameBoard extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(twoPlayerGameProvider);
    // Widget implementation...
  }
}
```

**Important State Management Patterns:**

- Avoid storing provider references at the top of build methods
- Each widget accesses providers internally rather than receiving data as
  parameters
- Use `ref.watch()` for listening to state changes
- Use `ref.read()` for one-time actions (like button callbacks)

### Game Logic Architecture

Game logic is organized to be shared across different game modes:

**Shared Logic** (`lib/src/features/game_modes/shared/logic/`):

- Use **top-level constants** for shared data (e.g., `winningCombinations`)
- Use **extension methods** on model types for game rules and validation:

  ```dart
  // Top-level constant
  const winningCombinations = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6],            // diagonals
  ];

  // Extension methods on List<Player?>
  extension GameBoardExtension on List<Player?> {
    bool hasWinner(Player player) { ... }
    bool get isFull { ... }
    bool get isDraw { ... }
    bool isValidMove(int index) { ... }
  }
  ```

**Avoid**: Class-as-namespace pattern (static classes with only static methods).
Prefer top-level functions and extension methods instead.

**Shared Models** (`lib/src/features/game_modes/shared/models/`):

- Keep models pure data classes with business logic only
- No display strings or UI concerns
- Use `copyWith` for immutability
- Example: `Player`, `GameState`, `GameStatus`

### Settings Features

The app includes dedicated features for theme and locale settings, following the features-based architecture principle.

#### Theme Settings Feature

**Location:** `lib/src/features/theme_settings/presentation/widgets/`

**ThemeModeSelector Widget:**

A reusable widget that provides a popup menu for selecting the app's theme mode (System, Light, or Dark).

```dart
import 'package:tic_tac_toe/src/features/theme_settings/presentation/widgets/theme_mode_selector.dart';

// Usage in AppBar:
AppBar(
  actions: [ThemeModeSelector()],
)
```

**Features:**
- Displays a brightness icon button that opens a popup menu
- Shows checkmark next to the currently selected theme mode
- Three options: System Default, Light, Dark
- Uses `appThemeModeProvider` from `core/providers/` for state management
- Localized labels using `context.l10n`

**Keys for testing:**
- `menu_theme_button` - The theme selector button
- `menu_theme_system` - System default option
- `menu_theme_light` - Light mode option
- `menu_theme_dark` - Dark mode option

#### Locale Settings Feature

**Location:** `lib/src/features/locale_settings/presentation/widgets/`

**LanguageSelector Widget:**

A reusable widget that provides a popup menu for selecting the app's language.

```dart
import 'package:tic_tac_toe/src/features/locale_settings/presentation/widgets/language_selector.dart';

// Usage in AppBar:
AppBar(
  actions: [LanguageSelector()],
)
```

**Features:**
- Displays a language icon button that opens a popup menu
- Shows checkmark next to the currently selected language
- Five options: System Default, English, French, Spanish, German
- Uses `appLocaleProvider` from `core/providers/` for state management
- Uses `systemDefaultLocale` sentinel for the "System Default" option
- Localized labels using `context.l10n`

**Keys for testing:**
- `menu_language_button` - The language selector button
- `menu_language_system` - System default option
- `menu_language_en` - English option
- `menu_language_fr` - French option
- `menu_language_es` - Spanish option
- `menu_language_de` - German option

**Note:** Both widgets are used in the MenuScreen's AppBar actions but are organized as separate features for better modularity and reusability.

### Routing - go_router with Type-Safe Routes

This project uses **go_router** with **go_router_builder** for type-safe,
declarative routing.

**Route Definitions (`lib/src/core/routing/app_router.dart`):**

- All routes are defined using `@TypedGoRoute` annotations
- Each route class extends `GoRouteData` and includes the generated mixin (e.g.,
  `with $MenuRoute`)
- Routes are centralized in `lib/src/core/routing/`

**Defining a New Route:**

```dart
@TypedGoRoute<MyNewRoute>(path: '/my-route')
class MyNewRoute extends GoRouteData with $MyNewRoute {
  const MyNewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const MyNewScreen();
  }
}
```

**Navigating Between Routes:**

```dart
// Type-safe navigation using route classes
const GameRoute().go(context);      // Navigate to game screen
const MenuRoute().go(context);      // Navigate to menu screen
```

**Route Parameters:** For routes with parameters, define them as class
properties:

```dart
@TypedGoRoute<ProfileRoute>(path: '/profile/:userId')
class ProfileRoute extends GoRouteData with $ProfileRoute {
  final String userId;
  const ProfileRoute(this.userId);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProfileScreen(userId: userId);
  }
}
```

**Nested Routes (Current Structure):** The app uses nested routes for game
modes. All game modes are children of the menu route:

```
/ (MenuRoute)
  └─ game/two-player (TwoPlayerGameRoute) → Full path: /game/two-player
```

To add more game modes, add them as siblings to TwoPlayerGameRoute:

```dart
@TypedGoRoute<MenuRoute>(
  path: '/',
  routes: [
    TypedGoRoute<TwoPlayerGameRoute>(path: 'game/two-player'),  // Current
    TypedGoRoute<SinglePlayerGameRoute>(path: 'game/single-player'),  // New mode
    TypedGoRoute<VsAiGameRoute>(path: 'game/vs-ai'),  // New mode
  ],
)
class MenuRoute extends GoRouteData with $MenuRoute {
  // ...
}
```

All game mode routes should follow the pattern: `game/<mode-name>` and route
classes should be named `<ModeName>GameRoute`.

**Important:** After adding or modifying routes, run code generation to update
the generated route files.

## Dependencies

Key dependencies in this project:

- `flutter_riverpod` - Riverpod v3 runtime for state management
- `riverpod_annotation` - Annotations for Riverpod code generation
- `go_router` - Declarative routing framework
- `flutter_localizations` - SDK package for localization support
- `intl` - Internationalization and localization support
- `drift` - SQLite ORM for Flutter persistence
- `drift_flutter` - Cross-platform Drift database support (web + mobile)
- `path_provider` - File system path access for database storage
- `riverpod_generator` - Riverpod code generation (dev dependency)
- `go_router_builder` - Type-safe routing code generation (dev dependency)
- `build_runner` - Code generation runner (dev dependency)
- `drift_dev` - Drift code generation (dev dependency)
- `integration_test` - Flutter integration testing framework (dev dependency)

## Database Layer

This project uses **Drift** (SQLite ORM) for local data persistence. The database layer follows the features-based architecture principle where core database infrastructure is shared, but data operations (repositories) are owned by individual features.

### Database Architecture

**Core Database Infrastructure** (`lib/src/core/database/`):

- **AppDatabase** (`app_database.dart`): Shared database class that defines tables
- Tables are defined centrally but accessed through feature-owned repositories
- Uses single-row pattern for app-level settings (id=1)
- Cross-platform support via `drift_flutter` (web + mobile)

```dart
@DriftDatabase(tables: [Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);  // For in-memory test databases

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'app_database',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
```

**Database Provider** (`lib/src/core/providers/database_provider.dart`):

Provides a singleton database instance with proper cleanup:

```dart
@riverpod
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
}
```

**Feature-Owned Repositories** (`lib/src/features/*/data/`):

Each feature owns its data operations through repository classes:

```dart
// Example: lib/src/features/locale_settings/data/locale_repository.dart
class LocaleRepository {
  final AppDatabase _db;
  LocaleRepository(this._db);

  Future<Locale?> getLocale() async {
    // Read from database
  }

  Future<void> saveLocale(Locale? locale) async {
    // Write to database
  }
}

// Repository provider
@riverpod
LocaleRepository localeRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return LocaleRepository(db);
}
```

### Database Testing Patterns

**In-Memory Databases for Tests:**

All tests use in-memory databases to ensure test isolation and avoid file system dependencies:

```dart
setUp(() {
  database = AppDatabase.forTesting(NativeDatabase.memory());
  container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
    ],
  );
});

tearDown(() async {
  container.dispose();
  await database.close();
});
```

**Widget Tests with Database:**

Widget tests that use providers depending on the database must override `appDatabaseProvider`:

```dart
testWidgets('my widget test', (tester) async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(() async => await database.close());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const MyWidget(),
    ),
  );

  // Wait for async providers to resolve
  await tester.pumpAndSettle();

  // Test assertions...
});
```

**Suppressing Multiple Database Warnings:**

When running tests that create multiple database instances (which is safe because each test uses isolated in-memory databases), suppress the debug warning:

```dart
void main() {
  // Suppress Drift warning about multiple database instances in tests
  // This is safe because each test creates its own isolated in-memory database
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('MyTests', () {
    // Tests...
  });
}
```

**Import Conflict Resolution:**

Drift exports an `isNull` function that conflicts with the matcher package. Use selective imports:

```dart
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
```

### Database Best Practices

- **Fire-and-Forget Writes**: UI-triggered database writes don't block (update UI state immediately, save to database asynchronously)
- **Graceful Error Handling**: Repository methods return null or fail silently on errors to avoid crashing the app
- **Single-Row Settings Pattern**: App-level preferences use a single row with id=1
- **Features Own Data**: Each feature owns its repository, even if using shared database tables
- **Test Isolation**: Always use in-memory databases in tests with proper cleanup

## Code Generation

This project uses code generation for Riverpod providers, go_router routes, and Drift database code.

**Generate code after making changes:**

```bash
fvm flutter pub run build_runner build              # One-time build
fvm flutter pub run build_runner watch              # Watch mode (auto-regenerates on file changes)
fvm flutter pub run build_runner build --delete-conflicting-outputs  # Clean build (removes conflicts)
```

**When to run code generation:**

- After adding or modifying `@TypedGoRoute` route definitions
- After adding or modifying `@riverpod` provider definitions
- After adding or modifying `@DriftDatabase` or table definitions
- When you see errors about missing generated files (`.g.dart` files)

**Generated files:**

- `lib/src/core/routing/app_router.g.dart` - Generated routing code
- `lib/src/core/database/app_database.g.dart` - Generated Drift database code
- `lib/src/core/providers/*.g.dart` - Generated Riverpod provider code
- Any file with `.g.dart` extension is auto-generated and should not be manually edited

## Internationalization (i18n)

This project supports multiple languages using Flutter's built-in localization
framework.

**Supported Languages:**

- English (en)
- French (fr)
- Spanish (es)
- German (de)

**Localization Architecture:**

The project follows a clean separation between data models and presentation
concerns:

1. **Model Layer** (`lib/src/features/game_modes/shared/models/`): Contains only
   data properties and business logic. No display strings.

2. **BuildContext Extension** (`lib/src/core/extensions/build_context_extensions.dart`):
   Provides convenient access to localizations via `context.l10n`.

   ```dart
   extension BuildContextL10nExtension on BuildContext {
     AppLocalizations get l10n => AppLocalizations.of(this);
   }
   ```

3. **Presentation Extensions**
   (`lib/src/features/game_modes/shared/presentation/extensions/`): Extension
   methods that add localized display functionality to models.

   ```dart
   // Example: player_extensions.dart
   extension PlayerL10n on Player {
     String displayName(BuildContext context) {
       final l10n = context.l10n;
       return switch (this) {
         Player.x => l10n.playerX,
         Player.o => l10n.playerO,
       };
     }
   }
   ```

4. **ARB Files** (`lib/src/core/l10n/arb/`): Translation strings for each
   language. The template file is `app_en.arb`.

**Adding New Translations:**

1. Add the translation key and value to `lib/src/core/l10n/arb/app_en.arb` (the
   template file):

   ```json
   {
     "myNewString": "My new string",
     "@myNewString": {
       "description": "Description of what this string is used for"
     }
   }
   ```

2. Add translations for the same key in all other language files (app_fr.arb,
   app_es.arb, app_de.arb)

3. Run `fvm flutter gen-l10n` to generate the localization code

4. Use in widgets:

   ```dart
   final l10n = context.l10n;
   Text(l10n.myNewString)
   ```

**For strings with parameters:**

```json
{
  "playerTurn": "{player}'s Turn",
  "@playerTurn": {
    "description": "Indicates whose turn it is",
    "placeholders": {
      "player": {
        "type": "String"
      }
    }
  }
}
```

```dart
// Usage
Text(l10n.playerTurn(gameState.currentPlayer.displayName(context)))
```

**Important Notes:**

- Always use `context.l10n` to access localizations instead of
  `AppLocalizations.of(context)` - it's shorter and cleaner
- Always keep model classes free of display strings - use presentation
  extensions instead
- Generated localization files are created in
  `.dart_tool/flutter_gen/gen_l10n/app_localizations*.dart` - do not edit these
  manually
- Run `fvm flutter gen-l10n` after modifying ARB files
- The `l10n.yaml` file configures the localization generation settings

## Testing

This project includes comprehensive test coverage for game logic, models, and
providers.

**Test Structure:**

```
test/
├── widget_test.dart         # Widget tests for UI components
├── core/
│   └── providers/           # Core provider tests (theme, locale)
└── features/
    ├── menu/
    │   └── presentation/    # Menu screen widget tests
    ├── theme_settings/
    │   └── presentation/
    │       └── widgets/     # ThemeModeSelector widget tests
    ├── locale_settings/
    │   ├── data/            # Locale repository tests (database operations)
    │   └── presentation/
    │       └── widgets/     # LanguageSelector widget tests
    └── game_modes/
        ├── shared/
        │   ├── logic/       # Game logic tests (win detection, validation)
        │   └── models/      # Model tests (Player, GameState, GameStatus)
        └── two_player/
            ├── presentation/ # Two-player UI widget tests
            └── providers/   # Provider tests (state management)

integration_test/
├── robots/                      # Shared robot classes (Robot Pattern)
│   ├── locale_robot.dart        # Language selection actions
│   ├── menu_robot.dart          # Menu screen interactions
│   ├── theme_mode_robot.dart    # Theme mode selection actions
│   └── two_player_game_robot.dart  # Game screen interactions
├── two_player_game_test.dart    # Integration tests for complete game flows
├── locale_switching_basic_test.dart  # Basic language switching test
└── locale_switching_comprehensive_test.dart  # Multi-language switching test
```

**Test Coverage:**

- **Game Logic** (26 tests): Win detection, draw detection, move validation, and
  board state checks
- **Models** (23 tests): Player properties, GameState immutability, GameStatus
  behavior
- **Providers** (66 tests):
  - Game Provider (26 tests): State transitions, move handling, game reset, win/draw
    scenarios
  - Theme Provider (6 tests): Theme mode state management, MaterialApp integration,
    theme persistence
  - Locale Provider (30 tests): Async locale state management (12 tests including sentinel
    conversion and persistence), effective locale computation and reactivity (6 tests),
    database persistence (12 tests)
  - Locale Repository (17 tests): Database CRUD operations for locale preferences
- **Widget Tests** (25 tests):
  - Main menu (1 test): App initialization with menu screen
  - Menu screen (1 test): Integration test verifying all components are present
  - ThemeModeSelector (7 tests): Checkmark display, theme mode switching (System, Light, Dark)
  - LanguageSelector (5 tests): Checkmark display, locale switching (including System Default)
  - Two-player game screen (11 tests): UI components, accessibility, tap targets,
    game interactions
- **Integration Tests** (3 test files, 5 testWidgets):
  - Theme Mode Switcher (two_player_game_test.dart): Tests switching between light, dark, and system themes
  - Two Player Game (two_player_game_test.dart): Complete game flows tested across all locales (en, fr, es, de). Each locale tests: Player X wins, Player O wins, draw, and reset game (4 scenarios × 4 locales tested sequentially)
  - Basic Locale Switching (locale_switching_basic_test.dart): Verifies switching to French and back to System Default
  - Comprehensive Locale Switching (locale_switching_comprehensive_test.dart): Verifies switching through all languages (en → fr → es → de → system)

**Total: 140 tests passing (133 unit/widget tests + 5 integration testWidgets across 3 files)**

**Running Tests:**

```bash
# Unit and Widget Tests
fvm flutter test                    # Run all unit/widget tests
fvm flutter test --coverage         # Generate coverage report
fvm flutter test test/path/to/file_test.dart  # Run specific test file

# Integration Tests
# Run each integration test file separately with flutter drive command
fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/two_player_game_test.dart \
  -d chrome                         # Run on Chrome browser

fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/locale_switching_basic_test.dart \
  -d chrome                         # Run on Chrome browser

fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/locale_switching_comprehensive_test.dart \
  -d web-server                     # Run headless (useful for CI/CD)
```

**Integration Test Architecture:**

Integration tests use the **Robot Pattern** with **Key-Based Selectors** for better
organization, maintainability, and language-independence.

**Robot Pattern and Code Reusability:**

All robot classes are extracted to the `integration_test/robots/` directory to eliminate
code duplication across integration test files. This follows the DRY (Don't Repeat
Yourself) principle and ensures consistent test behavior across all integration tests.

**Available Robot Classes:**

- **LocaleRobot** (`robots/locale_robot.dart`): Handles language selection via the menu AppBar
- **MenuRobot** (`robots/menu_robot.dart`): Handles menu screen actions (verify screen, start game)
- **ThemeModeRobot** (`robots/theme_mode_robot.dart`): Handles theme mode selection via the menu AppBar
- **TwoPlayerGameRobot** (`robots/two_player_game_robot.dart`): Handles game screen actions (play moves, verify results, reset game, navigate back)

Each robot class encapsulates UI interactions and assertions, making tests more
readable and easier to maintain. Robots provide high-level methods that hide
the complexity of widget finding and interaction.

**Important:** All integration test files should import robots from the shared directory:
```dart
import 'robots/locale_robot.dart';
import 'robots/menu_robot.dart';
import 'robots/theme_mode_robot.dart';
import 'robots/two_player_game_robot.dart';
```

**Test File Organization:**

Each integration test file should contain exactly **1 `testWidgets`** for better test
isolation and clarity. If you need to test multiple scenarios, create separate test
files rather than adding multiple `testWidgets` to a single file.

**Key-Based Widget Selectors:**

All interactive widgets have Keys assigned using a hierarchical naming convention:

```dart
// Pattern: {screen}_{widget_purpose}[_{identifier}]
const Key('menu_app_title')
const Key('menu_two_player_game_button')
const Key('menu_theme_button')           // Theme mode selector button
const Key('menu_theme_system')           // System default theme option
const Key('menu_theme_light')            // Light theme option
const Key('menu_theme_dark')             // Dark theme option
const Key('menu_language_button')        // Language selector button
const Key('menu_language_system')        // System default option
const Key('menu_language_en')            // English option
const Key('menu_language_fr')            // French option
const Key('menu_language_es')            // Spanish option
const Key('menu_language_de')            // German option
const Key('game_status_indicator')
const Key('game_cell_0')  // indexed 0-8 for board cells
const Key('game_reset_button')
const Key('game_over_dialog')
const Key('game_over_play_again_button')
```

**Benefits of key-based selectors:**
- Language-independent: Tests work across all locales (en, fr, es, de)
- More reliable: Won't break if text styling or content changes
- Clearer intent: Key names describe widget purpose
- Better performance: Direct key lookup vs. text traversal

**Multi-Language Testing:**

Integration tests test all 4 supported locales using the actual language selector UI:
- English (en)
- French (fr)
- Spanish (es)
- German (de)

The test uses the **LocaleRobot** to select each language via the menu AppBar, then
runs all test scenarios. This approach tests the actual user experience of changing
languages and verifies that the app works correctly in all languages. Currently
running all 4 locales takes ~60 seconds total.

Example:
```dart
final localeRobot = LocaleRobot(tester);
await localeRobot.selectLanguage('fr');  // Select French
// Run test scenarios...
await localeRobot.selectLanguage('es');  // Select Spanish
// Run test scenarios...
```

**Integration Test Scenarios:**

**two_player_game_test.dart:**
- **Theme Mode Switcher (1 testWidgets)**:
  1. Switch to Light Mode: Verifies switching to light theme
  2. Switch to Dark Mode: Verifies switching to dark theme
  3. Switch to System Mode: Verifies switching to system default theme

- **Two Player Game - All Scenarios (All Locales) (1 testWidgets)**:
  Tests all 4 locales (en, fr, es, de) sequentially. For each locale:
  1. Player X Wins: Complete game where X wins with top row
  2. Player O Wins: Complete game where O wins with middle row
  3. Draw: Complete game that ends in a draw
  4. Reset Game: Partial game followed by reset button test

**locale_switching_basic_test.dart (1 testWidgets):**
- Tests basic locale switching: System Default → French → System Default
- Verifies app title changes to French translation ('Morpion')

**locale_switching_comprehensive_test.dart (1 testWidgets):**
- Tests switching through all languages sequentially
- Flow: System → English → French → Spanish → German → System → French → System
- Verifies locale-specific content for each language

**Important Integration Test Notes:**

- **Robot Pattern**: All robot classes are shared in `integration_test/robots/` directory to eliminate code duplication
- **Test Organization**: Each integration test file contains exactly 1 `testWidgets` for better test isolation
- **Key-Based Selectors**: Uses key-based selectors for language-independent widget finding
- **Actual UI Testing**: Tests use robots to interact with actual UI (not provider overrides):
  - `ThemeModeRobot`: Change themes via the menu AppBar
  - `LocaleRobot`: Change languages via the menu AppBar
  - `MenuRobot`: Verify menu screen and start games
  - `TwoPlayerGameRobot`: Play games, verify results, reset
- **Multi-Locale Testing**: Tests run sequentially for each locale (en, fr, es, de)
- **Test Reusability**: Use `playAgain()` to test multiple games without restarting the app
- **Key Naming Pattern**: All keys follow `{screen}_{purpose}[_{index}]` convention
- **Running Tests**: Use `fvm flutter drive --driver=test_driver/integration_test.dart --target=integration_test/<test_file>.dart -d chrome` (or `-d web-server` for headless)

**Testing Best Practices:**

- Keep unit tests focused on a single behavior
- Use descriptive test names that explain what is being tested
- Test edge cases and error conditions
- Maintain high test coverage for business logic and state management
- **Integration Tests - Robot Pattern**:
  - Extract all robot classes to `integration_test/robots/` directory
  - Each robot encapsulates UI interactions for a specific feature area
  - Import robots from the shared directory in all integration test files
  - Do NOT duplicate robot code in multiple test files
- **Integration Tests - File Organization**:
  - Each integration test file should contain exactly **1 `testWidgets`**
  - Create separate test files for different test scenarios
  - Use the `fvm flutter drive` command (not `fvm flutter test`) to run integration tests
- **Widget Keys**:
  - Always add Keys to interactive widgets following the naming pattern: `{screen}_{purpose}[_{index}]`
  - Use key-based selectors in tests instead of text-based finders for language-independence
- **Multi-Language Testing**: Integration tests should test all supported locales (en, fr, es, de) using the LocaleRobot

## Linting

This project uses `flutter_lints` (version 6.0.0) for code analysis. Lint rules
are configured in `analysis_options.yaml` and follow Flutter's recommended
practices.

## UI/UX Best Practices

### Spacing Constants

Use the spacing constants library for consistent spacing throughout the app instead of hardcoding values:

```dart
import 'package:tic_tac_toe/src/core/theme/app_spacing.dart' as spacing;

// Usage
Padding(
  padding: EdgeInsets.all(spacing.md),
  child: Column(
    children: [
      const SizedBox(height: spacing.lg),
      // ...
    ],
  ),
)
```

**Available constants:**
- `spacing.xs` - 4.0 (extra small)
- `spacing.sm` - 8.0 (small)
- `spacing.md` - 16.0 (medium)
- `spacing.lg` - 32.0 (large)
- `spacing.xl` - 48.0 (extra large)

**Important:** Always use the `import as` pattern (not a class with static members) to follow Dart best practices and avoid the class-as-namespace anti-pattern.

### Accessibility

- **Minimum Tap Target Size**: All interactive elements should have a minimum size of 48x48dp for accessibility (WCAG guidelines)
- **Semantic Labels**: Use `Semantics` widgets to provide screen reader support
- **Live Regions**: Mark dynamic content with `liveRegion: true` to announce changes

Example:
```dart
Container(
  constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
  child: InkWell(
    onTap: () { ... },
    child: ...,
  ),
)
```

## Shared Widgets

Reusable widgets are located in `lib/src/shared/widgets/` to be used across multiple features.

### CheckableMenuItem

A reusable widget for popup menu items with checkmarks, commonly used in settings menus:

```dart
import 'package:tic_tac_toe/src/shared/widgets/checkable_menu_item.dart';

PopupMenuItem<String>(
  value: 'option1',
  child: CheckableMenuItem(
    isSelected: currentValue == 'option1',
    label: 'Option 1',
  ),
)
```

**Properties:**
- `isSelected` (bool): Whether this menu item is currently selected
- `label` (String): The text label to display

The widget displays a checkmark icon when selected, or empty space when not selected, followed by the label text.
