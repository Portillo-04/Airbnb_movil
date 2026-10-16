import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ApiClient() : dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl)) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          storage.delete(key: AppConstants.tokenKey);
          // Aquí podrías disparar un evento para cerrar sesión globalmente
        }
        return handler.next(e);
      },
    ));
  }
}

final apiClient = ApiClient();