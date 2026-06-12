import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/course_model.dart';
import '../../core/providers/course_provider.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/smart_refresh_wrapper.dart';
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
  // NUEVO 1: Modal Principal de Gestión de Estudiantes Inscritos
  // =====================================================================
  void _mostrarModalGestionEstudiantes(BuildContext context, Course course) {
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
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: SizedBox(
            height: MediaQuery.of(modalContext).size.height * 0.75, // Altura ajustada
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
                      onPressed: () => Navigator.pop(modalContext),
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
                    onPressed: () => _mostrarModalInscripcion(modalContext, course.id),
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
                                  context: modalContext,
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
                                  if (!success && modalContext.mounted) {
                                    ScaffoldMessenger.of(modalContext).showSnackBar(
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
      },
    );
  }

  // =====================================================================
  // Modal Secundario: Inscribir Estudiante (Con Filtro de ya inscritos)
  // =====================================================================
  void _mostrarModalInscripcion(BuildContext context, int courseId) {
    context.read<AdminProvider>().fetchStudents();
    final searchController = TextEditingController();
    
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
                              FocusScope.of(modalContext).unfocus();
                              final success = await context.read<CourseProvider>().inscribirEstudianteEnCurso(estudiante.id, courseId);

                              if (!modalContext.mounted) return;

                              if (success) {
                                Navigator.pop(modalContext); // Cierra este modal y vuelve al panel de gestión, el cual se actualizará solo
                              } else {
                                ScaffoldMessenger.of(modalContext).showSnackBar(
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
                          onPressed: () => _mostrarModalGestionEstudiantes(context, course),
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