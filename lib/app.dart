import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RampCheck',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const AppRoot(),
    );
  }
}

/// App-level decision widget
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMP: replace later with login/sync logic
    return const Scaffold(
      body: Center(
        child: Text('RampCheck Home'),
      ),
    );
  }
}

