import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../core/models/course_model.dart';
import '../core/models/resource_model.dart'; // Ajustado el path del import

class CourseService {
  final _storage = const FlutterSecureStorage();

  // Método 1: Obtener todos los cursos
  Future<List<Course>> fetchCourses() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    final url = Uri.parse('${ApiConstants.baseUrl}/curso/my');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Course.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los cursos.');
    }
  }
  // Método exclusivo para el ADMIN: Obtener TODOS los cursos de la plataforma
  Future<List<Course>> fetchAllCourses() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    // Asumimos que la ruta estándar REST para obtener todos es /curso
    final url = Uri.parse('${ApiConstants.baseUrl}/curso'); 
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Course.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar todos los cursos.');
    }
  }


  // Método 2: Obtener recursos de un curso específico
  Future<List<Resource>> fetchCourseResources(int courseId) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/curso/$courseId/recursos');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> resourcesJson = data['recursos'];
      return resourcesJson.map((json) => Resource.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar recursos del curso');
    }
  }

  // Método 3: Crear tarea
  Future<bool> createTask(int courseId, Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/tarea');
    // Aseguramos que el curso esté vinculado
    data['id_curso'] = courseId;
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Método 4: Crear material
  Future<bool> createMaterial(int courseId, Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/material');
    data['id_curso'] = courseId;

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    print(response.body);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Método 5: Actualizar tarea
  Future<bool> updateTask(int taskId, Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'jwt_token');

    final url = Uri.parse('${ApiConstants.baseUrl}/tarea/$taskId');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  // Método 6: Actualizar material
  Future<bool> updateMaterial(int materialId, Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'jwt_token');

    final url = Uri.parse('${ApiConstants.baseUrl}/material/$materialId');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  // Método 7: Eliminar material
  Future<bool> deleteMaterial(int materialId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    final url = Uri.parse('${ApiConstants.baseUrl}/material/$materialId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error al eliminar el material.');
      } catch (_) {
        throw Exception(
          'Error del servidor al eliminar el material (${response.statusCode}).',
        );
      }
    }
    return true;
  }


  // --- MÉTODOS PARA GESTIÓN DE CURSOS (ADMIN) ---

  Future<bool> createCourse(Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/curso');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateCourse(int courseId, Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/curso/$courseId');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteCourse(int courseId) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/curso/$courseId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
