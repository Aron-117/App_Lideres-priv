import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../../services/mock_course_service.dart';

class CourseProvider extends ChangeNotifier {
  final MockCourseService _service = MockCourseService();

  List<Course> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para que la vista pueda leer los datos
  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Método para buscar los datos
  Future<void> loadCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Le avisa a la pantalla que muestre el "Cargando..."

    try {
      _courses = await _service.fetchCourses();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Le avisa a la pantalla que ya terminó (con éxito o error)
    }
  }
}
