import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../core/models/user_model.dart';

class AdminService {
  final _storage = const FlutterSecureStorage();

  // 1. Obtener todos los usuarios (GET /api/usuario)
  Future<List<User>> getAllUsers() async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/usuario');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener la lista de usuarios');
    }
  }

  // 2. Editar usuario (PATCH /api/usuario/{id})
  Future<bool> updateUser(int id, Map<String, dynamic> updates) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/usuario/$id');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updates),
    );
    return response.statusCode == 200;
  }

  // 3. Crear usuario (POST /api/usuario)
  Future<bool> createUser(Map<String, dynamic> userData) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/usuario');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(userData),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // 4. Eliminar usuario (DELETE /api/usuario/{id})
  Future<bool> deleteUser(int id) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/usuario/$id');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
