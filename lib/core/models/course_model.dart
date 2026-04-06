class Course {
  final String id;
  final String title;
  final String description;

  Course({required this.id, required this.title, required this.description});

  // Esto es vital para cuando el backend te mande el JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(id: json['id'], title: json['title'], description: json['description']);
  }
}
