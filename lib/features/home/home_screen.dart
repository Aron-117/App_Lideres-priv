import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/course_card.dart';
import '../../core/providers/course_provider.dart';
import '../../core/utils/app_routes.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ALTERACIÓN 1: Envolvemos el Scaffold en un Container para darle el degradado de fondo
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundLight, // Tu tono azul claro
            AppColors.surfaceWhite,    // Difuminándose hacia blanco puro
          ],
        ),
      ),
      child: Scaffold(
        // ALTERACIÓN 2: Hacemos el Scaffold transparente para que deje ver el degradado
        backgroundColor: Colors.transparent,
        drawer: const CustomDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // ALTERACIÓN 3: Forzamos el color del menú hamburguesa para que resalte sobre el fondo claro
          iconTheme: const IconThemeData(color: AppColors.primaryDark),
          actions: [
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: AppColors.secondary,
                radius: 16,
                child: Icon(Icons.person, color: AppColors.surfaceWhite, size: 20),
              ),
              onPressed: () {
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
                ).textTheme.displayLarge?.copyWith(
                  color: AppColors.primaryDark, 
                  fontSize: 28,
                  fontWeight: FontWeight.w900, // ALTERACIÓN 4: Título más "gordito" (Bold) para darle jerarquía
                ),
              ),
              const SizedBox(height: 24),

              // LÓGICA INTACTA
              Expanded(
                child: Consumer<CourseProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }

                    if (provider.errorMessage != null) {
                      return Center(child: Text('Error: ${provider.errorMessage}'));
                    }

                    if (provider.courses.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tienes materias asignadas.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: provider.courses.length,
                      // ALTERACIÓN 5: Añadimos un pequeño espacio (padding) extra al final de la lista
                      // para que la última tarjeta no quede pegada al borde inferior de la pantalla.
                      padding: const EdgeInsets.only(bottom: 24.0), 
                      itemBuilder: (context, index) {
                        final course = provider.courses[index];
                        return CourseCard(
                          title: course.title,
                          description: course.description,
                          // ALTERACIÓN 6: Agregamos el parámetro imagePath que tu CourseCard ahora exige.
                          imagePath: 'assets/images/banner3.png', 
                          onTap: () {
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
      ),
    );
  }
}