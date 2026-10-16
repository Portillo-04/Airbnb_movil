import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/usuario_model.dart';

class AuthService {
  final _client = apiClient;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.dio.post(
        '/usuarios/login',
        data: FormData.fromMap({
          'username': email,
          'password': password,
        }),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      
      final token = response.data['access_token'];
      await _client.storage.write(key: 'jwt_token', value: token);
      
      // ✅ Decodificar el token JWT para obtener los datos del usuario
      // El token tiene: {"sub": email, "id": usuario.id, "rol": usuario.rol}
      final payload = _decodeToken(token);
      
      final usuario = Usuario(
        id: payload['id'],
        nombre: payload['sub'], // El email está en 'sub'
        email: payload['sub'],
        telefono: '', // No viene en el token, lo obtendremos después si es necesario
        rol: RolUsuario.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == payload['rol'].toString().toLowerCase(),
          orElse: () => RolUsuario.visitante,
        ),
      );
      
      return {'success': true, 'token': token, 'usuario': usuario};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['detail'] ?? 'Error de conexión'};
    }
  }

  // Función simple para decodificar el payload del JWT (sin validar firma)
  Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return Map<String, dynamic>.from(jsonDecode(decoded));
  }

  Future<Map<String, dynamic>> register(String nombre, String email, String telefono, String password, String rol) async {
    try {
      final response = await _client.dio.post(
        '/usuarios/register',
        data: {
          'nombre': nombre,
          'email': email,
          'telefono': telefono,
          'password': password,
          'rol': rol,
        },
      );
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['detail'] ?? 'Error al registrar'};
    }
  }

  Future<void> logout() async {
    await _client.storage.delete(key: 'jwt_token');
  }
}