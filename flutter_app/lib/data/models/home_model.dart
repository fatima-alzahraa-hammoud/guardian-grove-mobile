class HomeData {
  final UserProfile user;
  final FamilyStats familyStats;
  final List<QuickAction> quickActions;
  final DailyMessage dailyMessage;
  final List<FamilyMember> familyMembers;

  const HomeData({
    required this.user,
    required this.familyStats,
    required this.quickActions,
    required this.dailyMessage,
    required this.familyMembers,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      user: UserProfile.fromJson(json['user'] ?? {}),
      familyStats: FamilyStats.fromJson(json['family_stats'] ?? {}),
      quickActions:
          (json['quick_actions'] as List<dynamic>?)
              ?.map((action) => QuickAction.fromJson(action))
              .toList() ??
          [],
      dailyMessage: DailyMessage.fromJson(json['daily_message'] ?? {}),
      familyMembers:
          (json['family_members'] as List<dynamic>?)
              ?.map((member) => FamilyMember.fromJson(member))
              .toList() ??
          [],
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class FamilyStats {
  final int stars;
  final int coins;
  final int rank;
  final int totalTasks;
  final int completedTasks;
  final int familyMembersCount;

  const FamilyStats({
    required this.stars,
    required this.coins,
    required this.rank,
    required this.totalTasks,
    required this.completedTasks,
    required this.familyMembersCount,
  });

  factory FamilyStats.fromJson(Map<String, dynamic> json) {
    return FamilyStats(
      stars: json['stars'] ?? 0,
      coins: json['coins'] ?? 0,
      rank: json['rank'] ?? 0,
      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      familyMembersCount: json['family_members_count'] ?? 0,
    );
  }
}

class QuickAction {
  final String id;
  final String title;
  final String icon;
  final String route;
  final String color;
  final bool isEnabled;

  const QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
    this.isEnabled = true,
  });

  factory QuickAction.fromJson(Map<String, dynamic> json) {
    return QuickAction(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      icon: json['icon'] ?? '',
      route: json['route'] ?? '',
      color: json['color'] ?? '',
      isEnabled: json['is_enabled'] ?? true,
    );
  }
}

class DailyMessage {
  final String id;
  final String message;
  final String category;
  final DateTime date;

  const DailyMessage({
    required this.id,
    required this.message,
    required this.category,
    required this.date,
  });

  factory DailyMessage.fromJson(Map<String, dynamic> json) {
    return DailyMessage(
      id: json['id'] ?? '',
      message:
          json['message'] ??
          'Every day is a new adventure waiting to unfold with your family!',
      category: json['category'] ?? 'Inspiration',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}

class FamilyMember {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String role;
  final bool isOnline;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
    this.isOnline = false,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      role: json['role'] ?? 'member',
      isOnline: json['is_online'] ?? false,
    );
  }
}
