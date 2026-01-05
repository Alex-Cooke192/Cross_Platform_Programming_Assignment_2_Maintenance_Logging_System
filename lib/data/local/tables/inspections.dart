import 'package:drift/drift.dart';

class Inspections extends Table {
  TextColumn get id => text()(); // UUID string

  // Sync-ready metadata (string-only)
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// e.g. 'dirty', 'clean', 'error' (if you still want this concept).
  /// If you don’t, you can delete this column entirely.
  TextColumn get syncStatus => text()
      .named('sync_status')
      .withDefault(const Constant('dirty'))();

  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();
  TextColumn get syncError => text().named('sync_error').nullable()();

  // Business fields
  TextColumn get aircraftTailNumber => text().named('aircraft_tail_number')();
  TextColumn get openedByTechnicianUid =>
      text().named('opened_by_technician_uid')();

  DateTimeColumn get openedAt => dateTime().named('opened_at')();
  DateTimeColumn get closedAt => dateTime().named('closed_at').nullable()();

  /// Workflow status for UI buckets (string-only).
  /// Suggested values: 'outstanding', 'in_progress', 'completed_awaiting_sync'
  /// (or if you prefer: 'open', 'in_progress', 'closed')
  TextColumn get status => text().named('status')();

  DateTimeColumn get lastModifiedAt => dateTime().named('last_modified_at')();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // Legacy (keep for 1 migration, remove later if you want)
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

