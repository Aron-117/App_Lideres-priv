import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../../services/mock_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final MockAuthService _service = MockAuthService();

  User? _currentUser;
  String? _jwtToken;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _jwtToken != null && _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Método que la UI llamará al presionar "Sign In"
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Flujo de 2 pasos exigido por la arquitectura
      _jwtToken = await _service.login(email, password);
      _currentUser = await _service.getProfile(_jwtToken!);

      _isLoading = false;
      notifyListeners();
      return true; // Éxito
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _jwtToken = null;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false; // Fallo
    }
  }

  void logout() {
    _jwtToken = null;
    _currentUser = null;
    notifyListeners();
  }
}
