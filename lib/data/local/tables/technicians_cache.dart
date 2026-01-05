// lib/data/local/tables/technicians_cache.dart
import 'package:drift/drift.dart';

class TechniciansCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get technicianUid => text()
      .named('technician_uid')
      .customConstraint('UNIQUE NOT NULL')();

  TextColumn get role => text().customConstraint('NOT NULL')();

  TextColumn get displayName => text().named('display_name').nullable()();

  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}
