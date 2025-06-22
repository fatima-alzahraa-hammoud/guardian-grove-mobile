import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    );

    // Add auth interceptor (we'll implement this later)
    _dio.interceptors.add(AuthInterceptor());
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Health check method to test backend connectivity
  Future<bool> testConnection() async {
    try {
      debugPrint('🔍 Testing backend connection to ${AppConstants.baseUrl}');
      final response = await _dio.get(
        '/health',
        options: Options(
          sendTimeout: const Duration(milliseconds: 5000),
          receiveTimeout: const Duration(milliseconds: 5000),
        ),
      );
      debugPrint('✅ Backend connection successful: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Backend connection failed: $e');
      // Connection test failed silently
      return false;
    }
  }

  // Test alternative URLs for connection
  Future<String?> findWorkingBaseUrl() async {
    final testUrls = [
      AppConstants.baseUrl,
      AppConstants.fallbackBaseUrl,
      AppConstants.localBaseUrl,
    ];

    for (final url in testUrls) {
      try {
        debugPrint('🔍 Testing connection to: $url');
        final tempDio = Dio(
          BaseOptions(
            baseUrl: url,
            connectTimeout: const Duration(milliseconds: 5000),
            receiveTimeout: const Duration(milliseconds: 5000),
          ),
        );

        final response = await tempDio.get('/health');
        if (response.statusCode == 200) {
          debugPrint('✅ Found working URL: $url');
          return url;
        }
      } catch (e) {
        debugPrint('❌ Failed to connect to: $url');
        continue;
      }
    }

    debugPrint('❌ No working backend URL found');
    return null;
  }
}

// Auth Interceptor to add token to requests
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add token to headers if available
    final token = StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle auth errors (401) - but don't automatically clear storage
    // The AuthBloc should handle logout logic to maintain state consistency
    if (err.response?.statusCode == 401) {
      // Just log the error, don't clear storage automatically
      debugPrint('401 Unauthorized - token may be expired');
    }
    handler.next(err);
  }
}
