import 'service_worker_registrar.dart';

/// Stub implementation of [ServiceWorkerRegistrar] for non-web platforms.
///
/// Returns null for registration since service workers are only
/// relevant for web platforms.
class ServiceWorkerRegistrarStub implements ServiceWorkerRegistrar {
  @override
  Future<String?> register(ServiceWorkerConfig config) async {
    // No-op on non-web platforms
    return null;
  }

  @override
  bool get isSupported => false;
}

/// Factory implementation for non-web platforms.
ServiceWorkerRegistrar createServiceWorkerRegistrar() =>
    ServiceWorkerRegistrarStub();
