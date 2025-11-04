import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

/// Sentinel value used by UI components (like PopupMenuButton) to represent
/// "System Default" locale selection.
///
/// Flutter's PopupMenuButton doesn't trigger the onSelected callback when a
/// PopupMenuItem has a null value - it treats it as menu dismissal instead.
/// This sentinel value works around that limitation. The AppLocale provider
/// automatically converts this sentinel to null internally.
const Locale systemDefaultLocale = Locale('__system__');

/// Provider for the app's locale
///
/// Returns null by default, which means the app will use the device's locale.
/// Call setLocale() to change the app's language at runtime.
@riverpod
class AppLocale extends _$AppLocale {
  @override
  Locale? build() {
    return null; // Use device locale by default
  }

  /// Sets the app locale
  ///
  /// Pass null to use the device's locale, or pass a specific Locale to use
  /// that language. You can also pass [systemDefaultLocale] which will be
  /// automatically converted to null internally.
  void setLocale(Locale? newLocale) {
    // Convert sentinel value to null automatically
    state = (newLocale == systemDefaultLocale) ? null : newLocale;
  }
}

/// Derived provider that computes the effective locale to use
///
/// Returns the user's preferred locale if set, otherwise returns the device's
/// system locale. This ensures MaterialApp always receives a concrete Locale
/// object, which is necessary for proper locale switching behavior.
@riverpod
Locale effectiveLocale(Ref ref) {
  final preferredLocale = ref.watch(appLocaleProvider);

  // If user explicitly selected a locale, use it
  if (preferredLocale != null) {
    return preferredLocale;
  }

  // Otherwise use device's system locale
  return WidgetsBinding.instance.platformDispatcher.locale;
}
