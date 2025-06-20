import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';

/// Test utility to verify backend connectivity and data structure
class BackendApiTester {
  final ApiClient apiClient;

  BackendApiTester(this.apiClient);

  /// Test all the home-related endpoints
  Future<void> testHomeEndpoints() async {
    debugPrint('🧪 Testing Backend Home Endpoints');
    debugPrint('=' * 50);

    await _testEndpoint('GET /users/user', () async {
      return await apiClient.dio.get('/users/user');
    });

    await _testEndpoint('POST /family/getFamily', () async {
      return await apiClient.dio.post('/family/getFamily');
    });

    await _testEndpoint('GET /family/FamilyMembers', () async {
      return await apiClient.dio.get('/family/FamilyMembers');
    });

    await _testEndpoint('GET /family/someFamilydetails', () async {
      return await apiClient.dio.get('/family/someFamilydetails');
    });

    debugPrint('=' * 50);
    debugPrint('🧪 Backend Home Endpoints Test Complete');
  }

  /// Test all the leaderboard-related endpoints
  Future<void> testLeaderboardEndpoints() async {
    debugPrint('🧪 Testing Backend Leaderboard Endpoints');
    debugPrint('=' * 50);

    await _testEndpoint('GET /family/familyLeaderboard', () async {
      return await apiClient.dio.get('/family/familyLeaderboard');
    });

    await _testEndpoint('GET /family/leaderboard', () async {
      return await apiClient.dio.get('/family/leaderboard');
    });

    await _testEndpoint('GET /family/', () async {
      return await apiClient.dio.get('/family/');
    });

    debugPrint('=' * 50);
    debugPrint('🧪 Backend Leaderboard Endpoints Test Complete');
  }

  /// Test a specific endpoint and log results
  Future<void> _testEndpoint(
    String name,
    Future<Response> Function() request,
  ) async {
    try {
      debugPrint('🔍 Testing: $name');
      final response = await request();

      debugPrint('✅ Status: ${response.statusCode}');
      debugPrint('📊 Response type: ${response.data.runtimeType}');

      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('🔑 Keys: ${data.keys.toList()}');
        // Look for nested data
        if (data.containsKey('data')) {
          final nestedData = data['data'];
          debugPrint('📦 Nested data type: ${nestedData.runtimeType}');
          if (nestedData is Map) {
            debugPrint('🔑 Nested keys: ${nestedData.keys.toList()}');
          } else if (nestedData is List) {
            debugPrint('📦 List length: ${nestedData.length}');
            if (nestedData.isNotEmpty && nestedData.first is Map) {
              debugPrint(
                '🔑 First item keys: ${(nestedData.first as Map).keys.toList()}',
              );
            }
          }
        }
      } else if (response.data is List) {
        final data = response.data as List;
        debugPrint('📦 List length: ${data.length}');
        if (data.isNotEmpty && data.first is Map) {
          debugPrint(
            '🔑 First item keys: ${(data.first as Map).keys.toList()}',
          );
        }
      }

      debugPrint('');
    } on DioException catch (e) {
      debugPrint('❌ Error: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.data != null) {
        debugPrint('📄 Error data: ${e.response?.data}');
      }
      debugPrint('');
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      debugPrint('');
    }
  }

  /// Test user authentication status
  Future<void> testAuthStatus() async {
    debugPrint('🔐 Testing Authentication Status');
    debugPrint('=' * 30);

    await _testEndpoint('GET /users/profile', () async {
      return await apiClient.dio.get('/users/profile');
    });

    await _testEndpoint('GET /auth/me', () async {
      return await apiClient.dio.get('/auth/me');
    });

    debugPrint('=' * 30);
    debugPrint('🔐 Authentication Test Complete');
  }
}
