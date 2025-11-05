import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe/src/core/providers/database_provider.dart';
import 'package:tic_tac_toe/src/features/locale_settings/data/locale_repository.dart';

part 'locale_provider.g.dart';

/// Sentinel value used by UI components (like PopupMenuButton) to represent
/// "System Default" locale selection.
///
/// Flutter's PopupMenuButton doesn't trigger the onSelected callback when a
/// PopupMenuItem has a null value - it treats it as menu dismissal instead.
/// This sentinel value works around that limitation. The AppLocale provider
/// automatically converts this sentinel to null internally.
const Locale systemDefaultLocale = Locale('__system__');

/// Provider for the locale repository
@riverpod
LocaleRepository localeRepository(Ref ref) {
  final db = ref.read(appDatabaseProvider);
  return LocaleRepository(db);
}

/// Provider for the app's locale
///
/// Loads the initial locale from the database and persists changes.
/// Returns null by default, which means the app will use the device's locale.
/// Call setLocale() to change the app's language at runtime.
@riverpod
class AppLocale extends _$AppLocale {
  @override
  Future<Locale?> build() async {
    // Load saved locale from database
    final repository = ref.read(localeRepositoryProvider);
    final locale = await repository.getLocale();
    return locale;
  }

  /// Sets the app locale and persists it to the database
  ///
  /// Pass null to use the device's locale, or pass a specific Locale to use
  /// that language. You can also pass [systemDefaultLocale] which will be
  /// automatically converted to null internally.
  Future<void> setLocale(Locale? newLocale) async {
    // Convert sentinel value to null automatically
    final locale = (newLocale == systemDefaultLocale) ? null : newLocale;

    // Update in-memory state immediately for responsive UI
    state = AsyncValue.data(locale);

    // Persist to database asynchronously (fire and forget - don't await to avoid blocking)
    final repository = ref.read(localeRepositoryProvider);
    // ignore: unawaited_futures
    repository.saveLocale(locale);
  }
}

/// Derived provider that computes the effective locale to use
///
/// Returns the user's preferred locale if set, otherwise returns the device's
/// system locale. This ensures MaterialApp always receives a concrete Locale
/// object, which is necessary for proper locale switching behavior.
@riverpod
Locale effectiveLocale(Ref ref) {
  final asyncLocale = ref.watch(appLocaleProvider);

  // Handle loading and error states by returning system locale
  final preferredLocale = asyncLocale.when(
    data: (locale) => locale,
    loading: () => null,
    error: (_, _) => null,
  );

  // If user explicitly selected a locale, use it
  if (preferredLocale != null) {
    return preferredLocale;
  }

  // Otherwise use device's system locale
  return WidgetsBinding.instance.platformDispatcher.locale;
}
