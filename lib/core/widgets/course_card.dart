import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath; // ALTERACIÓN 1: Variable para la ruta de la imagen
  final VoidCallback? onTap;

  const CourseCard({
    super.key, 
    required this.title, 
    required this.description, 
    required this.imagePath, // ALTERACIÓN 2: Lo pedimos como dato obligatorio
    this.onTap
  });

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
            // ALTERACIÓN 3: Cambiamos Placeholder por Image.asset envuelto en ClipRRect
            ClipRRect(
              // Cortamos solo las esquinas superiores para que no tapen el borde de la tarjeta
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                imagePath,
                height: 120,
                fit: BoxFit.cover, // Hace que la imagen llene el espacio sin aplastarse
              ),
            ),
            // Textos (TOTALMENTE INTACTOS)
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