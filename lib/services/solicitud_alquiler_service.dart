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
      print('   Propiedad ID: $propiedadId');
      print('   Fecha inicio: $fechaInicio');
      print('   Fecha fin: $fechaFin');

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

      print('✅ Respuesta exitosa: ${response.data}');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print('❌ Error de DioException:');
      print('   Tipo: ${e.type}');
      print('   Status: ${e.response?.statusCode}');
      print('   Data: ${e.response?.data}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {
          'success': false,
          'error': 'Tiempo de espera agotado. Intenta de nuevo.'
        };
      } else if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'error': 'No se pudo conectar con el servidor.'
        };
      } else {
        return {
          'success': false,
          'error': e.response?.data['detail'] ?? 'Error al crear solicitud'
        };
      }
    } catch (e) {
      print('❌ Error inesperado: $e');
      return {'success': false, 'error': 'Error inesperado: $e'};
    }
  }

  // Para propietario: obtener solicitudes
  Future<List<SolicitudAlquiler>> obtenerSolicitudes() async {
    try {
      print('📥 Obteniendo solicitudes del propietario...');
      final response = await _client.dio.get('/solicitudes-alquiler/propietario');
      final List<dynamic> data = response.data;
      print('✅ Solicitudes obtenidas: ${data.length}');
      return data.map((json) => SolicitudAlquiler.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Error al obtener solicitudes: ${e.response?.data}');
      throw Exception(
          e.response?.data['detail'] ?? 'Error al cargar solicitudes');
    }
  }

  // Para propietario: actualizar estado
  Future<Map<String, dynamic>> actualizarEstado({
    required int solicitudId,
    required String nuevoEstado,
    String? respuesta,
  }) async {
    try {
      print('📤 Actualizando estado de solicitud #$solicitudId');
      print('   Nuevo estado: $nuevoEstado');
      print('   Respuesta: $respuesta');

      final response = await _client.dio.patch(
        '/solicitudes-alquiler/$solicitudId/estado',
        data: {
          'nuevo_estado': nuevoEstado,
          'respuesta': respuesta ?? '',
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      print('✅ Respuesta exitosa: ${response.data}');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print('❌ Error de DioException:');
      print('   Tipo: ${e.type}');
      print('   Status: ${e.response?.statusCode}');
      print('   Data: ${e.response?.data}');
      print('   Message: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return {
          'success': false,
          'error': 'Tiempo de espera agotado. Intenta de nuevo.'
        };
      } else if (e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'error': 'No se pudo conectar con el servidor.'
        };
      } else if (e.response?.statusCode == 403) {
        return {
          'success': false,
          'error': 'No autorizado para realizar esta acción.'
        };
      } else if (e.response?.statusCode == 404) {
        return {'success': false, 'error': 'Solicitud no encontrada.'};
      } else {
        return {
          'success': false,
          'error':
              e.response?.data['detail'] ?? 'Error al actualizar estado'
        };
      }
    } catch (e) {
      print('❌ Error inesperado: $e');
      return {'success': false, 'error': 'Error inesperado: $e'};
    }
  }
}