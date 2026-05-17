enum UserRole {
  superAdmin, // El sudo
  admin, // Admin normal
  profesor, // Profesor
  estudiante, // Estudiante
}

// Extensión para facilitar la lógica en vistas
extension UserRoleExtension on UserRole {
  bool get canEditCourses =>
      this == UserRole.superAdmin ||
      this == UserRole.admin ||
      this == UserRole.profesor;
  bool get canManageUsers =>
      this == UserRole.superAdmin || this == UserRole.admin;
}
