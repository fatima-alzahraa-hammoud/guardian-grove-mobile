// lib/data/models/goal_model.dart
import 'package:equatable/equatable.dart';

class Goal extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // 'personal' or 'family'
  final List<Task> tasks;
  final int nbOfTasksCompleted;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final GoalRewards rewards;
  final double progress;

  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.tasks,
    required this.nbOfTasksCompleted,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
    required this.rewards,
    required this.progress,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'personal',
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((task) => Task.fromJson(task))
          .toList(),
      nbOfTasksCompleted: json['nbOfTasksCompleted'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      completedAt: json['completedAt'] != null 
          ? DateTime.tryParse(json['completedAt']) 
          : null,
      dueDate: json['dueDate'] != null 
          ? DateTime.tryParse(json['dueDate']) 
          : null,
      rewards: GoalRewards.fromJson(json['rewards'] ?? {}),
      progress: (json['progress'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'type': type,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'nbOfTasksCompleted': nbOfTasksCompleted,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'rewards': rewards.toJson(),
      'progress': progress,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        tasks,
        nbOfTasksCompleted,
        isCompleted,
        createdAt,
        completedAt,
        dueDate,
        rewards,
        progress,
      ];
}

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type;
  final TaskRewards rewards;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.rewards,
    required this.isCompleted,
    this.createdAt,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'personal',
      rewards: TaskRewards.fromJson(json['rewards'] ?? {}),
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.tryParse(json['completedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'type': type,
      'rewards': rewards.toJson(),
      'isCompleted': isCompleted,
      'createdAt': createdAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        rewards,
        isCompleted,
        createdAt,
        completedAt,
      ];
}

class GoalRewards extends Equatable {
  final int stars;
  final int coins;
  final String? achievementName;
  final String? achievementId;

  const GoalRewards({
    required this.stars,
    required this.coins,
    this.achievementName,
    this.achievementId,
  });

  factory GoalRewards.fromJson(Map<String, dynamic> json) {
    return GoalRewards(
      stars: json['stars'] ?? 0,
      coins: json['coins'] ?? 0,
      achievementName: json['achievementName'],
      achievementId: json['achievementId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stars': stars,
      'coins': coins,
      'achievementName': achievementName,
      'achievementId': achievementId,
    };
  }

  @override
  List<Object?> get props => [stars, coins, achievementName, achievementId];
}

class TaskRewards extends Equatable {
  final int stars;
  final int coins;

  const TaskRewards({
    required this.stars,
    required this.coins,
  });

  factory TaskRewards.fromJson(Map<String, dynamic> json) {
    return TaskRewards(
      stars: json['stars'] ?? 0,
      coins: json['coins'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stars': stars,
      'coins': coins,
    };
  }

  @override
  List<Object?> get props => [stars, coins];
}