import 'package:app_lideres/core/providers/resource_provider.dart';
import 'package:app_lideres/features/courses/create_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/resource_model.dart';
import '../../core/providers/task_detail_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/user_roles.dart';

import '../../services/task_service.dart';

import 'package:url_launcher/url_launcher.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Resource task;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    task = ModalRoute.of(context)?.settings.arguments as Resource;
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
    Navigator.pop(context, updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final isTeacher = auth.currentUser?.role.canEditCourses ?? false;

    final currentUserRole = auth.currentUser?.role ?? UserRole.estudiante;

    return ChangeNotifierProvider(
      create: (_) => TaskDetailProvider(),

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

            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10.0,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  /// HEADER
                  Text(
                    task.title,

                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 26,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (task.dueDate != null)
                    Text(
                      'Fecha de entrega: '
                      '${task.dueDate!.day}/'
                      '${task.dueDate!.month}/'
                      '${task.dueDate!.year}',

                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 32),

                  /// BOTÓN EDITAR
                  if (currentUserRole.canEditCourses) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceWhite,

                        foregroundColor: AppColors.primaryDark,

                        elevation: 0,

                        side: BorderSide(
                          color: AppColors.secondary.withOpacity(0.3),

                          width: 1.5,
                        ),

                        padding: const EdgeInsets.symmetric(vertical: 14),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      onPressed: _editTask,

                      icon: const Icon(Icons.create_rounded, size: 20),

                      label: const Text(
                        'Editar tarea',

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],

                  /// DESCRIPCIÓN
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

                  /// DESCARGAR
                  Align(
                    alignment: Alignment.centerLeft,

                    child: TextButton.icon(
                      onPressed: () async {
                        try {
                          final url = await TaskService().getDownloadUrl(
                            task.id,
                          );

                          final uri = Uri.parse(url);

                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },

                      icon: const Icon(
                        Icons.download_rounded,
                        color: AppColors.primary,
                      ),

                      label: const Text(
                        'Descargar material adjunto',

                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// ALUMNO
                  if (!isTeacher) ...[
                    const Text(
                      'Tu trabajo',

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      height: 140,

                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,

                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.3),

                          width: 1.5,
                        ),
                      ),

                      child: InkWell(
                        onTap: provider.isSuccess
                            ? null
                            : () => provider.pickFile(),

                        borderRadius: BorderRadius.circular(16),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            if (provider.selectedFile != null) ...[
                              const Icon(
                                Icons.insert_drive_file,
                                size: 32,
                                color: AppColors.primaryDark,
                              ),

                              const SizedBox(height: 8),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),

                                child: Text(
                                  provider.selectedFile!.name,

                                  textAlign: TextAlign.center,

                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,

                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),

                              TextButton(
                                onPressed: provider.isSuccess
                                    ? null
                                    : () => provider.clearFile(),

                                child: const Text(
                                  "Quitar archivo",

                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(12),

                                decoration: const BoxDecoration(
                                  color: AppColors.backgroundLight,

                                  shape: BoxShape.circle,
                                ),

                                child: const Icon(
                                  Icons.cloud_upload_outlined,

                                  size: 32,

                                  color: AppColors.primary,
                                ),
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'Toca para subir un archivo',

                                style: TextStyle(
                                  color: AppColors.textSecondary,

                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (provider.message != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),

                        child: Text(
                          provider.message!,

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: provider.isSuccess
                                ? Colors.green
                                : AppColors.error,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.isSuccess
                            ? Colors.green
                            : AppColors.primaryDark,

                        foregroundColor: AppColors.surfaceWhite,

                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      onPressed: (provider.isUploading || provider.isSuccess)
                          ? null
                          : () => provider.submitTask(task.id),

                      child: provider.isUploading
                          ? const SizedBox(
                              height: 20,
                              width: 20,

                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              provider.isSuccess
                                  ? 'Entregado'
                                  : 'Entregar Tarea',

                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,

                        borderRadius: BorderRadius.circular(16),

                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.3),
                        ),
                      ),

                      child: const Column(
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),

                          SizedBox(height: 12),

                          Text(
                            'Entregas de alumnos',

                            style: TextStyle(
                              fontWeight: FontWeight.bold,

                              fontSize: 18,

                              color: AppColors.primaryDark,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            'La visualización de entregas estará disponible próximamente.',

                            textAlign: TextAlign.center,

                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
