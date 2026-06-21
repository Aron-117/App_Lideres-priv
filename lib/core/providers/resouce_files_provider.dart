import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/resource_file_service.dart';

class ResourceFilesProvider extends ChangeNotifier {
  final ResourceFileService _service = ResourceFileService();

  bool _isLoading = false;
  bool _isUploading = false;
  String? _uploadingFileName;
  int _uploadProgress = 0;
  CancelToken? _uploadCancelToken;
  String? _error;
  String? _cancelMessage;
  List<dynamic> _files = [];
  int? _lastResourceId;
  String? _lastApiPath;

  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get uploadingFileName => _uploadingFileName;
  int get uploadProgress => _uploadProgress;
  String? get error => _error;
  String? get cancelMessage => _cancelMessage;
  List<dynamic> get files => _files;
  bool get canCancelUpload =>
      _uploadCancelToken != null && !_uploadCancelToken!.isCancelled;

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
    _lastResourceId = resourceId;
    _lastApiPath = apiPath;
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'],
      withData: true,
    );

    if (result != null) {
      final file = result.files.single;
      _uploadCancelToken = CancelToken();
      _isUploading = true;
      _uploadingFileName = file.name;
      _uploadProgress = 0;
      _error = null;
      notifyListeners();

      try {
        await _service.uploadFile(
          resourceId,
          file,
          apiPath,
          cancelToken: _uploadCancelToken,
          onSendProgress: (sent, total) {
            _uploadProgress = total == 0 ? 0 : ((sent / total) * 100).round();
            notifyListeners();
          },
        );
        _uploadProgress = 100;
        await fetchFiles(resourceId, apiPath);
      } catch (e) {
        // If the exception is a cancellation, don't show it as an error
        if (e is DioError && e.type == DioErrorType.cancel) {
          // ignore, cancellation handled separately
        } else {
          _error = e.toString().replaceAll('Exception: ', '');
        }
      } finally {
        _isUploading = false;
        _uploadingFileName = null;
        notifyListeners();
      }
    }
  }

  Future<void> cancelUpload() async {
    if (_uploadCancelToken != null && !_uploadCancelToken!.isCancelled) {
      _uploadCancelToken?.cancel('Cancelled by teacher');
    }

    _isUploading = false;
    _uploadingFileName = null;
    _uploadProgress = 0;
    _uploadCancelToken = null;
    _cancelMessage = 'Subida cancelada';
    _error = null;
    notifyListeners();

    // Refresh files so the list/empty box is shown correctly
    if (_lastResourceId != null && _lastApiPath != null) {
      await fetchFiles(_lastResourceId!, _lastApiPath!);
    }

    // Clear the cancel message after 5 seconds but keep files/box visible
    Timer(const Duration(seconds: 5), () {
      _cancelMessage = null;
      notifyListeners();
    });
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
