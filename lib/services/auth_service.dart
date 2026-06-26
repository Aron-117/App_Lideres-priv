import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../core/models/user_model.dart';

class AuthService {
  // Instancia para guardar datos de forma segura (encriptada)
  final _storage = const FlutterSecureStorage();

  // 1. Iniciar sesión y obtener Token
  Future<String> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      // El backend pide específicamente "correo" y "password"
      body: jsonEncode({'correo': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];

      // Guardamos el token en la "caja fuerte" del celular
      await _storage.write(key: 'jwt_token', value: token);
      return token;
    } else if (response.statusCode == 401) {
      throw Exception('Contraseña incorrecta'); // Regla exacta de tu API (Página 1)
    } else if (response.statusCode == 404) {
      throw Exception('Usuario no encontrado'); // Regla exacta de tu API (Página 1)
    } else {
      throw Exception('Error del servidor. Código: ${response.statusCode}');
    }
  }

  // 2. Obtener datos del perfil usando el Token
  Future<User> getProfile(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/profile');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Inyectamos la llave
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('No se pudo cargar el perfil del usuario');
    }
  }

  // 3. Cerrar sesión
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final url = Uri.parse('${ApiConstants.baseUrl}/auth/logout');
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      // Ignoramos errores de red al hacer logout para asegurar que
      // la sesión local siempre se borre incluso sin internet.
    } finally {
      await _storage.delete(key: 'jwt_token');
    }
  }

  // 4. Utilidad: Obtener el token guardado (lo usaremos para los cursos luego)
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
}
