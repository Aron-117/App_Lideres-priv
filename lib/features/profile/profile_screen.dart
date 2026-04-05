import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del usuario logueado
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Según tu diseño, tenemos una flecha para volver y una 'X' para cerrar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.primaryDark),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, size: 50, color: AppColors.surfaceWhite),
            ),
            const SizedBox(height: 40),

            // Contenedor de Información (Estilo tarjeta limpia de tu diseño)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(icon: Icons.person, text: user?.name ?? 'Personal Information'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoRow(icon: Icons.email, text: user?.email ?? 'example@gmail.com'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoRow(
                    icon: Icons.admin_panel_settings,
                    // Mostramos el nombre del rol en texto (ej. "admin", "student")
                    text: user?.role.name.toUpperCase() ?? 'ROL',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Botón de Cerrar Sesión
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceWhite,
                foregroundColor: AppColors.error,
                elevation: 0,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context); // Cierra la vista de perfil
                auth.logout(); // Destruye la sesión y te expulsa al Login
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para pintar cada fila del diseño
  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryDark),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
