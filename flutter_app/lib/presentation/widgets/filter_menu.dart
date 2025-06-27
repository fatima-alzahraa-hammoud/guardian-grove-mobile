// lib/widgets/filter_menu.dart
import 'package:flutter/material.dart';

class FilterMenu extends StatelessWidget {
  final int menuIndex;
  final int noteCount;
  final List<String> noteType;
  final Function(int) onFilterTap;

  const FilterMenu({
    super.key,
    required this.menuIndex,
    required this.noteCount,
    required this.noteType,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$noteCount ${noteCount == 1 ? 'Note' : 'Notes'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  noteType.asMap().entries.map((entry) {
                    final index = entry.key;
                    final type = entry.value;
                    final isSelected = index == menuIndex;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => onFilterTap(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(0xFF0EA5E9)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? const Color(0xFF0EA5E9)
                                      : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
