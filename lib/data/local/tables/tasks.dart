import 'package:drift/drift.dart';
import '../converters/sync_converters.dart';

enum TaskResult { pass, fail, na }

class TaskResultConverter extends TypeConverter<TaskResult?, String?> {
  const TaskResultConverter();
  @override
  TaskResult? fromSql(String? fromDb) =>
      fromDb == null ? null : TaskResult.values.firstWhere((e) => e.name == fromDb);
  @override
  String? toSql(TaskResult? value) => value?.name;
}

class Tasks extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get inspectionId => text()();

  // New (sync-ready)
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('dirty'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get syncError => text().nullable()();

  // Existing
  TextColumn get code => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();

  TextColumn get result => text().nullable().map(const TaskResultConverter())();
  TextColumn get notes => text().nullable()();

  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  DateTimeColumn get lastModifiedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // Legacy (keep for 1 migration, remove later if you want)
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

