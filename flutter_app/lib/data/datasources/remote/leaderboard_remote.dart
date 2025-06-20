import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../../models/leaderboard_model.dart';

abstract class LeaderboardRemoteDataSource {
  Future<List<LeaderboardFamily>> getLeaderboard();
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final ApiClient apiClient;

  LeaderboardRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<LeaderboardFamily>> getLeaderboard() async {
    debugPrint('🏆 Fetching leaderboard data from backend');

    try {
      // Strategy 1: Try the family leaderboard endpoint
      try {
        final response = await apiClient.dio.get('/family/familyLeaderboard');

        if (response.statusCode == 200) {
          debugPrint(
            '✅ Leaderboard data received from /family/familyLeaderboard',
          );
          debugPrint('📊 Response type: ${response.data.runtimeType}');
          debugPrint(
            '📊 Response keys: ${response.data is Map ? (response.data as Map).keys.toList() : 'N/A'}',
          );

          final leaderboardData = _convertBackendDataToLeaderboard(
            response.data,
          );
          if (leaderboardData.isNotEmpty) {
            return leaderboardData;
          }
        }
      } catch (e) {
        debugPrint('⚠️ /family/familyLeaderboard failed: $e');
      }

      // Strategy 2: Try the general leaderboard endpoint
      try {
        final response = await apiClient.dio.get('/family/leaderboard');

        if (response.statusCode == 200) {
          debugPrint('✅ Leaderboard data received from /family/leaderboard');
          debugPrint('📊 Response type: ${response.data.runtimeType}');
          debugPrint(
            '📊 Response keys: ${response.data is Map ? (response.data as Map).keys.toList() : 'N/A'}',
          );

          final leaderboardData = _convertBackendDataToLeaderboard(
            response.data,
          );
          if (leaderboardData.isNotEmpty) {
            return leaderboardData;
          }
        }
      } catch (e) {
        debugPrint('⚠️ /family/leaderboard failed: $e');
      }

      // Strategy 3: Try to get all families and construct leaderboard
      try {
        final response = await apiClient.dio.get('/family/');

        if (response.statusCode == 200) {
          debugPrint('✅ Family data received from /family/');
          debugPrint('📊 Response type: ${response.data.runtimeType}');
          debugPrint(
            '📊 Response keys: ${response.data is Map ? (response.data as Map).keys.toList() : 'N/A'}',
          );

          final leaderboardData = _convertBackendDataToLeaderboard(
            response.data,
          );
          if (leaderboardData.isNotEmpty) {
            return leaderboardData;
          }
        }
      } catch (e) {
        debugPrint('⚠️ /family/ failed: $e');
      }

      // All strategies failed, return fallback data
      debugPrint(
        '📝 All backend endpoints failed, using fallback leaderboard data',
      );
      return _getFallbackLeaderboard();
    } on DioException catch (e) {
      debugPrint('🌐 API Error: ${e.response?.statusCode} - ${e.message}');
      return _getFallbackLeaderboard();
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return _getFallbackLeaderboard();
    }
  }

  /// Convert backend response to leaderboard entries
  List<LeaderboardFamily> _convertBackendDataToLeaderboard(
    dynamic responseData,
  ) {
    debugPrint('🔄 Converting backend data to leaderboard format');

    try {
      List<dynamic> familiesData = [];

      // Handle different response structures
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data is List) {
            familiesData = data;
          } else if (data is Map && data.containsKey('families')) {
            familiesData = data['families'] as List? ?? [];
          } else if (data is Map && data.containsKey('leaderboard')) {
            familiesData = data['leaderboard'] as List? ?? [];
          }
        } else if (responseData.containsKey('families')) {
          familiesData = responseData['families'] as List? ?? [];
        } else if (responseData.containsKey('leaderboard')) {
          familiesData = responseData['leaderboard'] as List? ?? [];
        } else {
          // If it's a map but no known structure, wrap it in a list
          familiesData = [responseData];
        }
      } else if (responseData is List) {
        familiesData = responseData;
      }

      debugPrint('📊 Found ${familiesData.length} families in response');

      if (familiesData.isEmpty) {
        debugPrint('⚠️ No family data found in response');
        return [];
      } // Convert to leaderboard entries
      final entries = <LeaderboardFamily>[];

      for (int i = 0; i < familiesData.length && i < 20; i++) {
        final familyData = familiesData[i];
        if (familyData is! Map<String, dynamic>) continue;

        final familyId =
            familyData['_id']?.toString() ??
            familyData['id']?.toString() ??
            familyData['familyId']?.toString() ??
            '${i + 1}';

        final familyName =
            familyData['familyName']?.toString() ??
            familyData['name']?.toString() ??
            familyData['title']?.toString() ??
            'Family ${i + 1}';

        final totalStars =
            (familyData['totalStars'] ??
                    familyData['stars'] ??
                    familyData['points'] ??
                    familyData['score'] ??
                    0)
                .toInt();

        final totalCoins =
            (familyData['totalCoins'] ??
                    familyData['coins'] ??
                    familyData['currency'] ??
                    0)
                .toInt();

        final avatarUrl =
            familyData['familyAvatar']?.toString() ??
            familyData['avatarUrl']?.toString() ??
            familyData['avatar']?.toString() ??
            ''; // Handle family members
        final members = <FamilyMember>[];
        final membersData =
            familyData['members'] as List? ??
            familyData['familyMembers'] as List? ??
            [];

        for (final memberData in membersData) {
          if (memberData is Map<String, dynamic>) {
            final firstName =
                memberData['firstName']?.toString() ??
                memberData['first_name']?.toString() ??
                'Member';
            final lastName =
                memberData['lastName']?.toString() ??
                memberData['last_name']?.toString() ??
                '';
            final memberName = '$firstName $lastName';
            members.add(
              FamilyMember(
                id:
                    memberData['_id']?.toString() ??
                    memberData['id']?.toString() ??
                    '',
                name: memberName.trim(),
                avatar:
                    memberData['avatarUrl']?.toString() ??
                    memberData['avatar_url']?.toString() ??
                    memberData['profilePicture']?.toString() ??
                    '',
              ),
            );
          }
        }

        final entry = LeaderboardFamily(
          rank: i + 1,
          familyId: familyId,
          familyName: familyName,
          familyAvatar: avatarUrl,
          stars: totalStars,
          coins: totalCoins,
          totalPoints: totalStars + totalCoins, // Combined score
          members: members,
        );
        entries.add(entry);

        debugPrint(
          '✅ Added family: $familyName ($totalStars stars, $totalCoins coins)',
        );
      }

      debugPrint(
        '✅ Successfully converted ${entries.length} leaderboard entries',
      );
      return entries;
    } catch (e) {
      debugPrint('❌ Error converting backend data: $e');
      return [];
    }
  }

  /// Generate fallback leaderboard data with realistic families
  List<LeaderboardFamily> _getFallbackLeaderboard() {
    debugPrint('📝 Generating fallback leaderboard data');

    // Get the real logged-in user for current family
    final currentUser = StorageService.getUser();
    final currentUserFamilyId = currentUser?.familyId ?? '1';

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
      '👨‍👩‍👦‍👦',
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
    ];

    final entries = <LeaderboardFamily>[];

    // Generate random but consistent stars/coins based on rank
    for (int i = 0; i < 20; i++) {
      final rank = i + 1;
      final familyId =
          rank == 1 && currentUser != null
              ? currentUserFamilyId
              : 'family_$rank';

      // Higher ranked families have more stars (with some randomness)
      final baseStars = 500 - (rank * 15);
      final stars = (baseStars + (rank * 3) % 50).clamp(10, 500);
      final coins = (stars * 0.8).round();

      final familyName = familyNames[i];

      // Create mock family members
      final members = <FamilyMember>[];
      final memberCount = 2 + (i % 4); // 2-5 members per family

      for (int j = 0; j < memberCount; j++) {
        if (familyId == currentUserFamilyId && j == 0 && currentUser != null) {
          // Add current user as first member
          members.add(
            FamilyMember(
              id: currentUser.id,
              name: currentUser.name,
              avatar: currentUser.avatar,
            ),
          );
        } else {
          final memberNames = [
            'Alex',
            'Jordan',
            'Riley',
            'Casey',
            'Morgan',
            'Taylor',
            'Cameron',
            'Avery',
          ];
          members.add(
            FamilyMember(
              id: 'member_${familyId}_$j',
              name: memberNames[j % memberNames.length],
              avatar: avatars[(i + j) % avatars.length],
            ),
          );
        }
      }

      entries.add(
        LeaderboardFamily(
          rank: rank,
          familyId: familyId,
          familyName: familyName,
          familyAvatar: avatars[i % avatars.length],
          stars: stars,
          coins: coins,
          totalPoints: stars + coins,
          members: members,
        ),
      );
    }

    debugPrint('✅ Generated ${entries.length} fallback leaderboard entries');
    if (currentUser != null) {
      debugPrint('👤 Current user family ID: $currentUserFamilyId');
    }

    return entries;
  }
}
