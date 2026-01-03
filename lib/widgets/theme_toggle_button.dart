import 'package:flutter/material.dart';
import 'package:maintenance_logging_system/app.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Toggle light/dark mode',
      icon: Icon(
        themeController.themeMode.value == ThemeMode.dark
            ? Icons.light_mode
            : Icons.dark_mode,
      ),
      onPressed: () {
        themeController.toggleTheme();
      },
    );
  }
}
