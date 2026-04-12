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
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Course.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los cursos.');
    }
  }

  // Método 2: Obtener recursos de un curso específico
  Future<List<Resource>> fetchCourseResources(int courseId) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('${ApiConstants.baseUrl}/curso/$courseId/recursos');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> resourcesJson = data['recursos'];
      return resourcesJson.map((json) => Resource.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar recursos del curso');
    }
  }
}
