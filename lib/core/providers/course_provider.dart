import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../../services/course_service.dart'; 

class CourseProvider extends ChangeNotifier {
  final CourseService _service = CourseService();

  List<Course> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Variables para la gestión de inscritos en un curso específico
  List<dynamic> _inscripciones = [];
  bool _isLoadingInscripciones = false;

  // Getters para la vista
  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  List<dynamic> get inscripciones => _inscripciones;
  bool get isLoadingInscripciones => _isLoadingInscripciones;

  Future<void> loadCourses() async {
    _isLoading = true;
    _errorMessage = null;
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

  Future<bool> createCourse(Map<String, dynamic> data) async {
    try {
      final success = await _service.createCourse(data);
      if (success) await loadCourses(); 
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourse(int id, Map<String, dynamic> data) async {
    try {
      final success = await _service.updateCourse(id, data);
      if (success) await loadCourses();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourse(int id) async {
    try {
      final success = await _service.deleteCourse(id);
      if (success) {
        _courses.removeWhere((item) => item.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAllCourses() async {
    _isLoading = true;
    _errorMessage = null;
    Future.microtask(() => notifyListeners());

    try {
      _courses = await _service.fetchAllCourses();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- GESTIÓN DE INSCRIPCIONES ---

  Future<void> loadInscripciones(int courseId) async {
    _isLoadingInscripciones = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _inscripciones = await _service.fetchCourseInscripciones(courseId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingInscripciones = false;
      notifyListeners();
    }
  }

  Future<bool> inscribirEstudianteEnCurso(int idUsuario, int idCurso) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.inscribirEstudiante(idUsuario, idCurso);

      if (success) {
        // Al inscribir con éxito, recargamos la lista de inscritos para que se actualice la ventana
        await loadInscripciones(idCurso);
        await loadAllCourses();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (_errorMessage!.startsWith('[')) {
        _errorMessage = 'Error en los datos de inscripción. Revisa la información.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> desmatricularEstudiante(int idInscripcion, int courseId) async {
    _isLoadingInscripciones = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.deleteInscripcion(idInscripcion);
      if (success) {
        // Eliminamos localmente de la lista para no hacer doble recarga
        _inscripciones.removeWhere((item) => item['id_inscripcion'] == idInscripcion);
        await loadAllCourses(); // Actualiza cupos en la pantalla principal
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoadingInscripciones = false;
      notifyListeners();
    }
  }
}