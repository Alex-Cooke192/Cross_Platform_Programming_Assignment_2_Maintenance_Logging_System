// lib/data/repositories/task_repository.dart
//
// TaskRepository sits between UI and the local DB layer (TaskDao).
// - Converts from Drift rows -> TaskUi
// - Keeps DB concerns inside the DAO

import 'package:maintenance_logging_system/models/ui_models.dart';
import 'package:maintenance_logging_system/data/local/daos/task_dao.dart';

class TaskRepository {
  final TaskDao _taskDao;

  TaskRepository(this._taskDao);

  // ----------------------------
  // Watchers (UI reads)
  // ----------------------------

  /// Watch all tasks for a given inspection (by inspection UUID).
  Stream<List<TaskUi>> watchTasksForInspection(String inspectionId) {
    return _taskDao
        .watchForInspection(inspectionId)
        .map((rows) => rows.map<TaskUi>(_mapTaskRowToUi).toList());
  }

  /// Watch a single task by task UUID.
  Stream<TaskUi?> watchTaskById(String id) {
    return _taskDao.watchById(id).map((row) => row == null ? null : _mapTaskRowToUi(row));
  }

  // ----------------------------
  // Commands (UI writes)
  // ----------------------------

  /// Marks a task complete/incomplete.
  /// - If completing: sets completedAt=now (or keeps existing if already set, depending on DAO)
  /// - Updates lastModifiedAt=now and synced=false
  Future<void> setCompleted({
    required String taskId,
    required bool completed,
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now();

    if (completed) {
      await _taskDao.markCompleted(taskId, completedAt: ts, lastModifiedAt: ts);
    } else {
      await _taskDao.markNotCompleted(taskId, lastModifiedAt: ts);
    }
  }

  /// Sets the result (pass/fail/na) and updates lastModifiedAt + synced.
  Future<void> setResult({
    required String taskId,
    String? result, // "pass" | "fail" | "na" | null
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now();
    await _taskDao.updateResult(taskId, result: result, lastModifiedAt: ts);
  }

  /// Updates notes and bumps lastModifiedAt + synced.
  Future<void> setNotes({
    required String taskId,
    String? notes,
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now();
    await _taskDao.updateNotes(taskId, notes: notes, lastModifiedAt: ts);
  }

  /// Creates or updates a task row (useful if you seed tasks when starting an inspection).
  /// If you don’t need this yet, you can delete it.
  Future<void> upsertTask(TaskUi ui, {DateTime? now}) async {
    final ts = now ?? DateTime.now();
    await _taskDao.upsert(
      TaskUpsertRequest(
        id: ui.id,
        serverId: ui.serverId,
        inspectionId: ui.inspectionId,
        title: ui.title,
        code: ui.code,
        description: ui.description,
        result: ui.result,
        notes: ui.notes,
        completed: ui.completed,
        completedAt: ui.completedAt,
        lastModifiedAt: ui.lastModifiedAt.isBefore(ts) ? ts : ui.lastModifiedAt,
        synced: ui.synced,
      ),
    );
  }

  // ----------------------------
  // Mapping
  // ----------------------------

  // IMPORTANT:
  // Replace `Task` below with your actual Drift-generated row class type for the tasks table.
  // You can find it in your app_database.g.dart (search "class Task").
  TaskUi _mapTaskRowToUi(Task row) {
    return TaskUi(
      id: row.id,
      serverId: row.serverId,
      inspectionId: row.inspectionId,
      title: row.title,
      code: row.code,
      description: row.description,
      result: row.result,
      notes: row.notes,
      completed: row.completed,
      completedAt: row.completedAt,
      lastModifiedAt: row.lastModifiedAt,
      synced: row.synced,
    );
  }
}
