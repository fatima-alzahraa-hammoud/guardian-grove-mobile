import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/leaderboard/leaderboard_bloc.dart';
import '../../../data/models/leaderboard_model.dart';
import '../../../injection_container.dart' as di;

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<LeaderboardBloc>()..add(LoadLeaderboard()),
      child: const LeaderboardView(),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
            );
          } else if (state is LeaderboardError) {
            return _buildErrorState(context, state.message);
          } else if (state is LeaderboardLoaded) {
            return _buildLeaderboardContent(context, state);
          }
          return const SizedBox.shrink();
        },
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
                  context.read<LeaderboardBloc>().add(LoadLeaderboard());
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

  Widget _buildLeaderboardContent(
    BuildContext context,
    LeaderboardLoaded state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<LeaderboardBloc>().add(RefreshLeaderboard());
      },
      color: const Color(0xFF0EA5E9),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top 3 Podium
            if (state.families.isNotEmpty) ...[
              _buildPodiumSection(state.families.take(3).toList()),
              const SizedBox(height: 32),
            ], // Your Family Rank Card (only show if current family is NOT in top 20)
            if (state.currentFamily != null &&
                !state.isCurrentFamilyInTop20) ...[
              _buildYourRankCard(state.currentFamily!),
              const SizedBox(height: 24),
            ],

            // Leaderboard Title
            const Text(
              'Family Rankings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 16), // Leaderboard List
            if (state.families.isNotEmpty)
              ...state.families.asMap().entries.map((entry) {
                final index = entry.key;
                final family = entry.value;
                final isCurrentFamily =
                    family.familyId == state.currentFamily?.familyId;

                // Add separator before current family if it's not in top 20 (appears at bottom)
                final shouldShowSeparator =
                    isCurrentFamily &&
                    !state.isCurrentFamilyInTop20 &&
                    index == state.families.length - 1;

                return Column(
                  children: [
                    // Add separator before current family at bottom
                    if (shouldShowSeparator) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Your Family',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildLeaderboardRow(
                        family,
                        state.currentFamily?.familyId,
                      ),
                    ),
                  ],
                );
              })
            else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumSection(List<LeaderboardFamily> topFamilies) {
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
        children: [
          const Text(
            '🏆 Top Families',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd Place
              if (topFamilies.length > 1)
                _buildPodiumItem(
                  topFamilies[1],
                  2,
                  const Color(0xFF94A3B8),
                  80,
                ),
              // 1st Place
              if (topFamilies.isNotEmpty)
                _buildPodiumItem(
                  topFamilies[0],
                  1,
                  const Color(0xFFF59E0B),
                  100,
                ),
              // 3rd Place
              if (topFamilies.length > 2)
                _buildPodiumItem(
                  topFamilies[2],
                  3,
                  const Color(0xFFCD7F32),
                  60,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    LeaderboardFamily family,
    int position,
    Color color,
    double height,
  ) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child:
                family.familyAvatar.isNotEmpty
                    ? ClipOval(
                      child: Image.network(
                        family.familyAvatar,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildAvatarFallback(family.familyName),
                      ),
                    )
                    : _buildAvatarFallback(family.familyName),
          ),
        ),
        const SizedBox(height: 8),
        // Family Name
        Text(
          family.familyName,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Points
        Text(
          '${family.totalPoints} pts',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        // Podium
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '$position',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYourRankCard(LeaderboardFamily currentFamily) {
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
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${currentFamily.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Family Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
                  currentFamily.familyAvatar.isNotEmpty
                      ? ClipOval(
                        child: Image.network(
                          currentFamily.familyAvatar,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildAvatarFallback(
                                    currentFamily.familyName,
                                    true,
                                  ),
                        ),
                      )
                      : _buildAvatarFallback(currentFamily.familyName, true),
            ),
          ),
          const SizedBox(width: 16),
          // Family Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Family',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  currentFamily.familyName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatChip(
                      Icons.star_rounded,
                      '${currentFamily.stars}',
                      true,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.monetization_on_rounded,
                      '${currentFamily.coins}',
                      true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(
    LeaderboardFamily family,
    String? currentFamilyId,
  ) {
    final isCurrentFamily = family.familyId == currentFamilyId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isCurrentFamily
                ? const Color(0xFF0EA5E9).withValues(alpha: 0.05)
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCurrentFamily
                  ? const Color(0xFF0EA5E9).withValues(alpha: 0.3)
                  : const Color(0xFFE2E8F0),
        ),
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
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(family.rank).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${family.rank}',
                style: TextStyle(
                  color: _getRankColor(family.rank),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Family Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
                  family.familyAvatar.isNotEmpty
                      ? ClipOval(
                        child: Image.network(
                          family.familyAvatar,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildAvatarFallback(family.familyName),
                        ),
                      )
                      : _buildAvatarFallback(family.familyName),
            ),
          ),
          const SizedBox(width: 12),

          // Family Name & Members
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  family.familyName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isCurrentFamily
                            ? const Color(0xFF0EA5E9)
                            : const Color(0xFF1A202C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (family.members.isNotEmpty)
                  Text(
                    '${family.members.length} members',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
          ),

          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: _getRankColor(family.rank),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${family.stars}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getRankColor(family.rank),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on_rounded,
                    size: 16,
                    color: _getRankColor(family.rank),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${family.coins}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getRankColor(family.rank),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: const Column(
        children: [
          Icon(Icons.leaderboard_rounded, size: 80, color: Color(0xFFE2E8F0)),
          SizedBox(height: 20),
          Text(
            'No families yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Be the first family to join the leaderboard!',
            style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String familyName, [bool isWhite = false]) {
    return Text(
      familyName.isNotEmpty ? familyName[0].toUpperCase() : 'F',
      style: TextStyle(
        color: isWhite ? Colors.white : const Color(0xFF0EA5E9),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, [bool isWhite = false]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isWhite
                ? Colors.white.withValues(alpha: 0.2)
                : const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isWhite ? Colors.white : const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: isWhite ? Colors.white : const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFF59E0B); // Gold
      case 2:
        return const Color(0xFF94A3B8); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF0EA5E9); // Default blue
    }
  }
}
