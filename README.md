# Tic Tac Toe - Flutter

A modern, accessible Tic Tac Toe game built with Flutter, featuring a clean architecture, comprehensive testing, and multi-language support.

## Features

- ✨ Clean, intuitive UI with Material Design 3
- 🌍 Multi-language support (English, French, Spanish, German)
- 🎨 Light and Dark theme modes
- ♿ Full accessibility support with semantic labels
- 📱 Responsive design for mobile, tablet, and web
- ✅ Comprehensive test coverage (100+ tests)
- 🏗️ Feature-based architecture
- 🔄 Type-safe routing with go_router
- 🎯 State management with Riverpod v3

## Getting Started

### Prerequisites

- **Flutter SDK**: This project uses [FVM](https://fvm.app/) to manage the Flutter version
- **Git**: For version control

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/KLEAK-DEVELOPMENT/tic_tac_toe.git
   cd tic_tac_toe
   ```

2. **Install FVM** (if not already installed)
   ```bash
   dart pub global activate fvm
   ```

3. **Install the correct Flutter version**
   ```bash
   fvm install
   ```

4. **Get dependencies**
   ```bash
   fvm flutter pub get
   ```

5. **Generate code** (for providers and routing)
   ```bash
   fvm flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. **Generate localizations**
   ```bash
   fvm flutter gen-l10n
   ```

### Running the App

```bash
# Run in debug mode
fvm flutter run

# Run on a specific device
fvm flutter run -d chrome
fvm flutter run -d ios
fvm flutter run -d android

# Run in release mode
fvm flutter run --release
```

## Development

### Project Structure

```
lib/
├── main.dart                 # Entry point
└── src/
    ├── app.dart              # Root app widget
    ├── core/                 # Shared utilities, themes, routing
    │   ├── extensions/
    │   ├── l10n/             # Internationalization
    │   ├── providers/        # App-level providers
    │   ├── routing/          # go_router configuration
    │   └── theme/            # Theme definitions
    ├── features/             # Feature modules
    │   ├── menu/             # Menu screen
    │   └── game_modes/       # Game implementations
    │       ├── shared/       # Shared game logic
    │       └── two_player/   # Two-player mode
    └── shared/               # Shared widgets
```

For detailed architecture documentation, see [CLAUDE.md](CLAUDE.md).

### Commands

```bash
# Development
fvm flutter run                    # Run app
fvm flutter analyze                # Static analysis
fvm flutter format .               # Format code

# Testing
fvm flutter test                   # Unit & widget tests
fvm flutter test --coverage        # With coverage
fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/two_player_game_test.dart \
  -d chrome                        # Integration tests

# Code Generation
fvm flutter pub run build_runner build              # Generate once
fvm flutter pub run build_runner watch              # Watch mode
fvm flutter gen-l10n                                 # Generate i18n

# Dependencies
fvm flutter pub get                # Install
fvm flutter pub upgrade            # Upgrade
fvm flutter pub outdated           # Check outdated

# Building
fvm flutter build web              # Web
fvm flutter build apk              # Android
fvm flutter build ios              # iOS
```

## Testing

The project includes comprehensive test coverage:

- **Unit Tests**: Game logic, models, providers
- **Widget Tests**: UI components
- **Integration Tests**: Complete user flows across all languages

```bash
# Run all unit and widget tests
fvm flutter test

# Run with coverage
fvm flutter test --coverage

# Run integration tests
fvm flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/two_player_game_test.dart \
  -d chrome
```

**Test Coverage**: 100+ tests covering:
- Game logic (win detection, draw detection, move validation)
- State management (providers)
- UI components
- Multi-language support
- Theme switching

## Architecture

This project follows a **features-based architecture** with:

- **State Management**: Riverpod v3 with code generation
- **Routing**: go_router with type-safe routes
- **Internationalization**: Flutter's built-in l10n framework
- **Code Generation**: build_runner for providers and routes

Key architectural decisions:
- Features are self-contained modules
- Shared logic uses top-level constants and extension methods
- Models are pure data classes
- Providers handle business logic
- UI components are presentation-only

For detailed architecture documentation, see [CLAUDE.md](CLAUDE.md).

## Internationalization

The app supports 4 languages:
- 🇺🇸 English (en)
- 🇫🇷 French (fr)
- 🇪🇸 Spanish (es)
- 🇩🇪 German (de)

Translation files are in `lib/src/core/l10n/arb/`. After modifying ARB files, run:

```bash
fvm flutter gen-l10n
```

## Accessibility

The app is fully accessible with:
- Semantic labels for all interactive elements
- Live regions for dynamic content updates
- Screen reader support
- Keyboard navigation support

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Run tests (`fvm flutter test`)
4. Run analyze (`fvm flutter analyze`)
5. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
6. Push to the branch (`git push origin feature/AmazingFeature`)
7. Open a Pull Request

## License

This project is part of KLEAK-DEVELOPMENT.

## Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- State management: [Riverpod](https://riverpod.dev/)
- Routing: [go_router](https://pub.dev/packages/go_router)
- Testing: [flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) & [integration_test](https://github.com/flutter/flutter/tree/main/packages/integration_test)
