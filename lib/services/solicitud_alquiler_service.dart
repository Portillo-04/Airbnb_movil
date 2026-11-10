import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/solicitud_alquiler_model.dart';

class SolicitudAlquilerService {
  final _client = apiClient;

  // Para inquilino: crear solicitud
  Future<Map<String, dynamic>> crearSolicitud({
    required int propiedadId,
    required String fechaInicio,
    required String fechaFin,
  }) async {
    try {
      print('📤 Enviando solicitud de alquiler...');

      final response = await _client.dio.post(
        '/solicitudes-alquiler/',
        data: {
          'propiedad_id': propiedadId,
          'fecha_inicio': fechaInicio,
          'fecha_fin': fechaFin,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print('❌ Error al crear solicitud: ${e.response?.data}');
      return {
        'success': false,
        'error': e.response?.data['detail'] ?? 'Error al crear solicitud',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error inesperado: $e'};
    }
  }

  // ✅ CORREGIDO: URL y lógica para propietario
  Future<List<SolicitudAlquiler>> obtenerSolicitudesPropietario() async {
    try {
      print('📥 Obteniendo solicitudes del propietario...');

      // ✅ BACKEND ESPERA: GET /solicitudes-alquiler/ (filtra solo por token)
      final response = await _client.dio.get('/solicitudes-alquiler/');

      final List<dynamic> data = response.data;
      print('✅ Solicitudes obtenidas: ${data.length}');

      return data.map((json) => SolicitudAlquiler.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Error al obtener solicitudes: ${e.response?.data}');
      throw Exception(
        e.response?.data['detail'] ?? 'Error al cargar solicitudes',
      );
    }
  }

  // ✅ CORREGIDO: URL y cuerpo del request
  Future<Map<String, dynamic>> responderSolicitud({
    required int id,
    required String estado, // APROBADA, RECHAZADA, POSPUESTA
    String? respuesta,
  }) async {
    try {
      print('📤 Respondiendo solicitud #$id -> $estado');

      // ✅ BACKEND ESPERA: PATCH /solicitudes-alquiler/{id}
      // ✅ BODY ESPERA: {"estado": "...", "respuesta_propietario": "..."}
      final response = await _client.dio.patch(
        '/solicitudes-alquiler/$id',
        data: {'estado': estado, 'respuesta_propietario': respuesta ?? ''},
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      print('✅ Respuesta exitosa: ${response.data}');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print('❌ Error al responder: ${e.response?.data}');
      return {
        'success': false,
        'error': e.response?.data['detail'] ?? 'Error al actualizar estado',
      };
    } catch (e) {
      return {'success': false, 'error': 'Error inesperado: $e'};
    }
  }
}
