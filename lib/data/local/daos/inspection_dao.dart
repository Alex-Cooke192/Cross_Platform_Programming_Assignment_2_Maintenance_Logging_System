// lib/data/local/db/daos/inspection_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/inspections.dart';
import '../../../models/inspection_statuses.dart';

part 'inspection_dao.g.dart';

@DriftAccessor(tables: [Inspections])
class InspectionDao extends DatabaseAccessor<AppDatabase>
    with _$InspectionDaoMixin {
  InspectionDao(AppDatabase db) : super(db);

  Stream<List<Inspection>> watchByStatus(String status) {
    return (select(inspections)
          ..where((tbl) => tbl.status.equals(status)))
        .watch();
  }

  Stream<Inspection?> watchById(String id) {
    return (select(inspections)
          ..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<void> markInProgress(String id, DateTime openedAt) {
    return (update(inspections)..where((t) => t.id.equals(id))).write(
      InspectionsCompanion(
        status: const Value(InspectionStatuses.inProgress),
        openedAt: Value(openedAt),
        closedAt: const Value.absent(),
      ),
    );
  }

  Future<void> markCompleted(String id, DateTime closedAt) {
    return (update(inspections)..where((t) => t.id.equals(id))).write(
      InspectionsCompanion(
        status: const Value(InspectionStatuses.completedAwaitingSync),
        closedAt: Value(closedAt),
      ),
    );
  }

  // Counts inspections with status = outstanding
  Stream<int> watchReadyToBeginCount() {
    final query = selectOnly(inspections)
      ..addColumns([inspections.id.count()])
      ..where(inspections.status.equals('outstanding'));

    return query.watchSingle().map((row) {
      return row.read(inspections.id.count()) ?? 0;
    });
  }

  // Counts inspections with status = In Progress
  Stream<int> watchInProgressCount() {
    final query = selectOnly(inspections)
      ..addColumns([inspections.id.count()])
      ..where(inspections.status.equals('in_progress'));

    return query.watchSingle().map((row) {
      return row.read(inspections.id.count()) ?? 0;
    });
  }

  // Counts inspections completed but not yet synced
  Stream<int> watchAwaitingSyncCount() {
    final query = selectOnly(inspections)
      ..addColumns([inspections.id.count()])
      ..where(
        inspections.status.equals('completed_awaiting_sync') &
        inspections.syncStatus.isNotIn(['clean']),
      );

    return query.watchSingle().map((row) {
      return row.read(inspections.id.count()) ?? 0;
    });
  }
}
