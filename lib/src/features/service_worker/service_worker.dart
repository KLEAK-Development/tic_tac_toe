/// Service worker registration feature for PWA offline support.
///
/// This feature provides service worker registration for web platforms,
/// enabling offline functionality and caching strategies.
///
/// ## Usage
///
/// 1. Import this feature in your app:
/// ```dart
/// import 'package:your_app/src/features/service_worker/service_worker.dart';
/// ```
///
/// 2. Add to your app startup provider:
/// ```dart
/// @Riverpod(keepAlive: true)
/// Future<void> appStartup(Ref ref) async {
///   await Future.wait([
///     initializeServiceWorker(ref),
///     // ... other initialization
///   ]);
/// }
/// ```
///
/// 3. Ensure you have a compiled service worker at `/sw.js` in your
///    `web/` directory.
///
/// ## Portability
///
/// To use this feature in another project:
/// 1. Copy the `service_worker/` folder to your `lib/src/features/`
/// 2. Update imports to match your package name
/// 3. Call `initializeServiceWorker(ref)` in your app startup
/// 4. Ensure you have a service worker script at `web/sw.js`
library;

export 'data/service_worker_registrar.dart' show ServiceWorkerConfig;
export 'providers/service_worker_provider.dart'
    show initializeServiceWorker, serviceWorkerConfigProvider;
