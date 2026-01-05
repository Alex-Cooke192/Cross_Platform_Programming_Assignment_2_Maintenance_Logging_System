// lib/data/local/tables/aircraft_cache.dart
import 'package:drift/drift.dart';

class AircraftCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get tailNumber => text()
      .named('tail_number')
      .customConstraint('UNIQUE NOT NULL')();

  TextColumn get model => text().nullable()();

  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}
