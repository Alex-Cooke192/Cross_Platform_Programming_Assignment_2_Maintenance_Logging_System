import 'package:drift/drift.dart';

enum SyncStatus { dirty, syncing, clean, error }

class SyncStatusConverter extends TypeConverter<SyncStatus, String> {
  const SyncStatusConverter();
  @override
  SyncStatus fromSql(String fromDb) =>
      SyncStatus.values.firstWhere((e) => e.name == fromDb);
  @override
  String toSql(SyncStatus value) => value.name;
}

enum OutboxOp { create, update, delete }

class OutboxOpConverter extends TypeConverter<OutboxOp, String> {
  const OutboxOpConverter();
  @override
  OutboxOp fromSql(String fromDb) =>
      OutboxOp.values.firstWhere((e) => e.name == fromDb);
  @override
  String toSql(OutboxOp value) => value.name;
}
