import 'package:drift/drift.dart';

class ThemeSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// Stored theme mode as string: 'light', 'dark'; NULL means 'system'
  TextColumn get themeMode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
