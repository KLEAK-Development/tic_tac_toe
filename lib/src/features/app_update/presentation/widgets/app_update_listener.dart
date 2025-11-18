import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/features/app_update/providers/app_update_provider.dart';

/// Widget that listens for app updates and displays a SnackBar notification.
///
/// This widget wraps its child and monitors the app update status.
/// When a new version is detected (via service worker on web), it shows
/// a Material SnackBar with a refresh button.
///
/// Usage:
/// ```dart
/// MaterialApp.router(
///   builder: (context, child) {
///     return AppUpdateListener(child: child ?? const SizedBox.shrink());
///   },
/// )
/// ```
class AppUpdateListener extends ConsumerWidget {
  const AppUpdateListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for update status changes and show SnackBar
    ref.listen<AsyncValue<bool>>(
      appUpdateStatusProvider,
      (previous, next) {
        // Only show SnackBar when transitioning from false to true
        // This prevents showing on initial load and handles deduplication
        next.whenData((isUpdateAvailable) {
          // Extract previous value, defaulting to false if not available
          final previousData = previous?.when(
                data: (value) => value,
                loading: () => false,
                error: (_, _) => false,
              ) ??
              false;

          if (isUpdateAvailable && !previousData) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.appUpdateAvailable),
                duration: const Duration(days: 365), // Keep visible
                action: SnackBarAction(
                  label: context.l10n.appUpdateRefresh,
                  onPressed: () {
                    ref.read(appUpdateStatusProvider.notifier).reloadApp();
                  },
                ),
              ),
            );
          }
        });
      },
    );

    return child;
  }
}
