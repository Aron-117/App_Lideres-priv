class Course {
  final int id;
  final String title;
  final String description;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int? cupos;
  final int? idProfesor;

  Course({
    required this.id,
    required this.title,
    required this.description,
    this.fechaInicio,
    this.fechaFin,
    this.cupos,
    this.idProfesor,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id_curso'],
      title: json['nombre'] ?? 'Sin nombre',
      description: json['descripcion'] ?? 'Sin descripción',
      fechaInicio: json['fecha_inicio'] != null ? DateTime.tryParse(json['fecha_inicio']) : null,
      fechaFin: json['fecha_fin'] != null ? DateTime.tryParse(json['fecha_fin']) : null,
      cupos: json['cupos'],
      idProfesor: json['id_profesor'],
    );
  }
}