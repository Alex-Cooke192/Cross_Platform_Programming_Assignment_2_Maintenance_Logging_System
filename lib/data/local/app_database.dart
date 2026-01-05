import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Tables
import 'tables/technicians_cache.dart';
import 'tables/aircraft_cache.dart';
import 'tables/inspections.dart';
import 'tables/tasks.dart';
import 'tables/evidence.dart';
import 'tables/audit_events.dart';
import 'tables/outbox_items.dart';
import 'tables/sync_state.dart';
import 'tables/local_cache.dart';

// DAOs
import 'daos/inspection_dao.dart';
import 'daos/task_dao.dart';
import 'daos/outbox_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    TechniciansCache,
    AircraftCache,
    Inspections,
    Tasks,
    AuditEvents,
    OutboxItems,
    SyncState,
    LocalCache,
  ],
  daos: [
    InspectionDao,
    TaskDao, 
    OutboxDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forExecutor(super.e);

  /// Start at 1 for this schema - new schema
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();

          await into(syncState).insertOnConflictUpdate(
            SyncStateCompanion.insert(
              id: const Value(1),
              lastSyncAt: const Value.absent(),
              lastSuccessfulSyncAt: const Value.absent(),
              lastSyncToken: const Value.absent(),
              lastSyncError: const Value.absent(),
            ),
          );
        },
        onUpgrade: (m, from, to) async {
          // For now: if you're still early in development, simplest is to
          // handle upgrades by destructive reset (delete db) OR write explicit migrations.
          //
          // If you want real migrations, we can add versioned steps here.
        },
        beforeOpen: (details) async {
          // Optional: Enforce foreign keys (only matters if you define FK constraints in Drift).
          // await customStatement('PRAGMA foreign_keys = ON;');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'rampcheck.sqlite'));
    return NativeDatabase(file);
  });
}
