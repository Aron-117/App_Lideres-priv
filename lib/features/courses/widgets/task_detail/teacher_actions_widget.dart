import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/task_detail_provider.dart';

class TeacherActionsWidget extends StatelessWidget {
  final TaskDetailProvider provider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewSubmissions;

  const TeacherActionsWidget({
    Key? key,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
    required this.onViewSubmissions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          onPressed: onEdit,
          icon: const Icon(Icons.create_rounded, size: 20),
          label: const Text(
            'Editar tarea',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceWhite,
            foregroundColor: AppColors.error,
            elevation: 0,
            side: const BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: provider.isUploading ? null : onDelete,
          icon: provider.isUploading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.error,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.delete_outline, size: 20),
          label: const Text(
            'Eliminar tarea',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surfaceWhite,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onViewSubmissions,
          icon: const Icon(Icons.people_alt_rounded, size: 20),
          label: const Text(
            'Revisar entregas de alumnos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
