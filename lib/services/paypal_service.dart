import 'dart:convert';
import 'package:http/http.dart' as http;

class PayPalService {
  // ⚠️ REEMPLAZA ESTAS CREDENCIALES CON LAS TUYAS DE PAYPAL DEVELOPER
  // Obténlas gratis en: https://developer.paypal.com/dashboard/applications/sandbox
  static const String _clientId = 'BAAtYcMbPyCmHHFHmGein1yOfjoDyAQFuZkiMcounhsZfsRYntUC3rBQhzInX6hjgQy5m1VrD7UcvFvvKY';
  static const String _clientSecret = 'ECy4-XRStHTouUoJ6x-m0MmXWiqLi7us-lKwoQivRVD9bRuvSqZ9-iCv0P9yKMlQMyAq6tIUGULDqnk8';
  
  // URL de sandbox (pruebas) - Para producción usar: https://api-m.paypal.com
  static const String _baseUrl = 'https://api-m.sandbox.paypal.com';

  String? _accessToken;
  DateTime? _tokenExpiry;

  // Obtener token de acceso (con caché)
  Future<String?> _getAccessToken() async {
    // Si el token aún es válido, reutilizarlo
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    try {
      print('🔑 Obteniendo token de PayPal...');
      
      final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
      
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/oauth2/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        // El token expira en 32400 segundos (9 horas), lo guardamos con 8 horas de margen
        _tokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in'] - 3600));
        print('✅ Token obtenido exitosamente');
        return _accessToken;
      } else {
        print('❌ Error al obtener token: ${response.statusCode}');
        print('   Respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      return null;
    }
  }

  // Crear orden de pago
  Future<Map<String, dynamic>> crearOrden({
    required double monto,
    required String descripcion,
    String currencyCode = 'USD',
  }) async {
    final token = await _getAccessToken();
    if (token == null) {
      return {'success': false, 'error': 'No se pudo obtener token de PayPal'};
    }

    try {
      print('💳 Creando orden de pago...');
      print('   Monto: \$${monto.toStringAsFixed(2)} $currencyCode');
      print('   Descripción: $descripcion');

      final response = await http.post(
        Uri.parse('$_baseUrl/v2/checkout/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'intent': 'CAPTURE',
          'purchase_units': [
            {
              'description': descripcion,
              'amount': {
                'currency_code': currencyCode,
                'value': monto.toStringAsFixed(2),
              }
            }
          ],
          'application_context': {
            'brand_name': 'Airbnb Alquileres',
            'landing_page': 'NO_PREFERENCE',
            'user_action': 'PAY_NOW',
            // URLs de retorno (para pruebas, pueden ser cualquier cosa)
            'return_url': 'https://tu-app.com/return',
            'cancel_url': 'https://tu-app.com/cancel',
          }
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final orderId = data['id'];
        
        // Buscar el enlace de aprobación
        final links = data['links'] as List;
        final approvalLink = links.firstWhere(
          (link) => link['rel'] == 'approve',
          orElse: () => null,
        )?['href'];

        print('✅ Orden creada: $orderId');
        print('   URL de aprobación: $approvalLink');

        return {
          'success': true,
          'order_id': orderId,
          'approval_url': approvalLink,
        };
      } else {
        print(' Error al crear orden: ${response.statusCode}');
        print('   Respuesta: ${response.body}');
        return {'success': false, 'error': 'Error al crear orden de pago'};
      }
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Capturar el pago después de que el usuario apruebe
  Future<Map<String, dynamic>> capturarPago(String orderId) async {
    final token = await _getAccessToken();
    if (token == null) {
      return {'success': false, 'error': 'No se pudo obtener token de PayPal'};
    }

    try {
      print(' Capturando pago para orden: $orderId');

      final response = await http.post(
        Uri.parse('$_baseUrl/v2/checkout/orders/$orderId/capture'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final status = data['status'];
        
        print('✅ Pago capturado exitosamente');
        print('   Estado: $status');

        return {
          'success': true,
          'status': status,
          'transaction_id': data['purchase_units']?[0]?['payments']?['captures']?[0]?['id'],
          'data': data,
        };
      } else {
        print('❌ Error al capturar pago: ${response.statusCode}');
        print('   Respuesta: ${response.body}');
        return {'success': false, 'error': 'Error al procesar el pago'};
      }
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Verificar estado de una orden
  Future<Map<String, dynamic>> verificarOrden(String orderId) async {
    final token = await _getAccessToken();
    if (token == null) {
      return {'success': false, 'error': 'No se pudo obtener token de PayPal'};
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v2/checkout/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'data': data,
        };
      } else {
        return {'success': false, 'error': 'No se pudo verificar la orden'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}