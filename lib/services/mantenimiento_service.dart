import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/mantenimiento_model.dart';

class MantenimientoService {
  final _client = apiClient;

  Future<Map<String, dynamic>> crearSolicitud({
    required String titulo,
    required String descripcion,
    required int propiedadId,
  }) async {
    try {
      print('📤 Creando solicitud de mantenimiento...');

      final response = await _client.dio.post(
        '/mantenimiento/',
        data: {
          'titulo': titulo,
          'descripcion': descripcion,
          'propiedad_id': propiedadId,
        },
      );

      print('✅ Solicitud creada: ${response.data}');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print('❌ Error: ${e.response?.data}');
      return {'success': false, 'error': e.response?.data['detail'] ?? 'Error al crear solicitud'};
    }
  }

  Future<List<SolicitudMantenimiento>> obtenerMisSolicitudes() async {
    try {
      print('📥 Obteniendo mis solicitudes...');
      final response = await _client.dio.get('/mantenimiento/mis-solicitudes');
      final List<dynamic> data = response.data;
      return data.map((json) => SolicitudMantenimiento.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error al cargar solicitudes');
    }
  }

  Future<List<SolicitudMantenimiento>> obtenerSolicitudesPropietario() async {
    try {
      final response = await _client.dio.get('/mantenimiento/propietario');
      final List<dynamic> data = response.data;
      return data.map((json) => SolicitudMantenimiento.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error al cargar solicitudes');
    }
  }

  Future<Map<String, dynamic>> actualizarEstado({
    required int solicitudId,
    required String nuevoEstado,
    String? descripcion,
  }) async {
    try {
      final response = await _client.dio.patch(
        '/mantenimiento/$solicitudId/estado',
        data: {
          'estado': nuevoEstado,
          'descripcion': descripcion,
        },
      );
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['detail'] ?? 'Error al actualizar'};
    }
  }
}