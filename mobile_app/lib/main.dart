import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const RideGuideApp());
}

class RideGuideApp extends StatelessWidget {
  const RideGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Guide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {
        '/auth': (_) => const AuthScreen(),
      },
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == HomeShell.routeName) {
          final role = settings.arguments as String? ?? 'visitor';
          return MaterialPageRoute(
            builder: (_) => HomeShell(role: role),
          );
        }

        return null;
      },
    );
  }
}
