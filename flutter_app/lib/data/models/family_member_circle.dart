import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/family_model.dart' show FamilyMember;

class FamilyMemberCircle extends StatelessWidget {
  final FamilyMember member;
  final Color bgColor;
  final VoidCallback onTap;

  const FamilyMemberCircle({
    super.key,
    required this.member,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withAlpha((0.3 * 255).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildAvatar(),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              member.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    // Fix asset path: remove leading slash if present
    String fixedAvatar = member.avatar;
    if (fixedAvatar.startsWith('/assets/')) {
      fixedAvatar = fixedAvatar.substring(1);
    }
    if (fixedAvatar.isNotEmpty) {
      if ((fixedAvatar.endsWith('.png') ||
              fixedAvatar.endsWith('.jpg') ||
              fixedAvatar.endsWith('.jpeg')) &&
          fixedAvatar.startsWith('assets/')) {
        return Image.asset(
          fixedAvatar,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialAvatar(),
        );
      } else if (fixedAvatar.startsWith('http') ||
          fixedAvatar.startsWith('https')) {
        return Image.network(
          member.avatar,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialAvatar(),
        );
      }
    }
    return _buildInitialAvatar();
  }

  Widget _buildInitialAvatar() {
    return Center(
      child: Text(
        member.name.isNotEmpty ? member.name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
