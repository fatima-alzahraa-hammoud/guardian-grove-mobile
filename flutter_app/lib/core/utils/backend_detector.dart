import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Utility to detect and test backend connectivity across different configurations
class BackendDetector {
  static final List<String> _commonBaseUrls = [
    'http://10.0.2.2:8000', // Android emulator to localhost:8000
    'http://localhost:8000', // Direct localhost:8000
    'http://10.0.2.2:3000', // Android emulator to localhost:3000
    'http://localhost:3000', // Direct localhost:3000
    'http://127.0.0.1:8000', // Loopback:8000
    'http://127.0.0.1:3000', // Loopback:3000
  ];

  static final List<String> _testEndpoints = [
    '/',
    '/api',
    '/health',
    '/status',
    '/families',
    '/family',
    '/leaderboard',
    '/family/leaderboard',
    '/chats',
    '/ai',
    '/auth',
  ];

  /// Detect which backend configuration is actually responding
  static Future<Map<String, dynamic>> detectBackend() async {
    debugPrint('🔍 Detecting available backend configurations...');
    debugPrint('=' * 60);

    final results = <String, dynamic>{};

    for (final baseUrl in _commonBaseUrls) {
      debugPrint('📡 Testing: $baseUrl');
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );

      for (final endpoint in _testEndpoints) {
        try {
          final response = await dio.get(endpoint);
          final key = '$baseUrl$endpoint';
          results[key] = {
            'status': response.statusCode,
            'data': response.data,
            'baseUrl': baseUrl,
            'endpoint': endpoint,
          };
          debugPrint('✅ $baseUrl$endpoint - ${response.statusCode}');
        } on DioException catch (e) {
          if (e.response?.statusCode != null) {
            final key = '$baseUrl$endpoint';
            results[key] = {
              'status': e.response!.statusCode,
              'error': e.response?.data,
              'baseUrl': baseUrl,
              'endpoint': endpoint,
            };
            debugPrint('⚠️  $baseUrl$endpoint - ${e.response!.statusCode}');
          }
          // Don't log connection errors to reduce noise
        } catch (e) {
          // Ignore other errors
        }
      }
      debugPrint('');
    }

    debugPrint('=' * 60);
    debugPrint('🔍 Backend Detection Complete');

    // Analyze results
    final workingBaseUrls = <String>{};
    final availableEndpoints = <String, List<String>>{};

    for (final entry in results.entries) {
      final result = entry.value as Map<String, dynamic>;
      final baseUrl = result['baseUrl'] as String;
      final endpoint = result['endpoint'] as String;
      final status = result['status'] as int;

      if (status >= 200 && status < 400) {
        workingBaseUrls.add(baseUrl);
        availableEndpoints.putIfAbsent(baseUrl, () => []).add(endpoint);
      }
    }

    debugPrint('📊 Summary:');
    debugPrint('   Working base URLs: ${workingBaseUrls.length}');
    for (final url in workingBaseUrls) {
      debugPrint(
        '   ✅ $url (${availableEndpoints[url]?.length ?? 0} endpoints)',
      );
    }

    return {
      'workingBaseUrls': workingBaseUrls.toList(),
      'availableEndpoints': availableEndpoints,
      'detailedResults': results,
      'recommendedBaseUrl': _getRecommendedBaseUrl(
        workingBaseUrls,
        availableEndpoints,
      ),
    };
  }

  static String? _getRecommendedBaseUrl(
    Set<String> workingUrls,
    Map<String, List<String>> endpoints,
  ) {
    if (workingUrls.isEmpty) return null;

    // Prefer URLs with more endpoints
    return workingUrls.reduce((a, b) {
      final aCount = endpoints[a]?.length ?? 0;
      final bCount = endpoints[b]?.length ?? 0;
      return bCount > aCount ? b : a;
    });
  }

  /// Test specific chat endpoints
  static Future<void> testChatEndpoints(String baseUrl) async {
    debugPrint('💬 Testing Chat Endpoints at: $baseUrl');
    debugPrint('=' * 50);

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    final chatEndpoints = [
      '/chats',
      '/chats/getChats',
      '/chats/createChat',
      '/chats/sendMessage',
      '/ai',
      '/ai/chat',
      '/api/chats',
      '/api/ai',
    ];

    for (final endpoint in chatEndpoints) {
      try {
        final response = await dio.get(endpoint);
        debugPrint('✅ $endpoint - ${response.statusCode}');
        if (response.data != null) {
          debugPrint('   📊 Response type: ${response.data.runtimeType}');
        }
      } on DioException catch (e) {
        if (e.response?.statusCode != null) {
          debugPrint('⚠️  $endpoint - ${e.response!.statusCode}');
          if (e.response?.data != null) {
            debugPrint('   📄 Error: ${e.response!.data}');
          }
        } else {
          debugPrint('❌ $endpoint - Connection failed');
        }
      }
    }

    debugPrint('=' * 50);
  }
}
