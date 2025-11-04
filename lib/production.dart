import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:tic_tac_toe/src/app.dart';

void main() {
  // Configure path-based URL strategy (removes # from URLs)
  // This is recommended for production web deployments
  usePathUrlStrategy();

  runApp(const ProviderScope(child: App()));
}
