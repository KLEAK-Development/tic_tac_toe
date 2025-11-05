import 'package:flutter/material.dart';

/// Loading widget shown during app initialization
///
/// Displays a centered circular progress indicator while the app is loading
/// initial data (theme preferences, locale settings, etc.) from the database.
///
/// This widget is rendered inside MaterialApp.router's builder, so it inherits
/// the app's theme and locale configuration.
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
