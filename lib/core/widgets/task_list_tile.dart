import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TaskListTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;
  final String tipo;
  const TaskListTile({
    super.key,
    required this.title,
    required this.description,
    this.tipo = 'tarea',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ALTERACIÓN 1: Quitamos el borde total y el margen horizontal excesivo
      // para que encaje mejor dentro del ExpansionTile
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        // ALTERACIÓN 2: Sombra muy sutil para dar profundidad sin usar bordes oscuros
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        // Para que la línea lateral mida lo mismo que el contenido
        child: Row(
          children: [
            // ALTERACIÓN 3: Línea de color lateral (Identidad visual de SOCIEQAAP)
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.secondary, // Usamos el lila de la marca
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                // ALTERACIÓN 4: Ícono más moderno y sutil
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tipo == "tarea"
                        ? Icons.assignment_outlined
                        : Icons.book_rounded,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                ),
                title: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                subtitle: Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.backgroundLight,
                  size: 14,
                ),
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
