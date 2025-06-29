import 'package:equatable/equatable.dart';

class Family extends Equatable {
  final String id;
  final String familyName; // Backend: familyName
  final String familyAvatar; // Backend: familyAvatar
  final List<FamilyMember> members;

  const Family({
    required this.id,
    required this.familyName,
    required this.familyAvatar,
    required this.members,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['_id'] ?? '',
      familyName: json['familyName'] ?? json['name'] ?? '',
      familyAvatar: json['familyAvatar'] ?? '',
      members:
          (json['members'] as List<dynamic>? ?? [])
              .map((m) => FamilyMember.fromJson(m as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'familyName': familyName,
    'familyAvatar': familyAvatar,
    'members': members.map((m) => m.toJson()).toList(),
  };

  @override
  List<Object?> get props => [id, familyName, familyAvatar, members];
}

class FamilyMember extends Equatable {
  final String id;
  final String name;
  final String role; // 'parent', 'admin', or 'child'
  final String gender; // 'male' or 'female'
  final String avatar;
  final DateTime? birthday; // Optional, not always present in backend
  final List<String> interests;
  final int coins; // NEW: per-member coins
  final int rankInFamily; // NEW: per-member rank

  const FamilyMember({
    required this.id,
    required this.name,
    required this.role,
    required this.gender,
    required this.avatar,
    this.birthday,
    this.interests = const [],
    this.coins = 0,
    this.rankInFamily = 0,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      gender: json['gender'] ?? '',
      avatar: json['avatar'] ?? '',
      birthday:
          json['birthday'] != null && json['birthday'] != ''
              ? DateTime.tryParse(json['birthday'])
              : null,
      interests:
          (json['interests'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      coins: json['coins'] ?? 0,
      rankInFamily: json['rankInFamily'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'role': role,
    'gender': gender,
    'avatar': avatar,
    if (birthday != null) 'birthday': birthday!.toIso8601String(),
    'interests': interests,
    'coins': coins,
    'rankInFamily': rankInFamily,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    role,
    gender,
    avatar,
    birthday,
    interests,
    coins,
    rankInFamily,
  ];
}
