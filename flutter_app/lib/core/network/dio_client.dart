import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'api_interceptors.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  Dio? _dio; // Made nullable to check initialization
  bool _isInitialized = false;

  Dio get dio {
    if (_dio == null || !_isInitialized) {
      init(); // Auto-initialize if not done
    }
    return _dio!;
  }

  void init() {
    if (_isInitialized && _dio != null) {
      debugPrint('✅ DioClient already initialized');
      return; // Already initialized
    }

    try {
      _dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add interceptors
      _dio!.interceptors.addAll([
        AuthInterceptor(),
        LoggingInterceptor(),
        ErrorInterceptor(),
      ]);

      _isInitialized = true;
      debugPrint('✅ DioClient initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize DioClient: $e');
      rethrow;
    }
  }

  // Generic request methods with auto-initialization
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get<T>(  // Uses the getter which auto-initializes
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post<T>(  // Uses the getter which auto-initializes
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.put<T>(  // Uses the getter which auto-initializes
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete<T>(  // Uses the getter which auto-initializes
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Test connection method
  Future<bool> testConnection() async {
    try {
      debugPrint('🔍 Testing connection to: ${AppConstants.baseUrl}');
      final response = await dio.get('/health', 
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      debugPrint('✅ Connection test successful: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Connection test failed: $e');
      return false;
    }
  }

  // Reset method for debugging
  void reset() {
    _dio = null;
    _isInitialized = false;
    debugPrint('🔄 DioClient reset');
  }
}