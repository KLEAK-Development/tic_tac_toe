/// Interface for detecting app updates across platforms.
///
/// Provides a stream that emits when a new app version is available,
/// and a method to reload the app to apply updates.
abstract class AppUpdateDetector {
  /// Stream that emits `true` when an app update is available.
  ///
  /// On web platforms with service workers, this detects when a new
  /// service worker is waiting to activate.
  ///
  /// On non-web platforms, this stream never emits (or could be extended
  /// to support platform-specific update detection).
  Stream<bool> get updateAvailable;

  /// Reloads the app to apply the new version.
  ///
  /// On web, this performs a hard reload of the page.
  /// On other platforms, this could trigger platform-specific update flows.
  void reloadApp();

  /// Factory constructor that returns the appropriate implementation
  /// based on the current platform.
  factory AppUpdateDetector() {
    // Import conditional on platform will be handled by the factory
    return AppUpdateDetector.createDefault();
  }

  /// Platform-specific factory method.
  ///
  /// This will be implemented differently for web and non-web platforms
  /// using conditional imports.
  static AppUpdateDetector createDefault() {
    throw UnimplementedError(
      'AppUpdateDetector.createDefault() must be implemented for this platform',
    );
  }
}
