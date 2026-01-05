// lib/data/local/db/daos/inspection_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/inspections.dart';

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

  Future<void> updateStatus(String id, String status) {
    return (update(inspections)
          ..where((tbl) => tbl.id.equals(id)))
        .write(InspectionsCompanion(status: Value(status)));
  }
}
