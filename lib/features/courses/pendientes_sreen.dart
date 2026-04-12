import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/task_list_tile.dart';

class PendientesScreen extends StatelessWidget {
  const PendientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pendientes',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 22, // Un poco más pequeño para que se vea más elegante
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        // Añadimos padding para que las secciones no toquen los bordes
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildExpansionSection(
            context,
            title: 'Sin fecha limite',
            count: 1,
            tasks: [const TaskListTile(title: 'Título de tarea', description: 'Descripción')],
          ),
          const SizedBox(height: 12), // Separación entre secciones
          _buildExpansionSection(
            context,
            title: 'Esta semana',
            count: 2,
            tasks: [
              const TaskListTile(title: 'Título de tarea', description: 'Descripción'),
              const TaskListTile(title: 'Título de tarea', description: 'Descripción'),
            ],
          ),
          const SizedBox(height: 12),
          _buildExpansionSection(context, title: 'Anterior', count: 0, tasks: []),
        ],
      ),
    );
  }

  Widget _buildExpansionSection(
    BuildContext context, {
    required String title,
    required int count,
    required List<Widget> tasks,
  }) {
    return Container(
      // ALTERACIÓN 1: Envolvemos cada sección en un contenedor con borde y fondo blanco
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: count > 0,
          // ALTERACIÓN 2: Ajustamos el espaciado interno para que respire
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryDark, // Color más fuerte para el título
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              // ALTERACIÓN 3: El contador ahora tiene un pequeño fondo circular para resaltar
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          iconColor: AppColors.primaryDark,
          collapsedIconColor: AppColors.textSecondary,
          children: tasks.isEmpty 
            ? [const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No hay tareas en esta sección', style: TextStyle(color: AppColors.textSecondary)),
              )]
            : tasks,
        ),
      ),
    );
  }
}