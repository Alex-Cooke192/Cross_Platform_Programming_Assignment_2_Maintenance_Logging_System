import 'package:flutter/material.dart';
import 'package:maintenance_logging_system/core/theme/app_theme.dart';
import 'package:maintenance_logging_system/core/theme/theme_controller.dart';
import 'package:maintenance_logging_system/screens/login_screen.dart';

final ThemeController themeController = ThemeController();

class App extends StatelessWidget {
  const App({super.key});

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
          home: const AppRoot(),
        );
      },
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}

