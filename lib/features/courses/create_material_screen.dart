import 'package:app_lideres/core/models/resource_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/resource_provider.dart';

class CreateMaterialScreen extends StatefulWidget {
  final Resource? material;
  final int? courseId;
  const CreateMaterialScreen({super.key, this.courseId, this.material});

  @override
  State<CreateMaterialScreen> createState() => _CreateMaterialScreenState();
}

class _CreateMaterialScreenState extends State<CreateMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  bool _isLoading = false;

  bool get isEditing => widget.material != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.material?.title ?? '',
    );
    _descController = TextEditingController(
      text: widget.material?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final Map<String, dynamic> data = {
      'titulo': _titleController.text.trim(),
      'descripcion': _descController.text.trim(),
    };

    final provider = context.read<ResourceProvider>();
    bool success = false;

    try {
      if (isEditing) {
        success = await provider.updateMaterial(widget.material!.id, data);
      } else {
        success = await provider.createMaterial(widget.courseId!, data);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    if (!mounted) return;

    if (success) {
      Resource? updatedMaterial;
      if (isEditing) {
        updatedMaterial = widget.material!.copyWith(
          title: data['titulo'],
          description: data['descripcion'],
        );
      }
      Navigator.pop(context, updatedMaterial);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Material actualizado' : 'Material subido exitosamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                (isEditing
                    ? 'Error al actualizar material'
                    : 'Error al subir material'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          isEditing ? 'Editar Material' : 'Subir Material',
          style: const TextStyle(color: AppColors.primaryDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- CAMPO TÍTULO CORREGIDO ---
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del material',
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  // Truco del Login
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 16),

              // --- CAMPO DESCRIPCIÓN CORREGIDO ---
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  // Truco del Login
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isEditing ? Icons.edit_rounded : Icons.info_outline,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEditing
                          ? 'Estás modificando un material existente.'
                          : 'La subida de archivos adjuntos se habilitará próximamente.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.surfaceWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEditing ? 'Guardar Cambios' : 'Publicar Material',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
