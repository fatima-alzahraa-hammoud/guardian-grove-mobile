import 'package:flutter/material.dart';

// Example FamilyMember model
class FamilyMember {
  final String name;
  final String role; // "parent" or "child"
  final String avatar; // asset path or network url

  const FamilyMember({
    required this.name,
    required this.role,
    required this.avatar,
  });
}

class FamilyTreeScreen extends StatelessWidget {
  final List<FamilyMember> familyMembers;
  final bool collapsed;

  const FamilyTreeScreen({
    super.key,
    required this.familyMembers,
    this.collapsed = false,
  });

  static const parentColorPalette = [
    Color(0xFF3B82F6), // blue-500
    Color(0xFF8B5CF6), // purple-500
    Color(0xFF14B8A6), // teal-500
    Color(0xFFF43F5E), // rose-500
  ];

  static const childColorPalette = [
    Color(0xFF4ADE80), // green-400
    Color(0xFFFACC15), // yellow-400
    Color(0xFFF87171), // red-400
    Color(0xFFF472B6), // pink-400
    Color(0xFFA5B4FC), // indigo-400
    Color(0xFFFBBF24), // orange-400
    Color(0xFF22D3EE), // cyan-400
  ];

  @override
  Widget build(BuildContext context) {
    final parents = familyMembers.where((m) => m.role == "parent").toList();
    final children = familyMembers.where((m) => m.role == "child").toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(
          top: 48,
          left: collapsed ? 16 : 32,
          right: collapsed ? 16 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Family Tree",
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontWeight: FontWeight.bold,
                fontSize: collapsed ? 28 : 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Click on the family member to view their progress",
              style: TextStyle(
                color: Colors.grey,
                fontSize: collapsed ? 18 : 15,
              ),
            ),
            const SizedBox(height: 32),

            // Parents Row
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(parents.length, (index) {
                  final parent = parents[index];
                  final color =
                      parentColorPalette[index % parentColorPalette.length];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: collapsed ? 32 : 24,
                    ),
                    child: FamilyMemberCircle(
                      key: ValueKey(parent.name),
                      member: parent,
                      bgColor: color,
                      onTap: () {
                        // TODO: Show parent progress
                      },
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: collapsed ? 64 : 48),

            // Children Row/Grid
            Wrap(
              alignment: WrapAlignment.center,
              spacing: collapsed ? 32 : 24,
              runSpacing: collapsed ? 32 : 24,
              children: List.generate(children.length, (index) {
                final child = children[index];
                final color =
                    childColorPalette[index % childColorPalette.length];
                return FamilyMemberCircle(
                  key: ValueKey(child.name),
                  member: child,
                  bgColor: color,
                  onTap: () {
                    // TODO: Show child progress
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

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
            ),
            child: ClipOval(
              child:
                  member.avatar.isNotEmpty
                      ? Image.asset(
                        member.avatar,
                        fit: BoxFit.cover,
                        width: 72,
                        height: 72,
                      )
                      : Center(
                        child: Text(
                          member.name.isNotEmpty
                              ? member.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            member.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
