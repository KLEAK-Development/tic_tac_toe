import 'package:drift/drift.dart';

class LocaleSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// Stored locale code (e.g., 'en', 'fr', 'es', 'de')
  /// NULL means system default locale
  TextColumn get localeCode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}


