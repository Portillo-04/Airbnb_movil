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
        data: FormData.fromMap({'username': email, 'password': password}),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final token = response.data['access_token'];

      // ✅ 1. GUARDAR EL TOKEN DE ACCESO
      await _client.storage.write(key: 'jwt_token', value: token);

      // ✅ 2. Decodificar el token JWT para obtener los datos del usuario
      final payload = _decodeToken(token);

      // ✅ 3. NUEVO: GUARDAR EL ID Y EL ROL EN SECURE STORAGE
      // Esto es crítico para que property_form_screen pueda asociar
      // la propiedad al usuario correcto sin depender solo del token.
      if (payload['id'] != null) {
        await _client.storage.write(
          key: 'user_id',
          value: payload['id'].toString(),
        );
      }

      if (payload['rol'] != null) {
        await _client.storage.write(
          key: 'user_rol',
          value: payload['rol'].toString(),
        );
      }

      final usuario = Usuario(
        id: payload['id'],
        nombre: payload['sub'], // El email suele estar en 'sub'
        email: payload['sub'],
        telefono: '', // No viene en el token básico
        rol: RolUsuario.values.firstWhere(
          (e) =>
              e.toString().split('.').last.toLowerCase() ==
              payload['rol'].toString().toLowerCase(),
          orElse: () => RolUsuario.visitante,
        ),
      );

      return {'success': true, 'token': token, 'usuario': usuario};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['detail'] ?? 'Error de conexión',
      };
    }
  }

  // Función simple para decodificar el payload del JWT (sin validar firma criptográfica)
  Map<String, dynamic> _decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return Map<String, dynamic>.from(jsonDecode(decoded));
    } catch (e) {
      print('❌ Error al decodificar token: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> register(
    String nombre,
    String email,
    String telefono,
    String password,
    String rol,
  ) async {
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
      return {
        'success': false,
        'error': e.response?.data['detail'] ?? 'Error al registrar',
      };
    }
  }

  Future<void> logout() async {
    // ✅ LIMPIAR TODOS LOS DATOS AL CERRAR SESIÓN
    await _client.storage.delete(key: 'jwt_token');
    await _client.storage.delete(key: 'user_id');
    await _client.storage.delete(key: 'user_rol');
  }
}
