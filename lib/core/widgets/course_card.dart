import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  const CourseCard({super.key, required this.title, required this.description, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceWhite,
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.secondary.withOpacity(0.3)), // Bordecito
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen Provisional
            const SizedBox(height: 120, child: Placeholder(color: AppColors.accent)),
            // Textos
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
