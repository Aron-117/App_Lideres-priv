import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/task_service.dart';

class TaskDetailProvider extends ChangeNotifier {
  final TaskService _service = TaskService();

  PlatformFile? _selectedFile;
  bool _isUploading = false;
  String? _message;
  bool _isSuccess = false;
  bool _alreadySubmitted = false;
  Map<String, dynamic>? _submissionData;

  int? _studentScore;
  String? _teacherComment;

  int? get studentScore => _studentScore;
  String? get teacherComment => _teacherComment;
  bool get isGraded => _studentScore != null; // Saber si ya lo calificaron

  // Getters
  bool get alreadySubmitted => _alreadySubmitted;
  PlatformFile? get selectedFile => _selectedFile;
  bool get isUploading => _isUploading;
  String? get message => _message;
  bool get isSuccess => _isSuccess;
  Map<String, dynamic>? get submissionData => _submissionData;

  List<dynamic> get submissionFiles =>
      _submissionData?['entrega']?['archivos'] ?? [];

  Future<void> loadSubmissionStatus(int tareaId) async {
    try {
      final result = await _service.getSubmissionStatus(tareaId);
      _alreadySubmitted = result['entregado'] ?? false;
      _submissionData = result;

      // NUEVO: Extraemos la calificación y el comentario si la tarea ya fue entregada
      if (_alreadySubmitted && result['entrega'] != null) {
        _studentScore = result['entrega']['calificacion'];
        _teacherComment = result['entrega']['comentario_profesor'];
      } else {
        _studentScore = null;
        _teacherComment = null;
      }

      _message = null; // Limpiamos mensajes previos al recargar
      notifyListeners();
    } catch (e) {
      _message = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      withData: true,
    );

    if (result != null) {
      _selectedFile = result.files.single;
      _message = null;
      notifyListeners();
    }
  }

  void clearFile() {
    _selectedFile = null;
    notifyListeners();
  }

  Future<void> submitTask(int tareaId) async {
    _isUploading = true;
    _message = null;
    notifyListeners();

    try {
      final entregaId = await _service.createOrGetEntrega(tareaId);

      if (_selectedFile != null) {
        _isSuccess = await _service.uploadTaskFile(entregaId, _selectedFile!);
      } else {
        _isSuccess = true;
      }

      _message = "¡Tarea entregada con éxito!";

      // Recargamos el estado desde el servidor para actualizar los archivos y la UI limpiamente
      await loadSubmissionStatus(tareaId);
    } catch (e) {
      _isSuccess = false;
      _message = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// ==========================================
  /// NUEVO: CANCELAR / ANULAR LA ENTREGA COMPLETA
  /// ==========================================
  Future<void> cancelSubmission(int tareaId) async {
    _isUploading = true;
    _message = null;
    notifyListeners();

    try {
      // 1. Llamar al servicio encargado de borrar la entrega o cambiar su estado en el backend
      await _service.cancelSubmission(
        _submissionData?['entrega']?['id_entrega'],
      );

      // 2. Si el backend responde bien, limpiamos el estado localmente
      _alreadySubmitted = false;
      _submissionData = null;
      _selectedFile = null;
      _studentScore = null; // NUEVO: Limpiamos la calificación por seguridad
      _teacherComment = null; // NUEVO: Limpiamos el comentario por seguridad
      _isSuccess = false;
      _message = "Entrega anulada con éxito.";
    } catch (e) {
      _message = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// ==========================================
  /// NUEVO: ELIMINAR UN ARCHIVO INDIVIDUAL
  /// ==========================================
  Future<void> deleteSubmittedFile(int fileId, int tareaId) async {
    _isUploading = true;
    _message = null;
    notifyListeners();
    try {
      // 1. Llamar al backend para eliminar el archivo físico y su registro en BD
      await _service.deleteSubmissionFile(fileId);

      _message = "Archivo eliminado correctamente.";

      // 2. Refrescamos el estado para que desaparezca de la lista 'submissionFiles'
      await loadSubmissionStatus(tareaId);
    } catch (e) {
      _message = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCurrentTask(int tareaId) async {
    _isUploading = true;
    _message = null;
    notifyListeners();

    try {
      await _service.deleteTask(tareaId);
      return true; // Retornamos true si se borró con éxito
    } catch (e) {
      _message = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}