import 'dart:convert';

import '../../models/inspection_statuses.dart';
import '../../models/outbox_entity_types.dart';
import '../../models/outbox_types.dart';

import '../../models/ui_models.dart';
import '../local/daos/inspection_dao.dart';
import '../local/daos/task_dao.dart';
import '../local/daos/outbox_dao.dart';
import '../local/tables/inspections.dart';
import '../local/tables/tasks.dart';

import '../local/app_database.dart';

/// Repository = app/business logic over DAOs.
/// - Reads from DB via DAO streams
/// - Writes via DAO updates
/// - Enqueues outbox items for sync
class InspectionRepository {
  final InspectionDao _inspectionDao;
  final TaskDao _taskDao;
  final OutboxDao _outboxDao;

  InspectionRepository({
    required InspectionDao inspectionDao,
    required TaskDao taskDao,
    required OutboxDao outboxDao,
  })  : _inspectionDao = inspectionDao,
        _taskDao = taskDao,
        _outboxDao = outboxDao;

  // -----------------------------
  // Streams for 3 UI buckets
  // -----------------------------

  Stream<List<InspectionUi>> watchOutstandingInspections() {
    return _inspectionDao
        .watchByStatus(InspectionStatuses.outstanding)
        .map((rows) => rows.map<InspectionUi>(_mapInspectionRowToUi).toList());
  }

  Stream<List<InspectionUi>> watchInProgressInspections() {
    return _inspectionDao
        .watchByStatus(InspectionStatuses.inProgress)
        .map((rows) => rows.map<InspectionUi>(_mapInspectionRowToUi).toList());
  }

  Stream<List<InspectionUi>> watchCompletedAwaitingSyncInspections() {
    return _inspectionDao
        .watchByStatus(InspectionStatuses.completedAwaitingSync)
        .map((rows) => rows.map<InspectionUi>(_mapInspectionRowToUi).toList());
  }


 // Counters for each inspection status
  Stream<int> watchReadyToBeginCount() {
  // "Ready to begin" corresponds to "outstanding"
  return _inspectionDao.watchReadyToBeginCount();
  }

  Stream<int> watchInProgressCount() {
    return _inspectionDao.watchInProgressCount();
  }

  Stream<int> watchAwaitingSyncCount() {
    // "Awaiting sync" corresponds to "completedAwaitingSync"
    return _inspectionDao.watchAwaitingSyncCount();
  }

  // -----------------------------
  // Details
  // -----------------------------

  Stream<InspectionUi?> watchInspection(String inspectionId) {
    return _inspectionDao
        .watchById(inspectionId)
        .map((row) => row == null ? null : _mapInspectionRowToUi(row));
  }

  Stream<List<TaskUi>> watchTasksForInspection(String inspectionId) {
    return _taskDao
        .watchForInspection(inspectionId)
        .map((rows) => rows.map<TaskUi>(_mapTaskRowToUi).toList());
  }

  

  // -----------------------------
  // Business actions
  // -----------------------------

  /// When the user hits "Start inspection".
  /// - sets status to in_progress
  /// - sets openedAt if missing (optional)
  /// - enqueues an outbox item
  Future<void> startInspection({
    required String inspectionId,
    required String technicianUid,
  }) async {
    final now = DateTime.now();

    await _inspectionDao.markInProgress(
      inspectionId, DateTime.now(),
    );

    await _outboxDao.enqueue(
      type: OutboxTypes.inspectionStarted,
      entityType: OutboxEntityTypes.inspection,
      entityLocalId: inspectionId,
      payloadJson: jsonEncode({
        'inspectionId': inspectionId,
        'technicianUid': technicianUid,
        'status': InspectionStatuses.inProgress,
        'occurredAt': now.toIso8601String(),
      }),
      operation: 'update',
      status: 'pending',
      idempotencyKey: 'inspection_started:$inspectionId:${now.millisecondsSinceEpoch}',
    );
  }

  /// When the user completes the inspection.
  /// - sets status to completed_awaiting_sync (matches your UI bucket)
  /// - sets closedAt
  /// - marks dirty
  /// - enqueues outbox item
  Future<void> completeInspection({
    required String inspectionId,
    required String technicianUid,
  }) async {
    final now = DateTime.now();

    await _inspectionDao.markCompleted(
      inspectionId, DateTime.now(), 
    );

    await _outboxDao.enqueue(
      type: OutboxTypes.inspectionCompleted,
      entityType: OutboxEntityTypes.inspection,
      entityLocalId: inspectionId,
      payloadJson: jsonEncode({
        'inspectionId': inspectionId,
        'technicianUid': technicianUid,
        'status': InspectionStatuses.completedAwaitingSync,
        'closedAt': now.toIso8601String(),
      }),
      operation: 'update',
      status: 'pending',
      idempotencyKey: 'inspection_completed:$inspectionId:${now.millisecondsSinceEpoch}',
    );
  }

  /*
  /// Optional: pausing an inspection (if your UI supports it).
  /// You can either:
  /// - set status back to outstanding, or
  /// - create a separate 'paused' status constant.
  Future<void> pauseInspection({
    required String inspectionId,
    required String technicianUid,
  }) async {
    final now = DateTime.now();

    // If you want a true paused state, add:
    // static const paused = 'paused';
    // and use that here.
    await _inspectionDao.updateInspection(
      inspectionId: inspectionId,
      status: InspectionStatuses.outstanding,
      lastModifiedAt: now,
      syncStatus: 'dirty',
    );

    await _outboxDao.enqueue(
      type: OutboxTypes.inspectionPaused,
      entityType: OutboxEntityTypes.inspection,
      entityLocalId: inspectionId,
      payloadJson: jsonEncode({
        'inspectionId': inspectionId,
        'technicianUid': technicianUid,
        'status': InspectionStatuses.outstanding,
        'occurredAt': now.toIso8601String(),
      }),
      operation: 'update',
      status: 'pending',
      idempotencyKey: 'inspection_paused:$inspectionId:${now.millisecondsSinceEpoch}',
    );
  }
  */

  // -----------------------------
  // Mapping Drift rows -> UI models
  // -----------------------------

  InspectionUi _mapInspectionRowToUi(Inspection row) {
    // Adjust to match your actual InspectionUi fields.
    return InspectionUi(
      id: row.id,
      aircraftTailNumber: row.aircraftTailNumber,
      openedByTechnicianUid: row.openedByTechnicianUid,
      openedAt: row.openedAt,
      closedAt: row.closedAt,
      status: row.status,
      synced: row.synced, 
    );
  }

  TaskUi _mapTaskRowToUi(Task row) {
    // Adjust to match your actual TaskUi fields.
    return TaskUi(
      id: row.id,
      serverId: row.serverId,
      inspectionId: row.inspectionId,
      title: row.title,
      code: row.code,
      description: row.description,
      result: row.result, // you used resultLabel earlier in UI
      notes: row.notes,
      completed: row.completed,
      completedAt: row.completedAt, 
      lastModifiedAt: row.lastModifiedAt, 
      synced: row.synced, 
    );
  }
}
