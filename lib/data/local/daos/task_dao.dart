import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tasks.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(AppDatabase db) : super(db);

  /// Watch all tasks for an inspection (auto-updates UI when tasks change).
  Stream<List<Task>> watchForInspection(String inspectionId) {
    return (select(tasks)
          ..where((t) => t.inspectionId.equals(inspectionId))
          ..orderBy([
            // code first if present, then title
            (t) => OrderingTerm.asc(t.code),
            (t) => OrderingTerm.asc(t.title),
          ]))
        .watch();
  }

  /// Watch a single task by id.
  Stream<Task?> watchById(String taskId) {
    return (select(tasks)..where((t) => t.id.equals(taskId))).watchSingleOrNull();
  }

  /// One-shot fetch by id
  Future<Task?> getById(String taskId) {
    return (select(tasks)..where((t) => t.id.equals(taskId))).getSingleOrNull();
  }

  /// Shared update helper that preserves invariants:
  Future<void> _updateTask({
    required String taskId,
    String? result,
    String? notes,
    bool? completed,
  }) async {
    final now = DateTime.now();

    await transaction(() async {
      final existing = await getById(taskId);
      if (existing == null) {
        throw StateError('Task not found: $taskId');
      }

      // Only update completed/completedAt if caller explicitly provided `completed`.
      final bool newCompleted = completed ?? existing.completed;

      final Value<bool> completedValue =
          completed != null ? Value(newCompleted) : const Value.absent();

      final Value<DateTime?> completedAtValue;
      if (completed == null) {
        completedAtValue = const Value.absent();
      } else if (newCompleted) {
        completedAtValue = Value(existing.completedAt ?? now);
      } else {
        completedAtValue = const Value<DateTime?>(null);
      }

      await (update(tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(
          // Only touch fields that were provided.
          result: result != null ? Value(result) : const Value.absent(),
          notes: notes != null ? Value(notes) : const Value.absent(),
          completed: completedValue,
          completedAt: completedAtValue,

          // Always bump these on user work updates.
          lastModifiedAt: Value(now),
          syncStatus: const Value('dirty'),
          version: Value(existing.version + 1),
        ),
      );
    });
  }

  // Split APIs for the above function

  Future<void> updateResult({
    required String taskId,
    required String result, // e.g. 'pass'/'fail'/'na'
  }) {
    return _updateTask(taskId: taskId, result: result);
  }

  Future<void> updateNotes({
    required String taskId,
    required String notes,
  }) {
    return _updateTask(taskId: taskId, notes: notes);
  }

  Future<void> updateCompleted({
    required String taskId,
    required bool completed,
  }) {
    return _updateTask(taskId: taskId, completed: completed);
  }

  Future<void> updateTaskWork({
    required String taskId,
    String? result, // e.g. 'pass'/'fail'/'na'
    String? notes,
    bool? completed,
  }) {
    return _updateTask(
      taskId: taskId,
      result: result,
      notes: notes,
      completed: completed,
    );
  }

  Future<void> markCompleted(String taskId, {String? result, String? notes}) {
    return _updateTask(
      taskId: taskId,
      result: result,
      notes: notes,
      completed: true,
    );
  }

  Future<void> markNotCompleted(String taskId) {
    return updateCompleted(taskId: taskId, completed: false);
  }

  /// Mark as clean after successful sync
  Future<void> markClean(String taskId, {DateTime? syncedAt}) async {
    await (update(tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        syncStatus: const Value('clean'),
        lastSyncedAt: Value(syncedAt ?? DateTime.now()),
        syncError: const Value(null),
      ),
    );
  }

  /// Record a sync failure. 
  Future<void> markSyncError(String taskId, String error) async {
    await (update(tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        syncStatus: const Value('error'),
        syncError: Value(error),
      ),
    );
  }

  /// Soft delete a task locally (tombstone)
  Future<void> softDelete(String taskId) async {
    final now = DateTime.now();
    await (update(tasks)..where((t) => t.id.equals(taskId))).write(
      TasksCompanion(
        deletedAt: Value(now),
        syncStatus: const Value('dirty'),
        lastModifiedAt: Value(now),
      ),
    );
  }
}
