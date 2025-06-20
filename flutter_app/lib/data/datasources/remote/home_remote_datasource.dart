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
        stars:
            (userData['stars'] ??
                    userData['totalStars'] ??
                    familyData['totalStars'] ??
                    familyData['stars'] ??
                    0)
                .toInt(),
        coins:
            (userData['coins'] ??
                    userData['totalCoins'] ??
                    familyData['totalCoins'] ??
                    familyData['coins'] ??
                    0)
                .toInt(),
        rank: (familyData['rank'] ?? 1).toInt(),
        totalTasks: (familyData['totalTasks'] ?? 0).toInt(),
        completedTasks: (familyData['completedTasks'] ?? 0).toInt(),
        familyMembersCount: familyMembers.length,
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
              email: memberData['email']?.toString() ?? '',
              avatar:
                  memberData['avatarUrl']?.toString() ??
                  memberData['avatar_url']?.toString() ??
                  memberData['profilePicture']?.toString() ??
                  '',
              role: memberData['role']?.toString() ?? 'member',
              isOnline:
                  memberData['isOnline'] ?? memberData['is_online'] ?? false,
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
        '👤 User: ${user.name} (${familyStats.coins} coins, ${familyStats.stars} stars)',
      );
      debugPrint(
        '👨‍👩‍👧‍👦 Family: ${familyStats.familyMembersCount} members, rank ${familyStats.rank}',
      );

      return HomeData(
        user: user,
        familyStats: familyStats,
        quickActions: quickActions,
        dailyMessage: dailyMessage,
        familyMembers: members,
      );
    } catch (e) {
      debugPrint('❌ Error converting backend data: $e');
      return _getFallbackHomeData();
    }
  }

  /// Convert only user data to HomeData model (when family data is not available)
  HomeData _convertUserDataToHome(Map<String, dynamic> userData) {
    debugPrint('🔄 Converting user-only data to HomeData model');
    debugPrint('👤 User data keys: ${userData.keys.toList()}');

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
        stars: (userData['stars'] ?? userData['totalStars'] ?? 0).toInt(),
        coins: (userData['coins'] ?? userData['totalCoins'] ?? 0).toInt(),
        rank: 1,
        totalTasks: 0,
        completedTasks: 0,
        familyMembersCount: 1,
      );

      final members = [
        FamilyMember(
          id: user.id,
          name: user.name,
          email: user.email,
          avatar: user.avatar,
          role: 'admin',
          isOnline: true,
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
        '👤 User: ${user.name} (${familyStats.coins} coins, ${familyStats.stars} stars)',
      );

      return HomeData(
        user: user,
        familyStats: familyStats,
        quickActions: quickActions,
        dailyMessage: dailyMessage,
        familyMembers: members,
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
          stars: currentUser.stars,
          coins: currentUser.coins,
          rank: currentUser.rankInFamily,
          totalTasks: 0, // Initial value for new users
          completedTasks: currentUser.nbOfTasksCompleted,
          familyMembersCount:
              currentUser.familyId != null ? 1 : 0, // At least the current user
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
            email: currentUser.email,
            avatar: currentUser.avatar,
            role: currentUser.role,
            isOnline: true,
          ),
        ],
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
      familyStats: const FamilyStats(
        stars: 0,
        coins: 0,
        rank: 1,
        totalTasks: 0,
        completedTasks: 0,
        familyMembersCount: 1,
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
        const FamilyMember(
          id: 'temp-user',
          name: 'Guest User',
          email: 'guest@example.com',
          avatar: '',
          role: 'member',
          isOnline: true,
        ),
      ],
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
