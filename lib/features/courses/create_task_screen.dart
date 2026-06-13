import 'package:app_lideres/core/models/resource_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/resource_provider.dart';
import '../../core/widgets/informative_form_card.dart';

class CreateTaskScreen extends StatefulWidget {
  final int? courseId;
  final Resource? task;
  const CreateTaskScreen({super.key, this.courseId, this.task});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _scoreController; 
  DateTime? _selectedDate;
  bool _isLoading = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _scoreController = TextEditingController(
      text: widget.task?.maxScore?.toString() ?? '100',
    );
    _selectedDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _scoreController.dispose(); 
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedDate != null 
            ? TimeOfDay.fromDateTime(_selectedDate!) 
            : const TimeOfDay(hour: 23, minute: 59),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una fecha y hora de entrega'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // --- EL CAMBIO ESTÁ AQUÍ ---
    final Map<String, dynamic> data = {
      'titulo': _titleController.text.trim(),
      'descripcion': _descController.text.trim(),
      'fecha_entrega': _selectedDate!.toIso8601String(),
      // Ahora enviamos "calificacion" como acordaste con tu compañero
      'calificacion': int.tryParse(_scoreController.text.trim()) ?? 100,
    };

    final provider = context.read<ResourceProvider>();
    bool success = false;

    try {
      if (isEditing) {
        success = await provider.updateTask(widget.task!.id, data);
      } else {
        success = await provider.createTask(widget.courseId!, data);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    if (!mounted) return;

    if (success) {
      final updatedTask = Resource(
        id: isEditing ? widget.task!.id : 0,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        type: 'tarea',
        dueDate: _selectedDate,
        maxScore: int.tryParse(_scoreController.text.trim()) ?? 100, 
      );
      if (!mounted) return;
      Navigator.pop(context, updatedTask);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Tarea actualizada' : 'Tarea creada exitosamente',
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
                    ? 'Error al actualizar tarea'
                    : 'Error al crear tarea'),
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
          isEditing ? 'Editar Tarea' : 'Crear Tarea',
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título de la tarea',
                  prefixIcon: Icon(Icons.title_rounded, color: AppColors.primary, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.notes_rounded, color: AppColors.primary, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_filled_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'Establecer Fecha y Hora'
                                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} - ${_selectedDate!.hour.toString().padLeft(2, '0')}:${_selectedDate!.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _scoreController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Puntos',
                        prefixIcon: Icon(Icons.military_tech_rounded, color: AppColors.primary, size: 20),
                        filled: true,
                        fillColor: AppColors.surfaceWhite,
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Req.' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              InformativeFormCard(
                icon: isEditing ? Icons.edit_rounded : Icons.assignment_rounded,
                text: isEditing
                    ? 'Estás modificando una tarea existente.'
                    : 'Completa la información para publicar la tarea.',
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
                        isEditing ? 'Guardar Cambios' : 'Publicar Tarea',
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