import 'package:flutter/material.dart';
// Las pantallas
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/courses/pendientes_sreen.dart';
import '../../features/courses/class_detail_screen.dart';
import '../../features/admin/admin_screen.dart';
import '../../features/courses/task_detail_screen.dart';
import '../../features/profile/profile_screen.dart';

class AppRoutes {
  AppRoutes._();

  //  las rutas
  static const String login = '/login';
  static const String home = '/home';
  static const String pendientes = '/pendientes';
  static const String classDetail = '/class-detail';
  static const String admin = '/admin';
  static const String taskDetail = '/task-detail';
  static const String profile = '/profile';

  // Mapa de rutas
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    pendientes: (context) => const PendientesScreen(),
    classDetail: (context) => const ClassDetailScreen(),
    admin: (context) => const AdminScreen(),
    taskDetail: (context) => const TaskDetailScreen(),
    profile: (context) => const ProfileScreen(),
  };
}
