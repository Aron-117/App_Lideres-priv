import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // <-- Para detectar Chrome
import '../core/constants/api_constants.dart';
import '../core/models/pending_task_model.dart';

class TaskService {
  final _storage = const FlutterSecureStorage();

  // 1. Método para traer las tareas pendientes (INTACTO)
  Future<List<PendingTask>> fetchPendingTasks() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    final url = Uri.parse('${ApiConstants.baseUrl}/tarea/pendientes');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => PendingTask.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las tareas pendientes');
    }
  }

  // 2. Método MULTIPLATAFORMA para subir el archivo
  // Ahora recibimos un PlatformFile en lugar de un File de dart:io
  Future<bool> uploadTaskFile(int entregaId, PlatformFile file) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    final url = Uri.parse('${ApiConstants.baseUrl}/archivo-entrega');
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.fields['id_entrega'] = entregaId.toString();

    http.MultipartFile multipartFile;

    if (kIsWeb) {
      // LOGICA PARA WEB: Tomamos el archivo directamente de la memoria (bytes)
      multipartFile = http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      );
    } else {
      // LOGICA PARA MÓVIL: Tomamos el archivo de la ruta del disco duro
      multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path!,
        filename: file.name,
      );
    }

    request.files.add(multipartFile);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Error al subir archivo. Código: ${response.statusCode}');
    }
  }

  // 3. Método para obtener la URL de descarga para Web/Navegador
  Future<String> getDownloadUrl(int archivoId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    // Generamos la URL con el token incrustado para que el navegador tenga permisos
    return '${ApiConstants.baseUrl}/archivo-entrega/$archivoId?token=$token';
  }

  Future<int> createOrGetEntrega(int tareaId) async {
    final token = await _storage.read(key: 'jwt_token');

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/entrega'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'id_tarea': tareaId}),
    );
    final data = jsonDecode(response.body);
    return data['id_entrega'];
  }

  Future<Map<String, dynamic>> getSubmissionStatus(int tareaId) async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      throw Exception('No hay sesión activa.');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/entrega/tarea/$tareaId');
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
      throw Exception('Error al obtener estado de entrega');
    }
  }

  /// ==========================================
  /// 4. Cancelar o anular una entrega completa
  /// ==========================================
  Future<void> cancelSubmission(int entregaId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');
    final url = Uri.parse('${ApiConstants.baseUrl}/entrega/$entregaId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      // Intentamos extraer el mensaje de error del servidor si existe
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error al anular la entrega.');
      } catch (_) {
        throw Exception(
          'Error del servidor al anular la entrega (${response.statusCode}).',
        );
      }
    }
  }

  /// ==========================================
  /// 5. Eliminar un archivo individual entregado
  /// ==========================================
  Future<void> deleteSubmissionFile(int fileId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');
    final url = Uri.parse('${ApiConstants.baseUrl}/archivo-entrega/$fileId');

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
        throw Exception(data['message'] ?? 'No se pudo eliminar el archivo.');
      } catch (_) {
        throw Exception(
          'Error del servidor al eliminar el archivo (${response.statusCode}).',
        );
      }
    }
  }

  Future<List<dynamic>> getSubmissionsByTask(int tareaId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    final url = Uri.parse(
      '${ApiConstants.baseUrl}/entrega/tarea/$tareaId/todas',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Retornamos la lista de entregas parseada desde el JSON
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Error al cargar la lista de entregas (${response.statusCode})',
      );
    }
  }

  Future<void> gradeSubmission(
    int entregaId,
    int nota,
    String comentario,
  ) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    // Usamos tu endpoint PATCH /entrega/:id
    final url = Uri.parse('${ApiConstants.baseUrl}/entrega/$entregaId');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'calificacion': nota,
        'comentario_profesor': comentario,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al guardar la calificación del alumno.');
    }
  }

  Future<void> deleteTask(int tareaId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    final url = Uri.parse('${ApiConstants.baseUrl}/tarea/$tareaId');

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
        throw Exception(data['message'] ?? 'Error al eliminar la tarea.');
      } catch (_) {
        throw Exception(
          'Error del servidor al eliminar la tarea (${response.statusCode}).',
        );
      }
    }
  }
}
