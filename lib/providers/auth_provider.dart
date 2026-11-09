import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../core/api_client.dart';
import '../models/usuario_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  Usuario? _usuario;

  bool get isAuthenticated => _isAuthenticated;
  Usuario? get usuario => _usuario;

  // Verificar si el usuario puede registrar propiedades (admin o propietario)
  bool get puedeRegistrarPropiedades {
    if (_usuario == null) return false;
    return _usuario!.rol == RolUsuario.administrador ||  _usuario!.rol == RolUsuario.propietario;
  }

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await apiClient.storage.read(key: 'jwt_token');
    _isAuthenticated = token != null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _authService.login(email, password);
    if (result['success']) {
      _isAuthenticated = true;
      _usuario = result['usuario']; // ✅ Guardamos los datos del usuario
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> register(String nombre, String email, String telefono, String password, String rol) async {
    return await _authService.register(nombre, email, telefono, password, rol);
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _usuario = null;
    notifyListeners();
  }
}