class TimeBasedLeaderboardResponse {
  final List<LeaderboardFamily> dailyTop10;
  final List<LeaderboardFamily> weeklyTop10;
  final List<LeaderboardFamily> monthlyTop10;
  final List<LeaderboardFamily> yearlyTop10;
  final LeaderboardFamily? dailyFamilyRank;
  final LeaderboardFamily? weeklyFamilyRank;
  final LeaderboardFamily? monthlyFamilyRank;
  final LeaderboardFamily? yearlyFamilyRank;

  const TimeBasedLeaderboardResponse({
    required this.dailyTop10,
    required this.weeklyTop10,
    required this.monthlyTop10,
    required this.yearlyTop10,
    this.dailyFamilyRank,
    this.weeklyFamilyRank,
    this.monthlyFamilyRank,
    this.yearlyFamilyRank,
  });

  factory TimeBasedLeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return TimeBasedLeaderboardResponse(
      dailyTop10: _parseLeaderboardList(json['dailyTop10']),
      weeklyTop10: _parseLeaderboardList(json['weeklyTop10']),
      monthlyTop10: _parseLeaderboardList(json['monthlyTop10']),
      yearlyTop10: _parseLeaderboardList(json['yearlyTop10']),
      dailyFamilyRank:
          json['dailyFamilyRank'] != null
              ? LeaderboardFamily.fromJson(json['dailyFamilyRank'])
              : null,
      weeklyFamilyRank:
          json['weeklyFamilyRank'] != null
              ? LeaderboardFamily.fromJson(json['weeklyFamilyRank'])
              : null,
      monthlyFamilyRank:
          json['monthlyFamilyRank'] != null
              ? LeaderboardFamily.fromJson(json['monthlyFamilyRank'])
              : null,
      yearlyFamilyRank:
          json['yearlyFamilyRank'] != null
              ? LeaderboardFamily.fromJson(json['yearlyFamilyRank'])
              : null,
    );
  }

  static List<LeaderboardFamily> _parseLeaderboardList(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];

    return data.map<LeaderboardFamily>((item) {
      if (item is Map<String, dynamic>) {
        return LeaderboardFamily.fromJson(item);
      }
      return LeaderboardFamily(
        rank: 0,
        familyId: '',
        familyName: 'Unknown',
        familyAvatar: '',
        stars: 0,
        coins: 0,
        totalPoints: 0,
        members: [],
      );
    }).toList();
  }
}

class FamilyProgressStats {
  final int totalTasks;
  final int completedTasks;
  final int totalGoals;
  final int completedGoals;
  final int totalAchievements;
  final int unlockedAchievements;

  const FamilyProgressStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.totalGoals,
    required this.completedGoals,
    required this.totalAchievements,
    required this.unlockedAchievements,
  });

  factory FamilyProgressStats.fromJson(Map<String, dynamic> json) {
    return FamilyProgressStats(
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      totalGoals: json['totalGoals'] ?? 0,
      completedGoals: json['completedGoals'] ?? 0,
      totalAchievements: json['totalAchievements'] ?? 0,
      unlockedAchievements: json['unlockedAchievements'] ?? 0,
    );
  }

  double get taskProgress => totalTasks > 0 ? completedTasks / totalTasks : 0.0;
  double get goalProgress => totalGoals > 0 ? completedGoals / totalGoals : 0.0;
  double get achievementProgress =>
      totalAchievements > 0 ? unlockedAchievements / totalAchievements : 0.0;
}

enum LeaderboardTimeFrame {
  daily('Daily Stars'),
  weekly('Weekly Champions'),
  monthly('Monthly Achievers'),
  yearly('Yearly Legends');

  const LeaderboardTimeFrame(this.displayName);
  final String displayName;

  String get apiKey {
    switch (this) {
      case LeaderboardTimeFrame.daily:
        return 'daily';
      case LeaderboardTimeFrame.weekly:
        return 'weekly';
      case LeaderboardTimeFrame.monthly:
        return 'monthly';
      case LeaderboardTimeFrame.yearly:
        return 'yearly';
    }
  }
}

// Updated LeaderboardFamily to include tasks (from React version)
class LeaderboardFamily {
  final int rank;
  final String familyId;
  final String familyName;
  final String familyAvatar;
  final int stars;
  final int coins;
  final int tasks; // Added to match React version
  final int totalPoints;
  final List<FamilyMember> members;

  const LeaderboardFamily({
    required this.rank,
    required this.familyId,
    required this.familyName,
    required this.familyAvatar,
    required this.stars,
    required this.coins,
    this.tasks = 0, // Default to 0 for backward compatibility
    required this.totalPoints,
    required this.members,
  });

  factory LeaderboardFamily.fromJson(Map<String, dynamic> json) {
    return LeaderboardFamily(
      rank: json['rank'] ?? 0,
      familyId: json['familyId'] ?? json['_id'] ?? json['id'] ?? '',
      familyName: json['familyName'] ?? json['name'] ?? '',
      familyAvatar: json['familyAvatar'] ?? json['avatar'] ?? '',
      stars: json['stars'] ?? 0,
      coins: json['coins'] ?? 0,
      tasks: json['tasks'] ?? 0, // Include tasks from React version
      totalPoints: json['totalPoints'] ?? json['total_points'] ?? 0,
      members:
          (json['members'] as List<dynamic>?)
              ?.map((member) => FamilyMember.fromJson(member))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'familyId': familyId,
      'familyName': familyName,
      'familyAvatar': familyAvatar,
      'stars': stars,
      'coins': coins,
      'tasks': tasks,
      'totalPoints': totalPoints,
      'members': members.map((member) => member.toJson()).toList(),
    };
  }
}

class FamilyMember {
  final String id;
  final String name;
  final String avatar;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatar': avatar};
  }
}
