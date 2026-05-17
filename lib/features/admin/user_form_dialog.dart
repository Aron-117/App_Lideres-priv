import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/user_roles.dart';
import '../../core/providers/admin_provider.dart';

class UserFormDialog extends StatefulWidget {
  final User? userToEdit;

  const UserFormDialog({super.key, this.userToEdit});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late UserRole _selectedRole;

  bool _isLoading = false;
  bool _isOculto = true;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userToEdit?.name ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userToEdit?.email ?? '',
    );
    _passwordController = TextEditingController();
    _selectedRole = widget.userToEdit?.role ?? UserRole.estudiante;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<AdminProvider>();
    final isEditing = widget.userToEdit != null;

    // El backend espera el rol en texto ("Admin", "Profesor", "Estudiante")
    String roleString = 'Estudiante';
    if (_selectedRole == UserRole.superAdmin) roleString = 'Admin';
    if (_selectedRole == UserRole.profesor) roleString = 'Profesor';

    bool success = false;

    if (isEditing) {
      final updates = <String, dynamic>{
        'nombre': _nameController.text.trim(),
        'correo': _emailController.text.trim(),
        'rol': roleString,
      };
      if (_passwordController.text.isNotEmpty) {
        updates['password'] = _passwordController.text;
      }
      success = await provider.updateUser(widget.userToEdit!.id, updates);
    } else {
      final newUser = <String, dynamic>{
        'nombre': _nameController.text.trim(),
        'correo': _emailController.text.trim(),
        'password': _passwordController.text,
        'rol': roleString,
        'fecha_registro': DateTime.now().toIso8601String(),
      };
      success = await provider.createUser(newUser);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Usuario actualizado' : 'Usuario creado exitosamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error al guardar el usuario'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.userToEdit != null;
    return AlertDialog(
      title: Text(isEditing ? 'Editar Usuario' : 'Nuevo Usuario'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || !val.contains('@')
                    ? 'Correo inválido'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _isOculto,
                decoration: InputDecoration(
                  labelText: isEditing ? 'Contraseña (opcional)' : 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOculto ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isOculto = !_isOculto;
                      });
                    },
                  ),
                ),
                validator: (val) {
                  if (!isEditing && (val == null || val.isEmpty)) {
                    return 'Requerido para nuevos usuarios';
                  }
                  if (val != null && val.isNotEmpty && val.length < 8) {
                    return 'Mínimo 8 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(
                    value: UserRole.estudiante,
                    child: Text('Estudiante'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.profesor,
                    child: Text('Profesor'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.superAdmin,
                    child: Text('Administrador'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
