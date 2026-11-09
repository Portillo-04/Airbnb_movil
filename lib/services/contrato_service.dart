import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/contrato_model.dart';

class ContratoService {
  final _client = apiClient;

  // Subir PDF de contrato
  Future<Map<String, dynamic>> subirPdfContrato(File pdf) async {
    try {
      print('📄 Subiendo PDF de contrato...');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdf.path,
          filename: pdf.path.split('/').last,
        ),
      });

      final response = await _client.dio.post(
        '/contratos/upload-pdf',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      print('✅ PDF subido: ${response.data}');
      return {'success': true, 'pdf_url': response.data['pdf_url']};
    } on DioException catch (e) {
      print(' Error al subir PDF: ${e.response?.data}');
      return {'success': false, 'error': e.response?.data['detail'] ?? 'Error al subir PDF'};
    }
  }

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

  // Actualizar contrato (agregar PDF o cambiar estado)
  Future<Map<String, dynamic>> actualizarContrato({
    required int id,
    String? estado,
    String? pdfUrl,
  }) async {
    try {
      print(' Actualizando contrato #$id...');

      final data = <String, dynamic>{};
      if (estado != null) data['estado'] = estado;
      if (pdfUrl != null) data['pdf_url'] = pdfUrl;

      final response = await _client.dio.patch(
        '/contratos/$id',
        data: data,
      );

      print('✅ Contrato actualizado: ${response.data}');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print('❌ Error: ${e.response?.data}');
      return {'success': false, 'error': e.response?.data['detail'] ?? 'Error al actualizar contrato'};
    }
  }

  // ✅ NUEVO: Crear contrato con PDF (para el propietario)
  Future<Map<String, dynamic>> crearContratoConPdf({
    required int propiedadId,
    required int inquilinoId,
    required String fechaInicio,
    required String fechaFin,
    required double precioMensual,
    required String pdfUrl,
  }) async {
    try {
      print('📝 Creando contrato con PDF...');

      final response = await _client.dio.post(
        '/contratos',
        data: {
          'propiedad_id': propiedadId,
          'inquilino_id': inquilinoId,
          'fecha_inicio': fechaInicio,
          'fecha_fin': fechaFin,
          'precio_mensual': precioMensual,
          'estado': 'activo',
          'pdf_url': pdfUrl,
        },
      );

      print('✅ Contrato creado: ${response.data}');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print(' Error: ${e.response?.data}');
      return {'success': false, 'error': e.response?.data['detail'] ?? 'Error al crear contrato'};
    }
  }
}