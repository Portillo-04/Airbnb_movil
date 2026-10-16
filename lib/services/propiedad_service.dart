import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/propiedad_model.dart';

class PropiedadService {
  final _client = apiClient;

  // ==========================================
  // 1. CREAR PROPIEDAD
  // ==========================================
  Future<Map<String, dynamic>> crearPropiedad({
    required String direccion,
    required String descripcion,
    required double precioMensual,
    required String estado,
    String? imagenUrl,
  }) async {
    try {
      print('🏠 Creando propiedad...');

      final response = await _client.dio.post(
        '/propiedades/',
        data: {
          'direccion': direccion,
          'descripcion': descripcion,
          'precio_mensual': precioMensual,
          'estado': estado,
          'imagen_url': imagenUrl,
        },
      );

      print('✅ Propiedad creada: ${response.data}');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print('❌ Error al crear propiedad: ${e.response?.data}');
      return {
        'success': false,
        'error': e.response?.data['detail'] ?? 'Error al crear propiedad'
      };
    }
  }

  // ==========================================
  // 2. SUBIR IMAGEN
  // ==========================================
  Future<Map<String, dynamic>> subirImagen(File imagen) async {
    try {
      print('📸 Subiendo imagen...');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagen.path,
          filename: imagen.path.split('/').last,
        ),
      });

      final response = await _client.dio.post(
        '/propiedades/upload-imagen',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      print('✅ Imagen subida: ${response.data}');
      return {'success': true, 'imagen_url': response.data['imagen_url']};
    } on DioException catch (e) {
      print('❌ Error al subir imagen: ${e.response?.data}');
      return {
        'success': false,
        'error': e.response?.data['detail'] ?? 'Error al subir imagen'
      };
    }
  }

  // ==========================================
  // 3. OBTENER MIS PROPIEDADES (PROPIETARIO)
  // ==========================================
  Future<List<Propiedad>> obtenerMisPropiedades() async {
    try {
      print('🏠 Obteniendo mis propiedades...');
      final response = await _client.dio.get('/propiedades/mis-propiedades');
      final List<dynamic> data = response.data;
      return data.map((json) => Propiedad.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Error: ${e.response?.data}');
      throw Exception(
          e.response?.data['detail'] ?? 'Error al cargar propiedades');
    }
  }

  // ==========================================
  // 4. OBTENER PROPIEDADES DISPONIBLES
  // ==========================================
  Future<List<Propiedad>> obtenerDisponibles() async {
    try {
      print('🔍 Obteniendo propiedades disponibles...');
      final response = await _client.dio.get('/propiedades/disponibles');
      final List<dynamic> data = response.data;
      return data.map((json) => Propiedad.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Error: ${e.response?.data}');
      throw Exception(
          e.response?.data['detail'] ?? 'Error al cargar propiedades');
    }
  }

  // ==========================================
  // 5. OBTENER PROPIEDAD POR ID
  // ==========================================
  Future<Propiedad> obtenerPorId(int id) async {
    try {
      print('🔍 Obteniendo propiedad #$id...');
      final response = await _client.dio.get('/propiedades/$id');
      return Propiedad.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error: ${e.response?.data}');
      throw Exception(
          e.response?.data['detail'] ?? 'Error al cargar propiedad');
    }
  }

  // ==========================================
  // 6. ACTUALIZAR PROPIEDAD
  // ==========================================
  Future<Map<String, dynamic>> actualizarPropiedad({
    required int id,
    String? direccion,
    String? descripcion,
    double? precioMensual,
    String? estado,
    String? imagenUrl,
  }) async {
    try {
      print('🔄 Actualizando propiedad #$id...');

      final data = <String, dynamic>{};
      if (direccion != null) data['direccion'] = direccion;
      if (descripcion != null) data['descripcion'] = descripcion;
      if (precioMensual != null) data['precio_mensual'] = precioMensual;
      if (estado != null) data['estado'] = estado;
      if (imagenUrl != null) data['imagen_url'] = imagenUrl;

      final response = await _client.dio.put(
        '/propiedades/$id',
        data: data,
      );

      print('✅ Propiedad actualizada: ${response.data}');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print('❌ Error: ${e.response?.data}');
      return {
        'success': false,
        'error': e.response?.data['detail'] ?? 'Error al actualizar propiedad'
      };
    }
  }

  // ==========================================
  // 7. ELIMINAR PROPIEDAD
  // ==========================================
  Future<Map<String, dynamic>> eliminarPropiedad(int id) async {
    try {
      print('🗑️ Eliminando propiedad #$id...');

      await _client.dio.delete('/propiedades/$id');

      print('✅ Propiedad eliminada');
      return {'success': true};
    } on DioException catch (e) {
      print('❌ Error: ${e.response?.data}');
      return {
        'success': false,
        'error': e.response?.data['detail'] ?? 'Error al eliminar propiedad'
      };
    }
  }

  // ==========================================
  // 8. OBTENER PROPIEDADES ALQUILADAS (INQUILINO)
  // ==========================================
  Future<List<Propiedad>> obtenerPropiedadesAlquiladas() async {
    try {
      print('🏠 Obteniendo propiedades alquiladas por el inquilino...');
      final response =
          await _client.dio.get('/propiedades/mis-propiedades-alquiladas');
      final List<dynamic> data = response.data;
      print('✅ Propiedades alquiladas encontradas: ${data.length}');
      return data.map((json) => Propiedad.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ Error: ${e.response?.data}');
      throw Exception(
          e.response?.data['detail'] ?? 'Error al cargar propiedades alquiladas');
    }
  }
}