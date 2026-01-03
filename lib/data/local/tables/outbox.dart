import 'package:drift/drift.dart';

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

  TextColumn get type => text()();         // TASK_COMPLETED, INSPECTION_CLOSED, etc.
  TextColumn get entityType => text()();   // task, inspection, evidence
  TextColumn get entityLocalId => text()();

  TextColumn get payloadJson => text()();  // store as JSON string
  DateTimeColumn get createdAt => dateTime()();

  TextColumn get status => text().map(const OutboxStatusConverter())
      .withDefault(const Constant('pending'))();

  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
}
