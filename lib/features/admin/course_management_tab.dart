import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/course_model.dart';
import '../../core/providers/course_provider.dart';
// ¡NUEVO! Importamos el AdminProvider para poder buscar a los usuarios
import '../../core/providers/admin_provider.dart';
import '../../core/theme/app_colors.dart';
import 'course_form_dialog.dart';

class CourseManagementTab extends StatefulWidget {
  const CourseManagementTab({super.key});

  @override
  State<CourseManagementTab> createState() => _CourseManagementTabState();
}

class _CourseManagementTabState extends State<CourseManagementTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadAllCourses();
    });
  }

  void _showCourseDialog([Course? course]) {
    showDialog(
      context: context,
      builder: (_) => CourseFormDialog(courseToEdit: course),
    );
  }

  Future<void> _deleteCourse(Course course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Eliminar Curso',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Eliminar el curso ${course.title}? Se perderán todos sus recursos y tareas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<CourseProvider>().deleteCourse(
        course.id,
      );
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar curso'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // =====================================================================
  // NUEVO: Modal de Inscripción de Estudiantes
  // =====================================================================

  void _mostrarModalInscripcion(BuildContext context, int courseId) {
    // 1. CAMBIO: Ahora llamamos a fetchStudents() en lugar de fetchUsers()
    context.read<AdminProvider>().fetchStudents();
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inscribir Estudiante',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),

              // Buscador
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar estudiante...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  // 2. CAMBIO: Usamos el filtro específico de estudiantes
                  context.read<AdminProvider>().filterStudents(value);
                },
              ),
              const SizedBox(height: 16),

              // Lista de resultados
              SizedBox(
                height: 350,
                child: Consumer<AdminProvider>(
                  builder: (context, adminProvider, child) {
                    if (adminProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 3. CAMBIO: Leemos la lista 'students' en lugar de 'users'
                    final estudiantes = adminProvider.students;

                    if (estudiantes.isEmpty) {
                      return const Center(
                        child: Text('No se encontraron estudiantes.'),
                      );
                    }

                    return ListView.separated(
                      itemCount: estudiantes.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Colors.black12),
                      itemBuilder: (context, index) {
                        final estudiante = estudiantes[index];

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              estudiante.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            estudiante.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(estudiante.email),
                          trailing: TextButton(
                            onPressed: () async {
                              // Cerramos el teclado por si el administrador estaba buscando
                              FocusScope.of(modalContext).unfocus();

                              final success = await context
                                  .read<CourseProvider>()
                                  .inscribirEstudianteEnCurso(
                                    estudiante.id,
                                    courseId,
                                  );

                              if (!modalContext.mounted) return;

                              if (success) {
                                // 1. ¡ÉXITO! Cerramos el modal primero
                                Navigator.pop(modalContext);

                                // 2. Mostramos el mensaje verde usando el "context" de la pantalla principal (no el modalContext)
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('¡Inscrito correctamente!'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                // 3. ¡ERROR! (ej. Ya estaba inscrito o no hay cupo).
                                // Dejamos el modal abierto para que vea el error rojo sin perder su búsqueda.
                                Navigator.pop(modalContext);
                                ScaffoldMessenger.of(modalContext).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context
                                              .read<CourseProvider>()
                                              .errorMessage ??
                                          'Error al inscribir',
                                    ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCourseDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Curso', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Consumer<CourseProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.courses.isEmpty) {
              return const Center(child: Text('No hay cursos registrados.'));
            }

            return ListView.separated(
              itemCount: provider.courses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = provider.courses[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary.withOpacity(0.2),
                      child: const Icon(
                        Icons.school,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    title: Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ¡NUEVO! Botón para inscribir
                        IconButton(
                          icon: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Colors.green,
                            size: 20,
                          ),
                          tooltip: 'Inscribir Alumno',
                          onPressed: () =>
                              _mostrarModalInscripcion(context, course.id),
                        ),
                        // Botón Editar
                        IconButton(
                          icon: const Icon(
                            Icons.edit_square,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          tooltip: 'Editar Curso',
                          onPressed: () => _showCourseDialog(course),
                        ),
                        // Botón Eliminar
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          tooltip: 'Eliminar Curso',
                          onPressed: () => _deleteCourse(course),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
