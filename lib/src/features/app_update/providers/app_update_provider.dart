import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe/src/features/app_update/data/app_update_detector.dart';
import 'package:tic_tac_toe/src/features/app_update/data/app_update_detector_factory.dart';

part 'app_update_provider.g.dart';

/// Provider for the app update detector singleton
@riverpod
AppUpdateDetector appUpdateDetector(Ref ref) {
  return createAppUpdateDetector();
}

/// Provider that exposes the current update availability state
///
/// Returns `true` if an update is available, `false` otherwise.
/// While loading or on error, returns `false`.
@riverpod
class AppUpdateStatus extends _$AppUpdateStatus {
  @override
  Stream<bool> build() {
    final detector = ref.watch(appUpdateDetectorProvider);
    return detector.updateAvailable;
  }

  /// Reloads the app to apply the available update
  void reloadApp() {
    final detector = ref.read(appUpdateDetectorProvider);
    detector.reloadApp();
  }
}
