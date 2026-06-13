import 'package:app_lideres/features/courses/task_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/task_list_tile.dart';
import '../../core/widgets/smart_refresh_wrapper.dart';
import '../../core/utils/user_roles.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/resource_provider.dart';

import 'material_detail_screen.dart';
import 'widgets/class_detail/class_header_widget.dart';
import 'widgets/class_detail/create_options_bottom_sheet.dart';

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
            body: SmartRefreshWrapper(
              onRefresh: () => provider.loadCourse(courseId),
              isLoading: provider.isLoading,
              errorMessage: provider.errorMessage,
              isEmpty: false, // La pantalla nunca debe mostrarse vacía completamente porque tiene un encabezado.
              onRetry: () => provider.loadCourse(courseId),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                children: [
                  const ClassHeaderWidget(),

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
                          CreateOptionsBottomSheet.show(context, courseId, provider),
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

                  if (provider.resources.isEmpty)
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
                          dynamic result;

                          if (res.type == 'tarea') {
                            result = await Navigator.push<dynamic>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TaskDetailScreen(),
                                settings: RouteSettings(arguments: res),
                              ),
                            );
                          } else if (res.type == 'material') {
                            result = await Navigator.push<dynamic>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const MaterialDetailScreen(),
                                settings: RouteSettings(arguments: res),
                              ),
                            );
                          }

                          if (result != null && context.mounted) {
                            await provider.loadCourse(courseId);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // (El BottomSheet de creación fue movido a CreateOptionsBottomSheet)
}
