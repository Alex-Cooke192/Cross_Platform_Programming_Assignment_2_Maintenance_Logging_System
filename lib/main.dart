import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/local/app_database.dart';
import 'data/local/daos/inspection_dao.dart';
import 'data/local/daos/task_dao.dart';
import 'data/local/daos/outbox_dao.dart';
import 'data/repositories/inspection_repository.dart';
import 'data/repositories/task_repository.dart';

void main() {
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ------------------------------------------------------------------
        // Database (single instance, disposed automatically)
        // ------------------------------------------------------------------
        Provider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (_, db) => db.close(),
        ),

        // ------------------------------------------------------------------
        // DAOs (depend on AppDatabase)
        // ------------------------------------------------------------------
        ProxyProvider<AppDatabase, InspectionDao>(
          update: (_, db, __) => InspectionDao(db),
        ),
        ProxyProvider<AppDatabase, TaskDao>(
          update: (_, db, __) => TaskDao(db),
        ),
        ProxyProvider<AppDatabase, OutboxDao>(
          update: (_, db, __) => OutboxDao(db),
        ),

        // ------------------------------------------------------------------
        // Repositories
        // ------------------------------------------------------------------

        /// InspectionRepository needs THREE DAOs
        ProxyProvider3<InspectionDao, TaskDao, OutboxDao, InspectionRepository>(
          update: (_, inspectionDao, taskDao, outboxDao, __) =>
              InspectionRepository(
            inspectionDao: inspectionDao,
            taskDao: taskDao,
            outboxDao: outboxDao,
          ),
        ),

        /// TaskRepository only needs TaskDao
        ProxyProvider<TaskDao, TaskRepository>(
          update: (_, taskDao, __) => TaskRepository(taskDao),
        ),
      ],
      child: const App(),
    );
  }
}

