import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime birthday;
  final String dailyMessage;
  final String gender;
  final String role;
  final String avatar;
  final List<String> interests;
  final DateTime memberSince;
  final String currentLocation;
  final int stars;
  final int coins;
  final int nbOfTasksCompleted;
  final int rankInFamily;
  final String? familyId;
  final bool isTempPassword;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.birthday,
    required this.dailyMessage,
    required this.gender,
    required this.role,
    required this.avatar,
    required this.interests,
    required this.memberSince,
    required this.currentLocation,
    required this.stars,
    required this.coins,
    required this.nbOfTasksCompleted,
    required this.rankInFamily,
    this.familyId,
    this.isTempPassword = false,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      birthday:
          json['birthday'] != null
              ? DateTime.parse(json['birthday'])
              : DateTime.now(),
      dailyMessage: json['dailyMessage'] ?? 'You are shining💫!',
      gender: json['gender'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      memberSince:
          json['memberSince'] != null
              ? DateTime.parse(json['memberSince'])
              : DateTime.now(),
      currentLocation: json['currentLocation'] ?? 'not specified',
      stars: json['stars'] ?? 0,
      coins: json['coins'] ?? 0,
      nbOfTasksCompleted: json['nbOfTasksCompleted'] ?? 0,
      rankInFamily: json['rankInFamily'] ?? 0,
      familyId: json['familyId'],
      isTempPassword: json['isTempPassword'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'birthday': birthday.toIso8601String(),
      'dailyMessage': dailyMessage,
      'gender': gender,
      'role': role,
      'avatar': avatar,
      'interests': interests,
      'memberSince': memberSince.toIso8601String(),
      'currentLocation': currentLocation,
      'stars': stars,
      'coins': coins,
      'nbOfTasksCompleted': nbOfTasksCompleted,
      'rankInFamily': rankInFamily,
      'familyId': familyId,
      'isTempPassword': isTempPassword,
    };
  }

  // Add a copyWith method for updating fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? birthday,
    String? dailyMessage,
    String? gender,
    String? role,
    String? avatar,
    List<String>? interests,
    DateTime? memberSince,
    String? currentLocation,
    int? stars,
    int? coins,
    int? nbOfTasksCompleted,
    int? rankInFamily,
    String? familyId,
    bool? isTempPassword,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      dailyMessage: dailyMessage ?? this.dailyMessage,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      interests: interests ?? this.interests,
      memberSince: memberSince ?? this.memberSince,
      currentLocation: currentLocation ?? this.currentLocation,
      stars: stars ?? this.stars,
      coins: coins ?? this.coins,
      nbOfTasksCompleted: nbOfTasksCompleted ?? this.nbOfTasksCompleted,
      rankInFamily: rankInFamily ?? this.rankInFamily,
      familyId: familyId ?? this.familyId,
      isTempPassword: isTempPassword ?? this.isTempPassword,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    birthday,
    dailyMessage,
    gender,
    role,
    avatar,
    interests,
    memberSince,
    currentLocation,
    stars,
    coins,
    nbOfTasksCompleted,
    rankInFamily,
    familyId,
    isTempPassword,
  ];
}

// Request models for login and register
class LoginRequest extends Equatable {
  final String name;
  final String email;
  final String password;

  const LoginRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'password': password};
  }

  @override
  List<Object> get props => [name, email, password];
}

class RegisterRequest extends Equatable {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final DateTime birthday;
  final String gender;
  final String role;
  final String avatar;
  final List<String> interests;
  final String familyName;
  final String familyAvatar;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.birthday,
    required this.gender,
    required this.role,
    required this.avatar,
    required this.interests,
    required this.familyName,
    required this.familyAvatar,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'birthday': birthday.toIso8601String(),
      'gender': gender,
      'role': role,
      'avatar': avatar,
      'interests': interests,
      'familyName': familyName,
      'familyAvatar': familyAvatar,
    };
  }

  @override
  List<Object> get props => [
    name,
    email,
    password,
    confirmPassword,
    birthday,
    gender,
    role,
    avatar,
    interests,
    familyName,
    familyAvatar,
  ];
}

// Response model for login/register
class AuthResponse extends Equatable {
  final UserModel user;
  final String token;
  final bool requiresPasswordChange;
  final String message;

  const AuthResponse({
    required this.user,
    required this.token,
    required this.requiresPasswordChange,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'] ?? '',
      requiresPasswordChange: json['requiresPasswordChange'] ?? false,
      message: json['message'] ?? '',
    );
  }

  @override
  List<Object> get props => [user, token, requiresPasswordChange, message];
}

// Request model for adding family member
class AddMemberRequest extends Equatable {
  final String name;
  final DateTime birthday;
  final String gender;
  final String role;
  final String avatar;
  final List<String> interests;

  const AddMemberRequest({
    required this.name,
    required this.birthday,
    required this.gender,
    required this.role,
    required this.avatar,
    required this.interests,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthday': birthday.toIso8601String(),
      'gender': gender,
      'role': role,
      'avatar': avatar,
      'interests': interests,
    };
  }

  @override
  List<Object> get props => [name, birthday, gender, role, avatar, interests];
}

// Request model for changing password
class ChangePasswordRequest extends Equatable {
  final String? userId;
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    this.userId,
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
    if (userId != null) {
      data['userId'] = userId!;
    }
    return data;
  }

  @override
  List<Object?> get props => [
    userId,
    oldPassword,
    newPassword,
    confirmPassword,
  ];
}
