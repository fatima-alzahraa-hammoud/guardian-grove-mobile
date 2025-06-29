class LeaderboardFamily {
  final int rank;
  final String familyId;
  final String familyName;
  final String familyAvatar;
  final int stars;
  final int coins;
  final int totalPoints;
  final List<FamilyMember> members;

  const LeaderboardFamily({
    required this.rank,
    required this.familyId,
    required this.familyName,
    required this.familyAvatar,
    required this.stars,
    required this.coins,
    required this.totalPoints,
    required this.members,
  });

  factory LeaderboardFamily.fromJson(Map<String, dynamic> json) {
    return LeaderboardFamily(
      rank: json['rank'] ?? 0,
      familyId: json['family_id'] ?? '',
      familyName: json['family_name'] ?? '',
      familyAvatar: json['family_avatar'] ?? '',
      stars: json['stars'] ?? 0,
      coins: json['coins'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      members: (json['members'] as List<dynamic>?)
          ?.map((member) => FamilyMember.fromJson(member))
          .toList() ?? [],
    );
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}