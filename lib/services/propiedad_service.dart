import 'dart:io';
import 'dart:convert'; // ✅ OBLIGATORIO para jsonEncode
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/propiedad_model.dart';

class PropiedadService {
  final _client = apiClient;

  // ==========================================
  // 1. CREAR PROPIEDAD (POST /)
  // ==========================================
  Future<Map<String, dynamic>> crearPropiedad({
    required String direccion,
    required String descripcion,
    required double precioMensual,
    required String estado,
    required int propietarioId,
    required String departamento, // ✅ NUEVO CAMPO OBLIGATORIO
    required String distrito, // ✅ NUEVO CAMPO OBLIGATORIO
    File? file,
  }) async {
    try {
      print('🏠 Creando propiedad para usuario #$propietarioId...');

      final datosObj = {
        'direccion': direccion,
        'descripcion': descripcion,
        'precio_mensual': precioMensual,
        'estado': estado.toUpperCase(),
        'propietario_id': propietarioId,
        'departamento': departamento, // ✅ INCLUIDO EN EL JSON
        'distrito': distrito, // ✅ INCLUIDO EN EL JSON
      };

      // ✅ Enviamos 'datos' como STRING JSON dentro del FormData
      final formData = FormData.fromMap({
        'datos': jsonEncode(datosObj),
        if (file != null)
          'file': await MultipartFile.fromFile(
            file.path,
            filename: 'propiedad_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
      });

      final response = await _client.dio.post('/propiedades/', data: formData);

      print('✅ Propiedad creada. ID: ${response.data['id']}');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print('❌ Error al crear: ${e.response?.data}');
      return {
        'success': false,
        'error': e.response?.data['detail'] ?? 'Error al crear propiedad',
      };
    }
  }

  // ==========================================
  // 2. ACTUALIZAR PROPIEDAD (PUT /{id})
  // ==========================================
  Future<Map<String, dynamic>> actualizarPropiedad({
    required int id,
    String? direccion,
    String? descripcion,
    double? precioMensual,
    String? estado,
    String? fotosUrl,
    String? departamento, // ✅ NUEVO CAMPO OPCIONAL
    String? distrito, // ✅ NUEVO CAMPO OPCIONAL
    File? file,
  }) async {
    try {
      print('🔄 Actualizando propiedad #$id...');

      final datosObj = <String, dynamic>{};
      if (direccion != null) datosObj['direccion'] = direccion;
      if (descripcion != null) datosObj['descripcion'] = descripcion;
      if (precioMensual != null) datosObj['precio_mensual'] = precioMensual;
      if (estado != null) datosObj['estado'] = estado.toUpperCase();
      if (fotosUrl != null) datosObj['imagen_url'] = fotosUrl;
      if (departamento != null)
        datosObj['departamento'] = departamento; // ✅ INCLUIDO SI SE ENVÍA
      if (distrito != null)
        datosObj['distrito'] = distrito; // ✅ INCLUIDO SI SE ENVÍA

      // ✅ También usa FormData + jsonEncode para el PUT
      final formData = FormData.fromMap({
        'datos': jsonEncode(datosObj),
        if (file != null)
          'file': await MultipartFile.fromFile(
            file.path,
            filename: 'propiedad_$id.jpg',
          ),
      });

      final response = await _client.dio.put(
        '/propiedades/$id',
        data: formData,
      );

      print('✅ Propiedad actualizada');
      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      print('❌ Error al actualizar: ${e.response?.data}');
      return {
        'success': false,
        'error': e.response?.data['detail'] ?? 'Error al actualizar',
      };
    }
  }

  // ==========================================
  // 3. SUBIR IMAGEN (Alias para actualizar solo imagen)
  // ==========================================
  Future<Map<String, dynamic>> subirImagen({
    required int propiedadId,
    required File imagen,
  }) async {
    return await actualizarPropiedad(id: propiedadId, file: imagen);
  }

  // ==========================================
  // 4. OBTENER MIS PROPIEDADES
  // ==========================================
  Future<List<Propiedad>> obtenerMisPropiedades() async {
    try {
      final res = await _client.dio.get('/propiedades/mis-propiedades');
      return (res.data as List).map((e) => Propiedad.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error al cargar propiedades');
    }
  }

  // ==========================================
  // 5. OBTENER DISPONIBLES
  // ==========================================
  Future<List<Propiedad>> obtenerDisponibles() async {
    try {
      final res = await _client.dio.get(
        '/propiedades/disponibles',
        options: Options(extra: {'public': true}),
      );
      return (res.data as List).map((e) => Propiedad.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error al cargar disponibles');
    }
  }

  // ==========================================
  // 6. OBTENER POR ID
  // ==========================================
  Future<Propiedad> obtenerPorId(int id) async {
    try {
      final res = await _client.dio.get('/propiedades/$id');
      return Propiedad.fromJson(res.data);
    } catch (e) {
      throw Exception('Error al cargar propiedad');
    }
  }

  // ==========================================
  // 7. ELIMINAR PROPIEDAD
  // ==========================================
  Future<Map<String, dynamic>> eliminarPropiedad(int id) async {
    try {
      await _client.dio.delete('/propiedades/$id');
      return {'success': true};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['detail']};
    }
  }

  // ==========================================
  // 8. OBTENER ALQUILADAS
  // ==========================================
  Future<List<Propiedad>> obtenerPropiedadesAlquiladas() async {
    try {
      final res = await _client.dio.get(
        '/propiedades/mis-propiedades-alquiladas',
      );
      return (res.data as List).map((e) => Propiedad.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error al cargar alquiladas');
    }
  }
}
