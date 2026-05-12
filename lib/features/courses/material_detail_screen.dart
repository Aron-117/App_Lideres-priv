import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/resource_model.dart';

class MaterialDetailScreen extends StatelessWidget {
  const MaterialDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibimos el material que enviamos desde ClassDetailScreen
    final material = ModalRoute.of(context)?.settings.arguments as Resource?;

    if (material == null) {
      return const Scaffold(body: Center(child: Text("Error: Material no encontrado")));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark),
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
                material.description ?? 'Sin descripción proporcionada por el profesor.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ),
            const SizedBox(height: 32),

            // --- ZONA DE ADJUNTOS (PLACEHOLDER) ---
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
                  Icon(Icons.insert_drive_file_outlined, size: 40, color: AppColors.primary),
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
