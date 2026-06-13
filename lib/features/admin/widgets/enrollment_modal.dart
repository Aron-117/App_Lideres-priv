import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/admin_provider.dart';
import '../../../../core/providers/course_provider.dart';
import '../../../../core/theme/app_colors.dart';

class EnrollmentModal extends StatelessWidget {
  final int courseId;
  final Set<dynamic> enrolledUserIds;

  const EnrollmentModal({
    super.key,
    required this.courseId,
    required this.enrolledUserIds,
  });

  static void show(BuildContext context, int courseId) {
    context.read<AdminProvider>().fetchStudents();
    
    // Obtenemos los IDs de los que YA están inscritos para ocultarlos de la lista
    final currentInscripciones = context.read<CourseProvider>().inscripciones;
    final enrolledUserIds = currentInscripciones.map((ins) => ins['usuario']?['id_usuario']).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return EnrollmentModal(
          courseId: courseId,
          enrolledUserIds: enrolledUserIds,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seleccionar Estudiante',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Buscar estudiante...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (value) => context.read<AdminProvider>().filterStudents(value),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 300,
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filtramos: Solo estudiantes que NO estén en enrolledUserIds
                final estudiantesDisponibles = adminProvider.students.where((s) => !enrolledUserIds.contains(s.id)).toList();

                if (estudiantesDisponibles.isEmpty) {
                  return const Center(
                    child: Text('No hay estudiantes disponibles o todos ya están inscritos.'),
                  );
                }

                return ListView.separated(
                  itemCount: estudiantesDisponibles.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black12),
                  itemBuilder: (context, index) {
                    final estudiante = estudiantesDisponibles[index];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child: Text(
                          estudiante.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(estudiante.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(estudiante.email),
                      trailing: TextButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          final success = await context.read<CourseProvider>().inscribirEstudianteEnCurso(estudiante.id, courseId);

                          if (!context.mounted) return;

                          if (success) {
                            Navigator.pop(context); // Cierra este modal y vuelve al panel de gestión, el cual se actualizará solo
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.read<CourseProvider>().errorMessage ?? 'Error al inscribir'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          backgroundColor: Colors.green.withOpacity(0.1),
                        ),
                        child: const Text('Inscribir'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
