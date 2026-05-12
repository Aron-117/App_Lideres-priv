import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/task_list_tile.dart';
import '../../core/providers/pending_tasks_provider.dart';

class PendientesScreen extends StatelessWidget {
  const PendientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Forzamos la carga al abrir la pantalla
    return ChangeNotifierProvider(
      create: (_) => PendingTasksProvider()..loadTasks(),
      child: Consumer<PendingTasksProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryDark,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Pendientes',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 22,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.errorMessage != null
                ? Center(
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      _buildExpansionSection(
                        context,
                        title: 'Sin fecha limite',
                        count: provider.sinFecha.length,
                        tasks: provider.sinFecha
                            .map((t) => TaskListTile(title: t.title, description: t.courseName))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      _buildExpansionSection(
                        context,
                        title: 'Próximas',
                        count: provider.estaSemana.length,
                        tasks: provider.estaSemana
                            .map((t) => TaskListTile(title: t.title, description: t.courseName))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      _buildExpansionSection(
                        context,
                        title: 'Anteriores (Vencidas)',
                        count: provider.anteriores.length,
                        tasks: provider.anteriores
                            .map((t) => TaskListTile(title: t.title, description: t.courseName))
                            .toList(),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  // Tu widget _buildExpansionSection se mantiene exactamente igual que antes.
  Widget _buildExpansionSection(
    BuildContext context, {
    required String title,
    required int count,
    required List<Widget> tasks,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: count > 0,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
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
              ? [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No hay tareas en esta sección',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ]
              : tasks,
        ),
      ),
    );
  }
}
