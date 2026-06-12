import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

class SubmissionCardWidget extends StatelessWidget {
  final Map<String, dynamic> entrega;
  final int maxScore;
  final VoidCallback onTapGrade;

  const SubmissionCardWidget({
    Key? key,
    required this.entrega,
    required this.maxScore,
    required this.onTapGrade,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final usuario = entrega['usuario'] ?? {};
    final nombreAlumno = '${usuario['nombre'] ?? 'Alumno'}'.trim();
    final archivos = List<dynamic>.from(entrega['archivos'] ?? []);
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
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    nombreAlumno.isNotEmpty ? nombreAlumno[0].toUpperCase() : 'A',
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
                          'Calificación: ${entrega['calificacion']}/$maxScore',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (entrega['comentario_profesor'] != null &&
                        entrega['comentario_profesor'].toString().isNotEmpty) ...[
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
                onPressed: onTapGrade,
                icon: Icon(
                  entrega['calificacion'] != null ? Icons.edit : Icons.grade,
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
  }
}
