import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/resource_model.dart';
import '../../core/providers/task_detail_provider.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibimos la tarea que enviamos desde ClassDetailScreen
    final task = ModalRoute.of(context)?.settings.arguments as Resource?;

    if (task == null)
      return const Scaffold(body: Center(child: Text("Error: Tarea no encontrada")));

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
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- ENCABEZADO ---
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
                      'Fecha de entrega: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 32),

                  // --- DESCRIPCIÓN ---
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
                      task.description ?? 'Sin descripción proporcionada por el profesor.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- ZONA DE ADJUNTOS ---
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
                      border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1.5),
                    ),
                    child: InkWell(
                      onTap: provider.isSuccess ? null : () => provider.pickFile(),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                provider.selectedFile!.name, // Muestra el nombre del archivo
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
                              onPressed: provider.isSuccess ? null : () => provider.clearFile(),
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

                  // --- MENSAJES DE ERROR O ÉXITO ---
                  if (provider.message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        provider.message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: provider.isSuccess ? Colors.green : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // --- BOTÓN DE ENTREGA ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.isSuccess ? Colors.green : AppColors.primaryDark,
                      foregroundColor: AppColors.surfaceWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    // Desactivamos el botón si está cargando o si ya tuvo éxito
                    onPressed: (provider.isUploading || provider.isSuccess)
                        ? null
                        : () =>
                              provider.submitTask(task.id), // Enviamos el ID de la tarea al backend
                    child: provider.isUploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            provider.isSuccess ? 'Entregado' : 'Entregar Tarea',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
