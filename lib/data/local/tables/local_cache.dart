// lib/data/local/tables/local_blob_cache.dart
import 'package:drift/drift.dart';

class LocalCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// DBML note: "evidence_upload, temp_export, etc."
  TextColumn get purpose => text().customConstraint('NOT NULL')();

  TextColumn get localPath =>
      text().named('local_path').customConstraint('NOT NULL')();

  TextColumn get sha256 => text().nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get retentionExpiresAt =>
      dateTime().named('retention_expires_at').nullable()();
}
