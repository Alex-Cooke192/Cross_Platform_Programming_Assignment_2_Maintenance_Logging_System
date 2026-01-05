import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/outbox_items.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [OutboxItems])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(AppDatabase db) : super(db);

  /// Enqueue an outbox item to be sent to the server.
  Future<int> enqueue({
    required String type,          // e.g. 'TASK_COMPLETED'
    required String entityType,    // e.g. 'task'
    required String entityLocalId, // local UUID or local id
    required String payloadJson,   // minimal JSON payload
    String operation = 'update',   // 'create'/'update'/'delete'
    String status = 'pending',     // 'pending'/'sending'/'sent'/'failed'
    String? idempotencyKey,
  }) {
    return into(outboxItems).insert(
      OutboxItemsCompanion.insert(
        type: type,
        entityType: entityType,
        entityLocalId: entityLocalId,
        payloadJson: payloadJson,
        createdAt: DateTime.now(),
        operation: Value(operation),
        status: Value(status),
        idempotencyKey: Value(idempotencyKey),
        retryCount: const Value(0),
        lastAttemptAt: const Value.absent(),
        lastError: const Value.absent(),
      ),
    );
  }

  /// Watch pending work for UI/debug pages.
  Stream<List<OutboxItem>> watchPending({int limit = 100}) {
    return (select(outboxItems)
          ..where((o) => o.status.equals('pending'))
          ..orderBy([(o) => OrderingTerm.asc(o.createdAt)])
          ..limit(limit))
        .watch();
  }

  /// Get the next batch of items to send (one-shot).
  Future<List<OutboxItem>> getNextPending({int limit = 20}) {
    return (select(outboxItems)
          ..where((o) => o.status.equals('pending'))
          ..orderBy([(o) => OrderingTerm.asc(o.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Mark an item as sending.
  Future<void> markSending(int id) {
    return (update(outboxItems)..where((o) => o.id.equals(id))).write(
      OutboxItemsCompanion(
        status: const Value('sending'),
        lastAttemptAt: Value(DateTime.now()),
        lastError: const Value(null),
      ),
    );
  }

  /// Mark an item as sent (success).
  Future<void> markSent(int id) {
    return (update(outboxItems)..where((o) => o.id.equals(id))).write(
      OutboxItemsCompanion(
        status: const Value('sent'),
        lastAttemptAt: Value(DateTime.now()),
        lastError: const Value(null),
      ),
    );
  }

  /// Mark an item as failed (keeps it for retry or manual inspection).
  Future<void> markFailed(int id, String error) async {
    await transaction(() async {
      final row = await (select(outboxItems)..where((o) => o.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;

      await (update(outboxItems)..where((o) => o.id.equals(id))).write(
        OutboxItemsCompanion(
          status: const Value('failed'),
          retryCount: Value(row.retryCount + 1),
          lastAttemptAt: Value(DateTime.now()),
          lastError: Value(error),
        ),
      );
    });
  }

  /// Reset failed items back to pending (e.g. when network returns).
  Future<void> retryAllFailed() {
    return (update(outboxItems)..where((o) => o.status.equals('failed'))).write(
      OutboxItemsCompanion(
        status: const Value('pending'),
      ),
    );
  }

  /// Optional cleanup: remove sent items after some time.
  Future<int> deleteSentOlderThan(DateTime cutoff) {
    return (delete(outboxItems)
          ..where((o) => o.status.equals('sent') & o.createdAt.isSmallerThanValue(cutoff)))
        .go();
  }
}
