import 'package:flutter/material.dart';
import 'package:maintenance_logging_system/data/local/app_database.dart';
import 'package:maintenance_logging_system/data/local/daos/inspection_dao.dart';
import 'package:maintenance_logging_system/data/local/daos/outbox_dao.dart';
import 'package:maintenance_logging_system/data/local/daos/task_dao.dart';
import 'package:maintenance_logging_system/data/repositories/inspection_repository.dart';
import 'app.dart';

void main() {
  final db = AppDatabase()
  final inspectionDao = InspectionDao(db); 
  final taskDao = TaskDao(db); 
  final outboxDao = OutboxDao(db); 

  final inspectionRepo = InspectionRepository(
    inspectionDao: inspectionDao, 
    taskDao: taskDao, 
    outboxDao: outboxDao);
  // final taskRepo = TaskRepo(); 

  runApp(const App());
}
