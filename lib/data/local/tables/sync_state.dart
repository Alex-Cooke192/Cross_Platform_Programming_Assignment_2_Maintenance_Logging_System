// lib/data/local/tables/sync_state.dart
import 'package:drift/drift.dart';

class SyncState extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get lastSyncAt => dateTime().named('last_sync_at').nullable()();

  DateTimeColumn get lastSuccessfulSyncAt =>
      dateTime().named('last_successful_sync_at').nullable()();

  TextColumn get lastSyncToken => text().named('last_sync_token').nullable()();

  TextColumn get lastSyncError => text().named('last_sync_error').nullable()();
}
