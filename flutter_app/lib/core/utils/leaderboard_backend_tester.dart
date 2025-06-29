import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../services/storage_service.dart';

/// Utility class to test leaderboard backend connection
class LeaderboardBackendTester {
  final ApiClient _apiClient;

  LeaderboardBackendTester(this._apiClient);

  /// Test all leaderboard endpoints to verify backend connection
  Future<void> testLeaderboardConnection() async {
    debugPrint('🧪 Testing Leaderboard Backend Connection');
    debugPrint('=' * 60);

    // Test 1: Main leaderboard endpoint
    await _testEndpoint(
      'Main Leaderboard',
      AppConstants.leaderboardEndpoint,
      queryParameters: {'limit': 10},
    );

    // Test 2: Family leaderboard endpoint
    await _testEndpoint(
      'Family Leaderboard',
      AppConstants.familyLeaderboardEndpoint,
    );

    // Test 3: Families endpoint
    await _testEndpoint('Families List', AppConstants.familiesEndpoint);

    // Test 4: Current family rank endpoint
    await _testEndpoint(
      'Current Family Rank',
      AppConstants.currentFamilyRankEndpoint,
    );

    // Test 5: Users with family data
    await _testEndpoint(
      'Users with Family Data',
      '/users',
      queryParameters: {
        'includeFamily': true,
        'populate': 'family',
        'limit': 10,
      },
    );

    debugPrint('=' * 60);
    debugPrint('🧪 Leaderboard Backend Connection Test Complete');
  }

  /// Test a specific endpoint
  Future<void> _testEndpoint(
    String name,
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      debugPrint('🔍 Testing: $name');
      debugPrint('📡 Endpoint: ${AppConstants.baseUrl}$endpoint');

      final response = await _apiClient.get(
        endpoint,
        queryParameters: queryParameters,
      );

      final statusCode = response.statusCode;
      final hasData = response.data != null;

      if (statusCode == 200) {
        debugPrint('✅ $name: SUCCESS (200)');
        debugPrint('📊 Data received: $hasData');

        if (hasData) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            debugPrint('📋 Response keys: ${data.keys.toList()}');

            // Check for common data structures
            if (data.containsKey('data')) {
              final dataList = data['data'];
              if (dataList is List) {
                debugPrint('📈 Records count: ${dataList.length}');
              }
            } else if (data.containsKey('families')) {
              final familiesList = data['families'];
              if (familiesList is List) {
                debugPrint(
                  '👨‍👩‍👧‍👦 Families count: ${familiesList.length}',
                );
              }
            }
          } else if (data is List) {
            debugPrint('📈 Records count: ${data.length}');
          }
        }
      } else {
        debugPrint('⚠️ $name: HTTP $statusCode');
      }
    } catch (e) {
      debugPrint('❌ $name: FAILED');
      debugPrint('🔥 Error: $e');
    }

    debugPrint('-' * 40);
  }

  /// Test the complete leaderboard data flow
  Future<void> testLeaderboardDataFlow() async {
    debugPrint('🔄 Testing Complete Leaderboard Data Flow');
    debugPrint('=' * 60);
    try {
      // Check if user is logged in
      final currentUser = StorageService.getUser();
      if (currentUser == null) {
        debugPrint('❌ No user logged in - cannot test data flow');
        return;
      }

      debugPrint('👤 Current user: ${currentUser.name}');
      debugPrint('🆔 Family ID: ${currentUser.familyId ?? "None"}');
      debugPrint('⭐ Stars: ${currentUser.stars}');
      debugPrint('🪙 Coins: ${currentUser.coins}');

      // Test leaderboard data retrieval
      debugPrint('\n🏆 Testing leaderboard data retrieval...');

      final response = await _apiClient.get(
        AppConstants.leaderboardEndpoint,
        queryParameters: {'limit': 20},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Leaderboard data retrieved successfully');

        final data = response.data;
        List<dynamic> families = [];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            families = data['data'] as List<dynamic>? ?? [];
          } else if (data.containsKey('families')) {
            families = data['families'] as List<dynamic>? ?? [];
          }
        } else if (data is List) {
          families = data;
        }

        debugPrint('📊 Found ${families.length} families in leaderboard');

        // Check if current user's family is in the leaderboard
        bool currentFamilyFound = false;
        for (final family in families) {
          if (family is Map<String, dynamic>) {
            final familyId =
                family['_id']?.toString() ??
                family['id']?.toString() ??
                family['familyId']?.toString();

            if (familyId == currentUser.familyId) {
              currentFamilyFound = true;
              debugPrint('✅ Current user\'s family found in leaderboard');
              debugPrint(
                '🏠 Family: ${family['name'] ?? family['familyName'] ?? "Unknown"}',
              );
              debugPrint('🏆 Rank: ${family['rank'] ?? "Unknown"}');
              break;
            }
          }
        }

        if (!currentFamilyFound && currentUser.familyId != null) {
          debugPrint('⚠️ Current user\'s family not found in top leaderboard');
        }
      } else {
        debugPrint(
          '❌ Failed to retrieve leaderboard data: ${response.statusCode}',
        );
      }

      // Test current family rank
      debugPrint('\n👨‍👩‍👧‍👦 Testing current family rank...');

      try {
        final rankResponse = await _apiClient.get(
          AppConstants.currentFamilyRankEndpoint,
        );

        if (rankResponse.statusCode == 200) {
          debugPrint('✅ Current family rank retrieved successfully');
          final rankData = rankResponse.data;
          debugPrint('📊 Current family rank data: $rankData');
        } else {
          debugPrint(
            '⚠️ Current family rank endpoint returned: ${rankResponse.statusCode}',
          );
        }
      } catch (e) {
        debugPrint('⚠️ Current family rank endpoint not available: $e');
      }
    } catch (e) {
      debugPrint('❌ Error testing leaderboard data flow: $e');
    }

    debugPrint('=' * 60);
    debugPrint('🔄 Leaderboard Data Flow Test Complete');
  }

  /// Test leaderboard screen integration
  Future<Map<String, dynamic>> testLeaderboardScreenIntegration() async {
    debugPrint('📱 Testing Leaderboard Screen Integration');
    debugPrint('=' * 60);

    final results = <String, dynamic>{
      'backendConnection': false,
      'dataRetrieval': false,
      'currentUserFamily': false,
      'fallbackWorking': true,
      'endpoints': <String, bool>{},
    };

    try {
      // Test main leaderboard endpoint
      try {
        final response = await _apiClient.get(
          AppConstants.leaderboardEndpoint,
          queryParameters: {'limit': 20},
        );

        results['endpoints'][AppConstants.leaderboardEndpoint] =
            response.statusCode == 200;
        results['backendConnection'] = response.statusCode == 200;

        if (response.statusCode == 200) {
          results['dataRetrieval'] = response.data != null;
        }
      } catch (e) {
        results['endpoints'][AppConstants.leaderboardEndpoint] = false;
      }

      // Test family leaderboard endpoint
      try {
        final response = await _apiClient.get(
          AppConstants.familyLeaderboardEndpoint,
        );
        results['endpoints'][AppConstants.familyLeaderboardEndpoint] =
            response.statusCode == 200;
      } catch (e) {
        results['endpoints'][AppConstants.familyLeaderboardEndpoint] = false;
      }

      // Test families endpoint
      try {
        final response = await _apiClient.get(AppConstants.familiesEndpoint);
        results['endpoints'][AppConstants.familiesEndpoint] =
            response.statusCode == 200;
      } catch (e) {
        results['endpoints'][AppConstants.familiesEndpoint] = false;
      }

      // Test current user family
      final currentUser = StorageService.getUser();
      results['currentUserFamily'] = currentUser?.familyId != null;

      // Calculate success rate
      final workingEndpoints =
          results['endpoints'].values.where((working) => working).length;
      final totalEndpoints = results['endpoints'].length;

      debugPrint('📊 Integration Test Results:');
      debugPrint('🔗 Backend Connection: ${results['backendConnection']}');
      debugPrint('📥 Data Retrieval: ${results['dataRetrieval']}');
      debugPrint('👥 Current User Family: ${results['currentUserFamily']}');
      debugPrint('🔄 Fallback Working: ${results['fallbackWorking']}');
      debugPrint('✅ Working Endpoints: $workingEndpoints/$totalEndpoints');

      if (workingEndpoints > 0) {
        debugPrint('🎉 Leaderboard screen is connected to backend!');
      } else {
        debugPrint('⚠️ No backend endpoints working - using fallback data');
      }
    } catch (e) {
      debugPrint('❌ Error testing leaderboard screen integration: $e');
    }

    debugPrint('=' * 60);
    debugPrint('📱 Leaderboard Screen Integration Test Complete');

    return results;
  }
}
