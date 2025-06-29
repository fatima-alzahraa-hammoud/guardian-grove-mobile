import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final String label;
  final int completed;
  final int total;
  final Color? color;

  const ProgressBar({
    super.key,
    required this.label,
    required this.completed,
    required this.total,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    final progressColor = color ?? _getColorForLabel(label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            Text(
              '$completed/$total',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: progressColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Color _getColorForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'tasks':
        return const Color(0xFF10B981);
      case 'goals':
        return const Color(0xFF3B82F6);
      case 'achievements':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
