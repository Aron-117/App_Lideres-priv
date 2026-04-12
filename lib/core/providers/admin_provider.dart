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

  Future<void> removeUser(int id) async {
    final success = await _service.deleteUser(id);
    if (success) {
      _allUsers.removeWhere((u) => u.id == id);
      _filteredUsers.removeWhere((u) => u.id == id);
      notifyListeners();
    }
  }
}
