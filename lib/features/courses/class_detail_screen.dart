import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/task_list_tile.dart';
import '../../core/utils/user_roles.dart'; // ¡Importante importar tu nuevo modelo!

class ClassDetailScreen extends StatelessWidget {
  // El rool del user
  final UserRole userRole;

  const ClassDetailScreen({
    super.key,
    // Por defecto, temporal para debug
    this.userRole = UserRole.professor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primaryDark),
          onPressed: () {
            Navigator.pop(context);
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

          // Usamos la propiedad 'canEditCourses'
          // para mostrar el botón solo a los roles que pueden editar cursos
          if (userRole.canEditCourses) ...[
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

          const TaskListTile(title: 'Título de tarea', description: 'Descripción breve\nFecha'),
          const TaskListTile(title: 'Anuncio', description: 'Descripción breve\nFecha'),
        ],
      ),
    );
  }
}
