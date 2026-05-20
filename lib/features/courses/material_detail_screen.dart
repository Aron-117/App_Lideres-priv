import 'package:app_lideres/core/models/resource_model.dart';
import 'package:app_lideres/core/providers/auth_provider.dart';
import 'package:app_lideres/core/providers/resource_provider.dart';
import 'package:app_lideres/core/utils/user_roles.dart';
import 'package:app_lideres/core/widgets/resource_attachments_section.dart';
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
  bool _isDeleting = false; // Maneja el estado de carga del botón eliminar

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
    // Retornamos también para que la lista anterior se actualice
    Navigator.pop(context, updatedMaterial);
  }

  Future<void> _deleteMaterial() async {
    final confirm = await _showConfirmDialog(
      context,
      title: 'Eliminar material',
      content: '¿Estás seguro de que deseas eliminar este material de forma permanente?',
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);

      final provider = context.read<ResourceProvider>();
      final success = await provider.deleteMaterial(material.id);

      if (!mounted) return;
      setState(() => _isDeleting = false);

      if (success) {
        Navigator.of(context).pop(true); // Retorna a la lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Error al eliminar el material'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<bool?> _showConfirmDialog(BuildContext context, {required String title, required String content}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
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

            // --- BOTONES DEL PROFESOR (MODULAR) ---
            if (currentUserRole.canEditCourses) ...[
              _TeacherActionButtons(
                onEdit: _goToEdit,
                onDelete: _deleteMaterial,
                isDeleting: _isDeleting,
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
                material.description ?? 'Sin descripción proporcionada por el profesor.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
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
              child: ResourceAttachmentsSection(
                resourceId: material.id,
                isTeacher: currentUserRole.canEditCourses,
                apiPath: 'archivo-material',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// WIDGET LOCAL: Botones del Profesor
// =====================================================================
class _TeacherActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;

  const _TeacherActionButtons({
    required this.onEdit,
    required this.onDelete,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón Editar
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
          onPressed: isDeleting ? null : onEdit,
          icon: const Icon(Icons.create_rounded, size: 20),
          label: const Text(
            'Editar material',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        const SizedBox(height: 12),
        // Botón Eliminar
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceWhite,
            foregroundColor: AppColors.error,
            elevation: 0,
            side: const BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isDeleting ? null : onDelete,
          icon: isDeleting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.error,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.delete_outline, size: 20),
          label: const Text(
            'Eliminar material',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ],
    );
  }
}