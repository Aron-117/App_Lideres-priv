import 'package:app_lideres/core/models/resource_model.dart';
import 'package:app_lideres/core/providers/auth_provider.dart';
import 'package:app_lideres/core/providers/resource_provider.dart';
import 'package:app_lideres/core/utils/user_roles.dart';
import 'package:app_lideres/features/courses/create_material_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';

class MaterialDetailScreen extends StatefulWidget {
  const MaterialDetailScreen({super.key});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  late Resource material;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Resource?;

    if (args != null) {
      material = args;
    }
  }

  Future<void> _goToEdit() async {
    final updatedMaterial = await Navigator.push<Resource>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<ResourceProvider>(),
          child: CreateMaterialScreen(material: material),
        ),
      ),
    );

    if (updatedMaterial != null && mounted) {
      setState(() {
        material = updatedMaterial;
      });
    }
    Navigator.pop(context, updatedMaterial);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final currentUserRole = auth.currentUser?.role ?? UserRole.estudiante;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryDark,
          ),

          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // --- ENCABEZADO ---
            Text(
              material.title,

              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 26,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Material de estudio',

              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            // --- BOTÓN EDITAR ---
            if (currentUserRole.canEditCourses) ...[
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

                onPressed: _goToEdit,

                icon: const Icon(Icons.create_rounded, size: 20),

                label: const Text(
                  'Editar material',

                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),

              const SizedBox(height: 24),
            ],

            // --- DESCRIPCIÓN ---
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,

                borderRadius: BorderRadius.circular(16),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Text(
                material.description ??
                    'Sin descripción proporcionada por el profesor.',

                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ),

            const SizedBox(height: 32),

            // --- ZONA DE ADJUNTOS ---
            const Text(
              'Archivos adjuntos',

              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),

              child: const Column(
                children: [
                  Icon(
                    Icons.insert_drive_file_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Descarga próximamente',

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primaryDark,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'El soporte para visualización y descarga de archivos se habilitará en la próxima actualización.',

                    textAlign: TextAlign.center,

                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
