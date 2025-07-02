import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/leaderboard/time_based_leaderboard_bloc.dart';
import '../../../data/models/time_based_leaderboard_model.dart';
import '../../widgets/leaderboard_item.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/family_dialog.dart';
import '../../../injection_container.dart' as di;

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              di.sl<TimeBasedLeaderboardBloc>()
                ..add(LoadTimeBasedLeaderboard()),
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
      body: BlocBuilder<TimeBasedLeaderboardBloc, TimeBasedLeaderboardState>(
        builder: (context, state) {
          if (state is TimeBasedLeaderboardLoading) {
            return _buildLoadingState();
          } else if (state is TimeBasedLeaderboardError) {
            return _buildErrorState(context, state.message);
          } else if (state is TimeBasedLeaderboardLoaded) {
            return _buildLeaderboardContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Loading Leaderboard...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Preparing your family rankings',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A202C),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  context.read<TimeBasedLeaderboardBloc>().add(
                    RefreshTimeBasedLeaderboard(),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Try Again',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
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
    TimeBasedLeaderboardLoaded state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TimeBasedLeaderboardBloc>().add(
          RefreshTimeBasedLeaderboard(),
        );
      },
      color: const Color(0xFF0EA5E9),
      strokeWidth: 3,
      child: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Family Leaderboard',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.1,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Shine together! See how your family ranks',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (state.currentFamily != null)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap:
                                    () => _showYourAchievements(
                                      context,
                                      state.currentFamily!,
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.stars_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'View Achievements',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Time frame selector section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: _buildTimeFrameSelector(context, state.currentTimeFrame),
            ),
          ),

          // Motivational message
          if (state.motivationalMessage.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildMotivationalMessage(state.motivationalMessage),
            ),

          // Progress stats
          if (state.progressStats != null)
            SliverToBoxAdapter(
              child: _buildProgressStats(state.progressStats!),
            ),

          // Current family rank
          if (state.currentFamily != null)
            SliverToBoxAdapter(child: _buildYourRankCard(state.currentFamily!)),

          // Podium section (top 3)
          if (state.currentLeaderboard.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildPodiumSection(
                context,
                state.currentLeaderboard.take(3).toList(),
              ),
            ),

          // Section header for remaining families
          if (state.currentLeaderboard.length > 3)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF64748B).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people_rounded,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Flexible(
                      child: Text(
                        'Other Families',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A202C),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Remaining families list
          if (state.currentLeaderboard.length > 3)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final familyIndex = index + 3;
                  if (familyIndex >= state.currentLeaderboard.length) {
                    return const SizedBox.shrink();
                  }
                  final family = state.currentLeaderboard[familyIndex];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: LeaderboardItem(
                      family: family,
                      position: index + 4,
                      isCurrentFamily:
                          family.familyId == state.currentFamily?.familyId,
                      onView: () => _showFamilyDialog(context, family),
                    ),
                  );
                },
                childCount:
                    (state.currentLeaderboard.length - 3)
                        .clamp(0, double.infinity)
                        .toInt(),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector(
    BuildContext context,
    LeaderboardTimeFrame currentFrame,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children:
              LeaderboardTimeFrame.values.map((frame) {
                final isSelected = frame == currentFrame;
                final isFirst = frame == LeaderboardTimeFrame.values.first;
                final isLast = frame == LeaderboardTimeFrame.values.last;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.read<TimeBasedLeaderboardBloc>().add(
                        ChangeTimeFrame(frame),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF0EA5E9)
                                : Colors.transparent,
                        borderRadius: BorderRadius.horizontal(
                          left:
                              isFirst ? const Radius.circular(20) : Radius.zero,
                          right:
                              isLast ? const Radius.circular(20) : Radius.zero,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0EA5E9,
                                    ).withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            frame.name.toUpperCase(),
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildMotivationalMessage(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Text(
                  'Hooray!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStats(FamilyProgressStats stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF0EA5E9),
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              const Text(
                'Family Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A202C),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ProgressBar(
            label: 'Tasks Completed',
            completed: stats.completedTasks,
            total: stats.totalTasks,
          ),
          const SizedBox(height: 20),
          ProgressBar(
            label: 'Goals Achieved',
            completed: stats.completedGoals,
            total: stats.totalGoals,
          ),
          const SizedBox(height: 20),
          ProgressBar(
            label: 'Achievements Unlocked',
            completed: stats.unlockedAchievements,
            total: stats.totalAchievements,
          ),
        ],
      ),
    );
  }

  Widget _buildYourRankCard(LeaderboardFamily currentFamily) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#${currentFamily.rank}',
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  'RANK',
                  style: TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Family',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currentFamily.familyName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFBBF24),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${currentFamily.stars}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${currentFamily.totalPoints} points',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumSection(
    BuildContext context,
    List<LeaderboardFamily> topFamilies,
  ) {
    if (topFamilies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFF59E0B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                const Flexible(
                  child: Text(
                    'Top Families',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A202C),
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Fixed Podium with proper overflow handling
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Second place
              if (topFamilies.length > 1)
                Expanded(
                  child: _buildPodiumItem(
                    context,
                    topFamilies[1],
                    2,
                    const Color(0xFFC0C0C0),
                    isSecondPlace: true,
                  ),
                ),

              // First place (taller)
              if (topFamilies.isNotEmpty)
                Expanded(
                  child: _buildPodiumItem(
                    context,
                    topFamilies[0],
                    1,
                    const Color(0xFFFFD700),
                    isFirstPlace: true,
                  ),
                ),

              // Third place
              if (topFamilies.length > 2)
                Expanded(
                  child: _buildPodiumItem(
                    context,
                    topFamilies[2],
                    3,
                    const Color(0xFFCD7F32),
                    isThirdPlace: true,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    LeaderboardFamily family,
    int position,
    Color medalColor, {
    bool isFirstPlace = false,
    bool isSecondPlace = false,
    bool isThirdPlace = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown for first place
          if (isFirstPlace) ...[
            const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFFFD700),
              size: 24,
            ),
            const SizedBox(height: 8),
          ],

          // Medal with position number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [medalColor, medalColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: medalColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Family card with proper constraints
          Container(
            height: isFirstPlace ? 200 : (isSecondPlace ? 190 : 180),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    position == 1
                        ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                        : const Color(0xFFE2E8F0),
                width: position == 1 ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      position == 1
                          ? const Color(0xFFFFD700).withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.03),
                  blurRadius: position == 1 ? 12 : 6,
                  offset:
                      position == 1 ? const Offset(0, 4) : const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      (family.familyAvatar.isNotEmpty)
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              family.familyAvatar,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.family_restroom_rounded,
                                    color: Color(0xFF0EA5E9),
                                    size: 20,
                                  ),
                            ),
                          )
                          : const Icon(
                            Icons.family_restroom_rounded,
                            color: Color(0xFF0EA5E9),
                            size: 20,
                          ),
                ),
                const SizedBox(height: 10),

                // Family name with proper overflow handling
                SizedBox(
                  height: 36,
                  child: Center(
                    child: Text(
                      family.familyName.isNotEmpty
                          ? family.familyName
                          : 'Unknown Family',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            position == 1 ? FontWeight.w800 : FontWeight.w600,
                        color: const Color(0xFF1A202C),
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Stars badge - more compact
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF59E0B),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${family.stars}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF59E0B),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // View button - very compact to fit within boundaries
                Container(
                  width: double.infinity,
                  height: 18,
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ElevatedButton(
                    onPressed: () => _showFamilyDialog(context, family),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showYourAchievements(
    BuildContext context,
    LeaderboardFamily currentFamily,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => FamilyDialog(
            family: currentFamily,
            rank: currentFamily.rank,
            totalStars: currentFamily.stars,
            wonChallenges: currentFamily.totalPoints,
          ),
    );
  }

  void _showFamilyDialog(BuildContext context, LeaderboardFamily family) {
    showDialog(
      context: context,
      builder:
          (context) => FamilyDialog(
            family: family,
            rank: family.rank,
            totalStars: family.stars,
            wonChallenges: family.totalPoints,
          ),
    );
  }
}
