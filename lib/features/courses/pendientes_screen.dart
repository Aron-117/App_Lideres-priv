import 'package:app_lideres/core/models/resource_model.dart';
import 'package:app_lideres/features/courses/task_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/task_list_tile.dart';
import '../../core/providers/pending_tasks_provider.dart';
import '../../core/widgets/smart_refresh_wrapper.dart';

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
            body: SmartRefreshWrapper(
              onRefresh: () {
                return provider.loadTasks();
              },
              isLoading: provider.isLoading,
              errorMessage: provider.errorMessage,
              isEmpty:
                  (provider.sinFecha.isEmpty &&
                      provider.estaSemana.isEmpty &&
                      provider.anteriores.isEmpty) ||
                  provider.errorMessage != null,
              emptyMessage: 'No tienes tareas pendientes.',
              onRetry: () => provider.loadTasks(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  _buildExpansionSection(
                    context,
                    title: 'Sin fecha limite',
                    count: provider.sinFecha.length,
                    tasks: provider.sinFecha
                        .map(
                          (t) => TaskListTile(
                            title: t.titulo,
                            description: t.descripcion,
                            onTap: () async {
                              final resource = Resource(
                                id: t.idTarea,
                                title: t.titulo,
                                description: t.descripcion,
                                dueDate: DateTime.parse(t.fechaPublicacion),
                                type: 'tarea',
                              );
                              final updatedTask =
                                  await Navigator.push<Resource>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TaskDetailScreen(),
                                      settings: RouteSettings(
                                        arguments: resource,
                                      ),
                                    ),
                                  );
                              if (updatedTask != null && context.mounted) {
                                context
                                    .read<PendingTasksProvider>()
                                    .loadTasks();
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  _buildExpansionSection(
                    context,
                    title: 'Próximas',
                    count: provider.estaSemana.length,
                    tasks: provider.estaSemana
                        .map(
                          (t) => TaskListTile(
                            title: t.titulo,
                            description: t.descripcion,
                            onTap: () async {
                              final resource = Resource(
                                id: t.idTarea,
                                title: t.titulo,
                                description: t.descripcion,
                                dueDate: DateTime.parse(t.fechaPublicacion),
                                type: 'tarea',
                              );
                              final updatedTask =
                                  await Navigator.push<Resource>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TaskDetailScreen(),
                                      settings: RouteSettings(
                                        arguments: resource,
                                      ),
                                    ),
                                  );
                              if (updatedTask != null && context.mounted) {
                                context
                                    .read<PendingTasksProvider>()
                                    .loadTasks();
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  _buildExpansionSection(
                    context,
                    title: 'Anteriores (Vencidas)',
                    count: provider.anteriores.length,
                    tasks: provider.anteriores
                        .map(
                          (t) => TaskListTile(
                            title: t.titulo,
                            description: t.descripcion,
                            onTap: () async {
                              final resource = Resource(
                                id: t.idTarea,
                                title: t.titulo,
                                description: t.descripcion,
                                dueDate: DateTime.parse(t.fechaEntrega),
                                type: 'tarea',
                              );
                              final updatedTask =
                                  await Navigator.push<Resource>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TaskDetailScreen(),
                                      settings: RouteSettings(
                                        arguments: resource,
                                      ),
                                    ),
                                  );
                              if (updatedTask != null && context.mounted) {
                                context
                                    .read<PendingTasksProvider>()
                                    .loadTasks();
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
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
