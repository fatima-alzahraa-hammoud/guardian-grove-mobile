import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../../models/leaderboard_model.dart' as legacy;

abstract class LeaderboardRemoteDataSource {
  Future<List<legacy.LeaderboardFamily>> getLeaderboard({int limit = 20});
  Future<legacy.LeaderboardFamily?> getCurrentFamilyRank();
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final ApiClient _apiClient;

  LeaderboardRemoteDataSourceImpl(this._apiClient);
  @override
  Future<List<legacy.LeaderboardFamily>> getLeaderboard({
    int limit = 20,
  }) async {
    debugPrint('🏆 Starting leaderboard fetch...');
    debugPrint('📍 Backend URL: ${AppConstants.baseUrl}');
    debugPrint('🎯 Target endpoint: ${AppConstants.leaderboardEndpoint}');
    debugPrint('📊 Requested limit: $limit');

    try {
      debugPrint(
        '🏆 Fetching leaderboard from ${AppConstants.baseUrl}${AppConstants.leaderboardEndpoint}',
      );

      // Try the main leaderboard endpoint first
      final response = await _apiClient.get(
        AppConstants.leaderboardEndpoint,
        queryParameters: {'limit': limit.clamp(1, 20)},
      );

      debugPrint('📨 Leaderboard response status: ${response.statusCode}');
      debugPrint('📄 Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        debugPrint('✅ Leaderboard data received successfully');

        final data = response.data;
        List<dynamic> familiesData = [];

        // Handle different response structures
        if (data is Map<String, dynamic>) {
          debugPrint('📋 Response is Map with keys: ${data.keys.toList()}');
          if (data.containsKey('data')) {
            familiesData = data['data'] as List<dynamic>? ?? [];
            debugPrint('📊 Found data array with ${familiesData.length} items');
          } else if (data.containsKey('families')) {
            familiesData = data['families'] as List<dynamic>? ?? [];
            debugPrint(
              '📊 Found families array with ${familiesData.length} items',
            );
          } else if (data.containsKey('leaderboard')) {
            familiesData = data['leaderboard'] as List<dynamic>? ?? [];
            debugPrint(
              '📊 Found leaderboard array with ${familiesData.length} items',
            );
          } else {
            debugPrint(
              '⚠️ Response structure not recognized, treating as single item',
            );
            familiesData = [data];
          }
        } else if (data is List) {
          familiesData = data;
          debugPrint(
            '📊 Response is direct array with ${familiesData.length} items',
          );
        } else {
          debugPrint('❌ Unexpected response type: ${data.runtimeType}');
        }

        debugPrint('📊 Found ${familiesData.length} families in response');

        if (familiesData.isNotEmpty) {
          return _convertToLeaderboardFamilies(familiesData, limit);
        } else {
          debugPrint('⚠️ No family data found, trying alternative endpoints');
          return await _tryAlternativeEndpoints(limit);
        }
      } else {
        debugPrint('❌ Leaderboard API returned status: ${response.statusCode}');
        return await _tryAlternativeEndpoints(limit);
      }
    } on DioException catch (e) {
      debugPrint('🔥 Dio exception during leaderboard fetch: ${e.type}');
      debugPrint('📄 Error response: ${e.response?.data}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response?.statusCode == 404) {
        debugPrint('📝 Leaderboard endpoint not found, trying alternatives');
        return await _tryAlternativeEndpoints(limit);
      } else {
        return await _tryAlternativeEndpoints(limit);
      }
    } catch (e) {
      debugPrint('❌ Unexpected error during leaderboard fetch: $e');
      return await _getFallbackData(limit);
    }
  }

  Future<List<legacy.LeaderboardFamily>> _tryAlternativeEndpoints(
    int limit,
  ) async {
    debugPrint('🔄 Trying alternative leaderboard endpoints');

    // Try family leaderboard endpoint
    try {
      final response = await _apiClient.get(
        AppConstants.familyLeaderboardEndpoint,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Data received from family leaderboard endpoint');
        return _convertToLeaderboardFamilies(response.data, limit);
      }
    } on DioException catch (e) {
      debugPrint(
        '⚠️ Family leaderboard endpoint failed: ${e.response?.statusCode}',
      );
    }

    // Try families endpoint
    try {
      final response = await _apiClient.get(AppConstants.familiesEndpoint);

      if (response.statusCode == 200) {
        debugPrint('✅ Data received from families endpoint');
        return await _buildLeaderboardFromFamilies(response.data, limit);
      }
    } on DioException catch (e) {
      debugPrint('⚠️ Families endpoint failed: ${e.response?.statusCode}');
    }

    // Try users endpoint with family data
    try {
      final response = await _apiClient.get(
        '/users',
        queryParameters: {'includeFamily': true, 'populate': 'family'},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Data received from users endpoint');
        final userData = response.data['data'] ?? response.data;
        return _convertUsersToLeaderboard(userData, limit);
      }
    } on DioException catch (e) {
      debugPrint('⚠️ Users endpoint failed: ${e.response?.statusCode}');
    }

    debugPrint('📝 All backend endpoints failed, using fallback data');
    return await _getFallbackData(limit);
  }

  List<legacy.LeaderboardFamily> _convertToLeaderboardFamilies(
    dynamic data,
    int limit,
  ) {
    try {
      List<dynamic> familiesData = [];

      if (data is Map<String, dynamic>) {
        if (data.containsKey('data')) {
          familiesData = data['data'] as List<dynamic>? ?? [];
        } else if (data.containsKey('families')) {
          familiesData = data['families'] as List<dynamic>? ?? [];
        } else {
          familiesData = [data];
        }
      } else if (data is List) {
        familiesData = data;
      }

      final families = <legacy.LeaderboardFamily>[];

      for (int i = 0; i < familiesData.length && i < limit; i++) {
        final familyData = familiesData[i];
        if (familyData is! Map<String, dynamic>) continue;

        try {
          final family = legacy.LeaderboardFamily(
            rank: (familyData['rank'] ?? i + 1) as int,
            familyId:
                familyData['_id']?.toString() ??
                familyData['id']?.toString() ??
                familyData['familyId']?.toString() ??
                'family-$i',
            familyName:
                familyData['name']?.toString() ??
                familyData['familyName']?.toString() ??
                'Family ${i + 1}',
            familyAvatar:
                familyData['avatar']?.toString() ??
                familyData['familyAvatar']?.toString() ??
                '',
            stars:
                (familyData['stars'] ?? familyData['totalStars'] ?? 0) as int,
            coins:
                (familyData['coins'] ?? familyData['totalCoins'] ?? 0) as int,
            totalPoints:
                (familyData['totalPoints'] ??
                        ((familyData['stars'] ?? 0) +
                            (familyData['coins'] ?? 0)))
                    as int,
            members: _extractFamilyMembers(familyData['members'] ?? []),
          );

          families.add(family);
          debugPrint(
            '✅ Added family: ${family.familyName} (${family.stars} stars, ${family.coins} coins)',
          );
        } catch (e) {
          debugPrint('❌ Error parsing family data at index $i: $e');
        }
      }

      // Sort by total points descending
      families.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

      // Update ranks after sorting
      for (int i = 0; i < families.length; i++) {
        families[i] = legacy.LeaderboardFamily(
          rank: i + 1,
          familyId: families[i].familyId,
          familyName: families[i].familyName,
          familyAvatar: families[i].familyAvatar,
          stars: families[i].stars,
          coins: families[i].coins,
          totalPoints: families[i].totalPoints,
          members: families[i].members,
        );
      }

      debugPrint('📊 Successfully converted ${families.length} families');
      return families;
    } catch (e) {
      debugPrint('❌ Error converting leaderboard data: $e');
      return [];
    }
  }

  Future<List<legacy.LeaderboardFamily>> _buildLeaderboardFromFamilies(
    dynamic data,
    int limit,
  ) async {
    try {
      List<dynamic> familiesData = [];

      if (data is Map<String, dynamic>) {
        familiesData = data['data'] as List<dynamic>? ?? [];
      } else if (data is List) {
        familiesData = data;
      }

      final families = <legacy.LeaderboardFamily>[];

      for (int i = 0; i < familiesData.length && i < limit; i++) {
        final family = familiesData[i];
        if (family is! Map<String, dynamic>) continue;

        final familyId =
            family['_id']?.toString() ??
            family['id']?.toString() ??
            'family-$i';

        try {
          // Get family members
          final membersResponse = await _apiClient.get(
            '/users',
            queryParameters: {'familyId': familyId},
          );

          List<dynamic> membersList = [];
          if (membersResponse.statusCode == 200) {
            membersList = membersResponse.data['data'] ?? [];
          }

          // Calculate family stats
          int totalStars = 0;
          int totalCoins = 0;
          final members = <legacy.FamilyMember>[];

          for (final user in membersList) {
            final userStars = (user['stars'] ?? 0) as int;
            final userCoins = (user['coins'] ?? 0) as int;

            totalStars += userStars;
            totalCoins += userCoins;

            members.add(
              legacy.FamilyMember(
                id:
                    user['_id']?.toString() ??
                    user['id']?.toString() ??
                    'user-${members.length}',
                name: user['name']?.toString() ?? 'User ${members.length + 1}',
                avatar: user['avatar']?.toString() ?? '',
              ),
            );
          }

          final totalPoints = totalCoins + (totalStars * 10);

          families.add(
            legacy.LeaderboardFamily(
              rank: i + 1, // Will be updated after sorting
              familyId: familyId,
              familyName:
                  family['name']?.toString() ??
                  family['familyName']?.toString() ??
                  'Family ${i + 1}',
              familyAvatar:
                  family['avatar']?.toString() ??
                  family['familyAvatar']?.toString() ??
                  '',
              stars: totalStars,
              coins: totalCoins,
              totalPoints: totalPoints,
              members: members,
            ),
          );
        } catch (e) {
          debugPrint('❌ Error fetching data for family $familyId: $e');
        }
      }

      // Sort by total points
      families.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

      // Update ranks
      for (int i = 0; i < families.length; i++) {
        families[i] = legacy.LeaderboardFamily(
          rank: i + 1,
          familyId: families[i].familyId,
          familyName: families[i].familyName,
          familyAvatar: families[i].familyAvatar,
          stars: families[i].stars,
          coins: families[i].coins,
          totalPoints: families[i].totalPoints,
          members: families[i].members,
        );
      }

      return families.take(limit).toList();
    } catch (e) {
      debugPrint('❌ Error building leaderboard from families: $e');
      return [];
    }
  }

  List<legacy.LeaderboardFamily> _convertUsersToLeaderboard(
    dynamic userData,
    int limit,
  ) {
    try {
      List<dynamic> users = [];
      if (userData is List) {
        users = userData;
      } else if (userData is Map && userData.containsKey('data')) {
        users = userData['data'] as List<dynamic>? ?? [];
      }

      // Group users by family
      final Map<String, List<Map<String, dynamic>>> familyGroups = {};

      for (final user in users) {
        if (user is! Map<String, dynamic>) continue;

        final familyId =
            user['familyId']?.toString() ??
            user['family_id']?.toString() ??
            'no-family';

        if (!familyGroups.containsKey(familyId)) {
          familyGroups[familyId] = [];
        }
        familyGroups[familyId]!.add(user);
      }

      final families = <legacy.LeaderboardFamily>[];
      int rank = 1;

      for (final entry in familyGroups.entries) {
        if (rank > limit) break;

        final familyId = entry.key;
        final familyUsers = entry.value;

        if (familyUsers.isEmpty) continue;

        int totalStars = 0;
        int totalCoins = 0;
        final members = <legacy.FamilyMember>[];
        String familyName = 'Family $rank';
        String familyAvatar = '';

        for (final user in familyUsers) {
          totalStars += (user['stars'] ?? 0) as int;
          totalCoins += (user['coins'] ?? 0) as int;

          // Try to get family name from user data
          if (familyName == 'Family $rank') {
            familyName =
                user['familyName']?.toString() ??
                user['family_name']?.toString() ??
                familyName;
          }

          if (familyAvatar.isEmpty) {
            familyAvatar =
                user['familyAvatar']?.toString() ??
                user['family_avatar']?.toString() ??
                '';
          }

          members.add(
            legacy.FamilyMember(
              id:
                  user['_id']?.toString() ??
                  user['id']?.toString() ??
                  'user-${members.length}',
              name: user['name']?.toString() ?? 'User ${members.length + 1}',
              avatar: user['avatar']?.toString() ?? '',
            ),
          );
        }

        final totalPoints = totalCoins + (totalStars * 10);

        families.add(
          legacy.LeaderboardFamily(
            rank: rank,
            familyId: familyId,
            familyName: familyName,
            familyAvatar: familyAvatar,
            stars: totalStars,
            coins: totalCoins,
            totalPoints: totalPoints,
            members: members,
          ),
        );

        rank++;
      }

      // Sort by total points
      families.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

      // Update ranks after sorting
      for (int i = 0; i < families.length; i++) {
        families[i] = legacy.LeaderboardFamily(
          rank: i + 1,
          familyId: families[i].familyId,
          familyName: families[i].familyName,
          familyAvatar: families[i].familyAvatar,
          stars: families[i].stars,
          coins: families[i].coins,
          totalPoints: families[i].totalPoints,
          members: families[i].members,
        );
      }

      return families.take(limit).toList();
    } catch (e) {
      debugPrint('❌ Error converting users to leaderboard: $e');
      return [];
    }
  }

  List<legacy.FamilyMember> _extractFamilyMembers(dynamic membersData) {
    try {
      if (membersData is! List) return [];

      return membersData.map<legacy.FamilyMember>((memberData) {
        if (memberData is! Map<String, dynamic>) {
          return legacy.FamilyMember(id: '', name: 'Unknown', avatar: '');
        }

        return legacy.FamilyMember(
          id:
              memberData['_id']?.toString() ??
              memberData['id']?.toString() ??
              '',
          name:
              memberData['name']?.toString() ??
              memberData['firstName']?.toString() ??
              'Unknown',
          avatar:
              memberData['avatar']?.toString() ??
              memberData['avatarUrl']?.toString() ??
              '',
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error extracting family members: $e');
      return [];
    }
  }

  @override
  Future<legacy.LeaderboardFamily?> getCurrentFamilyRank() async {
    try {
      debugPrint(
        '👨‍👩‍👧‍👦 Fetching current family rank from ${AppConstants.baseUrl}${AppConstants.currentFamilyRankEndpoint}',
      );

      final response = await _apiClient.get(
        AppConstants.currentFamilyRankEndpoint,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Current family rank data received');
        final data = response.data['data'] ?? response.data;
        return legacy.LeaderboardFamily.fromJson(data);
      } else {
        debugPrint(
          '❌ Current family rank API returned status: ${response.statusCode}',
        );
        return await _getFallbackCurrentFamily();
      }
    } on DioException catch (e) {
      debugPrint(
        '🔥 Dio exception during current family rank fetch: ${e.type}',
      );
      debugPrint('📄 Error response: ${e.response?.data}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');

      if (e.response?.statusCode == 404) {
        debugPrint('📝 Current family rank endpoint not found, using fallback');
      }
      return await _getFallbackCurrentFamily();
    } catch (e) {
      debugPrint('❌ Unexpected error during current family rank fetch: $e');
      return await _getFallbackCurrentFamily();
    }
  }

  Future<List<legacy.LeaderboardFamily>> _getFallbackData(int limit) async {
    debugPrint('📱 Generating fallback leaderboard from local data');
    try {
      final user = StorageService.getUser();
      if (user == null) {
        debugPrint('❌ No user data available for fallback');
        return _generateSampleFamilies(limit);
      }

      debugPrint(
        '👤 Using real user data: ${user.name} - Stars: ${user.stars}, Coins: ${user.coins}',
      );

      // For development, let's create a mix of real user family + sample families
      final families = <legacy.LeaderboardFamily>[];

      // Add current user's family first
      final currentFamily = legacy.LeaderboardFamily(
        rank: 1, // Will be updated after sorting
        familyId: user.familyId ?? 'current-family',
        familyName: 'Your Family',
        familyAvatar: user.avatar,
        stars: user.stars,
        coins: user.coins,
        totalPoints: user.coins + (user.stars * 10),
        members: [
          legacy.FamilyMember(
            id: user.id,
            name: user.name,
            avatar: user.avatar,
          ),
        ],
      );
      families.add(currentFamily);

      // Add sample families for development/testing
      families.addAll(_generateSampleFamilies(limit - 1));

      // Sort by total points (highest first)
      families.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

      // Update ranks after sorting
      for (int i = 0; i < families.length; i++) {
        families[i] = legacy.LeaderboardFamily(
          rank: i + 1,
          familyId: families[i].familyId,
          familyName: families[i].familyName,
          familyAvatar: families[i].familyAvatar,
          stars: families[i].stars,
          coins: families[i].coins,
          totalPoints: families[i].totalPoints,
          members: families[i].members,
        );
      }

      debugPrint(
        '📊 Fallback: Showing ${families.length} families (1 real + ${families.length - 1} sample)',
      );
      return families.take(limit).toList();
    } catch (e) {
      debugPrint('❌ Error creating fallback data: $e');
      return _generateSampleFamilies(limit);
    }
  }

  List<legacy.LeaderboardFamily> _generateSampleFamilies(int limit) {
    debugPrint('🎭 Generating sample families for development/testing');

    final familyNames = [
      'The Johnsons',
      'Adventure Squad',
      'Happy Hearts',
      'Dream Team',
      'Star Collectors',
      'Rainbow Family',
      'Nature Lovers',
      'Bookworms United',
      'Creative Minds',
      'Sport Champions',
      'Music Makers',
      'Art Masters',
      'Science Explorers',
      'Cooking Crew',
      'Garden Gang',
      'Tech Wizards',
      'Travel Buddies',
      'Puzzle Solvers',
      'Game Masters',
      'Story Tellers',
    ];

    final avatars = [
      '👨‍👩‍👧‍👦',
      '👨‍👩‍👧‍👧',
      '👨‍👨‍👧‍👦',
      '👩‍👩‍👦‍👦',
      '🏠',
      '🌟',
      '🎯',
      '🚀',
      '🌈',
      '🎨',
      '📚',
      '⚽',
      '🎵',
      '🌺',
      '🦋',
      '🌙',
      '☀️',
      '🎪',
      '🎭',
      '🎨',
    ];

    final memberNames = [
      'Alex',
      'Jordan',
      'Riley',
      'Casey',
      'Morgan',
      'Taylor',
      'Cameron',
      'Avery',
      'Jamie',
      'Blake',
      'Sam',
      'Quinn',
    ];

    final families = <legacy.LeaderboardFamily>[];

    for (int i = 0; i < limit && i < familyNames.length; i++) {
      // Generate realistic but random points
      final basePoints = 1000 - (i * 50); // Higher points for higher ranks
      final randomVariation = (i * 13) % 100; // Some variation
      final stars = ((basePoints + randomVariation) / 20).floor();
      final coins = basePoints + randomVariation - (stars * 10);
      final totalPoints = stars * 10 + coins;

      // Generate family members
      final numMembers = 2 + (i % 4); // 2-5 members
      final members = <legacy.FamilyMember>[];

      for (int j = 0; j < numMembers; j++) {
        members.add(
          legacy.FamilyMember(
            id: 'sample-member-$i-$j',
            name: memberNames[(i + j) % memberNames.length],
            avatar: avatars[(i + j) % avatars.length],
          ),
        );
      }

      families.add(
        legacy.LeaderboardFamily(
          rank: i + 1,
          familyId: 'sample-family-$i',
          familyName: familyNames[i],
          familyAvatar: avatars[i % avatars.length],
          stars: stars,
          coins: coins,
          totalPoints: totalPoints,
          members: members,
        ),
      );
    }

    debugPrint('✅ Generated ${families.length} sample families');
    return families;
  }

  Future<legacy.LeaderboardFamily?> _getFallbackCurrentFamily() async {
    debugPrint('📱 Generating fallback current family from local data');
    try {
      final user = StorageService.getUser();
      if (user == null) {
        debugPrint('❌ No user data available for current family fallback');
        return null;
      }

      debugPrint(
        '👤 Using real user data: ${user.name} - Stars: ${user.stars}, Coins: ${user.coins}',
      );

      return legacy.LeaderboardFamily(
        rank: 1,
        familyId: user.familyId ?? 'current-family',
        familyName: 'Your Family',
        familyAvatar: user.avatar,
        stars: user.stars,
        coins: user.coins,
        totalPoints: user.coins + (user.stars * 10),
        members: [
          legacy.FamilyMember(
            id: user.id,
            name: user.name,
            avatar: user.avatar,
          ),
        ],
      );
    } catch (e) {
      debugPrint('❌ Error creating fallback current family: $e');
      return null;
    }
  }
}
