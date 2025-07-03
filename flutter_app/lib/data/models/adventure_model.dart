
// lib/data/models/adventure_model.dart
import 'package:equatable/equatable.dart';

class Adventure extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final List<Challenge> challenges;
  final int starsReward;
  final int coinsReward;
  final AdventureProgress? userProgress;

  const Adventure({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.challenges,
    required this.starsReward,
    required this.coinsReward,
    this.userProgress,
  });

  factory Adventure.fromJson(Map<String, dynamic> json) {
    return Adventure(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: json['endDate'] != null 
          ? DateTime.tryParse(json['endDate']) 
          : null,
      challenges: (json['challenges'] as List<dynamic>? ?? [])
          .map((challenge) => Challenge.fromJson(challenge))
          .toList(),
      starsReward: json['starsReward'] ?? 0,
      coinsReward: json['coinsReward'] ?? 0,
      userProgress: json['userProgress'] != null 
          ? AdventureProgress.fromJson(json['userProgress'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'challenges': challenges.map((challenge) => challenge.toJson()).toList(),
      'starsReward': starsReward,
      'coinsReward': coinsReward,
      'userProgress': userProgress?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startDate,
        endDate,
        challenges,
        starsReward,
        coinsReward,
        userProgress,
      ];
}

class Challenge extends Equatable {
  final String id;
  final String title;
  final String content;
  final int starsReward;
  final int coinsReward;

  const Challenge({
    required this.id,
    required this.title,
    required this.content,
    required this.starsReward,
    required this.coinsReward,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      starsReward: json['starsReward'] ?? 0,
      coinsReward: json['coinsReward'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'starsReward': starsReward,
      'coinsReward': coinsReward,
    };
  }

  @override
  List<Object?> get props => [id, title, content, starsReward, coinsReward];
}

class AdventureProgress extends Equatable {
  final List<ChallengeProgress> challenges;
  final bool isAdventureCompleted;
  final String status;
  final double progress;

  const AdventureProgress({
    required this.challenges,
    required this.isAdventureCompleted,
    required this.status,
    required this.progress,
  });

  factory AdventureProgress.fromJson(Map<String, dynamic> json) {
    return AdventureProgress(
      challenges: (json['challenges'] as List<dynamic>? ?? [])
          .map((challenge) => ChallengeProgress.fromJson(challenge))
          .toList(),
      isAdventureCompleted: json['isAdventureCompleted'] ?? false,
      status: json['status'] ?? 'in-progress',
      progress: (json['progress'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenges': challenges.map((challenge) => challenge.toJson()).toList(),
      'isAdventureCompleted': isAdventureCompleted,
      'status': status,
      'progress': progress,
    };
  }

  @override
  List<Object?> get props => [challenges, isAdventureCompleted, status, progress];
}

class ChallengeProgress extends Equatable {
  final String challengeId;
  final bool isCompleted;
  final DateTime? completedAt;

  const ChallengeProgress({
    required this.challengeId,
    required this.isCompleted,
    this.completedAt,
  });

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) {
    return ChallengeProgress(
      challengeId: json['challengeId'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.tryParse(json['completedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [challengeId, isCompleted, completedAt];
}