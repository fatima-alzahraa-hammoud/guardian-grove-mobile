import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import 'package:flutter_app/data/models/home_model.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/data/models/family_model.dart' show FamilyMember;
import 'package:flutter_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_app/presentation/bloc/auth/auth_event.dart';
import 'package:flutter_app/presentation/bloc/home/home_bloc.dart';
import 'package:flutter_app/presentation/pages/auth/add_member_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  int _calculateAge(DateTime birthday) {
    final today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
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
                        // User Info Card
                        _buildUserInfoCard(),
                        const SizedBox(height: 16),

                        // Family Stats Card
                        _buildFamilyStatsCard(),
                        const SizedBox(height: 24),

                        // Family Members Section
                        _buildFamilyMembersSection(),
                        const SizedBox(height: 40),

                        // Logout Button
                        _buildLogoutButton(),
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

  // Replace both _buildUserInfoCard() and _buildFamilyStatsCard() with these beautiful versions

  Widget _buildUserInfoCard() {
    if (currentUser == null) {
      return _buildLoadingCard();
    }

    // Use new FamilyMember model fields if available (for consistency)
    String avatarPath = currentUser!.avatar;

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
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child:
                          avatarPath.isNotEmpty
                              ? (avatarPath.startsWith('assets/')
                                  ? ClipOval(
                                    child: Image.asset(
                                      avatarPath,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _buildFallbackUserAvatar(),
                                    ),
                                  )
                                  : ClipOval(
                                    child: Image.network(
                                      avatarPath,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _buildFallbackUserAvatar(),
                                    ),
                                  ))
                              : _buildFallbackUserAvatar(),
                    ),
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
                            '${currentUser!.role} • ${_calculateAge(currentUser!.birthday)} years',
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

  Widget _buildFamilyStatsCard() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Default values
        String familyName = 'Your Family';
        String familyAvatar = '';
        int totalStars = 0;
        int totalTasks = 0;
        List<FamilyMember> familyMembers = [];

        if (state is HomeLoaded) {
          final homeData = state.homeData;
          familyName = homeData.familyName;
          familyAvatar = homeData.familyAvatar;
          totalStars = homeData.familyStats.totalStars;
          totalTasks = homeData.familyStats.tasks;
          familyMembers = homeData.familyMembers;
        }

        if (familyMembers.isEmpty && currentUser != null) {
          familyMembers = [
            FamilyMember(
              id: currentUser!.id,
              name: currentUser!.name,
              avatar: currentUser!.avatar,
              role: currentUser!.role,
              gender: currentUser!.gender,
            ),
          ];
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Family header with glassmorphism effect
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Improved Family Avatar
                    Stack(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child:
                                familyAvatar.isNotEmpty
                                    ? (familyAvatar.startsWith('assets/')
                                        ? Image.asset(
                                          familyAvatar,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  _buildFallbackFamilyIcon(),
                                        )
                                        : Image.network(
                                          familyAvatar,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  _buildFallbackFamilyIcon(),
                                        ))
                                    : _buildFallbackFamilyIcon(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Family name with better typography
                          Row(
                            children: [
                              const Text('🏠', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  familyName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Beautiful member count badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.group_rounded,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${familyMembers.length} ${familyMembers.length == 1 ? 'member' : 'members'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.95),
                                    fontWeight: FontWeight.w600,
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
              ),

              const SizedBox(height: 24),

              // Beautiful stats cards with improved design
              Row(
                children: [
                  // Total Stars Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
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
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$totalStars',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Stars',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Total Tasks Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
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
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.task_alt_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$totalTasks',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total Tasks',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Motivational message with animation-ready design
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
                      Icons.trending_up_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Keep up the amazing work! 🌟',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
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

  // Helper methods
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
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
    );
  }

  String _getUserRoleEmoji(String role) {
    switch (role.toLowerCase()) {
      case 'father':
      case 'dad':
        return '👨‍💼';
      case 'mother':
      case 'mom':
        return '👩‍💼';
      case 'child':
      case 'son':
        return '👦';
      case 'daughter':
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

  Widget _buildFamilyMembersSection() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        List<FamilyMember> familyMembers = [];

        if (state is HomeLoaded) {
          familyMembers = state.homeData.familyMembers;
        } else if (currentUser != null) {
          // Fallback to show current user as only family member
          familyMembers = [
            FamilyMember(
              id: currentUser!.id,
              name: currentUser!.name,
              avatar: currentUser!.avatar,
              role: currentUser!.role,
              gender: currentUser!.gender,
            ),
          ];
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
                    'Family Members:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  // Add Members button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const AddMemberScreen(fromProfile: true),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Add Members',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Family members list
              if (familyMembers.isEmpty)
                const Center(
                  child: Text(
                    'No family members found',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                )
              else
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: familyMembers.length + 1, // +1 for the arrow
                    itemBuilder: (context, index) {
                      if (index == familyMembers.length) {
                        // Show arrow at the end
                        return Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FE),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: Color(0xFF64748B),
                            size: 24,
                          ),
                        );
                      }

                      final member = familyMembers[index];
                      return GestureDetector(
                        onTap: () => _showMemberDialog(member),
                        child: Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            gradient: _getMemberGradient(member.role),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _getMemberGradient(
                                  member.role,
                                ).colors.first.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child:
                              member.avatar.isNotEmpty
                                  ? ClipOval(
                                    child:
                                        member.avatar.startsWith('assets/')
                                            ? Image.asset(
                                              member.avatar,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Center(
                                                    child: Icon(
                                                      _getMemberIcon(
                                                        member.role,
                                                      ),
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  ),
                                            )
                                            : Image.network(
                                              member.avatar,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Center(
                                                    child: Icon(
                                                      _getMemberIcon(
                                                        member.role,
                                                      ),
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  ),
                                            ),
                                  )
                                  : Icon(
                                    _getMemberIcon(member.role),
                                    color: Colors.white,
                                    size: 24,
                                  ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  LinearGradient _getMemberGradient(String role) {
    switch (role.toLowerCase()) {
      case 'father':
      case 'dad':
        return const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
        );
      case 'mother':
      case 'mom':
        return const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFEC4899)],
        );
      case 'child':
      case 'son':
      case 'daughter':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        );
    }
  }

  IconData _getMemberIcon(String role) {
    switch (role.toLowerCase()) {
      case 'father':
      case 'dad':
        return Icons.man_rounded;
      case 'mother':
      case 'mom':
        return Icons.woman_rounded;
      case 'child':
      case 'son':
      case 'daughter':
        return Icons.child_care_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  void _showMemberDialog(FamilyMember member) {
    final isChild =
        member.role.toLowerCase().contains('child') ||
        member.role.toLowerCase().contains('son') ||
        member.role.toLowerCase().contains('daughter');

    final currentUserIsParent =
        currentUser?.role.toLowerCase().contains('father') == true ||
        currentUser?.role.toLowerCase().contains('mother') == true ||
        currentUser?.role.toLowerCase().contains('dad') == true ||
        currentUser?.role.toLowerCase().contains('mom') == true;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Member Avatar (robust asset/network logic)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: _getMemberGradient(member.role),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: _getMemberGradient(
                            member.role,
                          ).colors.first.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        member.avatar.isNotEmpty
                            ? ClipOval(
                              child:
                                  member.avatar.startsWith('assets/')
                                      ? Image.asset(
                                        member.avatar,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                                  _getMemberIcon(member.role),
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                      )
                                      : Image.network(
                                        member.avatar,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                                  _getMemberIcon(member.role),
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                      ),
                            )
                            : Icon(
                              _getMemberIcon(member.role),
                              color: Colors.white,
                              size: 32,
                            ),
                  ),
                  const SizedBox(height: 16),

                  // Member Info
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A202C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member.role.toLowerCase().contains('child')
                        ? 'Child'
                        : member.role,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Basic info for all members
                  _buildDialogInfoRow('Role', member.role),
                  _buildDialogInfoRow('Gender', member.gender),
                  // Show birthday if present
                  if (member.birthday != null)
                    _buildDialogInfoRow(
                      'Birthday',
                      _formatDate(member.birthday!),
                    ),
                  // Show interests if present
                  if (member.interests.isNotEmpty)
                    _buildDialogInfoRow(
                      'Interests',
                      member.interests.join(', '),
                    ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (isChild && currentUserIsParent) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Navigate to child insight screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Opening ${member.name}\'s insights...',
                                    ),
                                    backgroundColor: const Color(0xFF0EA5E9),
                                  ),
                                );
                              },
                              child: const Text(
                                'View Insights',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDialogInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A202C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEF4444), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () {
            // Show logout confirmation dialog
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthBloc>().add(LogoutEvent());
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Color(0xFFEF4444)),
                        ),
                      ),
                    ],
                  ),
            );
          },
          child: const Center(
            child: Text(
              'Log out',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
