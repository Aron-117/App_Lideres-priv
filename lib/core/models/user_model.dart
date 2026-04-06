import '../utils/user_roles.dart';

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  User({required this.id, required this.name, required this.email, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    // Convertimos el string del JSON al Enum estricto de Dart
    UserRole parsedRole = UserRole.values.firstWhere(
      (e) => e.name == json['role'],
      orElse: () => UserRole.student, // Fallback de seguridad
    );

    return User(id: json['id'], name: json['name'], email: json['email'], role: parsedRole);
  }
}
