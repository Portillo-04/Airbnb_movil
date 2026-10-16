import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/notificacion_model.dart';

class NotificacionService {
  final _client = apiClient;

  Future<List<Notificacion>> obtenerMisNotificaciones() async {
    try {
      final response = await _client.dio.get('/notificaciones/mis-notificaciones');
      final List<dynamic> data = response.data;
      return data.map((json) => Notificacion.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error al cargar notificaciones');
    }
  }

  Future<Map<String, dynamic>> marcarComoLeida(int notificacionId) async {
    try {
      await _client.dio.patch('/notificaciones/$notificacionId/leida');
      return {'success': true};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['detail'] ?? 'Error'};
    }
  }

  Future<int> contarNoLeidas() async {
    try {
      final response = await _client.dio.get('/notificaciones/no-leidas/count');
      return response.data['count'] ?? 0;
    } on DioException catch (e) {
      return 0;
    }
  }
}