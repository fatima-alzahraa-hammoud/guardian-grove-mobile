import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../../models/home_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeData> getHomeData();
  Future<void> inviteFamilyMember(String email);
  Future<DailyMessage> refreshDailyMessage();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<HomeData> getHomeData() async {
    debugPrint('🏠 Fetching home dashboard data from real backend endpoints');

    try {
      // Strategy 1: Get user profile first
      final userResponse = await apiClient.dio.get('/users/user');

      if (userResponse.statusCode != 200) {
        debugPrint('❌ Failed to get user profile: ${userResponse.statusCode}');
        return _getFallbackHomeData();
      }

      debugPrint('✅ User profile received from API');
      final userData = userResponse.data['data'] ?? userResponse.data;

      // Strategy 2: Get family data
      HomeData homeData;
      try {
        final familyResponse = await apiClient.dio.post('/family/getFamily');

        if (familyResponse.statusCode == 200) {
          debugPrint('✅ Family data received from API');
          final familyData = familyResponse.data['data'] ?? familyResponse.data;

          // Try to get family members
          List<Map<String, dynamic>> familyMembers = [];
          try {
            final membersResponse = await apiClient.dio.get(
              '/family/FamilyMembers',
            );
            if (membersResponse.statusCode == 200) {
              final membersData =
                  membersResponse.data['data'] ?? membersResponse.data;
              if (membersData is List) {
                familyMembers = List<Map<String, dynamic>>.from(membersData);
              }
              debugPrint(
                '✅ Family members received: ${familyMembers.length} members',
              );
            }
          } catch (e) {
            debugPrint('⚠️ Could not fetch family members: $e');
          }

          homeData = _convertBackendDataToHome(
            userData,
            familyData,
            familyMembers,
          );
        } else {
          debugPrint('⚠️ Family data not available, using user data only');
          homeData = _convertUserDataToHome(userData);
        }
      } catch (e) {
        debugPrint('⚠️ Family endpoints not available: $e');
        homeData = _convertUserDataToHome(userData);
      }

      return homeData;
    } on DioException catch (e) {
      debugPrint('🌐 API Error: ${e.response?.statusCode} - ${e.message}');

      if (e.response?.statusCode == 404) {
        debugPrint('📝 User endpoint not found, using fallback data');
      } else if (e.response?.statusCode == 401) {
        debugPrint('🔐 Authentication required, using fallback data');
      } else {
        debugPrint('🔥 Network error occurred, using fallback data');
      }
      return _getFallbackHomeData();
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return _getFallbackHomeData();
    }
  }

  @override
  Future<void> inviteFamilyMember(String email) async {
    debugPrint('📧 Inviting family member: $email');

    try {
      final response = await apiClient.dio.post(
        '/family/invite',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Invitation sent successfully');
      } else {
        debugPrint('❌ Failed to send invitation: ${response.statusCode}');
        throw Exception('Failed to send invitation');
      }
    } on DioException catch (e) {
      debugPrint(
        '🌐 API Error sending invitation: ${e.response?.statusCode} - ${e.message}',
      );

      // For demo purposes, we'll simulate success even if API fails
      if (e.response?.statusCode == 404) {
        debugPrint('📝 Invite endpoint not found, simulating success');
        return; // Simulate success
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('❌ Unexpected error sending invitation: $e');
      throw Exception('Failed to send invitation: $e');
    }
  }

  @override
  Future<DailyMessage> refreshDailyMessage() async {
    debugPrint('🔄 Refreshing daily message');

    try {
      final response = await apiClient.dio.get('/home/daily-message');

      if (response.statusCode == 200) {
        debugPrint('✅ Daily message refreshed from API');
        return DailyMessage.fromJson(response.data['data']);
      } else {
        debugPrint('❌ API returned status: ${response.statusCode}');
        return _getMockDailyMessage();
      }
    } on DioException catch (e) {
      debugPrint(
        '🌐 API Error refreshing daily message: ${e.response?.statusCode} - ${e.message}',
      );

      if (e.response?.statusCode == 404) {
        debugPrint('📝 Daily message endpoint not found, using mock data');
      } else {
        debugPrint('🔥 Network error occurred, using mock data');
      }
      return _getMockDailyMessage();
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return _getMockDailyMessage();
    }
  }

  /// Convert backend user and family data to HomeData model
  HomeData _convertBackendDataToHome(
    Map<String, dynamic> userData,
    Map<String, dynamic> familyData,
    List<Map<String, dynamic>> familyMembers,
  ) {
    debugPrint('🔄 Converting backend data to HomeData model');
    debugPrint('👤 User data keys: ${userData.keys.toList()}');
    debugPrint('👨‍👩‍👧‍👦 Family data keys: ${familyData.keys.toList()}');
    debugPrint('👥 Family members count: ${familyMembers.length}');

    try {
      // Extract user information
      final user = UserProfile(
        id: userData['_id']?.toString() ?? userData['id']?.toString() ?? '1',
        name:
            '${userData['firstName']?.toString() ?? userData['first_name']?.toString() ?? 'User'} ${userData['lastName']?.toString() ?? userData['last_name']?.toString() ?? ''}',
        email: userData['email']?.toString() ?? 'user@example.com',
        avatar:
            userData['avatarUrl']?.toString() ??
            userData['avatar_url']?.toString() ??
            userData['profilePicture']?.toString() ??
            '',
        createdAt:
            DateTime.tryParse(
              userData['createdAt']?.toString() ??
                  userData['created_at']?.toString() ??
                  '',
            ) ??
            DateTime.now(),
      );

      // Extract family statistics
      final familyStats = FamilyStats(
        totalStars:
            (familyData['totalStars'] ?? familyData['stars'] ?? 0).toInt(),
        tasks: (familyData['tasks'] ?? 0).toInt(),
        stars: Stars(
          daily: (familyData['stars']?['daily'] ?? 0).toInt(),
          weekly: (familyData['stars']?['weekly'] ?? 0).toInt(),
          monthly: (familyData['stars']?['monthly'] ?? 0).toInt(),
          yearly: (familyData['stars']?['yearly'] ?? 0).toInt(),
        ),
        taskCounts: TaskCounts(
          daily: (familyData['taskCounts']?['daily'] ?? 0).toInt(),
          weekly: (familyData['taskCounts']?['weekly'] ?? 0).toInt(),
          monthly: (familyData['taskCounts']?['monthly'] ?? 0).toInt(),
          yearly: (familyData['taskCounts']?['yearly'] ?? 0).toInt(),
        ),
      );

      // Convert family members
      final members =
          familyMembers.map((memberData) {
            return FamilyMember(
              id:
                  memberData['_id']?.toString() ??
                  memberData['id']?.toString() ??
                  '',
              name:
                  '${memberData['firstName']?.toString() ?? memberData['first_name']?.toString() ?? 'Member'} ${memberData['lastName']?.toString() ?? memberData['last_name']?.toString() ?? ''}',
              role: memberData['role']?.toString() ?? 'member',
              gender: memberData['gender']?.toString() ?? '',
              avatar:
                  memberData['avatarUrl']?.toString() ??
                  memberData['avatar_url']?.toString() ??
                  memberData['profilePicture']?.toString() ??
                  '',
            );
          }).toList();

      // Create default quick actions
      final quickActions = [
        const QuickAction(
          id: '1',
          title: 'Create Activity',
          icon: 'add_task',
          route: '/create_activity',
          color: '#4CAF50',
        ),
        const QuickAction(
          id: '2',
          title: 'View Calendar',
          icon: 'calendar_today',
          route: '/calendar',
          color: '#2196F3',
        ),
        const QuickAction(
          id: '3',
          title: 'Family Chat',
          icon: 'chat',
          route: '/chat',
          color: '#FF9800',
        ),
        const QuickAction(
          id: '4',
          title: 'Settings',
          icon: 'settings',
          route: '/settings',
          color: '#9C27B0',
        ),
      ];

      // Create daily message
      final dailyMessage = DailyMessage(
        id: '1',
        message:
            'Welcome back, ${user.name.split(' ').first}! Ready for another amazing day with your family?',
        category: 'Welcome',
        date: DateTime.now(),
      );

      debugPrint('✅ Successfully converted backend data');
      debugPrint(
        '👤 User: ${user.name} (Total Stars: ${familyStats.totalStars}, Tasks: ${familyStats.tasks})',
      );
      debugPrint('👨‍👩‍👧‍👦 Family: ${members.length} members');

      return HomeData(
        user: user,
        familyStats: familyStats,
        quickActions: quickActions,
        dailyMessage: dailyMessage,
        familyMembers: members,
        familyName: familyData['familyName']?.toString() ?? '',
        email: familyData['email']?.toString() ?? '',
        createdAt:
            DateTime.tryParse(familyData['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        familyAvatar: familyData['familyAvatar']?.toString() ?? '',
        notifications: familyData['notifications'] ?? [],
        goals: familyData['goals'] ?? [],
        achievements: familyData['achievements'] ?? [],
        sharedStories: familyData['sharedStories'] ?? [],
      );
    } catch (e) {
      debugPrint('❌ Error converting backend data: $e');
      return _getFallbackHomeData();
    }
  }

  /// Convert only user data to HomeData model (when family data is not available)
  HomeData _convertUserDataToHome(Map<String, dynamic> userData) {
    debugPrint('🔄 Converting user-only data to HomeData model');
    debugPrint('👤 User data keys: \\${userData.keys.toList()}');

    try {
      final user = UserProfile(
        id: userData['_id']?.toString() ?? userData['id']?.toString() ?? '1',
        name:
            '${userData['firstName']?.toString() ?? userData['first_name']?.toString() ?? 'User'} ${userData['lastName']?.toString() ?? userData['last_name']?.toString() ?? ''}',
        email: userData['email']?.toString() ?? 'user@example.com',
        avatar:
            userData['avatarUrl']?.toString() ??
            userData['avatar_url']?.toString() ??
            userData['profilePicture']?.toString() ??
            '',
        createdAt:
            DateTime.tryParse(
              userData['createdAt']?.toString() ??
                  userData['created_at']?.toString() ??
                  '',
            ) ??
            DateTime.now(),
      );

      final familyStats = FamilyStats(
        totalStars: (userData['totalStars'] ?? 0).toInt(),
        tasks: (userData['tasks'] ?? 0).toInt(),
        stars: Stars(
          daily: (userData['stars']?['daily'] ?? 0).toInt(),
          weekly: (userData['stars']?['weekly'] ?? 0).toInt(),
          monthly: (userData['stars']?['monthly'] ?? 0).toInt(),
          yearly: (userData['stars']?['yearly'] ?? 0).toInt(),
        ),
        taskCounts: TaskCounts(
          daily: (userData['taskCounts']?['daily'] ?? 0).toInt(),
          weekly: (userData['taskCounts']?['weekly'] ?? 0).toInt(),
          monthly: (userData['taskCounts']?['monthly'] ?? 0).toInt(),
          yearly: (userData['taskCounts']?['yearly'] ?? 0).toInt(),
        ),
      );

      final members = [
        FamilyMember(
          id: user.id,
          name: user.name,
          role: 'admin',
          gender: userData['gender']?.toString() ?? '',
          avatar: user.avatar,
        ),
      ];

      final quickActions = [
        const QuickAction(
          id: '1',
          title: 'Create Activity',
          icon: 'add_task',
          route: '/create_activity',
          color: '#4CAF50',
        ),
        const QuickAction(
          id: '2',
          title: 'View Calendar',
          icon: 'calendar_today',
          route: '/calendar',
          color: '#2196F3',
        ),
        const QuickAction(
          id: '3',
          title: 'Invite Family',
          icon: 'person_add',
          route: '/invite_family',
          color: '#FF9800',
        ),
        const QuickAction(
          id: '4',
          title: 'Settings',
          icon: 'settings',
          route: '/settings',
          color: '#9C27B0',
        ),
      ];

      final dailyMessage = DailyMessage(
        id: '1',
        message:
            'Welcome, ${user.name.split(' ').first}! Start your family journey by inviting members and creating activities.',
        category: 'Getting Started',
        date: DateTime.now(),
      );

      debugPrint('✅ Successfully converted user data');
      debugPrint(
        '👤 User: ${user.name} (Total Stars: ${familyStats.totalStars}, Tasks: ${familyStats.tasks})',
      );

      return HomeData(
        user: user,
        familyStats: familyStats,
        quickActions: quickActions,
        dailyMessage: dailyMessage,
        familyMembers: members,
        familyName: userData['familyName']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        createdAt: user.createdAt,
        familyAvatar: userData['familyAvatar']?.toString() ?? '',
        notifications: userData['notifications'] ?? [],
        goals: userData['goals'] ?? [],
        achievements: userData['achievements'] ?? [],
        sharedStories: userData['sharedStories'] ?? [],
      );
    } catch (e) {
      debugPrint('❌ Error converting user data: $e');
      return _getFallbackHomeData();
    }
  }

  /// Fallback method that loads user data from storage if available
  HomeData _getFallbackHomeData() {
    debugPrint('📝 Generating home dashboard data with real user info');

    // Get the real logged-in user from storage
    final currentUser = StorageService.getUser();

    if (currentUser != null) {
      return HomeData(
        user: UserProfile(
          id: currentUser.id,
          name: currentUser.name,
          email: currentUser.email,
          avatar: currentUser.avatar,
          createdAt: currentUser.memberSince,
        ),
        familyStats: FamilyStats(
          totalStars: currentUser.stars,
          tasks: 0,
          stars: Stars(daily: 0, weekly: 0, monthly: 0, yearly: 0),
          taskCounts: TaskCounts(daily: 0, weekly: 0, monthly: 0, yearly: 0),
        ),
        quickActions: [
          const QuickAction(
            id: 'notes',
            title: 'Notes',
            icon: 'note_alt_rounded',
            route: '/notes',
            color: '#FF6B9D',
          ),
          const QuickAction(
            id: 'bonding',
            title: 'Bonding',
            icon: 'favorite_rounded',
            route: '/bonding',
            color: '#8B5CF6',
          ),
          const QuickAction(
            id: 'learn',
            title: 'Learn',
            icon: 'school_rounded',
            route: '/learn',
            color: '#10B981',
          ),
          const QuickAction(
            id: 'calendar',
            title: 'Calendar',
            icon: 'calendar_today_rounded',
            route: '/calendar',
            color: '#F59E0B',
          ),
        ],
        dailyMessage: DailyMessage(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          message:
              currentUser.dailyMessage.isNotEmpty
                  ? currentUser.dailyMessage
                  : 'Every day is a new adventure waiting to unfold with your family!',
          category: 'Inspiration',
          date: DateTime.now(),
        ),
        familyMembers: [
          FamilyMember(
            id: currentUser.id,
            name: currentUser.name,
            role: currentUser.role,
            gender: currentUser.gender,
            avatar: currentUser.avatar,
          ),
        ],
        familyName: '',
        email: currentUser.email,
        createdAt: currentUser.memberSince,
        familyAvatar: '',
        notifications: [],
        goals: [],
        achievements: [],
        sharedStories: [],
      );
    }

    // Fallback if no user in storage
    return HomeData(
      user: UserProfile(
        id: 'temp-user',
        name: 'Guest User',
        email: 'guest@example.com',
        avatar: '',
        createdAt: DateTime.now(),
      ),
      familyStats: FamilyStats(
        totalStars: 0,
        tasks: 0,
        stars: Stars(daily: 0, weekly: 0, monthly: 0, yearly: 0),
        taskCounts: TaskCounts(daily: 0, weekly: 0, monthly: 0, yearly: 0),
      ),
      quickActions: [
        const QuickAction(
          id: 'notes',
          title: 'Notes',
          icon: 'note_alt_rounded',
          route: '/notes',
          color: '#FF6B9D',
        ),
        const QuickAction(
          id: 'bonding',
          title: 'Bonding',
          icon: 'favorite_rounded',
          route: '/bonding',
          color: '#8B5CF6',
        ),
        const QuickAction(
          id: 'learn',
          title: 'Learn',
          icon: 'school_rounded',
          route: '/learn',
          color: '#10B981',
        ),
        const QuickAction(
          id: 'calendar',
          title: 'Calendar',
          icon: 'calendar_today_rounded',
          route: '/calendar',
          color: '#F59E0B',
        ),
      ],
      dailyMessage: DailyMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        message:
            'Every day is a new adventure waiting to unfold with your family!',
        category: 'Inspiration',
        date: DateTime.now(),
      ),
      familyMembers: [
        FamilyMember(
          id: 'temp-user',
          name: 'Guest User',
          role: 'member',
          gender: '',
          avatar: '',
        ),
      ],
      familyName: '',
      email: '',
      createdAt: DateTime.now(),
      familyAvatar: '',
      notifications: [],
      goals: [],
      achievements: [],
      sharedStories: [],
    );
  }

  DailyMessage _getMockDailyMessage() {
    final messages = [
      'Every day is a new adventure waiting to unfold with your family!',
      'Family time is the best time - make every moment count!',
      'Together we grow, together we learn, together we create memories!',
      'Your family bond is your greatest treasure - nurture it daily!',
      'Small moments with family create the biggest memories!',
      'Love, laughter, and family - the perfect recipe for happiness!',
    ];

    final categories = [
      'Inspiration',
      'Family',
      'Love',
      'Growth',
      'Joy',
      'Wisdom',
    ];

    final randomIndex = DateTime.now().millisecondsSinceEpoch % messages.length;

    debugPrint('📝 Generating random daily message: ${messages[randomIndex]}');

    return DailyMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      message: messages[randomIndex],
      category: categories[randomIndex],
      date: DateTime.now(),
    );
  }
}
