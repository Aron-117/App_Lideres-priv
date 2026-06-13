import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/course_model.dart';
import '../../core/providers/course_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/smart_refresh_wrapper.dart';
import 'course_form_dialog.dart';
import 'widgets/student_management_modal.dart';

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

  // (Modals movidos a student_management_modal.dart y enrollment_modal.dart)


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
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          return SmartRefreshWrapper(
            onRefresh: () => provider.loadAllCourses(),
            isLoading: provider.isLoading,
            errorMessage: provider.errorMessage,
            isEmpty: provider.courses.isEmpty,
            emptyMessage: 'No hay cursos registrados.',
            onRetry: () => provider.loadAllCourses(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
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
                        // ¡MODIFICADO! Botón de Gestión de Estudiantes
                        IconButton(
                          icon: const Icon(
                            Icons.people_alt_rounded,
                            color: Colors.blue,
                            size: 22,
                          ),
                          tooltip: 'Gestión de Alumnos',
                          onPressed: () => StudentManagementModal.show(context, course),
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
            ),
          );
        },
      ),
    );
  }
}