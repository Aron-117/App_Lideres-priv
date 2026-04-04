enum UserRole {
  superAdmin, // El sudo
  admin, // Admin normal
  professor, // Profesor
  student, // Estudiante
}

// Extensión para facilitar la lógica en vistas
extension UserRoleExtension on UserRole {
  bool get canEditCourses =>
      this == UserRole.superAdmin || this == UserRole.admin || this == UserRole.professor;
  bool get canManageUsers => this == UserRole.superAdmin || this == UserRole.admin;
}
