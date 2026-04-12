import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';
import '../core/models/course_model.dart';

class CourseService {
  final _storage = const FlutterSecureStorage();

  Future<List<Course>> fetchCourses() async {
    // 1. Recuperamos la "llave" (Token) que guardamos al iniciar sesión
    final token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      throw Exception('No hay sesión activa. Por favor, inicia sesión de nuevo.');
    }

    // 2. Preparamos la ruta
    final url = Uri.parse('${ApiConstants.baseUrl}/curso/my');

    // 3. Hacemos la petición GET inyectando el token en el Header
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    // 4. Verificamos la respuesta
    if (response.statusCode == 200) {
      // El backend manda una lista [ {curso1}, {curso2} ]
      List<dynamic> body = jsonDecode(response.body);

      // Convertimos cada objeto JSON en nuestro modelo Course
      List<Course> courses = body.map((dynamic item) => Course.fromJson(item)).toList();
      return courses;
    } else {
      throw Exception('Error al cargar los cursos. Código: ${response.statusCode}');
    }
  }
}
