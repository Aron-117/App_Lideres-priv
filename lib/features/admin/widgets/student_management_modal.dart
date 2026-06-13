import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/course_model.dart';
import '../../../../core/providers/course_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'enrollment_modal.dart';

class StudentManagementModal extends StatelessWidget {
  final Course course;

  const StudentManagementModal({super.key, required this.course});

  static void show(BuildContext context, Course course) {
    // Cargamos los inscritos al abrir el modal
    context.read<CourseProvider>().loadInscripciones(course.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return StudentManagementModal(course: course);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 20,
        right: 20,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75, // Altura ajustada
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gestión de Estudiantes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            Text(
              course.title,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Botón para inscribir a alguien nuevo
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Inscribir nuevo estudiante', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => EnrollmentModal.show(context, course.id),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            
            // Lista de Estudiantes Inscritos
            const Text(
              'Alumnos inscritos en el curso:',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<CourseProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingInscripciones) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.inscripciones.isEmpty) {
                    return const Center(
                      child: Text('Aún no hay estudiantes inscritos.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: provider.inscripciones.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black12),
                    itemBuilder: (context, index) {
                      final inscripcion = provider.inscripciones[index];
                      // Asumimos que el backend retorna { id_inscripcion: X, usuario: { id_usuario: Y, nombre: 'Z', email: 'W' } }
                      final idInscripcion = inscripcion['id_inscripcion'];
                      final usuario = inscripcion['usuario'] ?? {};
                      final nombre = usuario['nombre'] ?? 'Desconocido';
                      final email = usuario['email'] ?? '';

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: Text(
                            nombre[0].toUpperCase(),
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(email),
                        trailing: IconButton(
                          icon: const Icon(Icons.person_remove_rounded, color: AppColors.error),
                          tooltip: 'Desmatricular',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('¿Eliminar del curso?'),
                                content: Text('¿Deseas sacar a $nombre de este curso?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  )
                                ],
                              )
                            );

                            if (confirm == true) {
                              final success = await provider.desmatricularEstudiante(idInscripcion, course.id);
                              if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(provider.errorMessage ?? 'Error al eliminar'), backgroundColor: AppColors.error),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
