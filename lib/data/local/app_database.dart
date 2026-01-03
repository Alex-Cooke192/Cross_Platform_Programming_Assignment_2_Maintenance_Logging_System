import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/inspections.dart';
import 'tables/tasks.dart';
import 'tables/audit_events.dart';
import 'tables/outbox.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Inspections, Tasks, AuditEvents, OutboxItems],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'rampcheck.sqlite'));
    return NativeDatabase(file);
  });
}
