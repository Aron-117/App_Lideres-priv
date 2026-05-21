import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/course_model.dart';
import '../../core/providers/course_provider.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/user_roles.dart';

class CourseFormDialog extends StatefulWidget {
  final Course? courseToEdit;
  const CourseFormDialog({super.key, this.courseToEdit});

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _cuposController;
  
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int? _selectedProfesorId;
  
  bool _isLoading = false;

  bool get isEditing => widget.courseToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.courseToEdit?.title ?? '');
    _descController = TextEditingController(text: widget.courseToEdit?.description ?? '');
    _cuposController = TextEditingController(text: widget.courseToEdit?.cupos?.toString() ?? '30'); 
    
    _fechaInicio = widget.courseToEdit?.fechaInicio;
    _fechaFin = widget.courseToEdit?.fechaFin;
    _selectedProfesorId = widget.courseToEdit?.idProfesor;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _cuposController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isInicio) async {
    final initialDate = isInicio 
        ? (_fechaInicio ?? DateTime.now()) 
        : (_fechaFin ?? DateTime.now().add(const Duration(days: 30)));
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark, 
              onPrimary: Colors.white, 
              onSurface: AppColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        if (isInicio) {
          _fechaInicio = date;
        } else {
          _fechaFin = date;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona las fechas de inicio y fin.')),
      );
      return;
    }

    if (_selectedProfesorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor asigna un profesor titular.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'nombre': _titleController.text.trim(),
      'descripcion': _descController.text.trim(),
      'fecha_inicio': _fechaInicio!.toIso8601String(),
      'fecha_fin': _fechaFin!.toIso8601String(),
      'cupos': int.tryParse(_cuposController.text.trim()) ?? 0,
      'id_profesor': _selectedProfesorId,
    };

    final provider = context.read<CourseProvider>();
    bool success;

    if (isEditing) {
      success = await provider.updateCourse(widget.courseToEdit!.id, data);
    } else {
      success = await provider.createCourse(data);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      await provider.loadAllCourses();
      if (!mounted) return;
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Curso actualizado exitosamente' : 'Curso creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error desconocido'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final profesores = adminProvider.users.where((u) => u.role == UserRole.profesor).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.backgroundLight,
      titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      title: Column(
        children: [
          Icon(
            isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            isEditing ? 'Editar Curso' : 'Crear Nuevo Curso',
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // NOMBRE
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration('Nombre del curso', Icons.school_outlined),
                  validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                
                // DESCRIPCIÓN
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: _inputDecoration('Descripción del curso', Icons.subject_rounded),
                  validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                // CUPOS
                TextFormField(
                  controller: _cuposController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Límite de cupos', Icons.groups_outlined),
                  validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                
                // PROFESOR TITULAR (Diseño Mejorado)
                DropdownButtonFormField<int>(
                  value: _selectedProfesorId,
                  isExpanded: true, // Evita que los nombres largos rompan el diseño
                  decoration: _inputDecoration('Profesor Titular', Icons.person_outline_rounded),
                  dropdownColor: AppColors.surfaceWhite,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                  items: profesores.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.secondary.withOpacity(0.2),
                            child: Text(
                              p.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              p.name,
                              style: const TextStyle(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedProfesorId = val),
                  hint: const Text('Seleccionar un profesor...'),
                ),
                const SizedBox(height: 24),

                // FECHAS (Estilo de botones flotantes)
                Row(
                  children: [
                    Expanded(child: _buildDatePickerItem(isInicio: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDatePickerItem(isInicio: false)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(bottom: 20, right: 24, left: 24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surfaceWhite,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          onPressed: _isLoading ? null : _submit,
          child: _isLoading 
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                isEditing ? 'Guardar Cambios' : 'Crear Curso',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
        ),
      ],
    );
  }

  // Helper para el diseño del texto
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
      filled: true,
      fillColor: AppColors.surfaceWhite,
      // ¡LA SOLUCIÓN! Cambiamos OutlineInputBorder por UnderlineInputBorder
      border: const UnderlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // Helper para las cajas de fechas
  Widget _buildDatePickerItem({required bool isInicio}) {
    final date = isInicio ? _fechaInicio : _fechaFin;
    final label = isInicio ? 'Fecha de Inicio' : 'Fecha de Fin';

    return InkWell(
      onTap: () => _pickDate(isInicio),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isInicio ? Icons.calendar_month_rounded : Icons.event_available_rounded,
                size: 16,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? '${date.day}/${date.month}/${date.year}' : 'Definir',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: date != null ? AppColors.primaryDark : AppColors.primary,
                    ),
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