import 'package:app_lideres/core/providers/resouce_files_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';

class ResourceAttachmentsSection extends StatefulWidget {
  final int resourceId;
  final bool isTeacher;
  final String apiPath; // 'archivo-material' o 'archivo-tarea'

  const ResourceAttachmentsSection({
    super.key,
    required this.resourceId,
    required this.isTeacher,
    required this.apiPath,
  });

  @override
  State<ResourceAttachmentsSection> createState() =>
      _ResourceAttachmentsSectionState();
}

class _ResourceAttachmentsSectionState
    extends State<ResourceAttachmentsSection> {
  late ResourceFilesProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ResourceFilesProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchFiles(widget.resourceId, widget.apiPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<ResourceFilesProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Archivos adjuntos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                      fontSize: 18,
                    ),
                  ),
                  // Botón de subir archivo (Solo Profesor)
                  if (widget.isTeacher)
                    TextButton.icon(
                      onPressed: provider.isUploading
                          ? null
                          : () => provider.pickAndUploadFile(
                              widget.resourceId,
                              widget.apiPath,
                            ),
                      icon: provider.isUploading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primary,
                            ),
                      label: const Text(
                        'Añadir',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (provider.isLoading && provider.files.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.error != null)
                Text(
                  provider.error!,
                  style: const TextStyle(color: AppColors.error),
                )
              else if (provider.files.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'No hay archivos adjuntos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                ...provider.files.map((file) {
                  // Asegúrate de que las llaves correspondan a lo que devuelve tu backend
                  final fileId = file['id_archivo'];
                  final url = file['url'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.2),
                      ),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.insert_drive_file,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        file['nombre_archivo'] ?? 'Documento',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.download_rounded,
                              color: AppColors.primaryDark,
                            ),
                            onPressed: url == null
                                ? null
                                : () async {
                                    await launchUrl(
                                      Uri.parse(url),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                          ),
                          if (widget.isTeacher)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () async {
                                await provider.deleteFile(
                                  fileId,
                                  widget.resourceId,
                                  widget.apiPath,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
