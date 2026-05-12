class Course {
  final int id;
  final String title;
  final String description;

  Course({required this.id, required this.title, required this.description});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id_curso'],
      title: json['nombre'] ?? 'Sin nombre',
      description: json['descripcion'] ?? 'Sin descripción',
    );
  }
}
