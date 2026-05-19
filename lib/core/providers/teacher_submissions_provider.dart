import 'package:flutter/material.dart';
import '../../services/task_service.dart';

class TeacherSubmissionsProvider extends ChangeNotifier {
  final TaskService _service = TaskService();

  bool _isLoading = false;
  String? _error;
  List<dynamic> _submissions = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get submissions => _submissions;

  // Contador rápido para saber cuántos han entregado
  int get totalSubmissions => _submissions.length;

  Future<void> fetchSubmissions(int tareaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _submissions = await _service.getSubmissionsByTask(tareaId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ==========================================
  /// CALIFICAR Y ACTUALIZAR ESTADO LOCAL
  /// ==========================================
  Future<void> gradeSubmission(
    int entregaId,
    int nota,
    String comentario,
  ) async {
    try {
      await _service.gradeSubmission(entregaId, nota, comentario);
      final index = _submissions.indexWhere(
        (s) => s['id_entrega'] == entregaId,
      );
      if (index != -1) {
        _submissions[index]['calificacion'] = nota;
        _submissions[index]['comentario_profesor'] = comentario;
        notifyListeners();
      }
    } catch (e) {
      print(e);
      // Relanzamos el error para que la UI pueda mostrar un SnackBar
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
