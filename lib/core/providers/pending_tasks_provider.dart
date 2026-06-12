import 'package:flutter/material.dart';
import '../models/pending_task_model.dart';
import '../../services/task_service.dart';

class PendingTasksProvider extends ChangeNotifier {
  final TaskService _service = TaskService();

  List<PendingTask> sinFecha = [];
  List<PendingTask> estaSemana = [];
  List<PendingTask> anteriores = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadTasks() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final allTasks = await _service.fetchPendingTasks();
      final now = DateTime.now();

      // Limpiamos las listas
      sinFecha.clear();
      estaSemana.clear();
      anteriores.clear();
      // Separamos las tareas por fecha
      for (var task in allTasks) {
        if (DateTime.parse(task.fechaEntrega).isBefore(now)) {
          anteriores.add(task); // Ya vencieron
        } else {
          estaSemana.add(
            task,
          ); // Aún hay tiempo (simplificado como "esta semana")
        }
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
