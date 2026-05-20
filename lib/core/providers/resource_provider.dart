import 'package:flutter/material.dart';
import '../models/resource_model.dart';
import '../../services/course_service.dart';

class ResourceProvider extends ChangeNotifier {
  final CourseService _service = CourseService();
  int? _courseId;
  int? get courseId => _courseId;
  List<Resource> _resources = [];
  bool _isLoading = false;
  String? _errorMessage;

  int? _currentCourseId;

  List<Resource> get resources => _resources;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCourse(int courseId) async {
    _currentCourseId = courseId;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();
    try {
      _resources = await _service.fetchCourseResources(courseId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCourse() async {
    if (_currentCourseId == null) return;

    await loadCourse(_currentCourseId!);
  }

  Future<bool> createTask(int courseId, Map<String, dynamic> data) async {
    try {
      final success = await _service.createTask(courseId, data);

      if (success) {
        await loadCourse(courseId);
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  Future<bool> createMaterial(int courseId, Map<String, dynamic> data) async {
    try {
      final success = await _service.createMaterial(courseId, data);

      if (success) {
        await loadCourse(courseId);
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  Future<bool> updateTask(int taskId, Map<String, dynamic> data) async {
    try {
      final success = await _service.updateTask(taskId, data);

      if (success) {
        await refreshCourse();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  Future<bool> updateMaterial(int materialId, Map<String, dynamic> data) async {
    try {
      final success = await _service.updateMaterial(materialId, data);

      if (success) {
        await refreshCourse();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  // Agregar dentro de la clase ResourceProvider
  // Agregar dentro de la clase ResourceProvider
  Future<bool> deleteMaterial(int materialId) async {
    try {
      // Usamos "_service", que es el nombre real de tu variable en este archivo
      await _service.deleteMaterial(materialId);
      
      // Borramos de la lista local
      _resources.removeWhere((item) => item.id == materialId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
