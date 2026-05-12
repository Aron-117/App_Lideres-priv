import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../../services/course_service.dart'; // <--  servicio real

class CourseProvider extends ChangeNotifier {
  final CourseService _service = CourseService();

  List<Course> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para la vista
  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Método para buscar los datos reales
  Future<void> loadCourses() async {
    _isLoading = true;
    _errorMessage = null;
    // Retrasamos el notifyListeners usando un microtask para evitar colisiones
    // al construir la vista inicial en el HomeScreen
    Future.microtask(() => notifyListeners());

    try {
      _courses = await _service.fetchCourses();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
