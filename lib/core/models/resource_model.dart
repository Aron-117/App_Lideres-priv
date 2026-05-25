class Resource {
  final int id;
  final String title;
  final String? description;
  final String type; // "material" o "tarea"
  final DateTime? dueDate;
  final int? maxScore; // Puntaje máximo de la tarea
  final int? studentScore; // Calificación obtenida por el alumno

  Resource({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.dueDate,
    this.maxScore,
    this.studentScore,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    bool isTask = json['tipo'] == 'tarea';
    return Resource(
      id: isTask ? json['id_tarea'] : json['id_material'],
      title: json['titulo'] ?? 'Sin título',
      description: json['descripcion'],
      type: json['tipo'],
      dueDate: json['fecha_entrega'] != null
          ? DateTime.parse(json['fecha_entrega']).toLocal() 
          : null,
      // EL CAMBIO: Ahora leemos el puntaje máximo desde el campo "calificacion" de la tabla Tarea
      maxScore: json['calificacion'] ?? 100, 
      studentScore: null, // La nota del alumno se lee desde el Provider (tabla Entrega), así que aquí va null
    );
  }

  Resource copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    DateTime? dueDate,
    int? maxScore,
    int? studentScore,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      maxScore: maxScore ?? this.maxScore,
      studentScore: studentScore ?? this.studentScore,
    );
  }
}