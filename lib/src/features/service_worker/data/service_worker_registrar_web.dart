import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart';

import 'service_worker_registrar.dart';

/// Web implementation of [ServiceWorkerRegistrar].
///
/// Registers the service worker using the Web API and sets up
/// periodic update checking.
class ServiceWorkerRegistrarWeb implements ServiceWorkerRegistrar {
  Timer? _updateTimer;

  @override
  bool get isSupported {
    try {
      return window.navigator.serviceWorker.isDefinedAndNotNull;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> register(ServiceWorkerConfig config) async {
    if (!isSupported) {
      return null;
    }

    try {
      final registration = await window.navigator.serviceWorker
          .register(
            config.scriptUrl.toJS,
            RegistrationOptions(scope: config.scope),
          )
          .toDart;

      // Set up periodic update checking
      _setupUpdateChecking(registration, config.updateIntervalMs);

      return registration.scope;
    } catch (e) {
      // Registration failed - likely not served over HTTPS or localhost
      return null;
    }
  }

  /// Sets up periodic checking for service worker updates.
  void _setupUpdateChecking(
    ServiceWorkerRegistration registration,
    int intervalMs,
  ) {
    // Cancel any existing timer
    _updateTimer?.cancel();

    // Check for updates periodically
    _updateTimer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (_) {
        try {
          registration.update();
        } catch (_) {
          // Silently ignore update check failures
        }
      },
    );
  }
}

/// Factory implementation for web platform.
ServiceWorkerRegistrar createServiceWorkerRegistrar() =>
    ServiceWorkerRegistrarWeb();
