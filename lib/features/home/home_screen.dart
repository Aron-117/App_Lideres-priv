import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/course_card.dart';
import '../../core/providers/course_provider.dart';
import '../../core/utils/app_routes.dart';
import '../../core/widgets/smart_refresh_wrapper.dart';
import '../../core/widgets/custom_drawer.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/user_roles.dart';

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
    final auth = context.watch<AuthProvider>();
    final isTeacher = auth.currentUser?.role.canEditCourses ?? false;
    final userName = auth.currentUser?.name.split(' ').first ?? 'Usuario';

    // ALTERACIÓN 1: Envolvemos el Scaffold en un Container para darle el degradado de fondo
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundLight, // Tu tono azul claro
            AppColors.surfaceWhite, // Difuminándose hacia blanco puro
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
                child: Icon(
                  Icons.person,
                  color: AppColors.surfaceWhite,
                  size: 20,
                ),
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
                'Hola, $userName',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isTeacher ? 'Clases que impartes' : 'Tus Clases',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // LÓGICA INTACTA
              Expanded(
                child: Consumer<CourseProvider>(
                  builder: (context, provider, child) {
                    return SmartRefreshWrapper(
                      onRefresh: () => provider.loadCourses(),
                      isLoading: provider.isLoading,
                      errorMessage: provider.errorMessage,
                      isEmpty: provider.courses.isEmpty,
                      emptyMessage: 'No tienes materias asignadas.',
                      onRetry: () => provider.loadCourses(),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: provider.courses.length,
                        padding: const EdgeInsets.only(bottom: 24.0),
                        itemBuilder: (context, index) {
                          final course = provider.courses[index];
                          return CourseCard(
                            title: course.title,
                            description: course.description,
                            imagePath: 'assets/images/banner3.png',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.classDetail,
                                arguments: course.id,
                              );
                            },
                          );
                        },
                      ),
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
