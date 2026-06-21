import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/resource_model.dart';
import '../../core/providers/task_detail_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/resource_provider.dart';
import '../../core/utils/user_roles.dart';
import '../../core/utils/dialog_utils.dart';
import '../../core/widgets/resource_attachments_section.dart';

import 'create_task_screen.dart';
import 'submissions_list_screen.dart';
import 'widgets/task_detail/task_header_widget.dart';
import 'widgets/task_detail/teacher_actions_widget.dart';
import 'widgets/task_detail/student_workspace_widget.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Resource task;
  late TaskDetailProvider _provider;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _provider = TaskDetailProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      task = ModalRoute.of(context)!.settings.arguments as Resource;
      _provider.loadSubmissionStatus(task.id);
      _loaded = true;
    }
  }

  /// Método asíncrono que gatilla el RefreshIndicator
  Future<void> _handleRefresh() async {
    // Vuelve a consultar el estado de la entrega, notas y archivos desde NestJS
    await _provider.loadSubmissionStatus(task.id);
  }

  Future<void> _editTask() async {
    final updatedTask = await Navigator.push<Resource>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<ResourceProvider>(),
          child: CreateTaskScreen(task: task),
        ),
      ),
    );
    if (updatedTask != null && mounted) {
      setState(() {
        task = updatedTask;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isTeacher = auth.currentUser?.role.canEditCourses ?? false;
    final currentUserRole = auth.currentUser?.role ?? UserRole.estudiante;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<TaskDetailProvider>(
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
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            /// 1. Envolvemos el cuerpo en el indicador de recarga
            body: RefreshIndicator(
              color: AppColors.primary, // Color del spinner animado
              backgroundColor:
                  AppColors.surfaceWhite, // Fondo del círculo del icono
              onRefresh: _handleRefresh, // ◄ La función que pusimos arriba

              child: SingleChildScrollView(
                // 2. OBLIGATORIO: Fuerza el rebote de scroll aunque la pantalla tenga poco contenido
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TaskHeaderWidget(
                      task: task,
                      isTeacher: isTeacher,
                      provider: provider,
                    ),
                    const SizedBox(height: 24),

                    if (!isTeacher &&
                        provider.isGraded &&
                        provider.teacherComment != null &&
                        provider.teacherComment!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.insert_comment_rounded,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Retroalimentación del profesor:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${provider.teacherComment!}"',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (currentUserRole.canEditCourses) ...[
                      TeacherActionsWidget(
                        provider: provider,
                        onEdit: _editTask,
                        onDelete: () async {
                          final confirm = await DialogUtils.showConfirmDialog(
                            context,
                            title: 'Eliminar tarea',
                            content:
                                '¿Estás seguro de que deseas eliminar esta tarea de forma permanente? Se perderán todas las entregas asociadas.',
                          );
                          if (confirm == true) {
                            final success = await provider.deleteCurrentTask(
                              task.id,
                            );
                            if (!context.mounted) return;
                            if (success) {
                              Navigator.of(context).pop(true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.message ??
                                        'Error desconocido al eliminar',
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        onViewSubmissions: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubmissionsListScreen(task: task),
                            ),
                          );
                        },
                      ),
                    ],

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        task.description ?? 'Sin descripción proporcionada.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ResourceAttachmentsSection(
                      resourceId: task.id,
                      isTeacher: currentUserRole.canEditCourses,
                      apiPath: 'archivo-tarea',
                    ),
                    const SizedBox(height: 32),

                    if (!isTeacher) ...[
                      StudentWorkspaceWidget(
                        task: task,
                        provider: provider,
                        onCancelSubmissionPrompt: () =>
                            DialogUtils.showConfirmDialog(
                              context,
                              title: '¿Anular la entrega?',
                              content:
                                  'Si anulas la entrega, podrás quitar o cambiar los archivos adjuntos. No olvides volver a entregar cuando termines.',
                            ),
                        onSubmitWithoutFilePrompt: () =>
                            DialogUtils.showConfirmDialog(
                              context,
                              title: 'Entregar sin archivo',
                              content:
                                  'No seleccionaste ningún archivo. ¿Deseas continuar?',
                            ),
                        onDeleteFilePrompt: () => DialogUtils.showConfirmDialog(
                          context,
                          title: 'Eliminar archivo',
                          content:
                              '¿Estás seguro de que quieres eliminar este archivo de tu entrega?',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
