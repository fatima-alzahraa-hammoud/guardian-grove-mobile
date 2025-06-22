import 'package:flutter/material.dart';
import '../../../data/models/time_based_leaderboard_model.dart';

class LeaderboardItem extends StatelessWidget {
  final LeaderboardFamily family;
  final int position;
  final bool isCurrentFamily;
  final VoidCallback? onView;

  const LeaderboardItem({
    super.key,
    required this.family,
    required this.position,
    this.isCurrentFamily = false,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentFamily ? const Color(0xFFE3F2FD) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            isCurrentFamily
                ? Border.all(
                  color: const Color(0xFF3A8EBA),
                  width: 2,
                  style: BorderStyle.solid,
                )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Section
          SizedBox(width: 48, child: Center(child: _buildRankWidget())),

          const SizedBox(width: 16),

          // Avatar and Name Section
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF3F4F6),
                  ),
                  child: ClipOval(
                    child:
                        family.familyAvatar.isNotEmpty
                            ? Image.network(
                              family.familyAvatar,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.family_restroom,
                                  color: Color(0xFF9CA3AF),
                                  size: 24,
                                );
                              },
                            )
                            : const Icon(
                              Icons.family_restroom,
                              color: Color(0xFF9CA3AF),
                              size: 24,
                            ),
                  ),
                ),

                const SizedBox(width: 12),

                // Family Name
                Expanded(
                  child: Text(
                    family.familyName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isCurrentFamily ? FontWeight.bold : FontWeight.w500,
                      color:
                          isCurrentFamily
                              ? const Color(0xFF3A8EBA)
                              : const Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Stars, Tasks, and View Button
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Stars
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFBBF24), size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${family.stars}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),

                // Tasks (represented as total points)
                Row(
                  children: [
                    const Icon(
                      Icons.task_alt,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${family.totalPoints}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),                  ],
                ),                // View Button
                if (onView != null)
                  Container(
                    width: 12,
                    height: 28,
                    margin: const EdgeInsets.only(left: 8),
                    child: ElevatedButton(
                      onPressed: onView,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 244, 245, 246).withValues(alpha: 0.4),
                        foregroundColor: const Color.fromARGB(255, 24, 37, 65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),                      child: const Text(
                        '⋮',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
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

  Widget _buildRankWidget() {
    if (position <= 3) {
      // Top 3 get medal emojis
      const medals = ['🥇', '🥈', '🥉'];
      return Text(medals[position - 1], style: const TextStyle(fontSize: 24));
    } else {
      // Others get rank number
      return Text(
        '$position',
        style: TextStyle(
          fontSize: 18,
          fontWeight: isCurrentFamily ? FontWeight.bold : FontWeight.w600,
          color:
              isCurrentFamily
                  ? const Color(0xFF3A8EBA)
                  : const Color(0xFF6B7280),
        ),
      );
    }
  }
}
