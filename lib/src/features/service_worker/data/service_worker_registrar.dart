/// Configuration for service worker registration.
class ServiceWorkerConfig {
  const ServiceWorkerConfig({
    this.scriptUrl = '/sw.js',
    this.scope = '/',
    this.updateIntervalMs = 3600000, // 1 hour
  });

  /// URL path to the service worker script.
  final String scriptUrl;

  /// Scope for the service worker.
  final String scope;

  /// Interval in milliseconds for checking updates.
  /// Default is 1 hour (3600000ms).
  final int updateIntervalMs;
}

/// Interface for registering service workers across platforms.
///
/// Provides methods to register and manage service workers for PWA functionality.
/// On web platforms, this registers the actual service worker.
/// On non-web platforms, this is a no-op.
abstract class ServiceWorkerRegistrar {
  /// Registers the service worker with the given configuration.
  ///
  /// Returns the registration scope on success, or null on failure.
  Future<String?> register(ServiceWorkerConfig config);

  /// Checks if service workers are supported on this platform.
  bool get isSupported;

  /// Factory constructor that returns the appropriate implementation
  /// based on the current platform.
  factory ServiceWorkerRegistrar() {
    return ServiceWorkerRegistrar.createDefault();
  }

  /// Platform-specific factory method.
  ///
  /// This will be implemented differently for web and non-web platforms
  /// using conditional imports.
  static ServiceWorkerRegistrar createDefault() {
    throw UnimplementedError(
      'ServiceWorkerRegistrar.createDefault() must be implemented for this platform',
    );
  }
}
