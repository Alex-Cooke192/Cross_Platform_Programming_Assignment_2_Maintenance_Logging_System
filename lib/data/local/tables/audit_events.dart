import 'package:drift/drift.dart';

class AuditEvents extends Table {
  TextColumn get id => text()(); // UUID (helps syncing audit reliably)

  TextColumn get entityType => text()(); // inspection/task/evidence/auth
  TextColumn get entityId => text()();   // store UUID string

  TextColumn get action => text()();     // created/updated/completed/closed/etc
  TextColumn get technicianUid => text()();

  DateTimeColumn get occurredAt => dateTime()();

  TextColumn get metadataJson => text().nullable()(); // minimal JSON blob
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
