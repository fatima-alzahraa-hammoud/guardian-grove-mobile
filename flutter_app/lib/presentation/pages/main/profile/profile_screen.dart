import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import 'package:flutter_app/core/services/family_api_service.dart';
import 'package:flutter_app/data/models/home_model.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/models/family_model.dart' show FamilyMember;
import 'package:flutter_app/presentation/bloc/home/home_bloc.dart';
import 'package:flutter_app/presentation/pages/auth/add_member_screen.dart';
import 'package:flutter_app/presentation/pages/main/profile/edit_profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? currentUser;
  HomeData? homeData;
  bool _isDropdownExpanded = false;

  // Direct backend family members
  List<FamilyMember>? _backendFamilyMembers;
  bool _isLoadingFamilyMembers = false;
  String? _familyMembersError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchFamilyMembersDirect();
  }

  void _loadUserData() {
    // Get current user from storage
    currentUser = StorageService.getUser();
    setState(() {});
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownExpanded = !_isDropdownExpanded;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateAge(DateTime? birthday) {
    if (birthday == null) return 0;
    final today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  // Check if current user is a child
  bool _isCurrentUserChild() {
    if (currentUser == null) return false;
    final role = currentUser!.role.toLowerCase();
    return role.contains('child') ||
        role.contains('son') ||
        role.contains('daughter');
  }

  // Check if current user is a parent
  bool _isCurrentUserParent() {
    if (currentUser == null) return false;
    final role = currentUser!.role.toLowerCase();
    return role.contains('father') ||
        role.contains('mother') ||
        role.contains('dad') ||
        role.contains('mom') ||
        role.contains('parent') ||
        role.contains('admin') ||
        role.contains('owner');
  }

  Future<void> _fetchFamilyMembersDirect() async {
    setState(() {
      _isLoadingFamilyMembers = true;
      _familyMembersError = null;
    });
    try {
      final api = FamilyApiService();
      api.init();
      final members = await api.getFamilyMembers();
      setState(() {
        _backendFamilyMembers = members;
        _isLoadingFamilyMembers = false;
      });
    } catch (e) {
      setState(() {
        _familyMembersError = e.toString();
        _isLoadingFamilyMembers = false;
      });
    }
  }

  void _refreshUserData() {
    setState(() {
      currentUser = StorageService.getUser();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeLoaded) {
              setState(() {
                homeData = state.homeData;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header with settings dropdown
                _buildHeader(),
                const SizedBox(height: 24),

                // Main profile content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // User Info Card with Edit Button
                        _buildUserInfoCard(),
                        const SizedBox(height: 16),

                        // Family Stats Card (redesigned with app theme)
                        _buildRedesignedFamilyCard(),
                        const SizedBox(height: 24),

                        // Family Members Section (horizontal scrolling with real avatars)
                        _buildHorizontalFamilyMembersSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A202C),
          ),
        ),
        // Settings dropdown button
        GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            width: 40,
            height: 40,
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
            child: Icon(
              _isDropdownExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF64748B),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard() {
    if (currentUser == null) {
      return _buildLoadingCard();
    }

    String avatarPath = currentUser!.avatar;
    int age = _calculateAge(currentUser!.birthday);
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
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => _buildFallbackUserAvatar(),
            ),
          );
        } else if (fixedAvatar.startsWith('http') ||
            fixedAvatar.startsWith('https')) {
          return ClipOval(
            child: Image.network(
              avatarPath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => _buildFallbackUserAvatar(),
            ),
          );
        }
      }
      return _buildFallbackUserAvatar();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
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
              // Beautiful Avatar with glow effect
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                          const Color(0xFF0284C7).withValues(alpha: 0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: buildAvatar()),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name with beautiful typography
                    Text(
                      currentUser!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A202C),
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Beautiful role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                            const Color(0xFF0284C7).withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getUserRoleEmoji(currentUser!.role),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${currentUser!.role} • $age yrs',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF0EA5E9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Profile Button
              GestureDetector(
                onTap: () async {
                  if (currentUser == null) return;
                  // Navigate to EditProfileScreen
                  final isParent = _isCurrentUserParent();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditProfileScreen(
                            user: currentUser!,
                            familyName: homeData?.familyName ?? '',
                            familyAvatar: homeData?.familyAvatar ?? '',
                            isParent: isParent,
                            onConfirm: (data) {
                              _refreshUserData();
                              _fetchFamilyMembersDirect();
                            },
                          ),
                    ),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF8F9FE),
                  Colors.white.withValues(alpha: 0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                _buildBeautifulInfoRow(
                  'Email',
                  currentUser!.email,
                  Icons.email_rounded,
                  const Color(0xFFFF6B9D),
                ),
                const SizedBox(height: 16),
                _buildBeautifulInfoRow(
                  'Member since',
                  _formatDate(currentUser!.memberSince),
                  Icons.calendar_today_rounded,
                  const Color(0xFF10B981),
                ),
                const SizedBox(height: 16),
                _buildBeautifulInfoRow(
                  'Gender',
                  currentUser!.gender,
                  currentUser!.gender.toLowerCase() == 'male'
                      ? Icons.male_rounded
                      : Icons.female_rounded,
                  const Color(0xFF8B5CF6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Redesigned Family Card with app theme
  Widget _buildRedesignedFamilyCard() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Default values
        String familyName = 'Your Family';
        String familyAvatar = '';
        int totalFamilyStars = 0;
        int userCoins = currentUser?.coins ?? 0;
        int userRank = currentUser?.rankInFamily ?? 0;

        if (state is HomeLoaded) {
          final homeData = state.homeData;
          familyName =
              homeData.familyName.isNotEmpty
                  ? homeData.familyName
                  : 'Your Family';
          familyAvatar = homeData.familyAvatar;
          totalFamilyStars = homeData.familyStats.totalStars;

          // Fix: Remove leading slash if present for asset avatars
          if (familyAvatar.startsWith('/assets/')) {
            familyAvatar = familyAvatar.substring(1);
          }

          // Try to get user's individual stats from family members
          final currentUserId = currentUser?.id;
          if (currentUserId != null) {
            try {
              final userMember = homeData.familyMembers.firstWhere(
                (member) => member.id == currentUserId,
              );
              // Update with member-specific data if available
              userCoins = userMember.coins;
              userRank = userMember.rankInFamily;
            } catch (e) {
              // User not found in family members, use current user data
              debugPrint('User not found in family members, using stored data');
            }
          }
        }

        Widget buildFamilyAvatar() {
          String fixedFamilyAvatar = familyAvatar;
          if (fixedFamilyAvatar.startsWith('/assets/')) {
            fixedFamilyAvatar = fixedFamilyAvatar.substring(1);
          }

          if (fixedFamilyAvatar.isNotEmpty) {
            if ((fixedFamilyAvatar.endsWith('.png') ||
                    fixedFamilyAvatar.endsWith('.jpg') ||
                    fixedFamilyAvatar.endsWith('.jpeg')) &&
                fixedFamilyAvatar.startsWith('assets/')) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  fixedFamilyAvatar,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _buildFallbackFamilyIcon(),
                ),
              );
            } else if (fixedFamilyAvatar.startsWith('http') ||
                fixedFamilyAvatar.startsWith('https')) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(
                  familyAvatar,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _buildFallbackFamilyIcon(),
                ),
              );
            }
          }
          return _buildFallbackFamilyIcon();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0EA5E9), // Primary blue matching app theme
                Color(0xFF0284C7), // Darker blue
                Color(0xFF0369A1), // Even darker blue for depth
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Family Header
              Row(
                children: [
                  // Family Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: buildFamilyAvatar(),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Family Name Label
                        Text(
                          'Family Name:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Family Name
                        Text(
                          familyName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Stats Row
              Row(
                children: [
                  // Family Stars
                  Expanded(
                    child: _buildFamilyStatCard(
                      icon: Icons.star_rounded,
                      value: '$totalFamilyStars',
                      label: 'Family Stars',
                      color: const Color(0xFFFBBF24), // Yellow
                    ),
                  ),
                  const SizedBox(width: 16),

                  // User Coins
                  Expanded(
                    child: _buildFamilyStatCard(
                      icon: Icons.monetization_on_rounded,
                      value: '$userCoins',
                      label: 'Your Coins',
                      color: const Color(0xFF10B981), // Green
                    ),
                  ),
                  const SizedBox(width: 16),

                  // User Rank
                  Expanded(
                    child: _buildFamilyStatCard(
                      icon: Icons.emoji_events_rounded,
                      value: userRank > 0 ? '#$userRank' : '-',
                      label: 'Your Rank',
                      color: const Color(0xFFFF6B9D), // Pink
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Motivational message - Fixed overflow
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.family_restroom_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Family grows stronger together! 💙',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFamilyStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Horizontal Family Members Section with Real Avatars and Proper Navigation
  Widget _buildHorizontalFamilyMembersSection() {
    // Prefer backend data if available
    if (_isLoadingFamilyMembers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
        ),
      );
    }
    if (_familyMembersError != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error loading family members:\n${_familyMembersError!}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    List<FamilyMember> familyMembers = [];
    if (_backendFamilyMembers != null && _backendFamilyMembers!.isNotEmpty) {
      familyMembers = _backendFamilyMembers!;
    } else {
      // fallback to HomeBloc
      final state = context.read<HomeBloc>().state;
      if (state is HomeLoaded) {
        familyMembers = state.homeData.familyMembers;
      } else if (currentUser != null) {
        familyMembers = [
          FamilyMember(
            id: currentUser!.id,
            name: currentUser!.name,
            avatar: currentUser!.avatar,
            role: currentUser!.role,
            gender: currentUser!.gender,
            birthday: currentUser!.birthday,
            coins: currentUser!.coins,
            rankInFamily: currentUser!.rankInFamily,
            interests: [],
          ),
        ];
      }
    }
    final isCurrentUserChild = _isCurrentUserChild();
    final isCurrentUserParent = _isCurrentUserParent();
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Family Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A202C),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${familyMembers.length} members',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0EA5E9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (familyMembers.isEmpty)
            _buildEmptyFamilyState()
          else
            Column(
              children: [
                _buildFamilyMembersList(
                  familyMembers,
                  isCurrentUserChild,
                  isCurrentUserParent,
                ),
                if (familyMembers.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF64748B,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swipe_left_rounded,
                                size: 12,
                                color: Color(0xFF64748B),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Swipe to see more',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          if (isCurrentUserParent)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const AddMemberScreen(fromProfile: true),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add Family Member'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0EA5E9),
                  side: const BorderSide(color: Color(0xFF0EA5E9)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build the actual family members list with proper click logic
  Widget _buildFamilyMembersList(
    List<FamilyMember> familyMembers,
    bool isCurrentUserChild,
    bool isCurrentUserParent,
  ) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: familyMembers.length,
        itemBuilder: (context, index) {
          final member = familyMembers[index];
          return _buildRealFamilyMemberCard(
            member,
            index,
            isCurrentUserChild,
            isCurrentUserParent,
          );
        },
      ),
    );
  }

  // Build individual family member card with proper click handling
  Widget _buildRealFamilyMemberCard(
    FamilyMember member,
    int index,
    bool isCurrentUserChild,
    bool isCurrentUserParent,
  ) {
    debugPrint(
      '👤 Profile: Building card for ${member.name} with avatar: ${member.avatar}',
    );

    // Check if this member is a child
    final isMemberChild = _isMemberChild(member);

    // Determine if this card should be clickable
    // Children can't click anything
    // Parents can only click children avatars
    final canClick =
        !isCurrentUserChild && (isCurrentUserParent && isMemberChild);

    // Handle member avatar with same logic as family tree
    String memberAvatarPath = member.avatar;
    String fixedMemberAvatar = memberAvatarPath;
    if (fixedMemberAvatar.startsWith('/assets/')) {
      fixedMemberAvatar = fixedMemberAvatar.substring(1);
    }

    Widget buildMemberAvatar() {
      if (fixedMemberAvatar.isNotEmpty) {
        if ((fixedMemberAvatar.endsWith('.png') ||
                fixedMemberAvatar.endsWith('.jpg') ||
                fixedMemberAvatar.endsWith('.jpeg')) &&
            fixedMemberAvatar.startsWith('assets/')) {
          debugPrint(
            '👤 Profile: Loading asset avatar for ${member.name}: $fixedMemberAvatar',
          );
          return ClipOval(
            child: Image.asset(
              fixedMemberAvatar,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('❌ Profile: Member avatar asset failed: $error');
                return _buildMemberInitials(member.name);
              },
            ),
          );
        } else if (fixedMemberAvatar.startsWith('http') ||
            fixedMemberAvatar.startsWith('https')) {
          debugPrint(
            '👤 Profile: Loading network avatar for ${member.name}: $memberAvatarPath',
          );
          return ClipOval(
            child: Image.network(
              memberAvatarPath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('❌ Profile: Member avatar network failed: $error');
                return _buildMemberInitials(member.name);
              },
            ),
          );
        }
      }
      debugPrint('👤 Profile: Using initials for ${member.name}');
      return _buildMemberInitials(member.name);
    }

    return GestureDetector(
      onTap: canClick ? () => _navigateToChildInsights(member) : null,
      child: Container(
        width: 75,
        margin: EdgeInsets.only(right: 12, left: index == 0 ? 4 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with role-based gradient and click indicator
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getMemberGradientColors(member.role),
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getMemberGradientColors(
                          member.role,
                        )[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(child: buildMemberAvatar()),
                ),
                // Click indicator for clickable children (only visible to parents)
                if (canClick)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Member name - optimized for horizontal scrolling
            Text(
              _truncateName(member.name, 7),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color:
                    canClick
                        ? const Color(0xFF0EA5E9)
                        : const Color(0xFF1A202C),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Member role
            Text(
              _formatMemberRole(member.role),
              style: TextStyle(
                fontSize: 9,
                color:
                    canClick
                        ? const Color(0xFF0EA5E9).withValues(alpha: 0.7)
                        : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for family members
  bool _isMemberChild(FamilyMember member) {
    final role = member.role.toLowerCase();
    return role.contains('child') ||
        role.contains('son') ||
        role.contains('daughter');
  }

  // Smart name truncation helper
  String _truncateName(String name, int maxLength) {
    if (name.length <= maxLength) return name;

    // Try to keep first name if it's reasonable
    final parts = name.split(' ');
    final firstName = parts.first;

    if (firstName.length <= maxLength) {
      return firstName;
    }

    // Fallback to character truncation
    return '${name.substring(0, maxLength - 1)}…';
  }

  // Helper to build member initials when avatar fails
  Widget _buildMemberInitials(String name) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'M',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // Helper to get gradient colors based on member role
  List<Color> _getMemberGradientColors(String role) {
    switch (role.toLowerCase()) {
      case 'father':
      case 'dad':
      case 'parent':
      case 'admin':
      case 'owner':
        return [const Color(0xFF0EA5E9), const Color(0xFF0284C7)];
      case 'mother':
      case 'mom':
        return [const Color(0xFFFF6B9D), const Color(0xFFE91E63)];
      case 'son':
      case 'boy':
      case 'child':
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case 'daughter':
      case 'girl':
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      default:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
    }
  }

  // Helper to format member role for display
  String _formatMemberRole(String role) {
    switch (role.toLowerCase()) {
      case 'father':
      case 'dad':
        return 'Dad';
      case 'mother':
      case 'mom':
        return 'Mom';
      case 'son':
      case 'boy':
        return 'Son';
      case 'daughter':
      case 'girl':
        return 'Daughter';
      case 'child':
        return 'Child';
      case 'parent':
        return 'Parent';
      case 'admin':
      case 'owner':
        return 'Admin';
      default:
        return role.isNotEmpty
            ? role[0].toUpperCase() + role.substring(1).toLowerCase()
            : 'Member';
    }
  }

  // Navigate to child insights (only for parents clicking children)
  void _navigateToChildInsights(FamilyMember child) {
    // TODO: Replace with actual child insights screen navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.insights_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('Opening ${child.name}\'s insights...'),
          ],
        ),
        backgroundColor: const Color(0xFF0EA5E9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Empty state when no family members
  Widget _buildEmptyFamilyState() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.group_add_rounded,
              size: 24,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No family members yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A202C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Add members to get started',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF64748B).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for UI
  Widget _buildFallbackUserAvatar() {
    return Text(
      currentUser!.name.isNotEmpty ? currentUser!.name[0].toUpperCase() : 'U',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildFallbackFamilyIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(Icons.home_rounded, color: Colors.white, size: 36),
    );
  }

  String _getUserRoleEmoji(String role) {
    switch (role.toLowerCase()) {
      case 'father':
      case 'dad':
      case 'parent':
      case 'admin':
      case 'owner':
        return '👨‍💼';
      case 'mother':
      case 'mom':
        return '👩‍💼';
      case 'child':
      case 'son':
      case 'boy':
        return '👦';
      case 'daughter':
      case 'girl':
        return '👧';
      default:
        return '👤';
    }
  }

  Widget _buildBeautifulInfoRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A202C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
      ),
    );
  }
}
