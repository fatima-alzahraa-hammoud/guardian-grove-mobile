// lib/data/repositories/goals_adventures_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/storage_service.dart';
import '../models/goal_model.dart';
import '../models/adventure_model.dart';

class GoalsAdventuresRepository {
  final DioClient _dioClient;

  GoalsAdventuresRepository(this._dioClient);

  // ============= GOALS METHODS =============

  /// Fetch user goals from API - CORRECTED TO MATCH YOUR BACKEND
  Future<List<Goal>> fetchGoals() async {
    try {
      final user = StorageService.getUser();
      if (user == null) throw Exception('User not found');

      debugPrint('🎯 Fetching goals for user: ${user.id}');

      // FIXED: Your backend expects POST /userGoals/goals with userId in body
      final response = await _dioClient.post(
        '/userGoals/goals',  // This matches your backend: router.post("/goals", authMiddleware, getGoals)
        data: {'userId': user.id},
      );

      debugPrint('📦 Goals Response: ${response.statusCode}');
      debugPrint('📦 Goals Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle your backend response structure
        List<dynamic> goalsData = [];
        if (data is Map<String, dynamic>) {
          // Your backend likely returns: { "goals": [...] } or { "data": [...] }
          goalsData = data['goals'] as List<dynamic>? ?? 
                     data['data'] as List<dynamic>? ?? 
                     data['userGoals'] as List<dynamic>? ?? 
                     [];
        } else if (data is List) {
          goalsData = data;
        }

        debugPrint('📦 Processing ${goalsData.length} goals');

        final goals = goalsData.map((goalJson) {
          debugPrint('📦 Goal JSON: $goalJson');
          return Goal.fromJson(goalJson);
        }).toList();

        // Cache the goals
        await StorageService.cacheGoals(goalsData);

        debugPrint('✅ Successfully fetched ${goals.length} goals');
        return goals;
      } else {
        throw Exception('Failed to fetch goals: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Network error fetching goals: ${e.message}');
      debugPrint('❌ Response status: ${e.response?.statusCode}');
      debugPrint('❌ Response data: ${e.response?.data}');
      debugPrint('❌ Request path: ${e.requestOptions.path}');

      // Try to return cached goals if network fails
      final cachedGoals = StorageService.getCachedGoals();
      if (cachedGoals != null) {
        debugPrint('📦 Returning ${cachedGoals.length} cached goals');
        return cachedGoals.map((goalJson) => Goal.fromJson(goalJson)).toList();
      }

      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error fetching goals: $e');
      rethrow;
    }
  }

  /// Create a new goal - CORRECTED TO MATCH YOUR BACKEND
  Future<Goal> createGoal({
    required String title,
    required String description,
    String type = 'personal',
    DateTime? dueDate,
    Map<String, dynamic>? rewards,
  }) async {
    try {
      final user = StorageService.getUser();
      if (user == null) throw Exception('User not found');

      debugPrint('🎯 Creating new goal: $title');

      // FIXED: Your backend expects POST /userGoals/ 
      final response = await _dioClient.post(
        '/userGoals/',  // This matches your backend: router.post("/", authMiddleware, createGoal)
        data: {
          'userId': user.id,
          'title': title,
          'description': description,
          'type': type,
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
          if (rewards != null) 'rewards': rewards,
        },
      );

      debugPrint('📦 Create Goal Response: ${response.statusCode}');
      debugPrint('📦 Create Goal Data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        final goalData = data['goal'] ?? data['data'] ?? data;
        final goal = Goal.fromJson(goalData);

        debugPrint('✅ Successfully created goal: ${goal.title}');
        return goal;
      } else {
        throw Exception('Failed to create goal: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error creating goal: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Generate AI goal - CORRECTED TO MATCH YOUR BACKEND
  Future<void> generateAIGoal() async {
    try {
      final user = StorageService.getUser();
      if (user == null) throw Exception('User not found');

      debugPrint('🤖 Generating AI goal for user: ${user.id}');

      // FIXED: Your backend expects POST /users/generateGoals
      final response = await _dioClient.post(
        '/users/generateGoals',  // This matches your backend: router.post("/generateGoals", regenerateGoalsAndTasksRoute)
        data: {'userId': user.id},
      );

      debugPrint('📦 AI Goal Response: ${response.statusCode}');
      debugPrint('📦 AI Goal Data: ${response.data}');

      if (response.statusCode == 200) {
        debugPrint('✅ Successfully generated AI goal');
      } else {
        throw Exception('Failed to generate AI goal: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error generating AI goal: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Complete a task - CORRECTED TO MATCH YOUR BACKEND
  Future<Map<String, dynamic>> completeTask({
    required String goalId,
    required String taskId,
  }) async {
    try {
      final user = StorageService.getUser();
      if (user == null) throw Exception('User not found');

      debugPrint('✅ Completing task: $taskId in goal: $goalId');

      // FIXED: Your backend expects POST /userGoals/taskDone
      final response = await _dioClient.post(
        '/userGoals/taskDone',  // This matches your backend: router.post("/taskDone", authMiddleware, completeTask)
        data: {'userId': user.id, 'goalId': goalId, 'taskId': taskId},
      );

      debugPrint('📦 Complete Task Response: ${response.statusCode}');
      debugPrint('📦 Complete Task Data: ${response.data}');

      if (response.statusCode == 200) {
        final result = response.data;

        // Update user coins and stars in storage
        if (result['task'] != null && result['task']['rewards'] != null) {
          final taskRewards = result['task']['rewards'];
          final currentUser = StorageService.getUser()!;

          await StorageService.updateUserFields({
            'stars': currentUser.stars + (taskRewards['stars'] ?? 0),
            'coins': currentUser.coins + (taskRewards['coins'] ?? 0),
          });
        }

        debugPrint('✅ Task completed successfully');
        return result;
      } else {
        throw Exception('Failed to complete task: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error completing task: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get monthly stats - CORRECTED TO MATCH YOUR BACKEND
  Future<Map<String, dynamic>> getMonthlyStats() async {
    try {
      debugPrint('📊 Fetching monthly stats');

      // FIXED: Your backend expects GET /userGoals/monthlyStats
      final response = await _dioClient.get('/userGoals/monthlyStats');

      debugPrint('📦 Monthly Stats Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final stats = response.data;
        debugPrint('✅ Successfully fetched monthly stats');
        return stats;
      } else {
        throw Exception('Failed to fetch monthly stats: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error fetching monthly stats: ${e.message}');
      rethrow;
    }
  }

  // ============= ADVENTURES METHODS =============

  /// Fetch all adventures - CORRECTED TO MATCH YOUR BACKEND
  Future<List<Adventure>> fetchAdventures() async {
    try {
      debugPrint('🗺️ Fetching adventures...');

      // FIXED: Your backend expects GET /adventures/
      final response = await _dioClient.get('/adventures/');  // This matches your backend: router.get("/", authMiddleware, getAllAdventures)

      debugPrint('📦 Adventures Response: ${response.statusCode}');
      debugPrint('📦 Adventures Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle your backend response structure
        List<dynamic> adventuresData = [];
        if (data is Map<String, dynamic>) {
          // Your backend likely returns: { "adventures": [...] } or just an array
          adventuresData = data['adventures'] as List<dynamic>? ?? 
                          data['data'] as List<dynamic>? ?? 
                          [];
        } else if (data is List) {
          adventuresData = data;
        }

        debugPrint('📦 Processing ${adventuresData.length} adventures');

        final adventures = adventuresData.map((adventureJson) {
          debugPrint('📦 Adventure JSON: $adventureJson');
          return Adventure.fromJson(adventureJson);
        }).toList();

        // Cache the adventures
        await StorageService.cacheAdventures(adventuresData);

        debugPrint('✅ Successfully fetched ${adventures.length} adventures');
        return adventures;
      } else {
        throw Exception('Failed to fetch adventures: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Network error fetching adventures: ${e.message}');
      debugPrint('❌ Response status: ${e.response?.statusCode}');
      debugPrint('❌ Response data: ${e.response?.data}');
      debugPrint('❌ Request path: ${e.requestOptions.path}');

      // Try to return cached adventures if network fails
      final cachedAdventures = StorageService.getCachedAdventures();
      if (cachedAdventures != null) {
        debugPrint('📦 Returning ${cachedAdventures.length} cached adventures');
        return cachedAdventures
            .map((adventureJson) => Adventure.fromJson(adventureJson))
            .toList();
      }

      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error fetching adventures: $e');
      rethrow;
    }
  }

  /// Get user's adventure progress - CORRECTED TO MATCH YOUR BACKEND
  Future<List<AdventureProgress>> getUserAdventureProgress() async {
    try {
      debugPrint('🗺️ Fetching user adventure progress...');

      // FIXED: Your backend expects GET /users/adventures
      final response = await _dioClient.get('/users/adventures');

      debugPrint('📦 Adventure Progress Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle your backend response structure
        List<dynamic> progressData = [];
        if (data is Map<String, dynamic>) {
          progressData = data['adventures'] as List<dynamic>? ?? 
                        data['Adventure'] as List<dynamic>? ?? 
                        data['data'] as List<dynamic>? ?? 
                        [];
        } else if (data is List) {
          progressData = data;
        }

        final progress = progressData
            .map((progressJson) => AdventureProgress.fromJson(progressJson))
            .toList();

        debugPrint('✅ Successfully fetched adventure progress');
        return progress;
      } else {
        throw Exception('Failed to fetch adventure progress: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error fetching adventure progress: ${e.message}');
      rethrow;
    }
  }

  /// Start an adventure - CORRECTED TO MATCH YOUR BACKEND
  Future<void> startAdventure(String adventureId) async {
    try {
      debugPrint('🗺️ Starting adventure: $adventureId');

      // FIXED: Your backend expects POST /users/adventure
      final response = await _dioClient.post(
        '/users/adventure',
        data: {'adventureId': adventureId},
      );

      debugPrint('📦 Start Adventure Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Successfully started adventure');
      } else {
        throw Exception('Failed to start adventure: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error starting adventure: ${e.message}');
      rethrow;
    }
  }

  /// Complete a challenge - CORRECTED TO MATCH YOUR BACKEND
  Future<Map<String, dynamic>> completeChallenge({
    required String adventureId,
    required String challengeId,
  }) async {
    try {
      debugPrint('⚔️ Completing challenge: $challengeId in adventure: $adventureId');

      // FIXED: Your backend expects POST /users/adventure/challenge
      final response = await _dioClient.post(
        '/users/adventure/challenge',
        data: {'adventureId': adventureId, 'challengeId': challengeId},
      );

      debugPrint('📦 Complete Challenge Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final result = response.data;

        // Update user coins and stars in storage if rewards provided
        if (result['rewards'] != null) {
          final rewards = result['rewards'];
          final currentUser = StorageService.getUser()!;

          await StorageService.updateUserFields({
            'stars': currentUser.stars + (rewards['stars'] ?? 0),
            'coins': currentUser.coins + (rewards['coins'] ?? 0),
          });
        }

        debugPrint('✅ Challenge completed successfully');
        return result;
      } else {
        throw Exception('Failed to complete challenge: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error completing challenge: ${e.message}');
      rethrow;
    }
  }

  /// Generate AI question for task completion - CORRECTED TO MATCH YOUR BACKEND
  Future<String> generateTaskQuestion(String taskDescription) async {
    try {
      final user = StorageService.getUser();
      if (user == null) throw Exception('User not found');

      debugPrint('🤖 Generating AI question for task: $taskDescription');

      // FIXED: Your backend has a typo in the endpoint name
      final response = await _dioClient.post(
        '/users/generateQusetion',  // Note: Your backend has this typo
        data: {'userId': user.id, 'taskDescription': taskDescription},
      );

      debugPrint('📦 Generate Question Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final question = data['question'] ?? data['data'] ?? '';
        debugPrint('✅ Successfully generated AI question');
        return question;
      } else {
        throw Exception('Failed to generate question: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error generating question: ${e.message}');
      rethrow;
    }
  }

  /// Check answer with AI - CORRECTED TO MATCH YOUR BACKEND
  Future<bool> checkAnswer({
    required String question,
    required String userAnswer,
  }) async {
    try {
      final user = StorageService.getUser();
      if (user == null) throw Exception('User not found');

      debugPrint('🤖 Checking answer with AI');

      // FIXED: Your backend expects POST /users/checkAnswer
      final response = await _dioClient.post(
        '/users/checkAnswer',
        data: {
          'userId': user.id,
          'question': question,
          'userAnswer': userAnswer,
        },
      );

      debugPrint('📦 Check Answer Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final isCorrect = data['questionAnswered'] ?? data['correct'] ?? false;
        debugPrint('✅ Answer checked: ${isCorrect ? 'Correct' : 'Incorrect'}');
        return isCorrect;
      } else {
        throw Exception('Failed to check answer: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Error checking answer: ${e.message}');
      rethrow;
    }
  }
}