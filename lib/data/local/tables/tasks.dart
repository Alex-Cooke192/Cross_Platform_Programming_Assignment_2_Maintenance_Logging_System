import 'package:drift/drift.dart';

class Tasks extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get inspectionId => text().named('inspection_id')();

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
  TextColumn get code => text().named('code').nullable()();
  TextColumn get title => text().named('title')();
  TextColumn get description => text().named('description').nullable()();

  /// e.g. 'pass', 'fail', 'na' (string-only)
  TextColumn get result => text().named('result').nullable()();

  TextColumn get notes => text().named('notes').nullable()();

  BoolColumn get completed =>
      boolean().named('completed').withDefault(const Constant(false))();

  DateTimeColumn get completedAt => dateTime().named('completed_at').nullable()();

  DateTimeColumn get lastModifiedAt => dateTime().named('last_modified_at')();

  IntColumn get version => integer().named('version').withDefault(const Constant(1))();

  // Legacy (keep for 1 migration, remove later if you want)
  BoolColumn get synced =>
      boolean().named('synced').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

