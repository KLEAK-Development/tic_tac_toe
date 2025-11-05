import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:tic_tac_toe/src/features/locale_settings/data/tables/locale_settings_table.dart';
import 'package:tic_tac_toe/src/features/theme_settings/data/tables/theme_settings_table.dart';

part 'app_database.g.dart';

// The locale settings table now lives in the locale feature

/// Main application database
@DriftDatabase(tables: [LocaleSettings, ThemeSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test constructor for dependency injection
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(themeSettings);
      }
    },
  );
}

/// Open database connection with cross-platform support
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    return driftDatabase(
      name: 'tic_tac_toe',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
        onResult: (_) {},
      ),
    );
  });
}
