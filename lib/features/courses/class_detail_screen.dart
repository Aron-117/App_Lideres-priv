import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/task_list_tile.dart';
import '../../core/utils/user_roles.dart'; // ¡Importante importar tu nuevo modelo!
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/custom_drawer.dart'; // Para el menú lateral
import '../../core/utils/app_routes.dart'; // Para navegar al detalle de la materia

class ClassDetailScreen extends StatelessWidget {
  const ClassDetailScreen({super.key}); // <-- Constructor

  @override
  Widget build(BuildContext context) {
    // Leemos el rol del usuario que inició sesión.
    // Si por alguna razón es nulo, por seguridad le asignamos rol de estudiante.
    final currentUserRole = context.read<AuthProvider>().currentUser?.role ?? UserRole.student;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const CustomDrawer(), // AGREGAR ESTA LÍNEA
      appBar: AppBar(
        // ... resto de tu código    appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primaryDark),
              onPressed: () {
                // Esto le dice a Flutter: "Busca el Scaffold más cercano y ábrele el menú"
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nombre de Clase',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text('Profesor', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: Placeholder(color: AppColors.primaryDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Usamos la propiedad 'canEditCourses' sobre el rol REAL
          if (currentUserRole.canEditCourses) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceWhite,
                foregroundColor: AppColors.primaryDark,
                elevation: 0,
                side: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Lógica para crear anuncio
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Nuevo anuncio'),
            ),
            const SizedBox(height: 24),
          ],

          // Recuerda el import de rutas arriba
          // import '../../core/utils/app_routes.dart';

          // ... (resto de tu código)
          TaskListTile(
            // Quita el const si lo tenía
            title: 'Título de tarea',
            description: 'Descripción breve\nFecha',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.taskDetail);
            },
          ),
          const TaskListTile(title: 'Anuncio', description: 'Descripción breve\nFecha'),
        ],
      ),
    );
  }
}
