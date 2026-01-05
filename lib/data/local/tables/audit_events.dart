import 'package:drift/drift.dart';

class AuditEvents extends Table {
  TextColumn get id => text()(); // UUID

  // Sync metadata (string-only)
  TextColumn get serverId => text().named('server_id').nullable()();
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  /// e.g. 'dirty', 'clean', 'error'
  TextColumn get syncStatus => text()
      .named('sync_status')
      .withDefault(const Constant('dirty'))();

  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();
  TextColumn get syncError => text().named('sync_error').nullable()();

  // Business fields
  TextColumn get entityType => text().named('entity_type')(); // inspection/task/evidence/auth
  TextColumn get entityId => text().named('entity_id')();     // UUID string (local or server)

  TextColumn get action => text().named('action')();          // created/updated/completed/closed/etc
  TextColumn get technicianUid => text().named('technician_uid')();

  DateTimeColumn get occurredAt => dateTime().named('occurred_at')();

  TextColumn get metadataJson => text().named('metadata_json').nullable()();

  // Legacy
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}


