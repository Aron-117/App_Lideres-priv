import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado de la Tarea
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Titulo de tarea',
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(fontSize: 24, color: AppColors.primaryDark),
                  ),
                ),
                Text(
                  '12 Sep, 10:00', // Fecha de entrega para test
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Añadido recientemente', // Estado o categoría
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Descripción (test)
            Text(
              'To edit this text, select the text area and double-click to edit. Pellentesque elit tellus, dictum at eleifend blandit, porttitor at quam. Cras lobortis eu urna.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Sección de Archivos Adjuntos
            Text(
              'Archivo adjunto',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Contenedor para simular un archivo o botón de subida
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.5),
                  style: BorderStyle.solid,
                ),
              ),
              child: InkWell(
                onTap: () {
                  // Lógica para abrir explorador de archivos
                },
                borderRadius: BorderRadius.circular(12),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, size: 40, color: AppColors.accent),
                    SizedBox(height: 8),
                    Text('Toca para subir un archivo'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Botón de Entrega
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.surfaceWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Lógica de entregar tarea
              },
              child: const Text('Entregar / Anular entrega', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
