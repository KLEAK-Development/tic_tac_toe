// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class LocaleSettings extends Table
    with TableInfo<LocaleSettings, LocaleSettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LocaleSettings(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('1'),
  );
  late final GeneratedColumn<String> localeCode = GeneratedColumn<String>(
    'locale_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, localeCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locale_settings';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocaleSettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocaleSettingsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_code'],
      ),
    );
  }

  @override
  LocaleSettings createAlias(String alias) {
    return LocaleSettings(attachedDatabase, alias);
  }
}

class LocaleSettingsData extends DataClass
    implements Insertable<LocaleSettingsData> {
  final int id;
  final String? localeCode;
  const LocaleSettingsData({required this.id, this.localeCode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || localeCode != null) {
      map['locale_code'] = Variable<String>(localeCode);
    }
    return map;
  }

  LocaleSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocaleSettingsCompanion(
      id: Value(id),
      localeCode: localeCode == null && nullToAbsent
          ? const Value.absent()
          : Value(localeCode),
    );
  }

  factory LocaleSettingsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocaleSettingsData(
      id: serializer.fromJson<int>(json['id']),
      localeCode: serializer.fromJson<String?>(json['localeCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localeCode': serializer.toJson<String?>(localeCode),
    };
  }

  LocaleSettingsData copyWith({
    int? id,
    Value<String?> localeCode = const Value.absent(),
  }) => LocaleSettingsData(
    id: id ?? this.id,
    localeCode: localeCode.present ? localeCode.value : this.localeCode,
  );
  LocaleSettingsData copyWithCompanion(LocaleSettingsCompanion data) {
    return LocaleSettingsData(
      id: data.id.present ? data.id.value : this.id,
      localeCode: data.localeCode.present
          ? data.localeCode.value
          : this.localeCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocaleSettingsData(')
          ..write('id: $id, ')
          ..write('localeCode: $localeCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, localeCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocaleSettingsData &&
          other.id == this.id &&
          other.localeCode == this.localeCode);
}

class LocaleSettingsCompanion extends UpdateCompanion<LocaleSettingsData> {
  final Value<int> id;
  final Value<String?> localeCode;
  const LocaleSettingsCompanion({
    this.id = const Value.absent(),
    this.localeCode = const Value.absent(),
  });
  LocaleSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.localeCode = const Value.absent(),
  });
  static Insertable<LocaleSettingsData> custom({
    Expression<int>? id,
    Expression<String>? localeCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localeCode != null) 'locale_code': localeCode,
    });
  }

  LocaleSettingsCompanion copyWith({
    Value<int>? id,
    Value<String?>? localeCode,
  }) {
    return LocaleSettingsCompanion(
      id: id ?? this.id,
      localeCode: localeCode ?? this.localeCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localeCode.present) {
      map['locale_code'] = Variable<String>(localeCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocaleSettingsCompanion(')
          ..write('id: $id, ')
          ..write('localeCode: $localeCode')
          ..write(')'))
        .toString();
  }
}

class ThemeSettings extends Table
    with TableInfo<ThemeSettings, ThemeSettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ThemeSettings(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('1'),
  );
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, themeMode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'theme_settings';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThemeSettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThemeSettingsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      ),
    );
  }

  @override
  ThemeSettings createAlias(String alias) {
    return ThemeSettings(attachedDatabase, alias);
  }
}

class ThemeSettingsData extends DataClass
    implements Insertable<ThemeSettingsData> {
  final int id;
  final String? themeMode;
  const ThemeSettingsData({required this.id, this.themeMode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || themeMode != null) {
      map['theme_mode'] = Variable<String>(themeMode);
    }
    return map;
  }

  ThemeSettingsCompanion toCompanion(bool nullToAbsent) {
    return ThemeSettingsCompanion(
      id: Value(id),
      themeMode: themeMode == null && nullToAbsent
          ? const Value.absent()
          : Value(themeMode),
    );
  }

  factory ThemeSettingsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThemeSettingsData(
      id: serializer.fromJson<int>(json['id']),
      themeMode: serializer.fromJson<String?>(json['themeMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String?>(themeMode),
    };
  }

  ThemeSettingsData copyWith({
    int? id,
    Value<String?> themeMode = const Value.absent(),
  }) => ThemeSettingsData(
    id: id ?? this.id,
    themeMode: themeMode.present ? themeMode.value : this.themeMode,
  );
  ThemeSettingsData copyWithCompanion(ThemeSettingsCompanion data) {
    return ThemeSettingsData(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThemeSettingsData(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, themeMode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThemeSettingsData &&
          other.id == this.id &&
          other.themeMode == this.themeMode);
}

class ThemeSettingsCompanion extends UpdateCompanion<ThemeSettingsData> {
  final Value<int> id;
  final Value<String?> themeMode;
  const ThemeSettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
  });
  ThemeSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
  });
  static Insertable<ThemeSettingsData> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
    });
  }

  ThemeSettingsCompanion copyWith({Value<int>? id, Value<String?>? themeMode}) {
    return ThemeSettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThemeSettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV2 extends GeneratedDatabase {
  DatabaseAtV2(QueryExecutor e) : super(e);
  late final LocaleSettings localeSettings = LocaleSettings(this);
  late final ThemeSettings themeSettings = ThemeSettings(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localeSettings,
    themeSettings,
  ];
  @override
  int get schemaVersion => 2;
}
