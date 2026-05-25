import 'package:app_lideres/core/providers/resource_provider.dart';
import 'package:app_lideres/core/widgets/resource_attachments_section.dart';
import 'package:app_lideres/features/courses/create_task_screen.dart';
import 'package:app_lideres/features/courses/submissions_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/resource_model.dart';
import '../../core/providers/task_detail_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/user_roles.dart';

import 'package:url_launcher/url_launcher.dart';

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
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// --- ENCABEZADO ESTILO CLASSROOM ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                'Límite: '
                                '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year} - '
                                '${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Bloque de Puntuación Flotante
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isTeacher && provider.isGraded) ...[
                            Text(
                              '${provider.studentScore}/${task.maxScore ?? 100}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800, // o FontWeight.bold
                                color: AppColors.primary,
                              ),
                            ),
                            const Text(
                              'Calificado',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else ...[
                            Text(
                              '${task.maxScore ?? 100} pts',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            if (!isTeacher)
                              Text(
                                provider.alreadySubmitted ? 'Entregado' : 'Asignado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: provider.alreadySubmitted ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  /// --- COMENTARIO DEL PROFESOR (SI EXISTE) ---
                  if (!isTeacher && provider.isGraded && provider.teacherComment != null && provider.teacherComment!.isNotEmpty) ...[
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
                          const Icon(Icons.insert_comment_rounded, color: Colors.blue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Retroalimentación del profesor:',
                                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '"${provider.teacherComment!}"',
                                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.primaryDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  /// --- ACCIONES EXCLUSIVAS DEL PROFESOR ---
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
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceWhite,
                        foregroundColor: AppColors.error,
                        elevation: 0,
                        side: const BorderSide(
                          color: AppColors.error,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: provider.isUploading
                          ? null
                          : () async {
                              final confirm = await _showConfirmDialog(
                                context,
                                title: 'Eliminar tarea',
                                content:
                                    '¿Estás seguro de que deseas eliminar esta tarea de forma permanente? Se perderán todas las entregas asociadas.',
                              );

                              if (confirm == true) {
                                final success = await provider
                                    .deleteCurrentTask(task.id);
                                if (!context.mounted) {
                                  return;
                                }

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
                      icon: provider.isUploading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.error,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.delete_outline, size: 20),
                      label: const Text(
                        'Eliminar tarea',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surfaceWhite,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubmissionsListScreen(task: task),
                          ),
                        );
                      },
                      icon: const Icon(Icons.people_alt_rounded, size: 20),
                      label: const Text(
                        'Revisar entregas de alumnos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  /// --- DESCRIPCIÓN E INSTRUCCIONES ---
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

                  /// --- ARCHIVOS ADJUNTOS DEL PROFESOR ---
                  ResourceAttachmentsSection(
                    resourceId: task.id,
                    isTeacher: currentUserRole.canEditCourses,
                    apiPath: 'archivo-tarea',
                  ),
                  const SizedBox(height: 32),

                  /// --- ESPACIO DE TRABAJO DEL ESTUDIANTE ---
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

                    /// Tarjeta de Carga / Selección de Archivo
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
                        onTap: provider.isUploading
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
                                onPressed: provider.isUploading
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

                    /// Mensajes de respuesta Informativa
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

                    /// Botones de Gestión de Entrega
                    Row(
                      children: [
                        if (provider.alreadySubmitted) ...[
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                backgroundColor: AppColors.error,
                                side: const BorderSide(
                                  color: AppColors.error,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: provider.isUploading
                                  ? null
                                  : () async {
                                      final confirm = await _showConfirmDialog(
                                        context,
                                        title: '¿Anular la entrega?',
                                        content:
                                            'Si anulas la entrega, podrás quitar o cambiar los archivos adjuntos. No olvides volver a entregar cuando termines.',
                                      );
                                      if (confirm == true) {
                                        await provider.cancelSubmission(
                                          task.id,
                                        );
                                      }
                                    },
                              child: const Text(
                                'Anular entrega',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: ElevatedButton(
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
                            onPressed: provider.isUploading
                                ? null
                                : () async {
                                    if (provider.selectedFile == null &&
                                        !provider.alreadySubmitted) {
                                      final confirm = await _showConfirmDialog(
                                        context,
                                        title: 'Entregar sin archivo',
                                        content:
                                            'No seleccionaste ningún archivo. ¿Deseas continuar?',
                                      );
                                      if (confirm != true) return;
                                    }
                                    await provider.submitTask(task.id);
                                  },
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
                                    provider.alreadySubmitted
                                        ? 'Reentregar tarea'
                                        : 'Entregar tarea',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    /// Lista de Archivos Cargados de la Entrega
                    if (provider.alreadySubmitted) ...[
                      const Text(
                        'Archivos entregados',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (provider.submissionFiles.isEmpty)
                        const Text(
                          'Entregado sin archivos adjuntos',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        ...provider.submissionFiles.map(
                          (file) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    file['nombre_archivo'] ?? 'Archivo',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.download_rounded,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    final url = file['url'];
                                    if (url == null) return;
                                    final uri = Uri.parse(url);
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    final confirm = await _showConfirmDialog(
                                      context,
                                      title: 'Eliminar archivo',
                                      content:
                                          '¿Estás seguro de que quieres eliminar este archivo de tu entrega?',
                                    );
                                    if (confirm == true) {
                                      await provider.deleteSubmittedFile(
                                        file['id_archivo'],
                                        task.id,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}