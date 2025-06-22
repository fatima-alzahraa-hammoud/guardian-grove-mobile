import 'package:flutter/foundation.dart';
import '../../injection_container.dart' as di;
import '../core/utils/leaderboard_backend_tester.dart';
import '../core/network/api_client.dart';

/// Example of how to test the leaderboard backend connection
/// This can be called from anywhere in the app during development
class LeaderboardTester {
  /// Quick test to verify leaderboard backend connection
  static Future<void> quickTest() async {
    if (!kDebugMode) return; // Only run in debug mode

    debugPrint('🚀 Starting Leaderboard Backend Quick Test');

    try {
      // Get the API client from dependency injection
      final apiClient = di.sl<ApiClient>();

      // Create the tester
      final tester = LeaderboardBackendTester(apiClient);

      // Run comprehensive test
      await tester.testLeaderboardConnection();
      await tester.testLeaderboardDataFlow();
      final results = await tester.testLeaderboardScreenIntegration();

      // Print summary
      debugPrint('\n🎯 LEADERBOARD BACKEND TEST SUMMARY:');
      debugPrint('=' * 50);
      debugPrint(
        '🔗 Backend Connection: ${results['backendConnection'] ? "✅ SUCCESS" : "❌ FAILED"}',
      );
      debugPrint(
        '📥 Data Retrieval: ${results['dataRetrieval'] ? "✅ SUCCESS" : "❌ FAILED"}',
      );
      debugPrint(
        '👥 Current User Family: ${results['currentUserFamily'] ? "✅ FOUND" : "❌ MISSING"}',
      );
      debugPrint(
        '🔄 Fallback System: ${results['fallbackWorking'] ? "✅ WORKING" : "❌ BROKEN"}',
      );

      final workingEndpoints =
          results['endpoints'].values.where((working) => working).length;
      final totalEndpoints = results['endpoints'].length;
      debugPrint('📊 Working Endpoints: $workingEndpoints/$totalEndpoints');

      if (workingEndpoints > 0) {
        debugPrint('\n🎉 SUCCESS: Leaderboard screen is connected to backend!');
        debugPrint(
          '💡 The app will fetch real leaderboard data from your server.',
        );
      } else {
        debugPrint('\n⚠️ WARNING: No backend endpoints working');
        debugPrint('💡 The app will use fallback data (current user only).');
        debugPrint('🔧 Check your backend server and API endpoints.');
      }

      debugPrint('=' * 50);
    } catch (e) {
      debugPrint('❌ CRITICAL ERROR: Failed to test leaderboard backend');
      debugPrint('🔥 Error: $e');
      debugPrint('💡 Make sure your backend server is running and accessible.');
    }
  }

  /// Test specific endpoint
  static Future<bool> testEndpoint(String endpoint) async {
    if (!kDebugMode) return false;

    try {
      final apiClient = di.sl<ApiClient>();
      final response = await apiClient.get(endpoint);

      final success = response.statusCode == 200;
      debugPrint(
        '🔍 Testing $endpoint: ${success ? "✅ SUCCESS" : "❌ FAILED (${response.statusCode})"}',
      );

      return success;
    } catch (e) {
      debugPrint('🔍 Testing $endpoint: ❌ FAILED ($e)');
      return false;
    }
  }

  /// Get backend status summary
  static Future<Map<String, dynamic>> getBackendStatus() async {
    try {
      final apiClient = di.sl<ApiClient>();
      final tester = LeaderboardBackendTester(apiClient);
      return await tester.testLeaderboardScreenIntegration();
    } catch (e) {
      return {
        'backendConnection': false,
        'dataRetrieval': false,
        'currentUserFamily': false,
        'fallbackWorking': true,
        'endpoints': <String, bool>{},
        'error': e.toString(),
      };
    }
  }
}

/// Usage examples:
/// 
/// 1. Quick test from anywhere:
///    await LeaderboardTester.quickTest();
/// 
/// 2. Test specific endpoint:
///    bool success = await LeaderboardTester.testEndpoint('/families/leaderboard');
/// 
/// 3. Get status for UI:
///    Map<String, dynamic> status = await LeaderboardTester.getBackendStatus();
///    print('Backend working: ${status['backendConnection']}');
