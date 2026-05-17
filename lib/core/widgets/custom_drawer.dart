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
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final bool canManageUsers = user?.role.canManageUsers ?? false;

    return Drawer(
      // ALTERACIÓN 1: Fondo limpio para que resalten los ítems
      backgroundColor: AppColors.surfaceWhite,
      child: Column(
        // Cambiamos ListView por Column + Expanded para el botón de cerrar abajo
        children: [
          // CABECERA MODERNIZADA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              bottom: 20,
              right: 20,
            ),
            // ALTERACIÓN 2: Degradado para dar profundidad
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.surfaceWhite,
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryDark,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  user?.name ?? 'Usuario',
                  style: const TextStyle(
                    color: AppColors.surfaceWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold, // Texto con más peso
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: AppColors.surfaceWhite.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // LISTA DE OPCIONES
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.assignment_rounded,
                  label: 'Pendientes',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.pendientes);
                  },
                ),
                if (canManageUsers)
                  _buildDrawerItem(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Administración',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.admin);
                    },
                  ),
              ],
            ),
          ),

          // SECCIÓN INFERIOR
          const Divider(indent: 20, endIndent: 20),
          _buildDrawerItem(
            icon: Icons.logout_rounded,
            label: 'Cerrar Sesión',
            color: AppColors.error,
            onTap: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget auxiliar para mantener los ListTile con un estilo moderno y uniforme
  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.primaryDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 26),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
      visualDensity: VisualDensity.compact, // Hace que se vea más estilizado
    );
  }
}
