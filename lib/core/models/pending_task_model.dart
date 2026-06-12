class PendingTask {
  final int idTarea;
  final int idCurso; // Extraemos el ID del objeto anidado
  final String titulo;
  final String descripcion;
  final String fechaPublicacion;
  final String fechaEntrega;
  final int calificacion;

  PendingTask({
    required this.idTarea,
    required this.idCurso,
    required this.titulo,
    required this.descripcion,
    required this.fechaPublicacion,
    required this.fechaEntrega,
    required this.calificacion,
  });

  factory PendingTask.fromJson(Map<String, dynamic> json) {
    return PendingTask(
      // Usamos ?? por si algún día un texto viene nulo, no colapse la app
      idTarea: json['id_tarea'] ?? 0,

      // 👇 EL TRUCO ESTÁ AQUÍ: Entramos al mapa 'curso' y sacamos su ID
      idCurso: json['curso'] != null ? json['curso']['id_curso'] : 0,

      titulo: json['titulo'] ?? 'Sin título',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      fechaPublicacion: json['fecha_publicacion'] ?? '',
      fechaEntrega: json['fecha_entrega'] ?? '',
      calificacion: json['calificacion'] ?? 0,
    );
  }
}
