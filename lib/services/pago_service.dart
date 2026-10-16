import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/pago_model.dart';

class PagoService {
  final _client = apiClient;

  Future<Map<String, dynamic>> registrarPago({
    required int contratoId,
    required double monto,
    required String fechaPago,
    required String metodoPago,
    String? descripcion,
  }) async {
    try {
      print('💰 Registrando pago...');
      print('   Contrato ID: $contratoId');
      print('   Monto: $monto');
      print('   Fecha: $fechaPago');
      print('   Método: $metodoPago');

      final response = await _client.dio.post(
        '/pagos/',
        data: {
          'contrato_id': contratoId,
          'monto': monto,
          'fecha_pago': fechaPago,
          'metodo_pago': metodoPago,
          'descripcion': descripcion,
        },
      );

      print('✅ Pago registrado: ${response.data}');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print('❌ Error: ${e.response?.data}');
      return {'success': false, 'error': e.response?.data['detail'] ?? 'Error al registrar pago'};
    }
  }

  Future<List<Pago>> obtenerMisPagos() async {
    try {
      print('📥 Obteniendo mis pagos...');
      final response = await _client.dio.get('/pagos/mis-pagos');
      final List<dynamic> data = response.data;
      return data.map((json) => Pago.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error al cargar pagos');
    }
  }

  Future<List<Pago>> obtenerPagosPropietario() async {
    try {
      final response = await _client.dio.get('/pagos/propietario');
      final List<dynamic> data = response.data;
      return data.map((json) => Pago.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error al cargar pagos');
    }
  }
}