import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/home/home_bloc.dart';
import '../../../injection_container.dart' as di;
import '../auth/login_page.dart';
import '../auth/add_member_screen.dart';
import '../../../core/services/storage_service.dart';
import 'home_subScreens/family_tree_screen.dart';
import 'home_subScreens/family_journal.dart';
import 'home_subScreens/notes.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/family_model.dart' show FamilyMember;
import 'home_subScreens/store.dart';
import 'home_subScreens/goals_adventure_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<HomeBloc>()..add(LoadHomeData()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<FamilyMember> _familyMembers = [];
  Map<String, dynamic>? _monthlyStats;
  Map<String, dynamic>? _lastUnlockedAchievement;
  bool _noAchievements = false;
  // Add these new fields for the scrollable quick actions
  final PageController _quickActionsController = PageController();
  int _currentQuickActionPage = 0;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembersDirectly();
    _fetchMonthlyStats(); // Add this
    _fetchLastUnlockedAchievement(); // Add this
  }

  @override
  void dispose() {
    _quickActionsController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyMembersDirectly() async {
    try {
      final dio = Dio();
      final token = StorageService.getToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      dio.options.baseUrl = AppConstants.baseUrl;
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      debugPrint('🔍 Home: Fetching family members...');

      // Step 1: Get user info to get familyId
      final userResponse = await dio.get('/users/user');
      if (userResponse.statusCode != 200) {
        debugPrint('❌ Home: Failed to get user info');
        return;
      }

      final userData = userResponse.data['user'] ?? userResponse.data;
      final familyId = userData['familyId'];

      if (familyId == null) {
        debugPrint('❌ Home: No family ID found');
        return;
      }

      debugPrint('👨‍👩‍👧‍👦 Home: Family ID: $familyId');

      // Step 2: Make POST request to get family members (as backend expects)
      Response? membersResponse;

      try {
        debugPrint('🔄 Home: Making POST request to /family/FamilyMembers...');
        membersResponse = await dio.post(
          '/family/FamilyMembers',
          data: {'familyId': familyId},
        );
        debugPrint('✅ Home: POST request successful');
      } catch (e) {
        debugPrint('❌ Home: POST request failed: $e');

        // Fallback: Try getFamily
        try {
          debugPrint('🔄 Home: Trying getFamily fallback...');
          final familyResponse = await dio.post(
            '/family/getFamily',
            data: {'familyId': familyId},
          );

          if (familyResponse.statusCode == 200) {
            final familyData = familyResponse.data['family'];
            if (familyData != null && familyData['members'] != null) {
              _processHomeMembersData(familyData['members'] as List);
              return;
            }
          }
          debugPrint('❌ Home: Fallback also failed');
          return;
        } catch (e2) {
          debugPrint('❌ Home: Fallback also failed: $e2');
          return;
        }
      }

      if (membersResponse.statusCode == 200) {
        final responseData = membersResponse.data;
        debugPrint('📄 Home: Members response received');

        List<dynamic> membersData = [];

        // Handle different response structures
        if (responseData['familyWithMembers'] != null) {
          membersData = responseData['familyWithMembers']['members'] ?? [];
        } else if (responseData['members'] != null) {
          membersData = responseData['members'];
        } else if (responseData is List) {
          membersData = responseData;
        }

        _processHomeMembersData(membersData);
      }
    } catch (e) {
      debugPrint('❌ Home: Error fetching family members: $e');
    }
  }

  void _processHomeMembersData(List<dynamic> membersData) {
    debugPrint('🔄 Home: Processing ${membersData.length} members');

    final members =
        membersData.map((memberData) {
          debugPrint(
            '👤 Home: Processing member: ${memberData['name'] ?? 'Unknown'}',
          );

          // Debug missing data
          final avatar = memberData['avatar']?.toString() ?? '';
          final gender = memberData['gender']?.toString() ?? '';

          if (avatar.isEmpty) {
            debugPrint('⚠️ Home: Missing avatar for: ${memberData['name']}');
          }
          if (gender.isEmpty) {
            debugPrint('⚠️ Home: Missing gender for: ${memberData['name']}');
          }

          return FamilyMember(
            id:
                memberData['_id']?.toString() ??
                memberData['id']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            name: memberData['name']?.toString() ?? 'Unknown Member',
            role: memberData['role']?.toString() ?? 'member',
            gender: gender,
            avatar: avatar,
            birthday:
                memberData['birthday'] != null
                    ? DateTime.tryParse(memberData['birthday'].toString())
                    : null,
            interests:
                memberData['interests'] != null &&
                        memberData['interests'] is List
                    ? List<String>.from(memberData['interests'])
                    : <String>[],
          );
        }).toList();

    setState(() {
      _familyMembers = members;
    });

    debugPrint('✅ Home: Successfully loaded ${members.length} family members');
    for (final member in members) {
      debugPrint(
        '   - ${member.name} (${member.role}) - Avatar: ${member.avatar.isNotEmpty ? '✅' : '❌'}',
      );
    }
  }

  Future<void> _fetchMonthlyStats() async {
    try {
      final dio = Dio();
      final token = StorageService.getToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      dio.options.baseUrl = AppConstants.baseUrl;

      final response = await dio.get('/userGoals/monthlyStats');
      if (response.statusCode == 200) {
        setState(() {
          _monthlyStats = response.data;
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching monthly stats: $e');
    }
  }

  Future<void> _fetchLastUnlockedAchievement() async {
    try {
      final dio = Dio();
      final token = StorageService.getToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      dio.options.baseUrl = AppConstants.baseUrl;

      final response = await dio.get('/achievements/lastUnlocked');
      if (response.statusCode == 200) {
        if (response.data['message'] == 'No achievements') {
          setState(() {
            _noAchievements = true;
          });
        } else {
          setState(() {
            _lastUnlockedAchievement = response.data['lastUnlockedAchievement'];
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching achievements: $e');
    }
  }

  void _showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Tasks Progress
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0EA5E9,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.task_alt_rounded,
                              color: Color(0xFF0EA5E9),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Tasks Completed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A202C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_monthlyStats != null) ...[
                        Text(
                          '${_monthlyStats!['completedTasks'] ?? 0} / ${_monthlyStats!['totalTasks'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0EA5E9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value:
                              (_monthlyStats!['totalTasks'] ?? 0) > 0
                                  ? (_monthlyStats!['completedTasks'] ?? 0) /
                                      (_monthlyStats!['totalTasks'] ?? 0)
                                  : 0.0,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF0EA5E9),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ] else ...[
                        const Text(
                          '0 / 0',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0EA5E9),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Goals Progress
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF59E0B,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.flag_rounded,
                              color: Color(0xFFF59E0B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Goals Completed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A202C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_monthlyStats != null) ...[
                        Text(
                          '${_monthlyStats!['completedGoals'] ?? 0} / ${_monthlyStats!['totalGoals'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value:
                              (_monthlyStats!['totalGoals'] ?? 0) > 0
                                  ? (_monthlyStats!['completedGoals'] ?? 0) /
                                      (_monthlyStats!['totalGoals'] ?? 0)
                                  : 0.0,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFF59E0B),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ] else ...[
                        const Text(
                          '0 / 0',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          },
        ),
        BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is NavigationRequested) {
              _handleNavigation(context, state.routeName);
            } else if (state is InvitationSent) {
              _showSuccessMessage(context, state.message);
            } else if (state is HomeError) {
              _showErrorMessage(context, state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
              );
            } else if (state is HomeLoaded) {
              return _buildHomeContent(context, state);
            } else if (state is HomeError) {
              return _buildErrorState(context, state.message);
            }
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeLoaded state) {
    final currentUser = StorageService.getUser();
    final isChild =
        currentUser?.role.toLowerCase().contains('child') == true ||
        currentUser?.role.toLowerCase().contains('son') == true ||
        currentUser?.role.toLowerCase().contains('daughter') == true;
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(RefreshHomeData());
      },
      color: const Color(0xFF0EA5E9),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with User Info
            _buildHeaderSection(state),
            const SizedBox(height: 24),

            // Add Members Section
            if (!isChild) _buildAddMembersSection(context),
            if (!isChild) const SizedBox(height: 24), // Daily Message Section
            _buildDailyMessageSection(context, state),
            const SizedBox(height: 24),

            // Quick Actions Grid
            _buildQuickActionsGrid(context),
            const SizedBox(height: 24),

            // Family Features Section
            const Text(
              'Family Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 16),
            _buildFamilyFeaturesGrid(context, state),
            const SizedBox(height: 24),

            // Ready to have tasks? Section
            _buildTasksSection(context),
            const SizedBox(height: 24),

            // Ready to play? Section
            _buildPlaySection(context),
            const SizedBox(height: 24),

            // Track your Child Section
            if (!isChild) _buildTrackChildSection(context),
            if (!isChild) const SizedBox(height: 24),

            // Progress Section
            _buildProgressSection(context, state),
            const SizedBox(height: 24),

            // AI Assistant Section
            _buildAIAssistantSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(HomeLoaded state) {
    // Use StorageService to get the most up-to-date user info (as in Profile)
    final currentUser = StorageService.getUser();
    final user = state.homeData.user;
    final stats = state.homeData.familyStats;

    String avatarPath = '';
    if (currentUser != null && currentUser.avatar.isNotEmpty) {
      avatarPath = currentUser.avatar;
    } else if (user.avatar.isNotEmpty) {
      avatarPath = user.avatar;
    }
    final displayName =
        (currentUser != null && currentUser.name.isNotEmpty)
            ? currentUser.name
            : user.name;
    // --- Consistent avatar logic ---
    String fixedAvatar = avatarPath;
    if (fixedAvatar.startsWith('/assets/')) {
      fixedAvatar = fixedAvatar.substring(1);
    }
    Widget buildAvatar() {
      if (fixedAvatar.isNotEmpty) {
        if ((fixedAvatar.endsWith('.png') ||
                fixedAvatar.endsWith('.jpg') ||
                fixedAvatar.endsWith('.jpeg')) &&
            fixedAvatar.startsWith('assets/')) {
          return ClipOval(
            child: Image.asset(
              fixedAvatar,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ),
          );
        } else if (fixedAvatar.startsWith('http') ||
            fixedAvatar.startsWith('https')) {
          return ClipOval(
            child: Image.network(
              fixedAvatar,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ),
          );
        }
      }
      return Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(child: buildAvatar()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $displayName 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    Text(
                      _formatCurrentDate(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Row
          Row(
            children: [
              _buildStatChip(
                Icons.star_rounded,
                '${stats.totalStars}',
                const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 12),
              if (currentUser != null) ...[
                _buildStatChip(
                  Icons.monetization_on_rounded,
                  '${currentUser.coins}',
                  const Color(0xFF38BDF8),
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  Icons.emoji_events_rounded,
                  'Rank ${currentUser.rankInFamily}',
                  const Color(0xFF6366F1),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMembersSection(BuildContext context) {
    final memberCount = _familyMembers.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Members',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Invite your family to join ($memberCount ${memberCount == 1 ? 'member' : 'members'})',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const AddMemberScreen(fromProfile: false),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.group_add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMessageSection(BuildContext context, HomeLoaded state) {
    final dailyMessage = state.homeData.dailyMessage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Message',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    context.read<HomeBloc>().add(RefreshDailyMessage());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${dailyMessage.message}"',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✨ ${dailyMessage.category}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Replace your existing _buildQuickActionsGrid method with this updated version:
  Widget _buildQuickActionsGrid(BuildContext context) {
    // Define quick action items with direct navigation
    final List<List<Map<String, dynamic>>> quickActionPages = [
      // Page 1
      [
        {
          'icon': Icons.note_alt_rounded,
          'title': 'Notes',
          'color': const Color(0xFFFF6B9D),
          'onTap': () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NotesScreen()),
            );
          },
        },
        {
          'icon': Icons.favorite_rounded,
          'title': 'Bonding',
          'color': const Color(0xFF8B5CF6),
          'onTap': () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bonding Activities - Coming Soon!'),
              ),
            );
          },
        },
        {
          'icon': Icons.school_rounded,
          'title': 'Learn',
          'color': const Color(0xFF10B981),
          'onTap': () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Learning Section - Coming Soon!')),
            );
          },
        },
      ],
      // Page 2
      [
        {
          'icon': Icons.store_rounded,
          'title': 'Store',
          'color': const Color(0xFF06B6D4),
          'onTap': () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const StoreScreen()),
            );
          },
        },
        {
          'icon': Icons.calendar_today_rounded,
          'title': 'Calendar',
          'color': const Color(0xFFF59E0B),
          'onTap': () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calendar - Coming Soon!')),
            );
          },
        },
        {
          'icon': Icons.sports_esports_rounded,
          'title': 'Games',
          'color': const Color(0xFFE11D48),
          'onTap': () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Games - Coming Soon!')),
            );
          },
        },
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 16),
        // Scrollable PageView for quick actions
        SizedBox(
          height: 80,
          child: PageView.builder(
            controller: _quickActionsController,
            onPageChanged: (index) {
              setState(() {
                _currentQuickActionPage = index;
              });
            },
            itemCount: quickActionPages.length,
            itemBuilder: (context, pageIndex) {
              return Row(
                children: [
                  // Build each action in the current page
                  ...quickActionPages[pageIndex].asMap().entries.map((entry) {
                    final index = entry.key;
                    final action = entry.value;
                    final isLast =
                        index == quickActionPages[pageIndex].length - 1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isLast ? 0 : 12),
                        child: _buildQuickActionCard(
                          icon: action['icon'],
                          title: action['title'],
                          color: action['color'],
                          onTap: action['onTap'],
                        ),
                      ),
                    );
                  }),
                  // Add empty expanded widgets if page has less than 3 items
                  ...List.generate(
                    3 - quickActionPages[pageIndex].length,
                    (index) => const Expanded(child: SizedBox()),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            quickActionPages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentQuickActionPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color:
                    _currentQuickActionPage == index
                        ? const Color(0xFF0EA5E9)
                        : const Color(0xFFE2E8F0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A202C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyFeaturesGrid(BuildContext context, HomeLoaded? state) {
    return Row(
      children: [
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.account_tree_rounded,
            title: 'Family Tree',
            subtitle: 'Explore your heritage',
            color: const Color(0xFF10B981),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FamilyTreeScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.auto_stories_rounded,
            title: 'Family Journal',
            subtitle: 'Share memories',
            color: const Color(0xFF8B5CF6),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FamilyJournalScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTasksSection(BuildContext context) {
    return _buildSectionCard(
      title: 'Ready to have tasks?',
      subtitle: 'Goals and adventures',
      buttonText: 'Start Adventures',
      icon: Icons.flag_rounded,
      color: const Color(0xFF10B981),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const GoalsAdventuresScreen(),
          ),
        );
      },
    );
  }

  Widget _buildPlaySection(BuildContext context) {
    return _buildSectionCard(
      title: 'Ready to play?',
      subtitle: 'Fun zone',
      buttonText: 'Let\'s Play',
      icon: Icons.sports_esports_rounded,
      color: const Color(0xFFFF6B9D),
      onTap: () => context.read<HomeBloc>().add(NavigateToFunZone()),
    );
  }

  Widget _buildTrackChildSection(BuildContext context) {
    return _buildSectionCard(
      title: 'Track your Child?',
      subtitle: 'Monitor your children',
      buttonText: 'Track Now',
      icon: Icons.child_care_rounded,
      color: const Color(0xFF10B981),
      onTap: () => context.read<HomeBloc>().add(NavigateToChildTracking()),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A202C),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Remove the Row with stats and just keep the title
        const Text(
          'Tap to view your progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                title: 'Tasks & Goals',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF0EA5E9),
                onTap:
                    () => _showProgressDialog(context), // Show dialog instead
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAchievementCard(), // Custom card for achievements
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProgressCard(
                title: 'Magic Garden',
                icon: Icons.local_florist_rounded,
                color: const Color(0xFF10B981),
                onTap:
                    () => context.read<HomeBloc>().add(NavigateToMagicGarden()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_noAchievements && _lastUnlockedAchievement != null) ...[
              // Show achievement photo if available
              if (_lastUnlockedAchievement!['photo'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _lastUnlockedAchievement!['photo'],
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFF59E0B,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            color: Color(0xFFF59E0B),
                            size: 16,
                          ),
                        ),
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFF59E0B),
                    size: 16,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                _lastUnlockedAchievement!['title'] ?? 'Achievement',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A202C),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              // Default achievement icon when no achievements
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFF59E0B),
                  size: 16,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A202C),
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'No unlocked yet',
                style: TextStyle(fontSize: 8, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Add missing _buildProgressCard method
  Widget _buildProgressCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A202C),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add missing _buildFeatureCard method
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A202C),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add missing _buildAIAssistantSection method
  Widget _buildAIAssistantSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need help or guidance today?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'I\'m here for you!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        () => context.read<HomeBloc>().add(
                          NavigateToAIAssistant(),
                        ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Talk to me, your AI Friend',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, String routeName) {
    if (routeName == '/family-tree') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const FamilyTreeScreen()));
      return;
    }
    if (routeName == '/notes') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const NotesScreen()));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text('Navigating to $routeName'),
          ],
        ),
        backgroundColor: const Color(0xFF0EA5E9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 80,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 20),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  context.read<HomeBloc>().add(LoadHomeData());
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
