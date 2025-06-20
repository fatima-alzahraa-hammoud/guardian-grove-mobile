import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../home/home_page.dart';

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
  final TextEditingController _birthdayController = TextEditingController();

  // Avatar options with fun colors
  final List<Map<String, dynamic>> _childAvatars = [
    {'id': 'child1', 'icon': Icons.child_care, 'color': AppColors.primaryPink},
    {'id': 'child2', 'icon': Icons.school, 'color': AppColors.primaryBlue},
    {
      'id': 'child3',
      'icon': Icons.sports_soccer,
      'color': AppColors.primaryGreen,
    },
    {'id': 'child4', 'icon': Icons.palette, 'color': AppColors.primaryPurple},
    {
      'id': 'child5',
      'icon': Icons.music_note,
      'color': AppColors.primaryOrange,
    },
    {'id': 'child6', 'icon': Icons.computer, 'color': AppColors.primaryTeal},
  ];

  final List<Map<String, dynamic>> _parentAvatars = [
    {'id': 'parent1', 'icon': Icons.woman, 'color': AppColors.primaryPink},
    {'id': 'parent2', 'icon': Icons.man, 'color': AppColors.primaryBlue},
    {'id': 'parent3', 'icon': Icons.person, 'color': AppColors.primaryPurple},
    {'id': 'parent4', 'icon': Icons.person_2, 'color': AppColors.primaryGreen},
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
              primary: AppColors.primaryTeal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkGray,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
        _birthdayController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.childishGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🎯 Select Child\'s Interests',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                interest,
                                style: const TextStyle(
                                  color: AppColors.darkGray,
                                  fontSize: 14,
                                ),
                              ),
                              value: isSelected,
                              activeColor: AppColors.primaryTeal,
                              onChanged: (bool? value) {
                                setDialogState(() {
                                  if (value == true) {
                                    _selectedInterests.add(interest);
                                  } else {
                                    _selectedInterests.remove(interest);
                                  }
                                });
                                setState(() {}); // Update main widget
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: AppColors.sunsetGradient,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Center(
                            child: Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
    // Reset form for adding another member
    setState(() {
      _memberType = '';
      _selectedAvatar = '';
      _selectedGender = '';
      _selectedInterests.clear();
      _selectedBirthday = null;
      _nicknameController.clear();
      _birthdayController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.white),
            SizedBox(width: 8),
            Text('Member added! Add another one.'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _saveAndContinue() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.childishGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '👨‍👩‍👧‍👦 Add Your Loved Ones!',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Let\'s build your family tree together',
                        style: TextStyle(
                          color: AppColors.darkGray,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Member Type Selection
                const Text(
                  'Member Type',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMemberTypeOption(
                        'Child',
                        Icons.child_care,
                        AppColors.primaryPink,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMemberTypeOption(
                        'Parent',
                        Icons.family_restroom,
                        AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),

                if (_memberType.isNotEmpty) ...[
                  const SizedBox(height: 32),

                  // Avatar Selection
                  const Text(
                    'Choose Avatar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
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
                        final isSelected = _selectedAvatar == avatar['id'];

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
                              gradient:
                                  isSelected
                                      ? LinearGradient(
                                        colors: [
                                          avatar['color'],
                                          avatar['color'].withValues(
                                            alpha: 0.7,
                                          ),
                                        ],
                                      )
                                      : null,
                              color:
                                  isSelected
                                      ? null
                                      : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              avatar['icon'],
                              size: 35,
                              color:
                                  isSelected ? Colors.white : avatar['color'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Nickname Field
                  const Text(
                    'Nickname',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _nicknameController,
                      style: const TextStyle(color: AppColors.darkGray),
                      decoration: const InputDecoration(
                        hintText: 'Enter nickname',
                        hintStyle: TextStyle(color: AppColors.mediumGray),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Birthday Field
                  const Text(
                    'Birthday',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _selectBirthday,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              _selectedBirthday != null
                                  ? AppColors.primaryTeal
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _birthdayController.text.isEmpty
                                  ? 'mm/dd/yyyy'
                                  : _birthdayController.text,
                              style: TextStyle(
                                color:
                                    _birthdayController.text.isEmpty
                                        ? AppColors.mediumGray
                                        : AppColors.darkGray,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color:
                                _selectedBirthday != null
                                    ? AppColors.primaryTeal
                                    : AppColors.mediumGray,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Gender Selection
                  Text(
                    _memberType == 'Child' ? 'Gender' : 'Role',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderOption(
                          _memberType == 'Child' ? 'Boy' : 'Father',
                          _memberType == 'Child' ? Icons.male : Icons.man,
                          AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGenderOption(
                          _memberType == 'Child' ? 'Girl' : 'Mother',
                          _memberType == 'Child' ? Icons.female : Icons.woman,
                          AppColors.primaryPink,
                        ),
                      ),
                    ],
                  ),

                  if (_memberType == 'Child') ...[
                    const SizedBox(height: 32),

                    // Child's Interests
                    const Text(
                      'Child\'s Interests',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showInterestsDialog,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _selectedInterests.isNotEmpty
                                    ? AppColors.primaryTeal
                                    : Colors.transparent,
                            width: 2,
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
                                          ? AppColors.mediumGray
                                          : AppColors.darkGray,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color:
                                  _selectedInterests.isNotEmpty
                                      ? AppColors.primaryTeal
                                      : AppColors.mediumGray,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_selectedInterests.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _selectedInterests.take(3).map((interest) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.sunsetGradient,
                                  borderRadius: BorderRadius.circular(16),
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
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ],

                  const SizedBox(height: 50),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: AppColors.primaryTeal,
                              width: 2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              onTap: _isFormValid() ? _addAnotherMember : null,
                              child: const Center(
                                child: Text(
                                  'Add Another',
                                  style: TextStyle(
                                    color: AppColors.primaryTeal,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
                          height: 56,
                          decoration: BoxDecoration(
                            gradient:
                                _isFormValid()
                                    ? AppColors.sunsetGradient
                                    : null,
                            color: _isFormValid() ? null : Colors.grey,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              onTap: _isFormValid() ? _saveAndContinue : null,
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.home, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Continue',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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
        height: 80,
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  )
                  : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: isSelected ? Colors.white : color),
            const SizedBox(height: 4),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
        height: 70,
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  )
                  : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
    _birthdayController.dispose();
    super.dispose();
  }
}
