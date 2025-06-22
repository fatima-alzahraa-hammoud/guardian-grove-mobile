import 'package:flutter/foundation.dart';
import '../../injection_container.dart' as di;
import '../core/network/api_client.dart';
import '../core/constants/app_constants.dart';
import '../data/datasources/remote/leaderboard_remote_backend.dart';

/// Debug utility to test leaderboard backend connection and diagnose issues
class LeaderboardDebugger {
  /// Main debug method to run all tests and show results
  static Future<void> diagnoseLeaderboardIssue() async {
    if (!kDebugMode) {
      debugPrint('⚠️ Debug mode only - skipping leaderboard diagnosis');
      return;
    }

    debugPrint('🔍 DIAGNOSING LEADERBOARD ISSUE');
    debugPrint('=' * 60);

    // Step 1: Check backend configuration
    await _checkBackendConfiguration();

    // Step 2: Test network connectivity
    await _testNetworkConnectivity();

    // Step 3: Test each leaderboard endpoint
    await _testLeaderboardEndpoints();

    // Step 4: Test data source directly
    await _testDataSourceIntegration();

    // Step 5: Provide recommendations
    _provideDiagnosisAndRecommendations();

    debugPrint('=' * 60);
    debugPrint('🔍 LEADERBOARD DIAGNOSIS COMPLETE');
  }

  static Future<void> _checkBackendConfiguration() async {
    debugPrint('\n📋 STEP 1: Backend Configuration');
    debugPrint('-' * 40);

    debugPrint('🌐 Base URL: ${AppConstants.baseUrl}');
    debugPrint('🎯 Leaderboard endpoint: ${AppConstants.leaderboardEndpoint}');
    debugPrint(
      '🏠 Family leaderboard: ${AppConstants.familyLeaderboardEndpoint}',
    );
    debugPrint('👥 Families endpoint: ${AppConstants.familiesEndpoint}');
    debugPrint(
      '📊 Current family rank: ${AppConstants.currentFamilyRankEndpoint}',
    );

    // Check if URLs look correct
    if (AppConstants.baseUrl.contains('localhost')) {
      debugPrint(
        '⚠️ WARNING: Using localhost - this won\'t work on real devices',
      );
    }
    if (AppConstants.baseUrl.contains('10.0.2.2')) {
      debugPrint('✅ Using emulator URL (10.0.2.2) - good for Android emulator');
    }
    if (AppConstants.baseUrl.contains('192.168')) {
      debugPrint('✅ Using local network IP - good for real devices');
    }
  }

  static Future<void> _testNetworkConnectivity() async {
    debugPrint('\n🌐 STEP 2: Network Connectivity');
    debugPrint('-' * 40);

    try {
      final apiClient = di.sl<ApiClient>();

      // Test basic connectivity to base URL
      debugPrint('🔄 Testing basic connectivity...');

      final response = await apiClient.get('/');
      debugPrint('✅ Base URL reachable - Status: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Base URL unreachable: $e');

      if (e.toString().contains('Connection refused')) {
        debugPrint('💡 Server is not running or wrong port');
      } else if (e.toString().contains('Network is unreachable')) {
        debugPrint('💡 Check your network connection and firewall');
      } else if (e.toString().contains('timeout')) {
        debugPrint('💡 Server is too slow or endpoint doesn\'t exist');
      }
    }
  }

  static Future<void> _testLeaderboardEndpoints() async {
    debugPrint('\n🎯 STEP 3: Leaderboard Endpoints');
    debugPrint('-' * 40);

    final apiClient = di.sl<ApiClient>();
    final endpoints = [
      {'name': 'Main Leaderboard', 'path': AppConstants.leaderboardEndpoint},
      {
        'name': 'Family Leaderboard',
        'path': AppConstants.familyLeaderboardEndpoint,
      },
      {'name': 'Families List', 'path': AppConstants.familiesEndpoint},
      {
        'name': 'Current Family Rank',
        'path': AppConstants.currentFamilyRankEndpoint,
      },
      {'name': 'Users (with families)', 'path': '/users?includeFamily=true'},
    ];

    int workingEndpoints = 0;

    for (final endpoint in endpoints) {
      try {
        debugPrint('🔄 Testing: ${endpoint['name']}');

        final response = await apiClient.get(endpoint['path']!);

        if (response.statusCode == 200) {
          debugPrint('✅ ${endpoint['name']}: SUCCESS');
          workingEndpoints++;

          // Analyze response data
          final data = response.data;
          if (data is Map<String, dynamic>) {
            debugPrint('   📋 Response keys: ${data.keys.toList()}');

            if (data.containsKey('data') && data['data'] is List) {
              final list = data['data'] as List;
              debugPrint('   📊 Records count: ${list.length}');

              if (list.isNotEmpty && list.first is Map) {
                final firstItem = list.first as Map<String, dynamic>;
                debugPrint('   🔑 First item keys: ${firstItem.keys.toList()}');
              }
            }
          } else if (data is List) {
            debugPrint('   📊 Direct array with ${data.length} items');
          }
        } else {
          debugPrint('⚠️ ${endpoint['name']}: HTTP ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ ${endpoint['name']}: FAILED - $e');
      }
    }

    debugPrint(
      '\n📊 Summary: $workingEndpoints/${endpoints.length} endpoints working',
    );

    if (workingEndpoints == 0) {
      debugPrint('🚨 CRITICAL: No leaderboard endpoints are working!');
      debugPrint(
        '💡 This is why you only see fallback data (your family only)',
      );
    } else if (workingEndpoints < endpoints.length) {
      debugPrint(
        '⚠️ Some endpoints are not working - using fallback for missing data',
      );
    } else {
      debugPrint('🎉 All endpoints working - should show multiple families!');
    }
  }

  static Future<void> _testDataSourceIntegration() async {
    debugPrint('\n🔗 STEP 4: Data Source Integration');
    debugPrint('-' * 40);

    try {
      // Get the actual data source and test it
      final leaderboardDataSource = di.sl<LeaderboardRemoteDataSource>();

      debugPrint('🔄 Testing data source getLeaderboard method...');

      // This will call the actual method used by the UI
      final families = await leaderboardDataSource.getLeaderboard(limit: 20);

      debugPrint('📊 Data source returned ${families.length} families');

      if (families.isEmpty) {
        debugPrint(
          '❌ No families returned - this explains the empty leaderboard',
        );
      } else if (families.length == 1) {
        final family = families.first;
        debugPrint('⚠️ Only 1 family returned: ${family.familyName}');
        if (family.familyName == 'Your Family') {
          debugPrint('💡 This is fallback data - backend connection failed');
        }
      } else {
        debugPrint('✅ Multiple families returned - should show in UI');
        for (int i = 0; i < families.length && i < 5; i++) {
          final family = families[i];
          debugPrint(
            '   ${i + 1}. ${family.familyName} - ${family.stars} stars, ${family.coins} coins',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Data source test failed: $e');
    }
  }

  static void _provideDiagnosisAndRecommendations() {
    debugPrint('\n💡 DIAGNOSIS AND RECOMMENDATIONS');
    debugPrint('-' * 40);

    debugPrint('If you only see one family (Your Family):');
    debugPrint('1. 🔍 Check if your backend server is running');
    debugPrint('2. 🌐 Verify the base URL in app_constants.dart');
    debugPrint('3. 🔗 Test endpoints manually in browser/Postman');
    debugPrint('4. 🔥 Check server logs for errors');
    debugPrint('5. 📱 Ensure device can reach the server');

    debugPrint('\nFor Android Emulator:');
    debugPrint('• Use http://10.0.2.2:PORT instead of localhost');

    debugPrint('\nFor Real Device:');
    debugPrint(
      '• Use your computer\'s IP address (e.g., http://192.168.1.100:PORT)',
    );
    debugPrint(
      '• Run "ipconfig" (Windows) or "ifconfig" (Mac/Linux) to find IP',
    );

    debugPrint('\nIf endpoints return 404:');
    debugPrint('• Check if your backend has these specific routes');
    debugPrint('• Verify API endpoints match your backend implementation');

    debugPrint('\nIf you see multiple families:');
    debugPrint('🎉 Backend is working! Data should appear in the leaderboard');
  }

  /// Quick test that you can call from anywhere
  static Future<String> quickDiagnosis() async {
    try {
      final apiClient = di.sl<ApiClient>();
      final response = await apiClient.get(AppConstants.leaderboardEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('data') && data['data'] is List) {
          final families = data['data'] as List;
          return '✅ Backend working: ${families.length} families found';
        } else if (data is List) {
          return '✅ Backend working: ${data.length} families found';
        } else {
          return '⚠️ Backend responds but data format unexpected';
        }
      } else {
        return '❌ Backend error: HTTP ${response.statusCode}';
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        return '❌ Server not running or wrong URL';
      } else if (e.toString().contains('404')) {
        return '❌ Leaderboard endpoint not found';
      } else {
        return '❌ Network error: ${e.toString().split('\n').first}';
      }
    }
  }
}

/// Usage:
/// 
/// // Full diagnosis
/// await LeaderboardDebugger.diagnoseLeaderboardIssue();
/// 
/// // Quick check
/// String result = await LeaderboardDebugger.quickDiagnosis();
/// print(result);
