import '../utils/user_roles.dart';

class User {
  final int id;
  final String name;
  final String email;
  final UserRole role;

  User({required this.id, required this.name, required this.email, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    // Mapeamos el rol del backend ("Estudiante", "Profesor") a tu Enum
    UserRole parsedRole;
    switch (json['rol']) {
      case 'Profesor':
        parsedRole = UserRole.professor;
        break;
      case 'Estudiante':
      default:
        parsedRole = UserRole.student;
        break;
    }

    return User(
      id: json['id_usuario'] ?? json['sub'] ?? 0, // 'sub' viene en el endpoint de profile
      name: json['nombre'] ?? 'Usuario',
      email: json['correo'] ?? '',
      role: parsedRole,
    );
  }
}
