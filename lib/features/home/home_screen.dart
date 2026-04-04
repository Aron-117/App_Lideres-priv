import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/course_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primaryDark),
          onPressed: () {},
        ),
        // Ícono de Perfil
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: AppColors.secondary,
              radius: 16,
              child: Icon(Icons.person, color: AppColors.surfaceWhite, size: 20),
            ),
            onPressed: () {
              // Navegar al perfil
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Buenas noches',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(color: AppColors.primaryDark, fontSize: 28),
            ),
            const SizedBox(height: 24),

            // Lista de cursos
            Expanded(
              child: ListView.builder(
                itemCount:
                    4, //cantidad de cursos, esto se deberia reemplazará por datos reales después
                itemBuilder: (context, index) {
                  return CourseCard(
                    title: 'Título de Curso ${index + 1}',
                    description: 'Descripción breve de la materia o curso.',
                    onTap: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
