import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe/src/core/database/app_database.dart';

part 'database_provider.g.dart';

/// Provider for the app database singleton
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();

  // Dispose database when provider is disposed
  ref.onDispose(() {
    db.close();
  });

  return db;
}
