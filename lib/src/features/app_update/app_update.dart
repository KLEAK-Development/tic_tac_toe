/// App update detection feature
///
/// This feature provides service worker update detection for web platforms.
/// When a new version of the app is available, it notifies the user via a
/// SnackBar with a refresh button.
///
/// Usage:
/// ```dart
/// import 'package:tic_tac_toe/src/features/app_update/app_update.dart';
///
/// // Wrap MaterialApp with AppUpdateListener
/// MaterialApp.router(
///   builder: (context, child) {
///     return AppUpdateListener(child: child!);
///   },
/// )
/// ```
library;

// Data layer
export 'data/app_update_detector.dart';

// Providers
export 'providers/app_update_provider.dart';

// Presentation layer
export 'presentation/widgets/app_update_listener.dart';
