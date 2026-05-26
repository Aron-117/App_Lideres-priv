import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/resource_model.dart';
import '../../core/providers/teacher_submissions_provider.dart';

class SubmissionsListScreen extends StatefulWidget {
  final Resource task;

  const SubmissionsListScreen({super.key, required this.task});

  @override
  State<SubmissionsListScreen> createState() => _SubmissionsListScreenState();
}

class _SubmissionsListScreenState extends State<SubmissionsListScreen> {
  late TeacherSubmissionsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = TeacherSubmissionsProvider();
    // Cargamos las entregas ni bien se abre la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchSubmissions(widget.task.id);
    });
  }

  // Función auxiliar para formatear la fecha que viene del backend
  String _formatDate(String? isoString) {
    if (isoString == null) return 'Fecha desconocida';
    try {
      final date = DateTime.parse(isoString).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} a las '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  Future<void> _showGradingDialog(
    BuildContext context,
    Map<String, dynamic> entrega,
    TeacherSubmissionsProvider provider,
  ) async {
    final notaController = TextEditingController(
      text: entrega['calificacion']?.toString() ?? '',
    );
    final comentarioController = TextEditingController(
      text: entrega['comentario_profesor'] ?? '',
    );
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Calificar entrega',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: notaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Nota (Máx: ${widget.task.maxScore})',
                        prefixIcon: const Icon(Icons.military_tech),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        final n = int.tryParse(value ?? '');
                        if (n == null) return 'Ingresa un número';
                        if (n > (widget.task.maxScore ?? 100))
                          return 'No supera los ${widget.task.maxScore} pts';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: comentarioController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Feedback (Opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setStateDialog(() => isSaving = true);
                            try {
                              await provider.gradeSubmission(
                                entrega['id_entrega'],
                                int.parse(notaController.text),
                                comentarioController.text.trim(),
                                widget.task.maxScore ??
                                    100, // Pasamos el límite
                              );
                              if (context.mounted) Navigator.pop(dialogContext);
                            } catch (e) {
                              setStateDialog(() => isSaving = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
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
          title: const Text(
            'Entregas de alumnos',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<TeacherSubmissionsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            provider.fetchSubmissions(widget.task.id),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (provider.submissions.isEmpty) {
              return const Center(
                child: Text(
                  'Aún no hay entregas para esta tarea.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.fetchSubmissions(widget.task.id),
              child: ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: provider.submissions.length,
                itemBuilder: (context, index) {
                  final entrega = provider.submissions[index];
                  final usuario = entrega['usuario'] ?? {};
                  final nombreAlumno = '${usuario['nombre'] ?? 'Alumno'}'
                      .trim();
                  final archivos = List<dynamic>.from(
                    entrega['archivos'] ?? [],
                  );
                  final fecha = _formatDate(entrega['fecha_entrega']);

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.secondary.withOpacity(0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Cabecera: Nombre y Avatar
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                                child: Text(
                                  nombreAlumno.isNotEmpty
                                      ? nombreAlumno[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombreAlumno,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    Text(
                                      'Entregado el $fecha',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(),
                          ),
                          const Text(
                            'Archivos adjuntos:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (archivos.isEmpty)
                            const Text(
                              'Entregado sin archivos',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          else
                            ...archivos.map((archivo) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.insert_drive_file,
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    archivo['nombre_archivo'] ?? 'Archivo',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.download_rounded,
                                      color: AppColors.primaryDark,
                                    ),
                                    onPressed: () async {
                                      final url = archivo['url'];
                                      if (url != null) {
                                        await launchUrl(
                                          Uri.parse(url),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            }),
                          if (entrega['calificacion'] != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Calificación: ${entrega['calificacion']}/${widget.task.maxScore}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (entrega['comentario_profesor'] != null &&
                                      entrega['comentario_profesor']
                                          .toString()
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Comentario: ${entrega['comentario_profesor']}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          // 4. Botón final para abrir el Diálogo
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryDark,
                                side: const BorderSide(
                                  color: AppColors.primaryDark,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => _showGradingDialog(
                                context,
                                entrega,
                                provider,
                              ),
                              icon: Icon(
                                entrega['calificacion'] != null
                                    ? Icons.edit
                                    : Icons.grade,
                              ),
                              label: Text(
                                entrega['calificacion'] != null
                                    ? 'Modificar calificación'
                                    : 'Calificar entrega',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
