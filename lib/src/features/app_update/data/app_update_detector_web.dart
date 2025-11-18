import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart';

import 'app_update_detector.dart';

/// Web implementation of [AppUpdateDetector].
///
/// Listens for service worker updates by detecting when a new service worker
/// is waiting to activate. When detected, it emits an event through the
/// [updateAvailable] stream.
class AppUpdateDetectorWeb implements AppUpdateDetector {
  AppUpdateDetectorWeb() {
    _init();
  }

  final _updateController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get updateAvailable => _updateController.stream;

  /// Service Worker Update Detection
  void _init() async {
    try {
      // Detect when a new service worker is available
      if (window.navigator.serviceWorker.isDefinedAndNotNull) {
        final registration = await window.navigator.serviceWorker.ready.toDart;

        // Check if there's already a waiting service worker
        if (registration.waiting.isDefinedAndNotNull) {
          _updateController.add(true);
        }

        registration.addEventListener(
          'updatefound',
          () {
            var newWorker = registration.installing;

            newWorker?.addEventListener(
              'statechange',
              () {
                // When the new service worker is installed and waiting
                if (newWorker.state == 'installed' &&
                    window.navigator.serviceWorker.controller != null) {
                  // Notify Flutter app that an update is available
                  _updateController.add(true);
                }
              }.toJS,
            );
          }.toJS,
        );
      }
    } catch (_) {
      // Silently ignore - service worker not supported
    }
  }

  @override
  void reloadApp() {
    // Perform a hard reload to activate the new service worker
    window.location.reload();
  }

  /// Closes the stream controller.
  void dispose() {
    _updateController.close();
  }
}

/// Factory implementation for web platform.
AppUpdateDetector createAppUpdateDetector() => AppUpdateDetectorWeb();
