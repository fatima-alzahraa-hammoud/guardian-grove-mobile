import 'family_model.dart' show FamilyMember;

class HomeData {
  final String id;
  final UserProfile user;
  final FamilyStats familyStats;
  final List<QuickAction> quickActions;
  final DailyMessage dailyMessage;
  final List<FamilyMember> familyMembers;
  final String familyName;
  final String email;
  final DateTime createdAt;
  final String familyAvatar;
  final List<dynamic> notifications;
  final List<dynamic> goals;
  final List<dynamic> achievements;
  final List<dynamic> sharedStories;

  HomeData({
    required this.id,
    required this.user,
    required this.familyStats,
    required this.quickActions,
    required this.dailyMessage,
    required this.familyMembers,
    required this.familyName,
    required this.email,
    required this.createdAt,
    required this.familyAvatar,
    required this.notifications,
    required this.goals,
    required this.achievements,
    required this.sharedStories,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      id: json['_id'] ?? json['id'] ?? '',
      user: UserProfile.fromJson(json['user'] ?? {}),
      familyStats: FamilyStats.fromJson(json['family_stats'] ?? {}),
      quickActions:
          (json['quick_actions'] as List<dynamic>?)
              ?.map((action) => QuickAction.fromJson(action))
              .toList() ??
          [],
      dailyMessage: DailyMessage.fromJson(json['daily_message'] ?? {}),
      familyMembers:
          (json['members'] as List<dynamic>? ?? [])
              .map((member) => FamilyMember.fromJson(member))
              .toList(),
      familyName: json['familyName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      familyAvatar: json['familyAvatar'] ?? '',
      notifications: json['notifications'] ?? [],
      goals: json['goals'] ?? [],
      achievements: json['achievements'] ?? [],
      sharedStories: json['sharedStories'] ?? [],
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
  final int totalStars;
  final int tasks;
  final Stars stars;
  final TaskCounts taskCounts;

  FamilyStats({
    required this.totalStars,
    required this.tasks,
    required this.stars,
    required this.taskCounts,
  });

  factory FamilyStats.fromJson(Map<String, dynamic> json) {
    return FamilyStats(
      totalStars: json['totalStars'] ?? 0,
      tasks: json['tasks'] ?? 0,
      stars: Stars.fromJson(json['stars'] ?? {}),
      taskCounts: TaskCounts.fromJson(json['taskCounts'] ?? {}),
    );
  }
}

class Stars {
  final int daily;
  final int weekly;
  final int monthly;
  final int yearly;

  Stars({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.yearly,
  });

  factory Stars.fromJson(Map<String, dynamic> json) {
    return Stars(
      daily: json['daily'] ?? 0,
      weekly: json['weekly'] ?? 0,
      monthly: json['monthly'] ?? 0,
      yearly: json['yearly'] ?? 0,
    );
  }
}

class TaskCounts {
  final int daily;
  final int weekly;
  final int monthly;
  final int yearly;

  TaskCounts({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.yearly,
  });

  factory TaskCounts.fromJson(Map<String, dynamic> json) {
    return TaskCounts(
      daily: json['daily'] ?? 0,
      weekly: json['weekly'] ?? 0,
      monthly: json['monthly'] ?? 0,
      yearly: json['yearly'] ?? 0,
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
