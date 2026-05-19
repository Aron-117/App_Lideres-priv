import 'package:app_lideres/core/utils/user_roles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../utils/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/course_provider.dart'; // NUEVO: Importamos el provider de cursos

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final bool canManageUsers = user?.role.canManageUsers ?? false;
    
    // NUEVO: Escuchamos los cursos del backend que ya cargó el HomeScreen
    final courseProvider = context.watch<CourseProvider>();

    // Lista de colores para alternar en los iconos de las materias
    final List<Color> avatarColors = [
      Colors.cyan.shade100,
      Colors.orange.shade100,
      Colors.blue.shade100,
      Colors.purple.shade100,
      Colors.teal.shade100,
    ];

    return Drawer(
      backgroundColor: AppColors.surfaceWhite,
      child: Column(
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
                    fontWeight: FontWeight.bold,
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
                
                // 1. CORRECCIÓN: Botón "Pendientes" antes del desplegable de clases
                _buildDrawerItem(
                  icon: Icons.assignment_rounded,
                  label: 'Pendientes',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.pendientes);
                  },
                ),

                // 2. CORRECCIÓN: Desplegable dinámico conectado al backend
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(Icons.school_rounded, color: AppColors.primaryDark, size: 26),
                    title: const Text(
                      'Clases que cursas',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    iconColor: AppColors.primaryDark,
                    collapsedIconColor: AppColors.primaryDark,
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    children: [
                      // Validamos estados de carga o si no hay cursos
                      if (courseProvider.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: SizedBox(
                              width: 24, 
                              height: 24, 
                              child: CircularProgressIndicator(strokeWidth: 2)
                            )
                          ),
                        )
                      else if (courseProvider.courses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No tienes materias asignadas.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        )
                      else
                        // Generamos las materias dinámicamente con un for
                        for (int i = 0; i < courseProvider.courses.length; i++)
                          _buildMateriaItem(
                            context: context,
                            nombre: courseProvider.courses[i].title,
                            // Si tu modelo tiene una propiedad sigla específica, cámbiala aquí.
                            // Por ahora usamos la descripción asumiendo que contiene detalles breves.
                            sigla: courseProvider.courses[i].description, 
                            inicial: courseProvider.courses[i].title.isNotEmpty 
                                ? courseProvider.courses[i].title[0].toUpperCase() 
                                : 'C',
                            color: avatarColors[i % avatarColors.length], // Alterna colores cíclicamente
                            courseId: courseProvider.courses[i].id,
                          ),
                    ],
                  ),
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
        ],
      ),
    );
  }

  // Widget auxiliar estándar
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
      visualDensity: VisualDensity.compact,
    );
  }

  // Widget auxiliar dinámico para las materias
// Widget auxiliar dinámico para las materias
  Widget _buildMateriaItem({
    required BuildContext context,
    required String nombre,
    required String sigla,
    required String inicial,
    required Color color,
    required int courseId, // <--- ¡LA SOLUCIÓN! Cambiamos String por int
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 45, right: 20),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color,
        child: Text(
          inicial,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      title: Text(
        nombre,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        sigla,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pop(context); // Cierra el Drawer
        // Navegación exacta a como la tienes en el HomeScreen
        Navigator.pushNamed(
          context,
          AppRoutes.classDetail,
          arguments: courseId, // Ahora pasa el int correctamente
        );
      },
      visualDensity: VisualDensity.compact,
    );
  }
}