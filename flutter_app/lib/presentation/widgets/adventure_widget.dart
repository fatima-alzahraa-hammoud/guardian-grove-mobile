// lib/presentation/widgets/adventure_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/goals_adventure_repository.dart'
    show GoalsAdventuresRepository;
import 'package:flutter_app/presentation/widgets/challenge_dialog_widget.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/adventure_model.dart';

class AdventureWidget extends StatefulWidget {
  final Adventure adventure;
  final GoalsAdventuresRepository repository;

  const AdventureWidget({
    super.key,
    required this.adventure,
    required this.repository,
  });

  @override
  State<AdventureWidget> createState() => _AdventureWidgetState();
}

class _AdventureWidgetState extends State<AdventureWidget> {
  Set<String> _completedChallenges = {};
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProgress() async {
    try {
      final progressList = await widget.repository.getUserAdventureProgress();
      final progress =
          progressList
              .where(
                (p) => p.challenges.any(
                  (c) => widget.adventure.challenges.any(
                    (ac) => ac.id == c.challengeId,
                  ),
                ),
              )
              .firstOrNull;

      if (progress != null) {
        setState(() {
          _completedChallenges =
              progress.challenges
                  .where((c) => c.isCompleted)
                  .map((c) => c.challengeId)
                  .toSet();
        });
      }
    } catch (e) {
      debugPrint('Error loading user progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(widget.adventure.startDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Adventure Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),

              // Adventure Title
              Text(
                widget.adventure.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'ComicSans',
                ),
                overflow: TextOverflow.visible,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Adventure Description and Rewards
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.adventure.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRewardChip(
                        Icons.star_rounded,
                        '${widget.adventure.starsReward}',
                        AppColors.primaryYellow,
                      ),
                      const SizedBox(width: 12),
                      _buildRewardChip(
                        Icons.monetization_on_rounded,
                        '${widget.adventure.coinsReward}',
                        AppColors.primaryOrange,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Challenges Section
        const Text(
          'Challenges',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontFamily: 'ComicSans',
          ),
        ),
        const SizedBox(height: 16),

        // Challenges Carousel
        Container(
          height: 220, // Increased height to prevent overflow
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Challenges PageView
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: (widget.adventure.challenges.length / 3).ceil(),
                itemBuilder: (context, pageIndex) {
                  final startIndex = pageIndex * 3;
                  final endIndex = (startIndex + 3).clamp(
                    0,
                    widget.adventure.challenges.length,
                  );
                  final pageChallenges = widget.adventure.challenges.sublist(
                    startIndex,
                    endIndex,
                  );

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          pageChallenges.map((challenge) {
                            final index = widget.adventure.challenges.indexOf(
                              challenge,
                            );
                            return _buildChallengeCard(challenge, index);
                          }).toList(),
                    ),
                  );
                },
              ),

              // Navigation Arrows
              if (widget.adventure.challenges.length > 3) ...[
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      onPressed:
                          _currentPage > 0
                              ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                              : null,
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color:
                            _currentPage > 0
                                ? AppColors.primaryTeal
                                : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      onPressed:
                          _currentPage <
                                  (widget.adventure.challenges.length / 3)
                                          .ceil() -
                                      1
                              ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                              : null,
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color:
                            _currentPage <
                                    (widget.adventure.challenges.length / 3)
                                            .ceil() -
                                        1
                                ? AppColors.primaryTeal
                                : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Page Indicators
        if (widget.adventure.challenges.length > 3) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              (widget.adventure.challenges.length / 3).ceil(),
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentPage == index
                          ? AppColors.primaryTeal
                          : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRewardChip(IconData icon, String value, Color color) {
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
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, int index) {
    final isCompleted = _completedChallenges.contains(challenge.id);
    final colors = [
      AppColors.primaryTeal,
      AppColors.primaryPurple,
      AppColors.primaryPink,
      AppColors.primaryBlue,
      AppColors.primaryOrange,
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () => _showChallengeDialog(challenge, index + 1),
      child: Container(
        width: 100,
        height: 140, // Increased height to prevent overflow
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      challenge.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: AppColors.primaryYellow,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${challenge.starsReward}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on_rounded,
                              size: 12,
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${challenge.coinsReward}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Completed Badge
            if (isCompleted)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showChallengeDialog(Challenge challenge, int challengeNumber) {
    final isCompleted = _completedChallenges.contains(challenge.id);

    showDialog(
      context: context,
      builder:
          (context) => ChallengeDialog(
            challenge: challenge,
            adventureId: widget.adventure.id,
            adventureTitle: widget.adventure.title,
            challengeNumber: challengeNumber,
            totalChallenges: widget.adventure.challenges.length,
            isCompleted: isCompleted,
            repository: widget.repository,
            onChallengeComplete: (challengeId) {
              setState(() {
                _completedChallenges.add(challengeId);
              });
            },
          ),
    );
  }

  String _formatDate(DateTime date) {
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

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}