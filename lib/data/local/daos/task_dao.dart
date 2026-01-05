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

  /// One-shot fetch (sometimes useful in services).
  Future<Task?> getById(String taskId) {
    return (select(tasks)..where((t) => t.id.equals(taskId))).getSingleOrNull();
  }

  /// Update the user's work on a task.
  /// - updates result/notes
  /// - updates completed/completedAt (optional)
  /// - bumps lastModifiedAt
  /// - marks syncStatus dirty
  /// - increments version
  Future<void> updateTaskWork({
    required String taskId,
    String? result, // e.g. 'pass'/'fail'/'na'
    String? notes,
    bool? completed,
  }) async {
    final now = DateTime.now();

    await transaction(() async {
      final existing = await getById(taskId);
      if (existing == null) {
        throw StateError('Task not found: $taskId');
      }

      final newCompleted = completed ?? existing.completed;
      final completedAtValue = newCompleted
          ? Value(existing.completedAt ?? now)
          : const Value<DateTime?>(null);

      await (update(tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(
          result: Value(result),
          notes: Value(notes),
          completed: Value(newCompleted),
          completedAt: completedAtValue,
          lastModifiedAt: Value(now),
          syncStatus: const Value('dirty'),
          version: Value(existing.version + 1),
        ),
      );
    });
  }

  /// Convenience: just mark a task completed (and dirty).
  Future<void> markCompleted(String taskId, {String? result, String? notes}) {
    return updateTaskWork(
      taskId: taskId,
      result: result,
      notes: notes,
      completed: true,
    );
  }

  /// Convenience: undo completion (and dirty).
  Future<void> markNotCompleted(String taskId) {
    return updateTaskWork(taskId: taskId, completed: false);
  }

  /// Mark as clean after successful sync.
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

  /// Soft delete a task locally (tombstone) + mark dirty.
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
