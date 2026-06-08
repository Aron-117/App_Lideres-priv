import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../core/models/course_model.dart';
import '../core/models/resource_model.dart';

class CourseService {
  final _storage = const FlutterSecureStorage();

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

  Future<List<Course>> fetchAllCourses() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

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

  Future<bool> createTask(int courseId, Map<String, dynamic> data) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/tarea');
    data['id_curso'] = courseId;
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] is List) {
          throw Exception(errorData['message'].join(', '));
        }
        throw Exception(errorData['message'] ?? 'Error desconocido al crear tarea');
      } catch (e) {
        throw Exception(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

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
    return response.statusCode == 200 || response.statusCode == 201;
  }

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
        throw Exception('Error del servidor al eliminar el material (${response.statusCode}).');
      }
    }
    return true;
  }

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

  Future<bool> inscribirEstudiante(int idUsuario, int idCurso) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/inscripcion');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id_usuario': idUsuario,
        'id_curso': idCurso,
        'estado': 'ACTIVO', 
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Error desconocido al inscribir');
    }
  }

  // --- NUEVAS FUNCIONALIDADES PARA GESTIÓN DE INSCRITOS ---

  Future<List<dynamic>> fetchCourseInscripciones(int courseId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    final url = Uri.parse('${ApiConstants.baseUrl}/curso/$courseId/inscripciones');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar la lista de estudiantes inscritos.');
    }
  }

  Future<bool> deleteInscripcion(int idInscripcion) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/inscripcion/$idInscripcion');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Error al eliminar la inscripción.');
    }
  }
}