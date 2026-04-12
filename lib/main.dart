import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_routes.dart';
import 'core/providers/course_provider.dart';
import 'core/providers/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'core/providers/pending_tasks_provider.dart';
import 'core/providers/admin_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Registramos Auth
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => PendingTasksProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Lideres',
      theme: AppTheme.lightTheme,
      // ELIMINAMOS initialRoute. En su lugar usamos un home reactivo:
      home: const AuthWrapper(),
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

// EL GUARDIÁN DE RUTAS
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // Si está autenticado de forma exitosa, muéstrale el Home
        if (auth.isAuthenticated) {
          return const HomeScreen();
        }
        // Si no, atrapalo en el Login
        return const LoginScreen();
      },
    );
  }
}
