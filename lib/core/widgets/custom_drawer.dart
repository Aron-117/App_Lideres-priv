import 'package:app_lideres/core/utils/user_roles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../utils/app_routes.dart';
import '../providers/auth_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Leemos el rol para saber qué botones mostrar
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final bool canManageUsers = user?.role.canManageUsers ?? false;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.surfaceWhite,
                  child: Icon(Icons.person, color: AppColors.primaryDark),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'Usuario',
                  style: const TextStyle(color: AppColors.surfaceWhite, fontSize: 18),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: AppColors.surfaceWhite, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.primaryDark),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context); // Cierra el menú
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment, color: AppColors.primaryDark),
            title: const Text('Pendientes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.pendientes);
            },
          ),
          // Solo mostramos Administración si tiene permisos
          if (canManageUsers)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: AppColors.primaryDark),
              title: const Text('Administración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.admin);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
            onTap: () {
              auth.logout();
              // El AuthWrapper en main.dart detectará el cambio y lo mandará al login
            },
          ),
        ],
      ),
    );
  }
}
