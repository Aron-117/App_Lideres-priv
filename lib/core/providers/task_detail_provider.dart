import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/task_service.dart';

class TaskDetailProvider extends ChangeNotifier {
  final TaskService _service = TaskService();

  // Cambiamos File por PlatformFile
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  String? _message;
  bool _isSuccess = false;

  PlatformFile? get selectedFile => _selectedFile;
  bool get isUploading => _isUploading;
  String? get message => _message;
  bool get isSuccess => _isSuccess;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      // CRÍTICO PARA WEB: Obliga a Flutter a cargar los bytes a la RAM
      withData: true,
    );

    if (result != null) {
      // Guardamos el objeto multiplataforma completo
      _selectedFile = result.files.single;
      _message = null;
      notifyListeners();
    }
  }

  void clearFile() {
    _selectedFile = null;
    notifyListeners();
  }

  Future<void> submitTask(int idEntrega) async {
    if (_selectedFile == null) {
      _message = "Por favor, selecciona un archivo primero.";
      notifyListeners();
      return;
    }

    _isUploading = true;
    _message = null;
    notifyListeners();

    try {
      _isSuccess = await _service.uploadTaskFile(idEntrega, _selectedFile!);
      if (_isSuccess) {
        _message = "¡Tarea entregada con éxito!";
      }
    } catch (e) {
      _message = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
