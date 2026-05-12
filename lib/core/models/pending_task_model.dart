class PendingTask {
  final int id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String courseName;

  PendingTask({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    required this.courseName,
  });

  factory PendingTask.fromJson(Map<String, dynamic> json) {
    return PendingTask(
      id: json['id_tarea'],
      title: json['titulo'] ?? 'Sin título',
      description: json['descripcion'] ?? '',
      // Convertimos el string ISO 8601 a DateTime de Dart
      dueDate: json['fecha_entrega'] != null ? DateTime.parse(json['fecha_entrega']) : null,
      courseName: json['curso'] != null ? json['curso']['nombre'] : 'Clase general',
    );
  }
}
