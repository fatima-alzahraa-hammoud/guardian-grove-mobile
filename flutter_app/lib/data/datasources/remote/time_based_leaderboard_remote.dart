import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../../models/time_based_leaderboard_model.dart';

abstract class TimeBasedLeaderboardRemoteDataSource {
  Future<TimeBasedLeaderboardResponse> getTimeBasedLeaderboard();
  Future<FamilyProgressStats?> getFamilyProgressStats(
    LeaderboardTimeFrame timeFrame,
  );
  Future<List<LeaderboardFamily>> getLeaderboardByTimeFrame(
    LeaderboardTimeFrame timeFrame,
  );
}

class TimeBasedLeaderboardRemoteDataSourceImpl
    implements TimeBasedLeaderboardRemoteDataSource {
  final ApiClient _apiClient;

  TimeBasedLeaderboardRemoteDataSourceImpl(this._apiClient);
  @override
  Future<TimeBasedLeaderboardResponse> getTimeBasedLeaderboard() async {
    try {
      // Get current user to fetch familyId
      final user = StorageService.getUser();
      if (user?.familyId == null) {
        debugPrint('❌ No family ID found for current user');
        return _getFallbackTimeBasedLeaderboard();
      }

      final familyId = user!.familyId!;

      debugPrint(
        '🏆 Fetching time-based leaderboard from ${AppConstants.baseUrl}${AppConstants.leaderboardEndpoint}?familyId=$familyId',
      );

      // Call the same endpoint as React version: /family/leaderboard?familyId=${familyId}
      final response = await _apiClient.get(
        AppConstants.leaderboardEndpoint,
        queryParameters: {'familyId': familyId},
      );

      debugPrint(
        '📨 Time-based leaderboard response status: ${response.statusCode}',
      );
      debugPrint('📄 Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        debugPrint('✅ Time-based leaderboard data received successfully');

        final data = response.data;
        if (data is Map<String, dynamic>) {
          debugPrint('📋 Response keys: ${data.keys.toList()}');
          return TimeBasedLeaderboardResponse.fromJson(data);
        } else {
          debugPrint('❌ Unexpected response format');
          return _getFallbackTimeBasedLeaderboard();
        }
      } else {
        debugPrint(
          '❌ Time-based leaderboard API returned status: ${response.statusCode}',
        );
        return _getFallbackTimeBasedLeaderboard();
      }
    } on DioException catch (e) {
      debugPrint(
        '🔥 Dio exception during time-based leaderboard fetch: ${e.type}',
      );
      debugPrint('📄 Error response: ${e.response?.data}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else {
        return _getFallbackTimeBasedLeaderboard();
      }
    } catch (e) {
      debugPrint('❌ Unexpected error during time-based leaderboard fetch: $e');
      return _getFallbackTimeBasedLeaderboard();
    }
  }

  @override
  Future<FamilyProgressStats?> getFamilyProgressStats(
    LeaderboardTimeFrame timeFrame,
  ) async {
    try {
      final user = StorageService.getUser();
      if (user?.familyId == null) {
        debugPrint('❌ No family ID found for progress stats');
        return null;
      }

      final familyId = user!.familyId!;

      debugPrint('📊 Fetching family progress stats for ${timeFrame.apiKey}');

      // Call the same endpoint as React: /family/familyProgressStats
      final response = await _apiClient.post(
        AppConstants.familyProgressStatsEndpoint,
        data: {'familyId': familyId, 'timeFrame': timeFrame.apiKey},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Family progress stats received');
        return FamilyProgressStats.fromJson(response.data);
      } else {
        debugPrint(
          '❌ Progress stats API returned status: ${response.statusCode}',
        );
        return null;
      }
    } on DioException catch (e) {
      debugPrint('🔥 Error fetching progress stats: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Unexpected error fetching progress stats: $e');
      return null;
    }
  }

  @override
  Future<List<LeaderboardFamily>> getLeaderboardByTimeFrame(
    LeaderboardTimeFrame timeFrame,
  ) async {
    try {
      final timeBasedData = await getTimeBasedLeaderboard();

      switch (timeFrame) {
        case LeaderboardTimeFrame.daily:
          return _mergeWithCurrentFamily(
            timeBasedData.dailyTop10,
            timeBasedData.dailyFamilyRank,
          );
        case LeaderboardTimeFrame.weekly:
          return _mergeWithCurrentFamily(
            timeBasedData.weeklyTop10,
            timeBasedData.weeklyFamilyRank,
          );
        case LeaderboardTimeFrame.monthly:
          return _mergeWithCurrentFamily(
            timeBasedData.monthlyTop10,
            timeBasedData.monthlyFamilyRank,
          );
        case LeaderboardTimeFrame.yearly:
          return _mergeWithCurrentFamily(
            timeBasedData.yearlyTop10,
            timeBasedData.yearlyFamilyRank,
          );
      }
    } catch (e) {
      debugPrint('❌ Error getting leaderboard by timeframe: $e');
      return _getFallbackFamiliesByTimeFrame(timeFrame);
    }
  }

  List<LeaderboardFamily> _mergeWithCurrentFamily(
    List<LeaderboardFamily> topFamilies,
    LeaderboardFamily? currentFamily,
  ) {
    final user = StorageService.getUser();
    final currentFamilyId = user?.familyId;

    if (currentFamily != null && currentFamilyId != null) {
      // Check if current family is already in top 10
      final isInTop10 = topFamilies.any(
        (family) => family.familyId == currentFamilyId,
      );

      if (!isInTop10) {
        // Add current family to the list
        return [...topFamilies, currentFamily];
      }
    }

    return topFamilies;
  }

  TimeBasedLeaderboardResponse _getFallbackTimeBasedLeaderboard() {
    debugPrint('📱 Generating fallback time-based leaderboard');

    final fallbackFamilies = _generateSampleFamilies();

    return TimeBasedLeaderboardResponse(
      dailyTop10: fallbackFamilies,
      weeklyTop10: fallbackFamilies,
      monthlyTop10: fallbackFamilies,
      yearlyTop10: fallbackFamilies,
      dailyFamilyRank: _getCurrentUserFamily(),
      weeklyFamilyRank: _getCurrentUserFamily(),
      monthlyFamilyRank: _getCurrentUserFamily(),
      yearlyFamilyRank: _getCurrentUserFamily(),
    );
  }

  List<LeaderboardFamily> _getFallbackFamiliesByTimeFrame(
    LeaderboardTimeFrame timeFrame,
  ) {
    final sampleFamilies = _generateSampleFamilies();
    final currentFamily = _getCurrentUserFamily();

    if (currentFamily != null) {
      return [currentFamily, ...sampleFamilies];
    }

    return sampleFamilies;
  }

  LeaderboardFamily? _getCurrentUserFamily() {
    try {
      final user = StorageService.getUser();
      if (user == null) return null;

      return LeaderboardFamily(
        rank: 1,
        familyId: user.familyId ?? 'current-family',
        familyName: 'Your Family',
        familyAvatar: user.avatar,
        stars: user.stars,
        coins: user.coins,
        tasks: 0, // Default tasks
        totalPoints: user.coins + (user.stars * 10),
        members: [
          FamilyMember(id: user.id, name: user.name, avatar: user.avatar),
        ],
      );
    } catch (e) {
      debugPrint('❌ Error getting current user family: $e');
      return null;
    }
  }

  List<LeaderboardFamily> _generateSampleFamilies() {
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
    ];

    final families = <LeaderboardFamily>[];

    for (int i = 0; i < familyNames.length; i++) {
      // Generate realistic but random points
      final basePoints = 1000 - (i * 50);
      final randomVariation = (i * 13) % 100;
      final stars = ((basePoints + randomVariation) / 20).floor();
      final coins = basePoints + randomVariation - (stars * 10);
      final tasks = (stars * 0.8).floor(); // Approximate tasks based on stars
      final totalPoints = stars * 10 + coins;

      // Generate family members
      final numMembers = 2 + (i % 4);
      final members = <FamilyMember>[];

      for (int j = 0; j < numMembers; j++) {
        members.add(
          FamilyMember(
            id: 'sample-member-$i-$j',
            name: memberNames[(i + j) % memberNames.length],
            avatar: avatars[(i + j) % avatars.length],
          ),
        );
      }

      families.add(
        LeaderboardFamily(
          rank: i + 1,
          familyId: 'sample-family-$i',
          familyName: familyNames[i],
          familyAvatar: avatars[i % avatars.length],
          stars: stars,
          coins: coins,
          tasks: tasks,
          totalPoints: totalPoints,
          members: members,
        ),
      );
    }

    debugPrint('✅ Generated ${families.length} sample families');
    return families;
  }
}
