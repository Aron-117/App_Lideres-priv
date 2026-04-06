import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TaskListTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  const TaskListTile({super.key, required this.title, required this.description, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.star_border, color: AppColors.primaryDark),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16)),
        subtitle: Text(description, style: Theme.of(context).textTheme.bodyMedium),
        onTap: onTap,
      ),
    );
  }
}
