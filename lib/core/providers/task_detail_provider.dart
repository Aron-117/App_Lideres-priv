import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/task_service.dart';

class TaskDetailProvider extends ChangeNotifier {
  final TaskService _service = TaskService();

  final List<PlatformFile> _selectedFiles = [];
  bool _isUploading = false;
  String? _uploadingFileName;
  int _uploadProgress = 0;
  CancelToken? _uploadCancelToken;
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
  List<PlatformFile> get selectedFiles => List.unmodifiable(_selectedFiles);
  bool get isUploading => _isUploading;
  String? get uploadingFileName => _uploadingFileName;
  int get uploadProgress => _uploadProgress;
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

      // Si ya existe una entrega registrada, limpiamos la selección local
      // para que la caja de subida quede vacía después de enviar.
      if (_alreadySubmitted && _selectedFiles.isNotEmpty) {
        _selectedFiles.clear();
      }

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
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      _selectedFiles
        ..clear()
        ..addAll(result.files);
      _message = null;
      notifyListeners();
    }
  }

  void removeSelectedFile(int index) {
    if (index >= 0 && index < _selectedFiles.length) {
      _selectedFiles.removeAt(index);
      notifyListeners();
    }
  }

  void clearFiles() {
    _selectedFiles.clear();
    notifyListeners();
  }

  Future<void> submitTask(int tareaId) async {
    _isUploading = true;
    _uploadingFileName = null;
    _uploadProgress = 0;
    _message = null;
    notifyListeners();

    try {
      final entregaId = await _service.createOrGetEntrega(tareaId);

      if (_selectedFiles.isNotEmpty) {
        _uploadCancelToken = CancelToken();
        _isSuccess = await _service.uploadTaskFiles(
          entregaId,
          _selectedFiles,
          cancelToken: _uploadCancelToken,
          onSendProgress: (index, sent, total) {
            _uploadingFileName = _selectedFiles[index].name;
            _uploadProgress = total == 0 ? 0 : ((sent / total) * 100).round();
            notifyListeners();
          },
        );
      } else {
        _isSuccess = true;
      }

      _message = "¡Tarea entregada con éxito!";
      _alreadySubmitted = true;
      clearFiles();
      // Recargamos el estado desde el servidor para actualizar los archivos y la UI limpiamente
      await loadSubmissionStatus(tareaId);
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        _isSuccess = false;
        _message = 'Subida cancelada por el usuario.';
      } else {
        _isSuccess = false;
        _message = e.toString().replaceAll('Exception: ', '');
      }
    } catch (e) {
      _isSuccess = false;
      _message = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isUploading = false;
      _uploadingFileName = null;
      _uploadProgress = 0;
      _uploadCancelToken = null;
      notifyListeners();
    }
  }

  /// Cancela la subida en curso si existe
  Future<void> cancelUpload() async {
    if (_uploadCancelToken != null && !_uploadCancelToken!.isCancelled) {
      _uploadCancelToken?.cancel('Cancelled by user');
    }

    // Aseguramos limpiar el estado de la UI
    _isUploading = false;
    _uploadingFileName = null;
    _uploadProgress = 0;
    _message = 'Subida cancelada.';
    _isSuccess = false;
    notifyListeners();
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
      clearFiles();
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
