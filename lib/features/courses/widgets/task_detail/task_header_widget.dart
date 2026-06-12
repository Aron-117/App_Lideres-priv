import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/resource_model.dart';
import '../../../../core/providers/task_detail_provider.dart';

class TaskHeaderWidget extends StatelessWidget {
  final Resource task;
  final bool isTeacher;
  final TaskDetailProvider provider;

  const TaskHeaderWidget({
    Key? key,
    required this.task,
    required this.isTeacher,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 26,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              if (task.dueDate != null)
                Text(
                  'Límite: '
                  '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year} - '
                  '${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isTeacher && provider.isGraded) ...[
              Text(
                '${provider.studentScore}/${task.maxScore ?? 100}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                'Calificado',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              Text(
                '${task.maxScore ?? 100} pts',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              if (!isTeacher)
                Text(
                  provider.alreadySubmitted ? 'Entregado' : 'Asignado',
                  style: TextStyle(
                    fontSize: 12,
                    color: provider.alreadySubmitted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }
}
