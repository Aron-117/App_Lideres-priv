import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _service = AdminService();

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _filteredUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<User> _students = [];
  List<User> _filteredStudents = [];

  List<User> get students =>
      _filteredStudents.isEmpty ? _students : _filteredStudents;

  // --- MÉTODO PARA TRAER SOLO ESTUDIANTES ---
  Future<void> fetchStudents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Llamamos al nuevo método del servicio
      _students = await _service.fetchStudents();
      _filteredStudents = []; // Limpiamos filtros anteriores
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- MÉTODO PARA FILTRAR ESTUDIANTES EN EL BUSCADOR ---
  void filterStudents(String query) {
    if (query.isEmpty) {
      _filteredStudents = [];
    } else {
      _filteredStudents = _students
          .where(
            (user) =>
                user.name.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _allUsers = await _service.getAllUsers();
      _filteredUsers = List.from(_allUsers);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers
          .where(
            (u) =>
                u.name.toLowerCase().contains(query.toLowerCase()) ||
                u.email.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      final success = await _service.createUser(userData);
      if (success) {
        await fetchUsers(); // Refresh the list
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> updates) async {
    try {
      final success = await _service.updateUser(id, updates);
      if (success) {
        await fetchUsers(); // Refresh the list
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> removeUser(int id) async {
    try {
      final success = await _service.deleteUser(id);
      if (success) {
        _allUsers.removeWhere((u) => u.id == id);
        _filteredUsers.removeWhere((u) => u.id == id);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
}
