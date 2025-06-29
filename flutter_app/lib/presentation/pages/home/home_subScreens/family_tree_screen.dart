import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/family_model.dart' show FamilyMember;
import 'package:flutter_app/core/services/family_api_service.dart';
import 'package:flutter_app/data/models/family_member_circle.dart';

class FamilyTreeScreen extends StatefulWidget {
  final bool collapsed;
  const FamilyTreeScreen({super.key, this.collapsed = false});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  List<FamilyMember> _familyMembers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFamilyMembers();
  }

  Future<void> _fetchFamilyMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    debugPrint(
      '🔍 Fetching family members for family tree (via FamilyApiService)...',
    );
    try {
      final members = await FamilyApiService.fetchFamilyMembersWithDebug();
      setState(() {
        _familyMembers = members;
        _isLoading = false;
      });
      debugPrint(
        '✅ Successfully loaded ${members.length} family members for family tree (via FamilyApiService)',
      );
      for (final member in members) {
        debugPrint(
          '   - \\${member.name} (\\${member.role}) - Avatar: \\${member.avatar.isNotEmpty ? '✅' : '❌'} - Gender: \\${member.gender.isNotEmpty ? member.gender : '❌'} - ID: \\${member.id}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching family members (FamilyApiService): $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Color palettes
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

  List<FamilyMember> get _parents {
    return _familyMembers.where((member) {
      final role = member.role.toLowerCase();
      return role.contains('parent') ||
          role.contains('father') ||
          role.contains('mother') ||
          role.contains('dad') ||
          role.contains('mom') ||
          role.contains('admin') ||
          role.contains('owner');
    }).toList();
  }

  List<FamilyMember> get _children {
    return _familyMembers.where((member) {
      final role = member.role.toLowerCase();
      return role.contains('child') ||
          role.contains('son') ||
          role.contains('daughter');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF0EA5E9),
                    size: 28,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 8),
                const Text(
                  'Family Tree',
                  style: TextStyle(
                    color: Color(0xFF1A202C),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF0EA5E9),
                    size: 24,
                  ),
                  onPressed: _fetchFamilyMembers,
                  tooltip: 'Refresh',
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.family_restroom_rounded,
                    color: Color(0xFF0EA5E9),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: widget.collapsed ? 16 : 32,
          right: widget.collapsed ? 16 : 32,
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0EA5E9)),
            SizedBox(height: 16),
            Text('Loading family members...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading family members',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchFamilyMembers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_familyMembers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.family_restroom_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No family members found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Add family members to see them here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            "Click on the family member to view their details",
            style: TextStyle(
              color: Colors.grey,
              fontSize: widget.collapsed ? 18 : 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Total members: ${_familyMembers.length} (${_parents.length} parents, ${_children.length} children)",
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),

          // Parents Section
          if (_parents.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.family_restroom,
                  color: Color(0xFF1A202C),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Parents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_parents.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0EA5E9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Parents Grid - Horizontal scrollable if many
            SizedBox(
              height: 120, // Fixed height for parent section
              child:
                  _parents.length <= 3
                      ? Center(
                        child: Wrap(
                          spacing: widget.collapsed ? 32 : 24,
                          children: List.generate(_parents.length, (index) {
                            final parent = _parents[index];
                            final color =
                                parentColorPalette[index %
                                    parentColorPalette.length];
                            return FamilyMemberCircle(
                              key: ValueKey(parent.id),
                              member: parent,
                              bgColor: color,
                              onTap: () => _showMemberDialog(parent),
                            );
                          }),
                        ),
                      )
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _parents.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final parent = _parents[index];
                          final color =
                              parentColorPalette[index %
                                  parentColorPalette.length];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: widget.collapsed ? 32 : 24,
                            ),
                            child: FamilyMemberCircle(
                              key: ValueKey(parent.id),
                              member: parent,
                              bgColor: color,
                              onTap: () => _showMemberDialog(parent),
                            ),
                          );
                        },
                      ),
            ),
            SizedBox(height: widget.collapsed ? 48 : 32),
          ],

          // Children Section
          if (_children.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.child_care,
                  color: Color(0xFF1A202C),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Children',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_children.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Children Grid - Centered wrap for many children
            Center(
              child: Wrap(
                spacing: widget.collapsed ? 24 : 20,
                runSpacing: widget.collapsed ? 24 : 20,
                children: List.generate(_children.length, (index) {
                  final child = _children[index];
                  final color =
                      childColorPalette[index % childColorPalette.length];
                  return FamilyMemberCircle(
                    key: ValueKey(child.id),
                    member: child,
                    bgColor: color,
                    onTap: () => _showMemberDialog(child),
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Family Stats Card
          if (_familyMembers.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Family Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Members',
                          '${_familyMembers.length}',
                          Icons.people,
                          const Color(0xFF0EA5E9),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Parents',
                          '${_parents.length}',
                          Icons.family_restroom,
                          const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Children',
                          '${_children.length}',
                          Icons.child_care,
                          const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showMemberDialog(FamilyMember member) {
    // Fix asset path: remove leading slash if present
    String fixedAvatar = member.avatar;
    if (fixedAvatar.startsWith('/assets/')) {
      fixedAvatar = fixedAvatar.substring(1);
    }
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child:
                        member.avatar.isNotEmpty
                            ? ClipOval(
                              child:
                                  (fixedAvatar.endsWith('.png') ||
                                              fixedAvatar.endsWith('.jpg') ||
                                              fixedAvatar.endsWith('.jpeg')) &&
                                          fixedAvatar.startsWith('assets/')
                                      ? Image.asset(
                                        fixedAvatar,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildInitialAvatar(member),
                                      )
                                      : (fixedAvatar.startsWith('http') ||
                                          fixedAvatar.startsWith('https'))
                                      ? Image.network(
                                        member.avatar,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildInitialAvatar(member),
                                      )
                                      : _buildInitialAvatar(member),
                            )
                            : _buildInitialAvatar(member),
                  ),
                  const SizedBox(height: 16),
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
                    member.role,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDialogInfoRow(
                    'Gender',
                    member.gender.isEmpty ? 'Not specified' : member.gender,
                  ),
                  if (member.birthday != null)
                    _buildDialogInfoRow(
                      'Age',
                      _calculateAge(member.birthday!).toString(),
                    ),
                  if (member.birthday != null)
                    _buildDialogInfoRow(
                      'Birthday',
                      member.birthday!.toIso8601String().split('T').first,
                    ),
                  if (member.interests.isNotEmpty)
                    _buildDialogInfoRow(
                      'Interests',
                      member.interests.join(', '),
                    ),
                  const SizedBox(height: 24),
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
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildInitialAvatar(FamilyMember member) {
    return Center(
      child: Text(
        member.name.isNotEmpty ? member.name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildDialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
      ),
    );
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
}
