import 'package:flutter/material.dart';
import 'package:tic_tac_toe/src/core/extensions/build_context_extensions.dart';
import 'package:tic_tac_toe/src/core/theme/app_spacing.dart' as spacing;

/// Error widget shown when app initialization fails
///
/// Displays an error message and a retry button when the app fails to load
/// initial data (theme preferences, locale settings, etc.) from the database.
///
/// This widget is rendered inside MaterialApp.router's builder, so it inherits
/// the app's theme and locale configuration.
class AppErrorWidget extends StatelessWidget {
  /// The error that occurred during initialization
  final Object error;

  /// Callback to retry the initialization
  final VoidCallback onRetry;

  const AppErrorWidget({
    required this.error,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(spacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: spacing.md),
              Text(
                context.l10n.appInitializationError,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: spacing.sm),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: spacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
