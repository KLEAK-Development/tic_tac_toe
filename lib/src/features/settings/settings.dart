/// Settings feature - fractal architecture parent module
///
/// This barrel file provides a single import point for all settings-related
/// functionality, following the fractal feature pattern. The settings feature
/// contains theme and locale sub-features, each with their own data, providers,
/// and presentation layers.

// Theme settings sub-feature
export 'theme/theme.dart';

// Locale settings sub-feature
export 'locale/locale.dart';
