import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/contrato_model.dart';

class ContratoService {
  final _client = apiClient;

  // Para inquilino: obtener sus contratos
  Future<List<Contrato>> obtenerContratosInquilino() async {
    try {
      print('📥 Obteniendo contratos del inquilino...');
      final response = await _client.dio.get('/contratos/mis-contratos');
      final List<dynamic> data = response.data;
      print('✅ Contratos obtenidos: ${data.length}');
      return data.map((json) => Contrato.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Error al obtener contratos: ${e.response?.data}');
      throw Exception(e.response?.data['detail'] ?? 'Error al cargar contratos');
    }
  }

  // Para propietario: obtener todos los contratos
  Future<List<Contrato>> obtenerTodosContratos() async {
    try {
      final response = await _client.dio.get('/contratos');
      final List<dynamic> data = response.data;
      return data.map((json) => Contrato.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Error al cargar contratos');
    }
  }

  // Crear contrato (uso interno)
  Future<Map<String, dynamic>> crearContrato({
    required int propiedadId,
    required int inquilinoId,
    required String fechaInicio,
    required String fechaFin,
    required double precioMensual,
  }) async {
    try {
      final response = await _client.dio.post(
        '/contratos',
        data: {
          'propiedad_id': propiedadId,
          'inquilino_id': inquilinoId,
          'fecha_inicio': fechaInicio,
          'fecha_fin': fechaFin,
          'precio_mensual': precioMensual,
          'estado': 'activo',
        },
      );
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['detail'] ?? 'Error al crear contrato'};
    }
  }
}