import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe/src/app.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}
