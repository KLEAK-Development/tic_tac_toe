// Conditional imports based on platform
export 'app_update_detector_stub.dart'
    if (dart.library.html) 'app_update_detector_web.dart';
