import 'package:app_lideres/core/models/resource_model.dart';
import 'package:app_lideres/features/courses/task_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/task_list_tile.dart';
import '../../core/utils/user_roles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/resource_provider.dart';

import 'create_task_screen.dart';
import 'create_material_screen.dart';
import 'material_detail_screen.dart';

class ClassDetailScreen extends StatefulWidget {
  const ClassDetailScreen({super.key});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  late final ResourceProvider _provider;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _provider = ResourceProvider();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final int courseId = args is int ? args : 0;

    // Cargamos solo UNA vez
    if (!_loaded) {
      _loaded = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _provider.loadCourse(courseId);
      });
    }

    final auth = context.watch<AuthProvider>();
    final currentUserRole = auth.currentUser?.role ?? UserRole.estudiante;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<ResourceProvider>(
        builder: (context, provider, child) {
          return Scaffold(
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
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    children: [
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.primaryDark,
                          image: const DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black45,
                              BlendMode.darken,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Detalles de Clase',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontSize: 26,
                                    color: AppColors.surfaceWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (currentUserRole.canEditCourses) ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceWhite,
                            foregroundColor: AppColors.primaryDark,
                            elevation: 0,
                            side: BorderSide(
                              color: AppColors.secondary.withOpacity(0.3),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () =>
                              _showCreateOptions(context, courseId, provider),
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Nuevo anuncio',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      const Text(
                        'Trabajo de clase',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (provider.errorMessage != null)
                        Center(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        )
                      else if (provider.resources.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'El profesor aún no ha subido tareas ni materiales.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      else
                        ...provider.resources.map(
                          (res) => TaskListTile(
                            title: res.title,
                            tipo: res.type,
                            description:
                                res.description ??
                                (res.type == 'tarea'
                                    ? 'Tarea asignada'
                                    : 'Material de estudio'),
                            onTap: () async {
                              Resource? updatedResource;

                              if (res.type == 'tarea') {
                                updatedResource =
                                    await Navigator.push<Resource>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TaskDetailScreen(),
                                        settings: RouteSettings(arguments: res),
                                      ),
                                    );
                              } else if (res.type == 'material') {
                                updatedResource =
                                    await Navigator.push<Resource>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MaterialDetailScreen(),
                                        settings: RouteSettings(arguments: res),
                                      ),
                                    );
                              }

                              if (updatedResource != null && context.mounted) {
                                await provider.loadCourse(courseId);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  void _showCreateOptions(
    BuildContext context,
    int courseId,
    ResourceProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surfaceWhite,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.backgroundLight,
                  child: Icon(
                    Icons.assignment_rounded,
                    color: AppColors.primaryDark,
                  ),
                ),
                title: const Text(
                  'Crear Tarea',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Asignar un trabajo con fecha de entrega'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: provider,
                        child: CreateTaskScreen(courseId: courseId),
                      ),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.backgroundLight,
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text(
                  'Subir Material',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Compartir documentos, videos o enlaces'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: provider,
                        child: CreateMaterialScreen(),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
