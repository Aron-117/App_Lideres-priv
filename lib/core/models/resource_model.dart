class Resource {
  final int id;
  final String title;
  final String? description;
  final String type; // "material" o "tarea"
  final DateTime? dueDate;

  Resource({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.dueDate,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    bool isTask = json['tipo'] == 'tarea';
    return Resource(
      id: isTask ? json['id_tarea'] : json['id_material'],
      title: json['titulo'] ?? 'Sin título',
      description: json['descripcion'],
      type: json['tipo'],
      dueDate: json['fecha_entrega'] != null ? DateTime.parse(json['fecha_entrega']) : null,
    );
  }
}
