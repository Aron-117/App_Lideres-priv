import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/admin_provider.dart';
import 'user_form_dialog.dart';
import 'course_management_tab.dart'; // Importamos la nueva pestaña

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos DefaultTabController para manejar las pestañas de forma nativa
    return DefaultTabController(
      length: 2, // Dos pestañas: Usuarios y Cursos
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Administración',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 28,
              color: AppColors.primaryDark,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primaryDark,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.people_alt_rounded), text: 'Usuarios'),
              Tab(icon: Icon(Icons.school_rounded), text: 'Cursos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Pestaña 1: Tu código anterior encapsulado
            _UserManagementTab(),
            // Pestaña 2: La nueva lógica de cursos
            CourseManagementTab(),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// WIDGET LOCAL: La gestión de usuarios que ya tenías
// =================================================================
class _UserManagementTab extends StatefulWidget {
  const _UserManagementTab();

  @override
  State<_UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<_UserManagementTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
    });
  }

  void _showUserDialog([user]) {
    showDialog(
      context: context,
      builder: (_) => UserFormDialog(userToEdit: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUserDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Usuario', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o correo...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surfaceWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => context.read<AdminProvider>().filterUsers(value),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<AdminProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                  if (provider.errorMessage != null) return Center(child: Text(provider.errorMessage!));
                  if (provider.users.isEmpty) return const Center(child: Text('No se encontraron usuarios.'));

                  return ListView.separated(
                    itemCount: provider.users.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = provider.users[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.secondary.withOpacity(0.2),
                            child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text('${user.email} \nRol: ${user.role.name}', style: TextStyle(color: Colors.grey.shade600, height: 1.3)),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit_square, color: AppColors.primary, size: 20), onPressed: () => _showUserDialog(user)),
                              IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20), onPressed: () => _showDeleteDialog(context, provider, user)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AdminProvider provider, user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Usuario', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que quieres eliminar a ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () {
              provider.removeUser(user.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}