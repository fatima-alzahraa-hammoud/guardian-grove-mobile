import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Utility class to test API connectivity and endpoints
class ApiTest {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Test basic API connectivity
  static Future<void> testConnectivity() async {
    debugPrint('🔍 Testing API connectivity to: ${AppConstants.baseUrl}');

    try {
      final response = await _dio.get('/');
      debugPrint('✅ API is reachable! Status: ${response.statusCode}');
      debugPrint('📊 Response: ${response.data}');
    } on DioException catch (e) {
      debugPrint('❌ API Connection Error: ${e.message}');
      debugPrint('   - Type: ${e.type}');
      debugPrint(
        '   - Response: ${e.response?.statusCode} - ${e.response?.data}',
      );
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
    }
  }

  /// Test specific endpoints
  static Future<void> testEndpoints() async {
    final endpoints = [
      '/families/leaderboard',
      '/families',
      '/users',
      '/auth/login',
      '/home/dashboard',
    ];

    for (final endpoint in endpoints) {
      debugPrint('🔍 Testing endpoint: $endpoint');
      try {
        final response = await _dio.get(endpoint);
        debugPrint('✅ $endpoint - Status: ${response.statusCode}');
        if (response.data != null) {
          debugPrint('📊 Data type: ${response.data.runtimeType}');
          if (response.data is Map) {
            debugPrint('📊 Keys: ${(response.data as Map).keys}');
          } else if (response.data is List) {
            debugPrint('📊 Array length: ${(response.data as List).length}');
          }
        }
      } on DioException catch (e) {
        debugPrint(
          '❌ $endpoint - Error: ${e.response?.statusCode} - ${e.message}',
        );
        if (e.response?.data != null) {
          debugPrint('   Response: ${e.response?.data}');
        }
      } catch (e) {
        debugPrint('❌ $endpoint - Unexpected error: $e');
      }
    }
  }

  /// Test with authentication (if needed)
  static Future<void> testWithAuth(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    debugPrint('🔐 Testing with authentication token');
    await testEndpoints();
  }
}
