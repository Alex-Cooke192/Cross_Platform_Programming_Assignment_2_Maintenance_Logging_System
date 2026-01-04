import 'package:drift/drift.dart';
import '../converters/sync_converters.dart';

enum InspectionStatus { open, inProgress, closed }

class InspectionStatusConverter extends TypeConverter<InspectionStatus, String> {
  const InspectionStatusConverter();
  @override
  InspectionStatus fromSql(String fromDb) =>
      InspectionStatus.values.firstWhere((e) => e.name == fromDb);
  @override
  String toSql(InspectionStatus value) => value.name;
}

class Inspections extends Table {
  TextColumn get id => text()(); // UUID string

  // New (sync-ready)
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('dirty'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get syncError => text().nullable()();

  // Existing
  TextColumn get aircraftTailNumber => text()();
  TextColumn get openedByTechnicianUid => text()();

  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();

  TextColumn get status =>
      text().map(const InspectionStatusConverter())(); // open/inProgress/closed

  DateTimeColumn get lastModifiedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // Legacy (keep for 1 migration, remove later if you want)
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

