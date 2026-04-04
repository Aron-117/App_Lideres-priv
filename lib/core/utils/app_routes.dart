import 'package:flutter/material.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/courses/pendientes_sreen.dart';

class AppRoutes {
  AppRoutes._();

  //  las rutas
  static const String login = '/login';
  static const String home = '/home';
  static const String pendientes = '/pendientes';

  // Mapa de rutas
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    pendientes: (context) => const PendientesScreen(),
  };
}
