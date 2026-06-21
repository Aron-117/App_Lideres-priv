import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/constants/api_constants.dart';

class ResourceFileService {
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();

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
    String apiPath, {
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('No hay sesión activa.');

    final url = Uri.parse('${ApiConstants.baseUrl}/$apiPath');
    final tipo = (apiPath == "archivo-material") ? "id_material" : "id_tarea";
    final formData = FormData.fromMap({
      tipo: resourceId.toString(),
      'file': kIsWeb
          ? MultipartFile.fromBytes(file.bytes!, filename: file.name)
          : await MultipartFile.fromFile(file.path!, filename: file.name),
    });

    final response = await _dio.postUri(
      url,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
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
