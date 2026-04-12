import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart'; // <-- Nuevo
import 'package:flutter/foundation.dart' show kIsWeb; // <-- Para detectar Chrome
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
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
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
      multipartFile = http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name);
    } else {
      // LOGICA PARA MÓVIL: Tomamos el archivo de la ruta del disco duro
      multipartFile = await http.MultipartFile.fromPath('file', file.path!, filename: file.name);
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
}
