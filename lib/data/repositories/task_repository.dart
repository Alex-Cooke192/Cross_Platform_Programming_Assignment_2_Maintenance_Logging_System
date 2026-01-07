import 'package:drift/drift.dart';

import '../local/daos/task_dao.dart';
import '../local/tables/tasks.dart';

import '../local/app_database.dart';

class TaskRepository {
  TaskRepository(this._taskDao);

  final TaskDao _taskDao;

  Stream<List<Task>> watchForInspection(String inspectionId) {
    return _taskDao.watchForInspection(inspectionId);
  }

  // Reads task by id
  Stream<Task?> watchById(String taskId) {
    return _taskDao.watchById(taskId);
  }

  Future<Task?> getById(String taskId) {
    return _taskDao.getById(taskId);
  }


  Future<void> setCompleted({
    required String taskId,
    required bool completed,
  }) {
    // DAO owns completedAt + lastModifiedAt + version + syncStatus
    return _taskDao.updateCompleted(taskId: taskId, completed: completed);
  }

  /// Sets the task result.
  Future<void> setResult({
    required String taskId,
    String? result, // "pass" | "fail" | "na" | null
  }) {
    // null means "do nothing"
    if (result == null) return Future.value();

    return _taskDao.updateResult(taskId: taskId, result: result);
  }

  /// Sets notes.
  Future<void> setNotes({
    required String taskId,
    String? notes,
  }) {
    // Option 1: null means "do nothing"
    if (notes == null) return Future.value();

    return _taskDao.updateNotes(taskId: taskId, notes: notes);
  }

  /// Convenience for when your UI submits multiple fields together.
  /// (Prefer this over calling setResult + setNotes + setCompleted separately.)
  Future<void> updateWork({
    required String taskId,
    String? result,
    String? notes,
    bool? completed,
  }) {
    return _taskDao.updateTaskWork(
      taskId: taskId,
      result: result,
      notes: notes,
      completed: completed,
    );
  }

  // --- Sync bookkeeping ---

  Future<void> markClean({required String taskId}) {
    return _taskDao.markClean(taskId);
  }

  Future<void> markSyncError({
    required String taskId,
    required String error,
  }) {
    return _taskDao.markSyncError(taskId, error);
  }

  Future<void> softDelete({required String taskId}) {
    return _taskDao.softDelete(taskId);
  }
}
