import 'package:flutter/material.dart';
import '../models/resource_model.dart';
import '../../services/course_service.dart';

class ResourceProvider extends ChangeNotifier {
  final CourseService _service = CourseService();

  List<Resource> _resources = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Resource> get resources => _resources;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadResources(int courseId) async {
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

  Future<bool> createTask(int courseId, Map<String, dynamic> data) async {
    try {
      final success = await _service.createTask(courseId, data);
      if (success) {
        await loadResources(courseId);
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
        await loadResources(courseId);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
