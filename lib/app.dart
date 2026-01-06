import 'package:flutter/material.dart';

import 'package:maintenance_logging_system/core/theme/app_theme.dart';
import 'package:maintenance_logging_system/core/theme/theme_controller.dart';
import 'package:maintenance_logging_system/screens/home_screen.dart';
import 'package:maintenance_logging_system/screens/login_screen.dart';

import 'data/local/app_database.dart';
import 'data/repositories/inspection_repository.dart';

final ThemeController themeController = ThemeController();

class App extends StatelessWidget {
  final InspectionRepository inspectionRepo;
  final TaskRepository taskRepo;
  final AppDatabase db; // optional, useful for closing later

  const App({
    super.key,
    required this.inspectionRepo,
    required this.taskRepo,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'RampCheck',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: AppRoot(
            inspectionRepo: inspectionRepo,
            taskRepo: taskRepo,
          ),
        );
      },
    );
  }
}

class AppRoot extends StatelessWidget {
  final InspectionRepository inspectionRepo;
  final TaskRepository taskRepo;

  const AppRoot({
    super.key,
    required this.inspectionRepo,
    required this.taskRepo,
  });

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      inspectionRepo: inspectionRepo,
      taskRepo: taskRepo,
    );
  }
}
