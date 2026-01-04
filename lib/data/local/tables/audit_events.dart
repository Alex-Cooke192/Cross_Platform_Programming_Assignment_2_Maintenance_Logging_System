import 'package:drift/drift.dart';
import '../converters/sync_converters.dart';

class AuditEvents extends Table {
  TextColumn get id => text()(); // UUID

  // New (sync-ready)
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text()
      .map(const SyncStatusConverter())
      .withDefault(const Constant('dirty'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get syncError => text().nullable()();

  // Existing
  TextColumn get entityType => text()(); // inspection/task/evidence/auth
  TextColumn get entityId => text()();   // UUID string

  TextColumn get action => text()();     // created/updated/completed/closed/etc
  TextColumn get technicianUid => text()();

  DateTimeColumn get occurredAt => dateTime()();

  TextColumn get metadataJson => text().nullable()();

  // Legacy (keep for 1 migration, remove later if you want)
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

