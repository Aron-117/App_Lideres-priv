import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/task_list_tile.dart';
import '../../core/utils/user_roles.dart'; 
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/custom_drawer.dart'; 
import '../../core/utils/app_routes.dart'; 

class ClassDetailScreen extends StatelessWidget {
  const ClassDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lógica funcional intacta
    final currentUserRole = context.read<AuthProvider>().currentUser?.role ?? UserRole.student;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          // Ícono un poco más moderno
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        children: [
          // --- 1. BANNER DE LA CLASE ---
          Container(
            height: 160, // Altura fija para que parezca una portada
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.primaryDark, // Color de respaldo por si no carga la imagen
              image: const DecorationImage(
                // Usé el logo de prueba, pero aquí iría la imagen de tu materia
                image: AssetImage('assets/images/Logo.png'), 
                fit: BoxFit.cover,
                // ALTERACIÓN CLAVE: Este filtro oscurece la imagen para que el texto blanco resalte
                colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end, // Empujamos el texto hacia abajo
              children: [
                Text(
                  'Nombre de Clase',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 26, 
                    color: AppColors.surfaceWhite, // Texto blanco
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Profesor', 
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.surfaceWhite.withOpacity(0.9), // Blanco ligeramente transparente
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- 2. BOTÓN DE EDICIÓN (Solo visible para rol con permisos) ---
          if (currentUserRole.canEditCourses) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceWhite,
                foregroundColor: AppColors.primaryDark,
                elevation: 0,
                side: BorderSide(color: AppColors.secondary.withOpacity(0.3), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Lógica para crear anuncio
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text('Nuevo anuncio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 24),
          ],

          // --- 3. LISTA DE TAREAS ---
          // Pequeño título de sección para dar orden visual
          const Text(
            'Trabajo de clase',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),

          TaskListTile(
            title: 'Título de tarea',
            description: 'Descripción breve\nFecha',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.taskDetail);
            },
          ),
          const TaskListTile(
            title: 'Anuncio', 
            description: 'Descripción breve\nFecha'
          ),
        ],
      ),
    );
  }
}