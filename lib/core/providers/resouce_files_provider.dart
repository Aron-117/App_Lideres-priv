import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/resource_file_service.dart';

class ResourceFilesProvider extends ChangeNotifier {
  final ResourceFileService _service = ResourceFileService();

  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;
  List<dynamic> _files = [];

  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get error => _error;
  List<dynamic> get files => _files;

  // Carga inicial
  Future<void> fetchFiles(int resourceId, String apiPath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _files = await _service.getFiles(resourceId, apiPath);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Subir archivo (Profesor)
  Future<void> pickAndUploadFile(int resourceId, String apiPath) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'],
      withData: true,
    );

    if (result != null) {
      _isUploading = true;
      _error = null;
      notifyListeners();

      try {
        await _service.uploadFile(resourceId, result.files.single, apiPath);
        // Si sube con éxito, recargamos la lista
        await fetchFiles(resourceId, apiPath);
      } catch (e) {
        _error = e.toString().replaceAll('Exception: ', '');
      } finally {
        _isUploading = false;
        notifyListeners();
      }
    }
  }

  // Eliminar archivo (Profesor)
  Future<void> deleteFile(int fileId, int resourceId, String apiPath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteFile(fileId, apiPath);
      await fetchFiles(resourceId, apiPath); // Recargar lista
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }
}
