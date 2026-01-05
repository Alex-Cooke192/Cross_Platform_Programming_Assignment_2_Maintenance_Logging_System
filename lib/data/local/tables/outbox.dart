import 'package:drift/drift.dart';

class OutboxItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Business event info
  // e.g. 'TASK_COMPLETED', 'INSPECTION_CLOSED', 'EVIDENCE_ADDED'
  TextColumn get type => text().customConstraint('NOT NULL')();

  // e.g. 'task', 'inspection', 'evidence'
  TextColumn get entityType => text().named('entity_type').customConstraint('NOT NULL')();

  // local id (string so you can use UUIDs)
  TextColumn get entityLocalId => text().named('entity_local_id').customConstraint('NOT NULL')();

  // e.g. 'create', 'update', 'delete' (string-only)
  TextColumn get operation => text()
      .named('operation')
      .withDefault(const Constant('update'))();

  // helps avoid duplicate server writes
  TextColumn get idempotencyKey => text().named('idempotency_key').nullable()();

  TextColumn get payloadJson => text().named('payload_json').customConstraint('NOT NULL')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  // e.g. 'pending', 'sending', 'sent', 'failed' (string-only)
  TextColumn get status => text()
      .named('status')
      .withDefault(const Constant('pending'))();

  IntColumn get retryCount => integer()
      .named('retry_count')
      .withDefault(const Constant(0))();

  DateTimeColumn get lastAttemptAt => dateTime().named('last_attempt_at').nullable()();

  TextColumn get lastError => text().named('last_error').nullable()();
}

