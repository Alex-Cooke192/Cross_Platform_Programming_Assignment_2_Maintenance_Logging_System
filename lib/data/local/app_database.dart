import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/inspections.dart';
import 'tables/tasks.dart';
import 'tables/audit_events.dart';
import 'tables/outbox.dart';
import 'converters/sync_converters.dart'; 

part 'app_database.g.dart';


@DriftDatabase(
  tables: [Inspections, Tasks, OutboxItems, AuditEvents],
  // daos: [...]
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // --- INSPECTIONS ---
        await m.addColumn(inspections, inspections.serverId);
        await m.addColumn(inspections, inspections.deletedAt);
        await m.addColumn(inspections, inspections.syncStatus);
        await m.addColumn(inspections, inspections.lastSyncedAt);
        await m.addColumn(inspections, inspections.syncError);

        // backfill syncStatus from legacy synced
        await customStatement('''
          UPDATE inspections
          SET sync_status = CASE WHEN synced = 1 THEN 'clean' ELSE 'dirty' END
        ''');

        // --- TASKS ---
        await m.addColumn(tasks, tasks.serverId);
        await m.addColumn(tasks, tasks.deletedAt);
        await m.addColumn(tasks, tasks.syncStatus);
        await m.addColumn(tasks, tasks.lastSyncedAt);
        await m.addColumn(tasks, tasks.syncError);

        await customStatement('''
          UPDATE tasks
          SET sync_status = CASE WHEN synced = 1 THEN 'clean' ELSE 'dirty' END
        ''');

        // --- AUDIT EVENTS ---
        await m.addColumn(auditEvents, auditEvents.serverId);
        await m.addColumn(auditEvents, auditEvents.deletedAt);
        await m.addColumn(auditEvents, auditEvents.syncStatus);
        await m.addColumn(auditEvents, auditEvents.lastSyncedAt);
        await m.addColumn(auditEvents, auditEvents.syncError);

        await customStatement('''
          UPDATE audit_events
          SET sync_status = CASE WHEN synced = 1 THEN 'clean' ELSE 'dirty' END
        ''');

        // --- OUTBOX ---
        await m.addColumn(outboxItems, outboxItems.operation);
        await m.addColumn(outboxItems, outboxItems.idempotencyKey);

        // Backfill outbox operation if you want: default update is already set.
        // Optionally, set idempotencyKey = 'outbox:' || id
        await customStatement('''
          UPDATE outbox_items
          SET idempotency_key = 'outbox:' || id
          WHERE idempotency_key IS NULL
        ''');
      }
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
