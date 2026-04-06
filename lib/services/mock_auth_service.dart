import '../core/models/user_model.dart';
import '../core/utils/user_roles.dart';

class MockAuthService {
  // 1. Primer endpoint simulado: /api/auth/login
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulamos latencia

    // Validación básica para la demo
    if (email.isEmpty || password.isEmpty) {
      throw Exception('El correo y la contraseña son obligatorios.');
    }
    if (password != '123456') {
      // Contraseña maestra para pruebas
      throw Exception('Credenciales incorrectas.');
    }

    return "eyJhbGciOiJIUzI1NiIsInR5cCI...fake_jwt";
  }

  // 2. Segundo endpoint simulado: /api/auth/profile
  Future<User> getProfile(String token) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulamos latencia

    if (token.isEmpty) throw Exception('Token inválido');

    // Devolvemos un JSON simulado y lo pasamos por nuestro Modelo
    // Prueba cambiando el 'role' a 'student', 'admin' o 'superAdmin'
    final mockJsonResponse = {
      "id": "u1",
      "name": "Randol (Test User)",
      "email": "test@lideres.com",
      "role": "professor",
    };

    return User.fromJson(mockJsonResponse);
  }
}
