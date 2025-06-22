import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  String _memberType = '';
  String _selectedAvatar = '';
  String _selectedGender = '';
  DateTime? _selectedBirthday;
  final List<String> _selectedInterests = [];

  final TextEditingController _nicknameController = TextEditingController();

  // Avatar options
  final List<Map<String, dynamic>> _childAvatars = [
    {
      'id': 'assets/images/avatars/child/avatar1.png',
      'path': 'assets/images/avatars/child/avatar1.png',
      'label': 'Child Avatar 1',
    },
    {
      'id': 'assets/images/avatars/child/avatar2.png',
      'path': 'assets/images/avatars/child/avatar2.png',
      'label': 'Child Avatar 2',
    },
    {
      'id': 'assets/images/avatars/child/avatar3.png',
      'path': 'assets/images/avatars/child/avatar3.png',
      'label': 'Child Avatar 3',
    },
    {
      'id': 'assets/images/avatars/child/avatar4.png',
      'path': 'assets/images/avatars/child/avatar4.png',
      'label': 'Child Avatar 4',
    },
    {
      'id': 'assets/images/avatars/child/avatar5.png',
      'path': 'assets/images/avatars/child/avatar5.png',
      'label': 'Child Avatar 5',
    },
    {
      'id': 'assets/images/avatars/child/avatar6.png',
      'path': 'assets/images/avatars/child/avatar6.png',
      'label': 'Child Avatar 6',
    },
        {
      'id': 'assets/images/avatars/child/avatar7.png',
      'path': 'assets/images/avatars/child/avatar7.png',
      'label': 'Child Avatar 7',
    },
        {
      'id': 'assets/images/avatars/child/avatar8.png',
      'path': 'assets/images/avatars/child/avatar8.png',
      'label': 'Child Avatar 8',
    },
        {
      'id': 'assets/images/avatars/child/avatar9.png',
      'path': 'assets/images/avatars/child/avatar9.png',
      'label': 'Child Avatar 9',
    },
        {
      'id': 'assets/images/avatars/child/avatar10.png',
      'path': 'assets/images/avatars/child/avatar10.png',
      'label': 'Child Avatar 10',
    },
  ];

  final List<Map<String, dynamic>> _parentAvatars = [
    {
      'id': 'assets/images/avatars/parent/avatar1.png',
      'path': 'assets/images/avatars/parent/avatar1.png',
      'label': 'Parent Avatar 1',
    },
    {
      'id': 'assets/images/avatars/parent/avatar2.png',
      'path': 'assets/images/avatars/parent/avatar2.png',
      'label': 'Parent Avatar 2',
    },
    {
      'id': 'assets/images/avatars/parent/avatar3.png',
      'path': 'assets/images/avatars/parent/avatar3.png',
      'label': 'Parent Avatar 3',
    },
    {
      'id': 'assets/images/avatars/parent/avatar4.png',
      'path': 'assets/images/avatars/parent/avatar4.png',
      'label': 'Parent Avatar 4',
    },
    {
      'id': 'assets/images/avatars/parent/avatar5.png',
      'path': 'assets/images/avatars/parent/avatar5.png',
      'label': 'Parent Avatar 5',
    },
    {
      'id': 'assets/images/avatars/parent/avatar6.png',
      'path': 'assets/images/avatars/parent/avatar6.png',
      'label': 'Parent Avatar 6',
    },
        {
      'id': 'assets/images/avatars/parent/avatar7.png',
      'path': 'assets/images/avatars/parent/avatar7.png',
      'label': 'Parent Avatar 7',
    },
        {
      'id': 'assets/images/avatars/parent/avatar8.png',
      'path': 'assets/images/avatars/parent/avatar8.png',
      'label': 'Parent Avatar 8',
    },
        {
      'id': 'assets/images/avatars/parent/avatar9.png',
      'path': 'assets/images/avatars/parent/avatar9.png',
      'label': 'Parent Avatar 9',
    },
  ];

  // Interest options for children
  final List<String> _childInterests = [
    '⚽ Sports & Games',
    '🎨 Arts & Crafts',
    '📚 Reading & Stories',
    '🎵 Music & Dance',
    '🔬 Science & Experiments',
    '🎮 Video Games',
    '🌳 Outdoor Adventures',
    '🍳 Cooking & Baking',
    '🐶 Animals & Pets',
    '🔧 Building & Making',
    '📸 Photography',
    '✏️ Drawing & Painting',
    '🎲 Board Games',
    '🏊 Swimming',
    '🏃 Running & Fitness',
    '💻 Technology',
    '🌱 Gardening',
    '🎬 Movies & Shows',
    '🧩 Puzzles',
    '🚀 Space & Astronomy',
  ];

  bool _isFormValid() {
    return _memberType.isNotEmpty &&
        _selectedAvatar.isNotEmpty &&
        _nicknameController.text.trim().isNotEmpty &&
        _selectedBirthday != null &&
        _selectedGender.isNotEmpty &&
        (_memberType == 'Parent' || _selectedInterests.isNotEmpty);
  }

  void _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0EA5E9),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A202C),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  void _showInterestsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
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
                    const Text(
                      'Select Child\'s Interests',
                      style: TextStyle(
                        color: Color(0xFF1A202C),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: _childInterests.length,
                        itemBuilder: (context, index) {
                          final interest = _childInterests[index];
                          final isSelected = _selectedInterests.contains(
                            interest,
                          );

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FE),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                interest,
                                style: const TextStyle(
                                  color: Color(0xFF1A202C),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: isSelected,
                              activeColor: const Color(0xFF0EA5E9),
                              onChanged: (bool? value) {
                                setDialogState(() {
                                  if (value == true) {
                                    _selectedInterests.add(interest);
                                  } else {
                                    _selectedInterests.remove(interest);
                                  }
                                });
                                setState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Center(
                            child: Text(
                              'Done',
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
              ),
            );
          },
        );
      },
    );
  }

  void _addAnotherMember() {
    setState(() {
      _memberType = '';
      _selectedAvatar = '';
      _selectedGender = '';
      _selectedInterests.clear();
      _selectedBirthday = null;
      _nicknameController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.celebration_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Member added! Add another one.'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _saveAndContinue() {
    // Complete the registration flow and go to MainApp
    context.read<AuthBloc>().add(CompleteRegistrationFlowEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                          onPressed: () {
                            // Complete the registration flow and go to MainApp
                            context.read<AuthBloc>().add(
                              CompleteRegistrationFlowEvent(),
                            );
                          },
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.eco_rounded,
                              color: Color(0xFF4CAF50),
                              size: 40,
                            );
                          },
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Add Family Member',
                    style: TextStyle(
                      color: Color(0xFF1A202C),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let\'s build your family tree together',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Member Type Selection
                    _buildSectionCard(
                      title: 'Member Type',
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMemberTypeOption(
                              'Child',
                              Icons.child_care_rounded,
                              const Color(0xFFFF6B9D),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMemberTypeOption(
                              'Parent',
                              Icons.family_restroom_rounded,
                              const Color(0xFF0EA5E9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_memberType.isNotEmpty) ...[
                      const SizedBox(height: 24),
                     // Avatar Selection
                    _buildSectionCard(
                      title: 'Choose Avatar',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hint text
                        Text(
                          'Swipe to see more options',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                          SizedBox(height: 12),
                          // Avatar selection with fade indicator
                          Stack(
                            children: [
                              Scrollbar(
                                thumbVisibility: true,
                                child: SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: 4), 
                                    itemCount:
                                        _memberType == 'Child'
                                            ? _childAvatars.length
                                            : _parentAvatars.length,
                                    itemBuilder: (context, index) {
                                      final avatars =
                                          _memberType == 'Child'
                                              ? _childAvatars
                                              : _parentAvatars;
                                      final avatar = avatars[index];
                                      final isSelected =
                                          _selectedAvatar == avatar['id'];
                                
                                      return GestureDetector(
                                        onTap:
                                            () => setState(
                                              () => _selectedAvatar = avatar['id'],
                                            ),
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F9FE),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected 
                                                ? const Color(0xFF4F46E5) 
                                                : const Color(0xFFE2E8F0),
                                            width: isSelected ? 3 : 2,
                                          ),
                                        ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: Image.asset(
                                              avatar['path'],
                                              width: 66,
                                              height: 66,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    _memberType == 'Child'
                                                        ? Icons.child_care
                                                        : Icons.person,
                                                    size: 32,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Right fade indicator with arrow
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                      const SizedBox(height: 24),

                      // Nickname Field
                      _buildSectionCard(
                        title: 'Nickname',
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _nicknameController,
                            style: const TextStyle(
                              color: Color(0xFF1A202C),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter nickname',
                              hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Birthday Field
                      _buildSectionCard(
                        title: 'Birthday',
                        child: GestureDetector(
                          onTap: _selectBirthday,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FE),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    _selectedBirthday != null
                                        ? const Color(0xFF0EA5E9)
                                        : const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  color:
                                      _selectedBirthday != null
                                          ? const Color(0xFF0EA5E9)
                                          : const Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedBirthday != null
                                      ? '${_selectedBirthday!.day}/${_selectedBirthday!.month}/${_selectedBirthday!.year}'
                                      : 'Select birthday',
                                  style: TextStyle(
                                    color:
                                        _selectedBirthday != null
                                            ? const Color(0xFF1A202C)
                                            : const Color(0xFF94A3B8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Gender Selection
                      _buildSectionCard(
                        title: _memberType == 'Child' ? 'Gender' : 'Role',
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildGenderOption(
                                _memberType == 'Child' ? 'Boy' : 'Father',
                                _memberType == 'Child'
                                    ? Icons.male_rounded
                                    : Icons.man_rounded,
                                const Color(0xFF0EA5E9),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildGenderOption(
                                _memberType == 'Child' ? 'Girl' : 'Mother',
                                _memberType == 'Child'
                                    ? Icons.female_rounded
                                    : Icons.woman_rounded,
                                const Color(0xFFFF6B9D),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_memberType == 'Child') ...[
                        const SizedBox(height: 24),

                        // Child's Interests
                        _buildSectionCard(
                          title: 'Child\'s Interests',
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _showInterestsDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FE),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          _selectedInterests.isNotEmpty
                                              ? const Color(0xFF0EA5E9)
                                              : const Color(0xFFE2E8F0),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedInterests.isEmpty
                                              ? 'Select interests for the child'
                                              : '${_selectedInterests.length} interests selected',
                                          style: TextStyle(
                                            color:
                                                _selectedInterests.isEmpty
                                                    ? const Color(0xFF94A3B8)
                                                    : const Color(0xFF1A202C),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color:
                                            _selectedInterests.isNotEmpty
                                                ? const Color(0xFF0EA5E9)
                                                : const Color(0xFF94A3B8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (_selectedInterests.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      _selectedInterests.take(3).map((
                                        interest,
                                      ) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0EA5E9),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            interest,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                                if (_selectedInterests.length > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '+${_selectedInterests.length - 3} more',
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: const Color(0xFF0EA5E9),
                                  width: 2,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(26),
                                  onTap:
                                      _isFormValid() ? _addAnotherMember : null,
                                  child: Center(
                                    child: Text(
                                      'Add Another',
                                      style: TextStyle(
                                        color:
                                            _isFormValid()
                                                ? const Color(0xFF0EA5E9)
                                                : const Color(0xFF94A3B8),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                gradient:
                                    _isFormValid()
                                        ? const LinearGradient(
                                          colors: [
                                            Color(0xFF0EA5E9),
                                            Color(0xFF0284C7),
                                          ],
                                        )
                                        : null,
                                color:
                                    _isFormValid()
                                        ? null
                                        : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(26),
                                boxShadow:
                                    _isFormValid()
                                        ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF0EA5E9,
                                            ).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                        : null,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(26),
                                  onTap:
                                      _isFormValid() ? _saveAndContinue : null,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.home_rounded,
                                          color:
                                              _isFormValid()
                                                  ? Colors.white
                                                  : const Color(0xFF94A3B8),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Continue',
                                          style: TextStyle(
                                            color:
                                                _isFormValid()
                                                    ? Colors.white
                                                    : const Color(0xFF94A3B8),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildMemberTypeOption(String type, IconData icon, Color color) {
    final isSelected = _memberType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _memberType = type;
          _selectedAvatar = '';
          _selectedGender = '';
          _selectedInterests.clear();
        });
      },
      child: Container(
        height: 90, // Increased height to prevent overflow
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Added to prevent overflow
          children: [
            Icon(
              icon,
              size: 24, // Reduced icon size slightly
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(height: 6), // Increased spacing slightly
            Flexible(
              // Wrapped text in Flexible to prevent overflow
              child: Text(
                type,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1A202C),
                  fontSize: 13, // Reduced font size slightly
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Prevent text overflow
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String title, IconData icon, Color color) {
    final isSelected = _selectedGender == title;

    return GestureDetector(
      onTap: () => setState(() => _selectedGender = title),
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1A202C),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
}
