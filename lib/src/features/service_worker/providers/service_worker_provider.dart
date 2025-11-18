import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe/src/features/service_worker/data/service_worker_registrar.dart';
import 'package:tic_tac_toe/src/features/service_worker/data/service_worker_registrar_factory.dart';

part 'service_worker_provider.g.dart';

/// Provider for service worker configuration.
///
/// Override this provider to customize the service worker settings:
/// ```dart
/// ProviderScope(
///   overrides: [
///     serviceWorkerConfigProvider.overrideWithValue(
///       const ServiceWorkerConfig(
///         scriptUrl: '/custom-sw.js',
///         scope: '/app/',
///         updateIntervalMs: 1800000,
///       ),
///     ),
///   ],
///   child: const MyApp(),
/// )
/// ```
@riverpod
ServiceWorkerConfig serviceWorkerConfig(Ref ref) {
  return const ServiceWorkerConfig();
}

/// Provider for the service worker registrar singleton.
@riverpod
ServiceWorkerRegistrar serviceWorkerRegistrar(Ref ref) {
  return createServiceWorkerRegistrar();
}

/// Provider that handles service worker registration during app startup.
///
/// This provider is kept alive throughout the app's lifetime and registers
/// the service worker once during initialization.
///
/// Returns the registration scope on success, or null on failure/unsupported.
@Riverpod(keepAlive: true)
Future<String?> serviceWorkerRegistration(Ref ref) async {
  final registrar = ref.watch(serviceWorkerRegistrarProvider);

  if (!registrar.isSupported) {
    return null;
  }

  final config = ref.watch(serviceWorkerConfigProvider);
  return registrar.register(config);
}

/// Initialize service worker registration.
///
/// This function should be called during app startup to register
/// the service worker. It's safe to call on non-web platforms.
///
/// Usage:
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
/// To customize the configuration, override `serviceWorkerConfigProvider`:
/// ```dart
/// ProviderScope(
///   overrides: [
///     serviceWorkerConfigProvider.overrideWithValue(
///       const ServiceWorkerConfig(
///         scriptUrl: '/custom-sw.js',
///         updateIntervalMs: 1800000, // 30 minutes
///       ),
///     ),
///   ],
///   child: const MyApp(),
/// )
/// ```
Future<void> initializeServiceWorker(Ref ref) async {
  await ref.read(serviceWorkerRegistrationProvider.future);
}
