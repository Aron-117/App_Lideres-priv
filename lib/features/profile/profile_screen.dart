import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del usuario logueado (Lógica intacta)
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // --- 1. HEADER CON DEGRADADO CURVO Y SUPERPOSICIÓN ---
          Stack(
            clipBehavior: Clip.none, // Permite que el avatar sobresalga del contenedor
            children: [
              // Fondo curvo
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(400, 50), // Crea la curva orgánica
                  ),
                ),
              ),
              
              // Botones de navegación (AppBar simulado)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.surfaceWhite),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.surfaceWhite),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),

              // Avatar superpuesto en el borde inferior
              Positioned(
                bottom: -40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundLight, // Borde del mismo color que el fondo de la app
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.secondary,
                      child: Icon(Icons.person_rounded, size: 50, color: AppColors.surfaceWhite),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 50), // Compensamos el espacio que ocupa el avatar salido

          // --- 2. CUERPO DE LA PANTALLA ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Título principal (Nombre y Rol extraídos de la tarjeta)
                  Text(
                    user?.name ?? 'Usuario Líder',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role.name.toUpperCase() ?? 'ROL',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Contenedor de Información con sombras en lugar de bordes duros
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.email_rounded, 
                          label: 'Correo Electrónico', 
                          text: user?.email ?? 'example@gmail.com'
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF0F0F0)),
                        _buildInfoRow(
                          icon: Icons.shield_rounded, 
                          label: 'Nivel de Acceso', 
                          text: user?.role.name.toUpperCase() ?? 'ESTÁNDAR'
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botón de Cerrar Sesión (Outlined para diseño más limpio)
                  SizedBox(
                    width: double.infinity, // Ocupa todo el ancho disponible
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      onPressed: () {
                        Navigator.pop(context); 
                        auth.logout(); 
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget reutilizable rediseñado
  Widget _buildInfoRow({required IconData icon, required String label, required String text}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Ícono dentro de un círculo suave
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Etiqueta pequeña para dar contexto
                Text(
                  label, 
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)
                ),
                const SizedBox(height: 2),
                // Dato real
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
