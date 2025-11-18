import 'dart:async';

import 'app_update_detector.dart';

/// Stub implementation of [AppUpdateDetector] for non-web platforms.
///
/// Returns a stream that never emits since service worker updates
/// are only relevant for web platforms.
class AppUpdateDetectorStub implements AppUpdateDetector {
  @override
  Stream<bool> get updateAvailable => const Stream.empty();

  @override
  void reloadApp() {
    // No-op on non-web platforms
    // Could be extended to support platform-specific update mechanisms
  }
}

/// Factory implementation for non-web platforms.
AppUpdateDetector createAppUpdateDetector() => AppUpdateDetectorStub();
