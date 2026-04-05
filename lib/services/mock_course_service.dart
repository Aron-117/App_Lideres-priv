import '../core/models/course_model.dart';

class MockCourseService {
  // Simulamos una petición HTTP que tarda 2 segundos
  Future<List<Course>> fetchCourses() async {
    await Future.delayed(const Duration(seconds: 2));

    // Aquí podrías simular un error descomentando la siguiente línea:
    // throw Exception('Error de conexión con el servidor');

    return [
      Course(
        id: 'c1',
        title: 'Matemáticas Avanzadas',
        description: 'Cálculo diferencial e integral.',
      ),
      Course(id: 'c2', title: 'Física Moderna', description: 'Termodinámica y mecánica cuántica.'),
      Course(
        id: 'c3',
        title: 'Historia Universal',
        description: 'Desde la prehistoria hasta la actualidad.',
      ),
    ];
  }
}
