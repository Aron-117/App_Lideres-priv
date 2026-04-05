import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importante
import '../../core/theme/app_colors.dart';
import '../../core/widgets/course_card.dart';
import '../../core/providers/course_provider.dart'; // Importante
import '../../core/utils/app_routes.dart'; // Para navegar al detalle de la materia
import '../../core/widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ejecutamos la búsqueda de cursos justo cuando la pantalla se crea
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const CustomDrawer(), // AGREGAR ESTA LÍNEA
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Flutter pondrá automáticamente el ícono de Menú (hamburguesa) a la izquierda
        // porque detecta que tienes un `drawer: const CustomDrawer()`.

        // Acciones a la derecha (Nuestro botón de Perfil)
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: AppColors.secondary,
              radius: 16,
              child: Icon(Icons.person, color: AppColors.surfaceWhite, size: 20),
            ),
            onPressed: () {
              // Navegar a la pantalla de perfil
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          const SizedBox(width: 16),
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

            // Aquí conectamos la UI con la lógica
            Expanded(
              child: Consumer<CourseProvider>(
                builder: (context, provider, child) {
                  // Caso 1: Está cargando
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  // Caso 2: Hubo un error
                  if (provider.errorMessage != null) {
                    return Center(child: Text('Error: ${provider.errorMessage}'));
                  }

                  // Caso 3: Éxito pero lista vacía
                  if (provider.courses.isEmpty) {
                    return const Center(child: Text('No tienes materias asignadas.'));
                  }

                  // Caso 4: Éxito con datos reales
                  return ListView.builder(
                    itemCount: provider.courses.length, // Ya no es '4'
                    itemBuilder: (context, index) {
                      final course = provider.courses[index];
                      return CourseCard(
                        title: course.title,
                        description: course.description,
                        onTap: () {
                          // Navegar al detalle de la materia
                          Navigator.pushNamed(context, AppRoutes.classDetail);
                        },
                      );
                    },
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
