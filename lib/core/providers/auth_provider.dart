import 'package:flutter/material.dart';
import '../models/user_model.dart';
<<<<<<< HEAD
import '../../services/auth_service.dart';
class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
=======
import '../../services/auth_service.dart'; // <-- Cambiamos al servicio real

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

>>>>>>> 91b22edbd346c7313ccd08073ef6b52da940fbf9
  User? _currentUser;
  String? _jwtToken;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _jwtToken != null && _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Método que la UI llama al presionar "Sign In"
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Pide el token al backend y lo guarda
      _jwtToken = await _service.login(email, password);

      // 2. Trae la información del usuario
      _currentUser = await _service.getProfile(_jwtToken!);

      _isLoading = false;
      notifyListeners();
      return true; // Éxito
    } catch (e) {
      // 1. Convertimos el error a texto para analizarlo
      String errorStr = e.toString();

      // 2. Si es un error de conexión (el servidor está apagado o no hay internet)
      if (errorStr.contains('SocketException') || errorStr.contains('ClientException')) {
        _errorMessage =
            'No se pudo conectar al servidor. Revisa tu conexión a internet o intenta más tarde.';
      }
      // 3. Si es un error controlado de nuestra API (ej: "Usuario no encontrado")
      else {
        _errorMessage = errorStr.replaceAll('Exception: ', '');
      }

      _jwtToken = null;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Modificamos el logout para que borre el token del celular
  Future<void> logout() async {
    await _service.logout();
    _jwtToken = null;
    _currentUser = null;
    notifyListeners();
  }
}
