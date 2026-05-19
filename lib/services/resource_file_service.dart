import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/constants/api_constants.dart';

class ResourceFileService {
  final _storage = const FlutterSecureStorage();

  // apiPath será 'archivo-material' o 'archivo-tarea'

  Future<List<dynamic>> getFiles(int resourceId, String apiPath) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');
    final tipo = (apiPath == 'archivo-material') ? "material" : "tarea";
    // Asumiendo que tu endpoint es /archivo-material/recurso/1 o similar
    final url = Uri.parse('${ApiConstants.baseUrl}/$apiPath/$tipo/$resourceId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error al cargar los archivos adjuntos.');
    }
  }

  Future<bool> uploadFile(
    int resourceId,
    PlatformFile file,
    String apiPath,
  ) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    final url = Uri.parse('${ApiConstants.baseUrl}/$apiPath');
    final tipo = (apiPath == "archivo-material") ? "id_material" : "id_tarea";
    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({'Authorization': 'Bearer $token'});

    // Asumiendo que tu backend espera 'id_recurso' (ajusta si espera id_material o id_tarea)
    request.fields[tipo] = resourceId.toString();

    http.MultipartFile multipartFile;
    if (kIsWeb) {
      multipartFile = http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      );
    } else {
      multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path!,
        filename: file.name,
      );
    }

    request.files.add(multipartFile);
    var streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200 ||
        streamedResponse.statusCode == 201) {
      return true;
    } else {
      throw Exception('Error al subir el archivo adjunto.');
    }
  }

  Future<void> deleteFile(int fileId, String apiPath) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    final url = Uri.parse('${ApiConstants.baseUrl}/$apiPath/$fileId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar el archivo.');
    }
  }
}
