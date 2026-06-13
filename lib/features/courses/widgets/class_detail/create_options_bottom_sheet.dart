import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/resource_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../create_material_screen.dart';
import '../../create_task_screen.dart';

class CreateOptionsBottomSheet extends StatelessWidget {
  final int courseId;
  final ResourceProvider provider;

  const CreateOptionsBottomSheet({
    super.key,
    required this.courseId,
    required this.provider,
  });

  static void show(BuildContext context, int courseId, ResourceProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surfaceWhite,
      builder: (context) {
        return CreateOptionsBottomSheet(
          courseId: courseId,
          provider: provider,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    child: CreateMaterialScreen(courseId: courseId),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
