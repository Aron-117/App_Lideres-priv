import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/resource_model.dart';
import '../../../../core/providers/task_detail_provider.dart';

class StudentWorkspaceWidget extends StatelessWidget {
  final Resource task;
  final TaskDetailProvider provider;
  final Future<bool?> Function() onCancelSubmissionPrompt;
  final Future<bool?> Function() onSubmitWithoutFilePrompt;
  final Future<bool?> Function() onDeleteFilePrompt;

  const StudentWorkspaceWidget({
    Key? key,
    required this.task,
    required this.provider,
    required this.onCancelSubmissionPrompt,
    required this.onSubmitWithoutFilePrompt,
    required this.onDeleteFilePrompt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Tu trabajo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),

        /// Tarjeta Flexible (Se eliminó el height: 300 rígido)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: InkWell(
            // El trigger de selección se desactiva solo si está subiendo
            onTap: provider.isUploading ? null : () => provider.pickFile(),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.selectedFiles.isNotEmpty) ...[
                  const Icon(
                    Icons.insert_drive_file,
                    size: 32,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: provider.selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = provider.selectedFiles[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_file,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                file.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.error,
                              ),
                              onPressed: provider.isUploading
                                  ? null
                                  : () => provider.removeSelectedFile(index),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${provider.selectedFiles.length} archivo(s) seleccionado(s)',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: provider.isUploading
                            ? null
                            : () => provider.clearFiles(),
                        child: const Text(
                          'Limpiar todo',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (provider.isUploading &&
                      provider.uploadingFileName != null) ...[
                    const Divider(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subiendo ${provider.uploadingFileName}: ${provider.uploadProgress}%',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: provider.uploadProgress / 100,
                          backgroundColor: AppColors.backgroundLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: provider.isUploading
                                  ? () => provider.cancelUpload()
                                  : null,
                              child: const Text(
                                'Cancelar subida',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ] else ...[
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 36,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Toca para seleccionar archivos',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
                color: provider.isSuccess ? Colors.green : AppColors.error,
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
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: provider.isUploading
                      ? null
                      : () async {
                          final confirm = await onCancelSubmissionPrompt();
                          if (confirm == true) {
                            await provider.cancelSubmission(task.id);
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
                        if (provider.selectedFiles.isEmpty &&
                            !provider.alreadySubmitted) {
                          final confirm = await onSubmitWithoutFilePrompt();
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

        /// Lista de Archivos Cargados de la Entrega (Persistidos en la BD)
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
              style: TextStyle(color: AppColors.textSecondary),
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
                      icon: const Icon(Icons.download_rounded, size: 20),
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
                        final confirm = await onDeleteFilePrompt();
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
    );
  }
}
