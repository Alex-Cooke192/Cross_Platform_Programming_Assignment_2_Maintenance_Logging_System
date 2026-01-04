import 'package:drift/drift.dart';
import '../converters/sync_converters.dart';

enum OutboxStatus { pending, sending, sent, failed }

class OutboxStatusConverter extends TypeConverter<OutboxStatus, String> {
  const OutboxStatusConverter();
  @override
  OutboxStatus fromSql(String fromDb) =>
      OutboxStatus.values.firstWhere((e) => e.name == fromDb);
  @override
  String toSql(OutboxStatus value) => value.name;
}

class OutboxItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Existing meaning (you can keep using your current "type" for business events)
  TextColumn get type => text()();         // TASK_COMPLETED, INSPECTION_CLOSED, etc.
  TextColumn get entityType => text()();   // task, inspection, evidence
  TextColumn get entityLocalId => text()();

  // New: explicit sync operation (server upsert semantics)
  TextColumn get operation => text()
      .map(const OutboxOpConverter())
      .withDefault(const Constant('update'))();

  // New: idempotency key (helps later to avoid duplicate server writes)
  TextColumn get idempotencyKey => text().nullable()();

  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();

  TextColumn get status => text()
      .map(const OutboxStatusConverter())
      .withDefault(const Constant('pending'))();

  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
}
