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
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pendientes',
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 24, color: AppColors.primaryDark),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Sección: Sin fecha límite
          _buildExpansionSection(
            context,
            title: 'Sin fecha limite',
            count: 1,
            tasks: [const TaskListTile(title: 'Título de tarea', description: 'Descripción')],
          ),

          // Sección: Esta semana
          _buildExpansionSection(
            context,
            title: 'Esta semana',
            count: 2,
            tasks: [
              const TaskListTile(title: 'Título de tarea', description: 'Descripción'),
              const TaskListTile(title: 'Título de tarea', description: 'Descripción'),
            ],
          ),

          // Sección: Anterior
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
    return Theme(
      // Esto quita las líneas divisoras feas de flutter
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: count > 0, // Se abre por defecto si hay tareas
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary, fontSize: 16),
            ),
            Text(
              count.toString(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        iconColor: AppColors.textSecondary,
        collapsedIconColor: AppColors.textSecondary,
        children: tasks,
      ),
    );
  }
}
